// Interfaz base de repositorio (kernel compartido).
// Los puertos por feature (IBovineRepository, IUserRepository, etc.) viven en
// features/<x>/domain/ports.
abstract class IRepository<T> {
  Future<String> create(T entity);
  Future<T?> getById(String id);
  Future<List<T>> getAll();
  Future<bool> update(String id, T entity);
  Future<bool> delete(String id);
  Stream<List<T>> streamAll();
}
