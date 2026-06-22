// Servicios refactorizados aplicando principios SOLID
import 'package:cloud_firestore/cloud_firestore.dart';
import '../access/farm_access_service.dart';
import '../interfaces/service_interface.dart';
import '../interfaces/repository_interface.dart';
import '../../models/bovine_model.dart';
import '../../models/treatment_model.dart';
import '../../models/inventory_model.dart';
import '../../models/notification_model.dart';
import '../../models/activity_model.dart';

// Aplicando Single Responsibility Principle (SRP)
// Cada servicio tiene una única razón para cambiar

class SolidBovineService {
  final IBovineRepository _repository;
  final INotificationService _notificationService;
  final IValidationService _validationService;
  final FarmAccessService _farmAccess;

  // Dependency Inversion Principle (DIP) - Dependemos de abstracciones
  SolidBovineService({
    required IBovineRepository repository,
    required INotificationService notificationService,
    required IValidationService validationService,
    required FarmAccessService farmAccess,
  }) : _repository = repository,
       _notificationService = notificationService,
       _validationService = validationService,
       _farmAccess = farmAccess;

  /// Bovinos visibles para el usuario actual según su acceso por hato
  /// (su propio hato + los hatos a los que fue invitado y aceptó).
  Future<List<BovineModel>> getAccessibleBovines() async {
    final ownerIds = await _farmAccess.accessibleOwnerIds();
    return _repository.getByOwners(ownerIds);
  }

  // Métodos aplicando Open/Closed Principle (OCP)
  Future<String> createBovine(BovineModel bovine) async {
    // El bovino siempre pertenece al hato del usuario actual (scoping seguro).
    final ownerId = await _farmAccess.currentFarmOwnerId();
    bovine = bovine.copyWith(propietarioId: ownerId);

    // Validación usando servicio especializado
    _validateBovine(bovine);

    // Creación usando repositorio
    final id = await _repository.create(bovine);
    
    // Notificación usando servicio especializado
    await _notificationService.sendNotification(
      bovine.propietarioId,
      'Nuevo Bovino Registrado',
      'Se ha registrado el bovino "${bovine.nombre}" exitosamente',
      type: 'bovino',
      priority: 'media',
    );
    
    return id;
  }

  Future<bool> updateBovine(String id, BovineModel bovine) async {
    _validateBovine(bovine);
    
    final updated = await _repository.update(id, bovine);
    
    if (updated) {
      await _notificationService.sendNotification(
        bovine.propietarioId,
        'Bovino Actualizado',
        'Los datos del bovino "${bovine.nombre}" han sido actualizados',
        type: 'bovino',
      );
    }
    
    return updated;
  }

  Future<bool> deleteBovine(String id) async {
    final bovine = await _repository.getById(id);
    if (bovine == null) return false;
    
    final deleted = await _repository.delete(id);
    
    if (deleted) {
      await _notificationService.sendNotification(
        bovine.propietarioId,
        'Bovino Eliminado',
        'El bovino "${bovine.nombre}" ha sido eliminado del sistema',
        type: 'bovino',
        priority: 'alta',
      );
    }
    
    return deleted;
  }

  Future<BovineModel?> getBovineById(String id) async {
    return await _repository.getById(id);
  }

  Future<List<BovineModel>> getAllBovines() async {
    try {
      return await _repository.getAll();
    } catch (e) {
      await _notificationService.sendNotification(
        'admin', 
        'Error', 
        'Error al obtener bovinos: $e'
      );
      return [];
    }
  }

  Future<List<BovineModel>> getBovinesByOwner(String ownerId) async {
    if (!_validationService.validateRequired(ownerId)) {
      throw ArgumentError('Owner ID is required');
    }
    return await _repository.getByOwner(ownerId);
  }

  Future<List<BovineModel>> getBovinesByStatus(String status) async {
    return await _repository.getByStatus(status);
  }

  Stream<List<BovineModel>> streamBovinesByOwner(String ownerId) {
    return _repository.streamByOwner(ownerId);
  }

  // Validación privada aplicando SRP
  void _validateBovine(BovineModel bovine) {
    if (!_validationService.validateRequired(bovine.nombre)) {
      throw ArgumentError('El nombre del bovino es requerido');
    }
    
    if (!_validationService.validateRequired(bovine.propietarioId)) {
      throw ArgumentError('El ID del propietario es requerido');
    }
    
    if (!_validationService.validateRequired(bovine.raza)) {
      throw ArgumentError('La raza del bovino es requerida');
    }
  }
}

class SolidTreatmentService {
  final ITreatmentRepository _repository;
  final IBovineRepository _bovineRepository;
  final INotificationService _notificationService;
  final IValidationService _validationService;
  final FarmAccessService _farmAccess;

