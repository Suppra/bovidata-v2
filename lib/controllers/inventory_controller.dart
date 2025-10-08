import 'package:flutter/material.dart';
import '../models/inventory_model.dart';
import '../services/inventory_service.dart';

class InventoryController extends ChangeNotifier {
  List<InventoryModel> _inventoryItems = [];
  List<InventoryModel> _filteredItems = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Filter parameters
  String _searchQuery = '';
  String _selectedCategory = '';
  String _selectedType = '';
  bool _showLowStock = false;
  bool _showExpired = false;
  bool _showExpiringSoon = false;

  // Getters
  List<InventoryModel> get inventoryItems => _filteredItems;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  String get selectedCategory => _selectedCategory;
  String get selectedType => _selectedType;
  bool get showLowStock => _showLowStock;
  bool get showExpired => _showExpired;
  bool get showExpiringSoon => _showExpiringSoon;

  // Statistics
  int get totalItems => _inventoryItems.length;
  int get lowStockItems => _inventoryItems.where((item) => item.cantidadActual <= item.cantidadMinima).length;
  int get outOfStockItems => _inventoryItems.where((item) => item.cantidadActual == 0).length;
  int get expiredItems => _inventoryItems.where((item) => _isExpired(item)).length;
  int get expiringSoonItems => _inventoryItems.where((item) => _isExpiringSoon(item)).length;
  
  double get totalValue => _inventoryItems
      .where((item) => item.precioUnitario != null)
      .fold(0.0, (sum, item) => sum + (item.precioUnitario! * item.cantidadActual));

  // Load all inventory items
  Future<void> loadInventoryItems() async {
    _setLoading(true);
    try {
      InventoryService.getAllInventoryItems().listen(
        (items) {
          _inventoryItems = items;
          _applyFilters();
          _setLoading(false);
        },
        onError: (error) {
          _setError('Error al cargar inventario: $error');
          _setLoading(false);
        },
      );
    } catch (e) {
      _setError('Error al cargar inventario: $e');
      _setLoading(false);
    }
  }

  // Load inventory by category
  Future<void> loadInventoryByCategory(String categoria) async {
    _setLoading(true);
    try {
      InventoryService.getInventoryByCategory(categoria).listen(
        (items) {
          _inventoryItems = items;
          _applyFilters();
          _setLoading(false);
        },
        onError: (error) {
          _setError('Error al cargar inventario por categoría: $error');
          _setLoading(false);
        },
      );
    } catch (e) {
      _setError('Error al cargar inventario por categoría: $e');
      _setLoading(false);
    }
  }

  // Load low stock items
  Future<void> loadLowStockItems() async {
    _setLoading(true);
    try {
      InventoryService.getLowStockItems().listen(
        (items) {
          _inventoryItems = items;
          _applyFilters();
          _setLoading(false);
        },
        onError: (error) {
          _setError('Error al cargar items con stock bajo: $error');
          _setLoading(false);
        },
      );
    } catch (e) {
      _setError('Error al cargar items con stock bajo: $e');
      _setLoading(false);
    }
  }

  // Load expiring soon items
  Future<void> loadExpiringSoonItems() async {
    _setLoading(true);
    try {
      InventoryService.getExpiringSoonItems().listen(
        (items) {
          _inventoryItems = items;
          _applyFilters();
          _setLoading(false);
        },
        onError: (error) {
          _setError('Error al cargar items próximos a vencer: $error');
          _setLoading(false);
        },
      );
    } catch (e) {
      _setError('Error al cargar items próximos a vencer: $e');
      _setLoading(false);
    }
  }

  // Load expired items
  Future<void> loadExpiredItems() async {
    _setLoading(true);
    try {
      InventoryService.getExpiredItems().listen(
        (items) {
          _inventoryItems = items;
          _applyFilters();
          _setLoading(false);
        },
        onError: (error) {
          _setError('Error al cargar items vencidos: $error');
          _setLoading(false);
        },
      );
    } catch (e) {
      _setError('Error al cargar items vencidos: $e');
      _setLoading(false);
    }
  }

