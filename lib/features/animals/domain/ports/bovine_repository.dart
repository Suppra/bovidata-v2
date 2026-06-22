// Capa de DOMINIO (animals) — puerto del repositorio de bovinos.
import 'package:bovidata_new/core/interfaces/repository_interface.dart' show IRepository;
import 'package:bovidata_new/models/bovine_model.dart';

abstract class IBovineRepository extends IRepository<BovineModel> {
  Future<List<BovineModel>> getByOwner(String ownerId);
  // Scoping por hato: bovinos de varios dueños accesibles (membresías).
  Future<List<BovineModel>> getByOwners(List<String> ownerIds);
  Future<List<BovineModel>> getByStatus(String status);
  Stream<List<BovineModel>> streamByOwner(String ownerId);
}
