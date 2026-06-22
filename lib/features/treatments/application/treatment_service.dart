// Capa de APLICACIÓN (treatments) — servicio de dominio para tratamientos.
import 'package:bovidata_new/core/interfaces/service_interface.dart';
import 'package:bovidata_new/core/access/farm_access_service.dart';
import 'package:bovidata_new/models/treatment_model.dart';
import 'package:bovidata_new/features/animals/domain/ports/bovine_repository.dart';
import 'package:bovidata_new/features/treatments/domain/ports/treatment_repository.dart';

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
  })  : _repository = repository,
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
    return _repository.update(id, treatment);
  }

  Future<bool> deleteTreatment(String id) => _repository.delete(id);

  Future<List<TreatmentModel>> getTreatmentsByBovine(String bovineId) =>
      _repository.getByBovine(bovineId);

  Future<List<TreatmentModel>> getTreatmentsByVeterinarian(String veterinarianId) =>
      _repository.getByVeterinarian(veterinarianId);

  Future<List<TreatmentModel>> getPendingTreatments() => _repository.getPending();

  Stream<List<TreatmentModel>> streamTreatmentsByBovine(String bovineId) =>
      _repository.streamByBovine(bovineId);

  Future<void> _validateTreatment(TreatmentModel treatment) async {
    if (!_validationService.validateRequired(treatment.bovineId)) {
      throw ArgumentError('El ID del bovino es requerido');
    }
    if (!_validationService.validateRequired(treatment.tipo)) {
      throw ArgumentError('El tipo de tratamiento es requerido');
    }
    final bovine = await _bovineRepository.getById(treatment.bovineId);
    if (bovine == null) {
      throw ArgumentError('El bovino especificado no existe');
    }
  }
}
