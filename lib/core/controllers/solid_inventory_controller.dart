// Controller moderno para inventario usando arquitectura SOLID
import 'package:flutter/material.dart';
import '../locator/service_locator.dart';
import '../services/solid_services.dart';
import '../../models/inventory_model.dart';

/// Controller moderno para inventario usando arquitectura SOLID
/// Reemplaza InventoryController legacy con principios SOLID aplicados
class SolidInventoryController extends ChangeNotifier {
  final SolidInventoryService _inventoryService = ServiceLocator.inventoryService;
  
  List<InventoryModel> _inventory = [];
  List<InventoryModel> _filteredInventory = [];
  bool _isLoading = false;
  String? _errorMessage;
  
  // Filtros
  String _searchQuery = '';
  String _selectedCategory = '';
  bool _showLowStock = false;

  // Getters
  List<InventoryModel> get inventory => _filteredInventory;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  String get selectedCategory => _selectedCategory;
  bool get showLowStock => _showLowStock;

  // Statistics usando principios SOLID
  int get totalItems => _inventory.length;
  int get lowStockItems => _inventory.where((item) => 
      item.cantidadActual <= item.cantidadMinima).length;
  int get outOfStockItems => _inventory.where((item) => 
      item.cantidadActual <= 0).length;
      
  // Items vencidos
  int get expiredItems {
    final now = DateTime.now();
    return _inventory.where((item) => 
      item.fechaVencimiento != null && item.fechaVencimiento!.isBefore(now)
    ).length;
  }

  // Categorías disponibles
  List<String> get availableCategories {
    return _inventory.map((item) => item.categoria).toSet().toList()..sort();
  }

  // Valor total del inventario
  double get totalInventoryValue {
    return _inventory.fold(0.0, (sum, item) => 
        sum + (item.cantidadActual * (item.precioUnitario ?? 0.0)));
  }

  /// Inicializar controller usando servicios SOLID
  void initialize() {
    loadInventory();
  }

  /// Buscar items en inventario
  void search(String query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  /// Cargar inventario usando servicio SOLID
  Future<void> loadInventory() async {
    _setLoading(true);
    _clearError();
    
    try {
      _inventory = await _inventoryService.getAllInventoryItems();
      _applyFilters();
    } catch (e) {
      _setError('Error al cargar inventario: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Crear item de inventario usando servicio SOLID
  Future<bool> createItem(InventoryModel item) async {
    _setLoading(true);
    _clearError();
    
    try {
      await _inventoryService.createInventoryItem(item);
      await loadInventory(); // Recargar lista
      return true;
    } catch (e) {
      _setError('Error al crear item: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Actualizar item de inventario usando servicio SOLID
  Future<bool> updateItem(InventoryModel item) async {
    _setLoading(true);
    _clearError();
    
    try {
      await _inventoryService.updateInventoryItem(item.id, item);
      await loadInventory(); // Recargar lista
      return true;
    } catch (e) {
      _setError('Error al actualizar item: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Eliminar item de inventario usando servicio SOLID
  Future<bool> deleteItem(String id) async {
    _setLoading(true);
    _clearError();
    
    try {
      await _inventoryService.deleteInventoryItem(id);
      await loadInventory(); // Recargar lista
      return true;
    } catch (e) {
      _setError('Error al eliminar item: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Cargar items con bajo stock
  Future<void> loadLowStockItems() async {
    _setLoading(true);
    _clearError();
    
    try {
      _inventory = await _inventoryService.getLowStockItems();
      _applyFilters();
    } catch (e) {
      _setError('Error al cargar items con bajo stock: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Buscar items en inventario
  void searchItems(String query) {
    _searchQuery = query;
    _applyFilters();
  }

  /// Filtrar por categoría
  void filterByCategory(String category) {
    _selectedCategory = category;
    _applyFilters();
  }

  /// Alternar mostrar solo items con bajo stock
  void toggleLowStockFilter(bool show) {
    _showLowStock = show;
    _applyFilters();
  }

  /// Limpiar filtros
  void clearFilters() {
    _searchQuery = '';
    _selectedCategory = '';
    _showLowStock = false;
    _applyFilters();
  }

  /// Aplicar filtros usando principios SOLID
  void _applyFilters() {
    _filteredInventory = _inventory.where((item) {
      bool matchesSearch = _searchQuery.isEmpty ||
          item.nombre.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          item.categoria.toLowerCase().contains(_searchQuery.toLowerCase());

      bool matchesCategory = _selectedCategory.isEmpty || 
          item.categoria == _selectedCategory;
      
      bool matchesStockFilter = !_showLowStock || 
          item.cantidadActual <= item.cantidadMinima;

      return matchesSearch && matchesCategory && matchesStockFilter;
    }).toList();
    
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  /// Refrescar datos
  void refresh() {
    loadInventory();
  }

  /// Limpiar error
  void clearError() {
    _clearError();
    notifyListeners();
  }

  /// Obtener item por ID
  InventoryModel? getItemById(String id) {
    try {
      return _inventory.firstWhere((item) => item.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Verificar si un item tiene bajo stock
  bool isLowStock(InventoryModel item) {
    return item.cantidadActual <= item.cantidadMinima;
  }

  /// Verificar si un item está agotado
  bool isOutOfStock(InventoryModel item) {
    return item.cantidadActual <= 0;
  }

  /// Alternar mostrar items con stock bajo
  void toggleShowLowStock(bool show) {
    _showLowStock = show;
    _applyFilters();
    notifyListeners();
  }

  /// Alternar mostrar items vencidos
  void toggleShowExpired(bool show) {
    // Implementar lógica de filtro si es necesario
    _applyFilters();
    notifyListeners();
  }

  /// Alternar mostrar items por vencer pronto
  void toggleShowExpiringSoon(bool show) {
    // Implementar lógica de filtro si es necesario
    _applyFilters();
    notifyListeners();
  }

  /// Agregar stock usando servicio SOLID
  Future<bool> addStock(String itemId, int quantity) async {
    _setLoading(true);
    _clearError();
    
    try {
      // Encontrar el item
      final index = _inventory.indexWhere((item) => item.id == itemId);
      if (index == -1) {
        _setError('Item no encontrado');
        return false;
      }
      
      // Crear versión actualizada
      final item = _inventory[index];
      final updatedItem = item.copyWith(
        cantidadActual: item.cantidadActual + quantity
      );
      
      // Usar servicio SOLID para actualizar
      final success = await _inventoryService.updateInventoryItem(itemId, updatedItem);
      if (success) {
        _inventory[index] = updatedItem;
        _applyFilters();
        notifyListeners();
      }
      return success;
    } catch (e) {
      _setError('Error al agregar stock: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Remover stock usando servicio SOLID
  Future<bool> removeStock(String itemId, int quantity) async {
    _setLoading(true);
    _clearError();
    
    try {
      // Encontrar el item
      final index = _inventory.indexWhere((item) => item.id == itemId);
      if (index == -1) {
        _setError('Item no encontrado');
        return false;
      }
      
      // Validar cantidad
      final item = _inventory[index];
      if (item.cantidadActual < quantity) {
        _setError('No hay suficiente stock disponible');
        return false;
      }
      
      // Crear versión actualizada
      final updatedItem = item.copyWith(
        cantidadActual: item.cantidadActual - quantity
      );
      
      // Usar servicio SOLID para actualizar
      final success = await _inventoryService.updateInventoryItem(itemId, updatedItem);
      if (success) {
        _inventory[index] = updatedItem;
        _applyFilters();
        notifyListeners();
      }
      return success;
    } catch (e) {
      _setError('Error al remover stock: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }
}