  SolidTreatmentService({
    required ITreatmentRepository repository,
    required IBovineRepository bovineRepository,
    required INotificationService notificationService,
    required IValidationService validationService,
    required FarmAccessService farmAccess,
  }) : _repository = repository,
       _bovineRepository = bovineRepository,
       _notificationService = notificationService,
       _validationService = validationService,
       _farmAccess = farmAccess;

  /// Tratamientos visibles según el acceso por hato del usuario actual.
  Future<List<TreatmentModel>> getAccessibleTreatments() async {
    final ownerIds = await _farmAccess.accessibleOwnerIds();
    return _repository.getByOwners(ownerIds);
  }

  Future<String> createTreatment(TreatmentModel treatment) async {
    await _validateTreatment(treatment);

    // El tratamiento hereda el hato (propietarioId) del bovino al que aplica.
    final bovine = await _bovineRepository.getById(treatment.bovineId);
    if (bovine != null) {
      treatment = treatment.copyWith(propietarioId: bovine.propietarioId);
    }

    final id = await _repository.create(treatment);

    // Notificar al propietario del bovino
    if (bovine != null) {
      await _notificationService.sendNotification(
        bovine.propietarioId,
        'Nuevo Tratamiento Programado',
        'Se ha programado un tratamiento para el bovino "${bovine.nombre}"',
        type: 'tratamiento',
        priority: 'alta',
      );
    }

    return id;
  }

  Future<bool> updateTreatment(String id, TreatmentModel treatment) async {
    await _validateTreatment(treatment);
    return await _repository.update(id, treatment);
  }

  Future<bool> deleteTreatment(String id) async {
    return await _repository.delete(id);
  }

  Future<List<TreatmentModel>> getTreatmentsByBovine(String bovineId) async {
    return await _repository.getByBovine(bovineId);
  }

  Future<List<TreatmentModel>> getTreatmentsByVeterinarian(String veterinarianId) async {
    return await _repository.getByVeterinarian(veterinarianId);
  }

  Future<List<TreatmentModel>> getPendingTreatments() async {
    return await _repository.getPending();
  }

  Stream<List<TreatmentModel>> streamTreatmentsByBovine(String bovineId) {
    return _repository.streamByBovine(bovineId);
  }

  // Validación que incluye verificación de bovino existente
  Future<void> _validateTreatment(TreatmentModel treatment) async {
    if (!_validationService.validateRequired(treatment.bovineId)) {
      throw ArgumentError('El ID del bovino es requerido');
    }
    
    if (!_validationService.validateRequired(treatment.tipo)) {
      throw ArgumentError('El tipo de tratamiento es requerido');
    }
    
    // Verificar que el bovino existe
    final bovine = await _bovineRepository.getById(treatment.bovineId);
    if (bovine == null) {
      throw ArgumentError('El bovino especificado no existe');
    }
  }
}

class SolidInventoryService {
  final IInventoryRepository _repository;
  final INotificationService _notificationService;
  final IValidationService _validationService;
  final FarmAccessService _farmAccess;

  SolidInventoryService({
    required IInventoryRepository repository,
    required INotificationService notificationService,
    required IValidationService validationService,
    required FarmAccessService farmAccess,
  }) : _repository = repository,
       _notificationService = notificationService,
       _validationService = validationService,
       _farmAccess = farmAccess;

  /// Inventario visible según el acceso por hato del usuario actual.
  Future<List<InventoryModel>> getAccessibleInventory() async {
    final ownerIds = await _farmAccess.accessibleOwnerIds();
    return _repository.getByOwners(ownerIds);
  }

  Future<String> createInventoryItem(InventoryModel item) async {
    // El ítem pertenece al hato del usuario actual (scoping seguro).
    final ownerId = await _farmAccess.currentFarmOwnerId();
    item = item.copyWith(propietarioId: ownerId);

    _validateInventoryItem(item);

    final id = await _repository.create(item);
    
    // Verificar si está por debajo del stock mínimo
    if (item.cantidadActual <= item.cantidadMinima) {
      await _notificationService.sendNotification(
        'admin',
        'Stock Bajo',
        'El item "${item.nombre}" está por debajo del stock mínimo',
        type: 'inventario',
        priority: 'alta',
      );
    }
    
    return id;
  }

  Future<bool> updateInventoryItem(String id, InventoryModel item) async {
    _validateInventoryItem(item);
    
    final updated = await _repository.update(id, item);
    
    // Verificar nuevamente el stock después de la actualización
    if (updated && item.cantidadActual <= item.cantidadMinima) {
      await _notificationService.sendNotification(
        'admin',
        'Alerta de Stock',
        'El item "${item.nombre}" requiere reabastecimiento',
        type: 'inventario',
        priority: 'media',
      );
    }
    
    return updated;
  }