  // Create inventory item
  Future<bool> createInventoryItem(InventoryModel item) async {
    _setLoading(true);
    try {
      final itemId = await InventoryService.createInventoryItem(item);
      if (itemId != null) {
        _setLoading(false);
        return true;
      } else {
        _setError('Error al crear el item del inventario');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Error al crear el item del inventario: $e');
      _setLoading(false);
      return false;
    }
  }

  // Update inventory item
  Future<bool> updateInventoryItem(InventoryModel item) async {
    _setLoading(true);
    try {
      final success = await InventoryService.updateInventoryItem(item);
      if (success) {
        _setLoading(false);
        return true;
      } else {
        _setError('Error al actualizar el item del inventario');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Error al actualizar el item del inventario: $e');
      _setLoading(false);
      return false;
    }
  }

  // Update stock
  Future<bool> updateStock(String itemId, int newQuantity) async {
    _setLoading(true);
    try {
      final success = await InventoryService.updateStock(itemId, newQuantity);
      if (success) {
        _setLoading(false);
        return true;
      } else {
        _setError('Error al actualizar el stock');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Error al actualizar el stock: $e');
      _setLoading(false);
      return false;
    }
  }

  // Add stock
  Future<bool> addStock(String itemId, int quantity) async {
    _setLoading(true);
    try {
      final success = await InventoryService.addStock(itemId, quantity);
      if (success) {
        _setLoading(false);
        return true;
      } else {
        _setError('Error al agregar stock');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Error al agregar stock: $e');
      _setLoading(false);
      return false;
    }
  }

  // Remove stock
  Future<bool> removeStock(String itemId, int quantity) async {
    _setLoading(true);
    try {
      final success = await InventoryService.removeStock(itemId, quantity);
      if (success) {
        _setLoading(false);
        return true;
      } else {
        _setError('Error al remover stock');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Error al remover stock: $e');
      _setLoading(false);
      return false;
    }
  }

  // Delete inventory item
  Future<bool> deleteInventoryItem(String itemId) async {
    _setLoading(true);
    try {
      final success = await InventoryService.deleteInventoryItem(itemId);
      if (success) {
        _setLoading(false);
        return true;
      } else {
        _setError('Error al eliminar el item del inventario');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Error al eliminar el item del inventario: $e');
      _setLoading(false);
      return false;
    }
  }

  // Search inventory items
  void searchInventoryItems(String query) {
    _searchQuery = query;
    _applyFilters();
  }

  // Filter by category
  void filterByCategory(String category) {
    _selectedCategory = category;
    _applyFilters();
  }

  // Filter by type
  void filterByType(String type) {
    _selectedType = type;
    _applyFilters();
  }

  // Toggle show low stock
  void toggleShowLowStock(bool show) {
    _showLowStock = show;
    _applyFilters();
  }

  // Toggle show expired
  void toggleShowExpired(bool show) {
    _showExpired = show;
    _applyFilters();
  }

  // Toggle show expiring soon
  void toggleShowExpiringSoon(bool show) {
    _showExpiringSoon = show;
    _applyFilters();
  }

  // Clear all filters
  void clearFilters() {
    _searchQuery = '';
    _selectedCategory = '';
    _selectedType = '';
    _showLowStock = false;
    _showExpired = false;
    _showExpiringSoon = false;
    _applyFilters();
  }

  // Apply filters to inventory list
  void _applyFilters() {
    _filteredItems = _inventoryItems.where((item) {
      // Status filters
      if (_showLowStock && item.cantidadActual > item.cantidadMinima) return false;
      if (_showExpired && !_isExpired(item)) return false;
      if (_showExpiringSoon && !_isExpiringSoon(item)) return false;

      // Category filter
      if (_selectedCategory.isNotEmpty && item.categoria != _selectedCategory) return false;

      // Type filter
      if (_selectedType.isNotEmpty && item.tipo != _selectedType) return false;

      // Search filter
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        if (!item.nombre.toLowerCase().contains(query) &&
            !item.tipo.toLowerCase().contains(query) &&
            !item.categoria.toLowerCase().contains(query) &&
            !(item.descripcion?.toLowerCase().contains(query) ?? false) &&
            !(item.proveedor?.toLowerCase().contains(query) ?? false)) {
          return false;
        }
      }

      return true;
    }).toList();

    notifyListeners();
  }

  // Get inventory statistics
  Future<Map<String, dynamic>> getInventoryStatistics() async {
    try {
      return await InventoryService.getInventoryStatistics();
    } catch (e) {
      _setError('Error al obtener estadísticas: $e');
      return {
        'total': 0,
        'lowStock': 0,
        'outOfStock': 0,
        'expired': 0,
        'expiringSoon': 0,
        'categoryCounts': <String, int>{},
        'totalValue': 0.0,
      };
    }
  }

  // Helper methods
  bool _isExpired(InventoryModel item) {
    if (item.fechaVencimiento == null) return false;
    return DateTime.now().isAfter(item.fechaVencimiento!);
  }

  bool _isExpiringSoon(InventoryModel item) {
    if (item.fechaVencimiento == null) return false;
    final daysUntilExpiry = item.fechaVencimiento!.difference(DateTime.now()).inDays;
    return daysUntilExpiry <= 30 && daysUntilExpiry >= 0;
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
  }
}