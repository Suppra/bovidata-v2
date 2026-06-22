// Capa de DOMINIO (treatments) — puerto del repositorio de tratamientos.
import 'package:bovidata_new/core/interfaces/repository_interface.dart' show IRepository;
import 'package:bovidata_new/models/treatment_model.dart';

abstract class ITreatmentRepository extends IRepository<TreatmentModel> {
  Future<List<TreatmentModel>> getByBovine(String bovineId);
  Future<List<TreatmentModel>> getByVeterinarian(String veterinarianId);
  Future<List<TreatmentModel>> getPending();
  // Scoping por hato: tratamientos de varios dueños accesibles.
  Future<List<TreatmentModel>> getByOwners(List<String> ownerIds);
  Stream<List<TreatmentModel>> streamByBovine(String bovineId);
}
