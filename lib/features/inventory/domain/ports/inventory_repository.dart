// Capa de DOMINIO (inventory) — puerto del repositorio de inventario.
import 'package:bovidata_new/core/interfaces/repository_interface.dart' show IRepository;
import 'package:bovidata_new/models/inventory_model.dart';

abstract class IInventoryRepository extends IRepository<InventoryModel> {
  Future<List<InventoryModel>> getLowStock();
  Future<List<InventoryModel>> getExpiring(DateTime date);
  Future<List<InventoryModel>> getByCategory(String category);
  // Scoping por hato: inventario de varios dueños accesibles.
  Future<List<InventoryModel>> getByOwners(List<String> ownerIds);
}
