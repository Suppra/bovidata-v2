// Capa de APLICACIÓN (animals) — servicio de dominio para bovinos.
import 'package:bovidata_new/core/interfaces/service_interface.dart';
import 'package:bovidata_new/core/access/farm_access_service.dart';
import 'package:bovidata_new/models/bovine_model.dart';
import 'package:bovidata_new/features/animals/domain/ports/bovine_repository.dart';

class SolidBovineService {
  final IBovineRepository _repository;
  final INotificationService _notificationService;
  final IValidationService _validationService;
  final FarmAccessService _farmAccess;

  SolidBovineService({
    required IBovineRepository repository,
    required INotificationService notificationService,
    required IValidationService validationService,
    required FarmAccessService farmAccess,
  })  : _repository = repository,
        _notificationService = notificationService,
        _validationService = validationService,
        _farmAccess = farmAccess;

  /// Bovinos visibles para el usuario actual según su acceso por hato.
  Future<List<BovineModel>> getAccessibleBovines() async {
    final ownerIds = await _farmAccess.accessibleOwnerIds();
    return _repository.getByOwners(ownerIds);
  }

  Future<String> createBovine(BovineModel bovine) async {
    // El bovino siempre pertenece al hato del usuario actual (scoping seguro).
    final ownerId = await _farmAccess.currentFarmOwnerId();
    bovine = bovine.copyWith(propietarioId: ownerId);

    _validateBovine(bovine);
    final id = await _repository.create(bovine);

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

  Future<BovineModel?> getBovineById(String id) => _repository.getById(id);

  Future<List<BovineModel>> getAllBovines() async {
    try {
      return await _repository.getAll();
    } catch (e) {
      return [];
    }
  }

  Future<List<BovineModel>> getBovinesByOwner(String ownerId) async {
    if (!_validationService.validateRequired(ownerId)) {
      throw ArgumentError('Owner ID is required');
    }
    return _repository.getByOwner(ownerId);
  }

  Future<List<BovineModel>> getBovinesByStatus(String status) =>
      _repository.getByStatus(status);

  Stream<List<BovineModel>> streamBovinesByOwner(String ownerId) =>
      _repository.streamByOwner(ownerId);

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
