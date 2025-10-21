// Servicios refactorizados aplicando principios SOLID
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

  // Dependency Inversion Principle (DIP) - Dependemos de abstracciones
  SolidBovineService({
    required IBovineRepository repository,
    required INotificationService notificationService,
    required IValidationService validationService,
  }) : _repository = repository,
       _notificationService = notificationService,
       _validationService = validationService;

  // Métodos aplicando Open/Closed Principle (OCP)
  Future<String> createBovine(BovineModel bovine) async {
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

  SolidTreatmentService({
    required ITreatmentRepository repository,
    required IBovineRepository bovineRepository,
    required INotificationService notificationService,
    required IValidationService validationService,
  }) : _repository = repository,
       _bovineRepository = bovineRepository,
       _notificationService = notificationService,
       _validationService = validationService;

  Future<String> createTreatment(TreatmentModel treatment) async {
    await _validateTreatment(treatment);
    
    final id = await _repository.create(treatment);
    
    // Notificar al propietario del bovino
    final bovine = await _bovineRepository.getById(treatment.bovineId);
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

  SolidInventoryService({
    required IInventoryRepository repository,
    required INotificationService notificationService,
    required IValidationService validationService,
  }) : _repository = repository,
       _notificationService = notificationService,
       _validationService = validationService;

  Future<String> createInventoryItem(InventoryModel item) async {
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

class ConcreteNotificationService implements INotificationService {
  @override
  Future<void> sendNotification(String userId, String title, String message,
      {String? type, String? priority}) async {
    // Implementación básica - en producción se conectaría con Firebase
    print('Notification to $userId: $title - $message');
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    // Implementación básica
    print('Marked notification $notificationId as read');
  }

  @override
  Stream<List<NotificationModel>> getNotificationsForUser(String userId) {
    // Implementación básica - retorna stream vacío
    return Stream.value([]);
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