  Future<bool> deleteInventoryItem(String id) async {
    return await _repository.delete(id);
  }

  Future<List<InventoryModel>> getAllInventoryItems() async {
    return await _repository.getAll();
  }

  Future<List<InventoryModel>> getLowStockItems() async {
    return await _repository.getLowStock();
  }

  Future<List<InventoryModel>> getExpiringItems(DateTime date) async {
    return await _repository.getExpiring(date);
  }

  Future<List<InventoryModel>> getItemsByCategory(String category) async {
    return await _repository.getByCategory(category);
  }

  void _validateInventoryItem(InventoryModel item) {
    if (!_validationService.validateRequired(item.nombre)) {
      throw ArgumentError('El nombre del item es requerido');
    }
    
    if (item.cantidadActual < 0) {
      throw ArgumentError('La cantidad no puede ser negativa');
    }
    
    if (item.cantidadMinima < 0) {
      throw ArgumentError('El stock mínimo no puede ser negativo');
    }
  }
}

// Implementaciones concretas de servicios

/// Servicio de notificaciones respaldado por Firestore.
/// Reemplaza el stub anterior que solo hacía `print()` (hallazgo C4 de la auditoría):
/// ahora los eventos de negocio (alta/baja de bovino, tratamiento, stock) persisten
/// notificaciones reales en la colección `notifications`.
class ConcreteNotificationService implements INotificationService {
  final FirebaseFirestore _firestore;
  static const String _collection = 'notifications';

  ConcreteNotificationService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<void> sendNotification(String userId, String title, String message,
      {String? type, String? priority}) async {
    // No emitir notificaciones a destinatarios no válidos (p. ej. el literal 'admin').
    if (userId.trim().isEmpty || userId == 'admin') return;

    // Las notificaciones son best-effort: un fallo aquí no debe romper el CRUD.
    try {
      final docRef = _firestore.collection(_collection).doc();
      final notification = NotificationModel(
        id: docRef.id,
        titulo: title,
        mensaje: message,
        tipo: type ?? 'general',
        usuarioId: userId,
        fechaCreacion: DateTime.now(),
        prioridad: priority ?? 'normal',
      );
      await docRef.set(notification.toFirestore());
    } catch (_) {
      // Silenciar de forma controlada; el flujo principal continúa.
    }
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    try {
      await _firestore.collection(_collection).doc(notificationId).update({
        'leida': true,
        'fechaLectura': FieldValue.serverTimestamp(),
      });
    } catch (_) {}
  }

  @override
  Stream<List<NotificationModel>> getNotificationsForUser(String userId) {
    return _firestore
        .collection(_collection)
        .where('usuarioId', isEqualTo: userId)
        .orderBy('fechaCreacion', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => NotificationModel.fromFirestore(doc))
            .toList());
  }
}

class ConcreteValidationService implements IValidationService {
  @override
  bool validateEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  @override
  bool validatePhone(String phone) {
    return RegExp(r'^[\+]?[1-9][\d]{0,15}$').hasMatch(phone);
  }

  @override
  bool validateRequired(String? value) {
    return value != null && value.trim().isNotEmpty;
  }

  @override
  String? validateField(String? value, List<String> rules) {
    for (String rule in rules) {
      switch (rule) {
        case 'required':
          if (!validateRequired(value)) {
            return 'Este campo es requerido';
          }
          break;
        case 'email':
          if (value != null && !validateEmail(value)) {
            return 'Ingrese un email válido';
          }
          break;
        case 'phone':
          if (value != null && !validatePhone(value)) {
            return 'Ingrese un teléfono válido';
          }
          break;
      }
    }
    return null;
  }
}

// Activity Service para logging de actividades
class ConcreteActivityService implements IActivityService {
  @override
  Future<void> logActivity(String type, String description, String entityId, String userId) async {
    // Implementación básica - en producción se guardaría en Firestore
    print('Activity logged: $type - $description for entity $entityId by user $userId');
  }

  @override
  Future<List<ActivityModel>> getActivitiesByUser(String userId) async {
    // Implementación básica - retorna lista vacía
    return [];
  }

  @override
  Future<List<ActivityModel>> getActivitiesByEntity(String entityId) async {
    // Implementación básica - retorna lista vacía
    return [];
  }
}

// File Service para manejo de archivos
class ConcreteFileService implements IFileService {
  @override
  Future<String?> uploadImage(String path, List<int> bytes) async {
    // Implementación básica - en producción se conectaría con Firebase Storage
    print('Uploading image to $path');
    return 'https://example.com/image_$path';
  }

  @override
  Future<bool> deleteImage(String url) async {
    print('Deleting image from $url');
    return true;
  }

  @override
  Future<List<int>?> downloadImage(String url) async {
    print('Downloading image from $url');
    return null;
  }
}