// Capa de APLICACIÓN (inventory) — servicio de dominio para inventario.
import 'package:bovidata_new/core/interfaces/service_interface.dart';
import 'package:bovidata_new/core/access/farm_access_service.dart';
import 'package:bovidata_new/models/inventory_model.dart';
import 'package:bovidata_new/features/inventory/domain/ports/inventory_repository.dart';

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
  })  : _repository = repository,
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

    if (item.cantidadActual <= item.cantidadMinima) {
      await _notificationService.sendNotification(
        item.propietarioId,
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
    if (updated && item.cantidadActual <= item.cantidadMinima) {
      await _notificationService.sendNotification(
        item.propietarioId,
        'Alerta de Stock',
        'El item "${item.nombre}" requiere reabastecimiento',
        type: 'inventario',
        priority: 'media',
      );
    }
    return updated;
  }

  Future<bool> deleteInventoryItem(String id) => _repository.delete(id);

  Future<List<InventoryModel>> getAllInventoryItems() => _repository.getAll();

  Future<List<InventoryModel>> getLowStockItems() => _repository.getLowStock();

  Future<List<InventoryModel>> getExpiringItems(DateTime date) =>
      _repository.getExpiring(date);

  Future<List<InventoryModel>> getItemsByCategory(String category) =>
      _repository.getByCategory(category);

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
