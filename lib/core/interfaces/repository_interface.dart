// Interfaz base de repositorio (kernel compartido) + puerto de usuarios.
// Los puertos por feature (IBovineRepository, ITreatmentRepository,
// IInventoryRepository) viven en features/<x>/domain/ports.
import 'package:bovidata_new/models/user_model.dart';

abstract class IRepository<T> {
  Future<String> create(T entity);
  Future<T?> getById(String id);
  Future<List<T>> getAll();
  Future<bool> update(String id, T entity);
  Future<bool> delete(String id);
  Stream<List<T>> streamAll();
}

// Interface Segregation Principle (ISP)
abstract class IUserRepository extends IRepository<UserModel> {
  Future<List<UserModel>> getByRole(String role);
  Future<UserModel?> getByEmail(String email);
}
