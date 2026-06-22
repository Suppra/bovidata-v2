// Interface Segregation Principle (ISP) - Interfaces específicas
import '../../models/bovine_model.dart';
import '../../models/treatment_model.dart';
import '../../models/inventory_model.dart';
import '../../models/user_model.dart';

abstract class IRepository<T> {
  Future<String> create(T entity);
  Future<T?> getById(String id);
  Future<List<T>> getAll();
  Future<bool> update(String id, T entity);
  Future<bool> delete(String id);
  Stream<List<T>> streamAll();
}

// Interfaces específicas para cada entidad
abstract class IBovineRepository extends IRepository<BovineModel> {
  Future<List<BovineModel>> getByOwner(String ownerId);
  Future<List<BovineModel>> getByStatus(String status);
  Stream<List<BovineModel>> streamByOwner(String ownerId);
}

abstract class ITreatmentRepository extends IRepository<TreatmentModel> {
  Future<List<TreatmentModel>> getByBovine(String bovineId);
  Future<List<TreatmentModel>> getByVeterinarian(String veterinarianId);
  Future<List<TreatmentModel>> getPending();
  Stream<List<TreatmentModel>> streamByBovine(String bovineId);
}

abstract class IInventoryRepository extends IRepository<InventoryModel> {
  Future<List<InventoryModel>> getLowStock();
  Future<List<InventoryModel>> getExpiring(DateTime date);
  Future<List<InventoryModel>> getByCategory(String category);
}

abstract class IUserRepository extends IRepository<UserModel> {
  Future<List<UserModel>> getByRole(String role);
  Future<UserModel?> getByEmail(String email);
}
