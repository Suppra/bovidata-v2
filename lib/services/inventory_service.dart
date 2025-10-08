import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/inventory_model.dart';
import '../constants/app_constants.dart';

class InventoryService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Create a new inventory item
  static Future<String?> createInventoryItem(InventoryModel item) async {
    try {
      final docRef = await _firestore
          .collection(AppConstants.inventoryCollection)
          .add(item.toFirestore());
      return docRef.id;
    } catch (e) {
      print('Error creating inventory item: $e');
      return null;
    }
  }

  // Get all inventory items
  static Stream<List<InventoryModel>> getAllInventoryItems() {
    return _firestore
        .collection(AppConstants.inventoryCollection)
        .where('activo', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
          List<InventoryModel> items = snapshot.docs
              .map((doc) => InventoryModel.fromFirestore(doc))
              .toList();
          // Ordenar en el cliente para evitar índices compuestos
          items.sort((a, b) => a.nombre.compareTo(b.nombre));
          return items;
        });
  }

  // Get inventory items by category
  static Stream<List<InventoryModel>> getInventoryByCategory(String categoria) {
    return _firestore
        .collection(AppConstants.inventoryCollection)
        .where('categoria', isEqualTo: categoria)
        .where('activo', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
          List<InventoryModel> items = snapshot.docs
              .map((doc) => InventoryModel.fromFirestore(doc))
              .toList();
          // Ordenar en el cliente
          items.sort((a, b) => a.nombre.compareTo(b.nombre));
          return items;
        });
  }

  // Get inventory items by type
  static Stream<List<InventoryModel>> getInventoryByType(String tipo) {
    return _firestore
        .collection(AppConstants.inventoryCollection)
        .where('tipo', isEqualTo: tipo)
        .where('activo', isEqualTo: true)
        .orderBy('nombre')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => InventoryModel.fromFirestore(doc)).toList());
  }

  // Get low stock items
  static Stream<List<InventoryModel>> getLowStockItems() {
    return _firestore
        .collection(AppConstants.inventoryCollection)
        .where('activo', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => InventoryModel.fromFirestore(doc))
              .where((item) => item.cantidadActual <= item.cantidadMinima)
              .toList();
        });
  }

  // Get items expiring soon
  static Stream<List<InventoryModel>> getExpiringSoonItems() {
    final now = DateTime.now();
    final thirtyDaysFromNow = now.add(const Duration(days: 30));
    
    return _firestore
        .collection(AppConstants.inventoryCollection)
        .where('fechaVencimiento', isLessThanOrEqualTo: Timestamp.fromDate(thirtyDaysFromNow))
        .where('fechaVencimiento', isGreaterThan: Timestamp.fromDate(now))
        .where('activo', isEqualTo: true)
        .orderBy('fechaVencimiento')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => InventoryModel.fromFirestore(doc)).toList());
  }

  // Get expired items
  static Stream<List<InventoryModel>> getExpiredItems() {
    final now = DateTime.now();
    
    return _firestore
        .collection(AppConstants.inventoryCollection)
        .where('fechaVencimiento', isLessThanOrEqualTo: Timestamp.fromDate(now))
        .where('activo', isEqualTo: true)
        .orderBy('fechaVencimiento', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => InventoryModel.fromFirestore(doc)).toList());
  }

  // Get inventory item by ID
  static Future<InventoryModel?> getInventoryItemById(String itemId) async {
    try {
      final doc = await _firestore
          .collection(AppConstants.inventoryCollection)
          .doc(itemId)
          .get();
      
      if (doc.exists && doc.data() != null) {
        return InventoryModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Error getting inventory item: $e');
      return null;
    }
  }

  // Update inventory item
  static Future<bool> updateInventoryItem(InventoryModel item) async {
    try {
      await _firestore
          .collection(AppConstants.inventoryCollection)
          .doc(item.id)
          .update(item.toFirestore());
      return true;
    } catch (e) {
      print('Error updating inventory item: $e');
      return false;
    }
  }

  // Update stock quantity
  static Future<bool> updateStock(String itemId, int newQuantity) async {
    try {
      await _firestore
          .collection(AppConstants.inventoryCollection)
          .doc(itemId)
          .update({
        'cantidadActual': newQuantity,
        'fechaActualizacion': Timestamp.now(),
      });
      return true;
    } catch (e) {
      print('Error updating stock: $e');
      return false;
    }
  }

  // Add stock
  static Future<bool> addStock(String itemId, int quantity) async {
    try {
      final doc = await _firestore
          .collection(AppConstants.inventoryCollection)
          .doc(itemId)
          .get();
      
      if (doc.exists) {
        final currentData = doc.data() as Map<String, dynamic>;
        final currentQuantity = currentData['cantidadActual'] ?? 0;
        final newQuantity = currentQuantity + quantity;
        
        await _firestore
            .collection(AppConstants.inventoryCollection)
            .doc(itemId)
            .update({
          'cantidadActual': newQuantity,
          'fechaActualizacion': Timestamp.now(),
        });
        return true;
      }
      return false;
    } catch (e) {
      print('Error adding stock: $e');
      return false;
    }
  }

  // Remove stock
  static Future<bool> removeStock(String itemId, int quantity) async {
    try {
      final doc = await _firestore
          .collection(AppConstants.inventoryCollection)
          .doc(itemId)
          .get();
      
      if (doc.exists) {
        final currentData = doc.data() as Map<String, dynamic>;
        final currentQuantity = currentData['cantidadActual'] ?? 0;
        final newQuantity = (currentQuantity - quantity).clamp(0, double.infinity).toInt();
        
        await _firestore
            .collection(AppConstants.inventoryCollection)
            .doc(itemId)
            .update({
          'cantidadActual': newQuantity,
          'fechaActualizacion': Timestamp.now(),
        });
        return true;
      }
      return false;
    } catch (e) {
      print('Error removing stock: $e');
      return false;
    }
  }

  // Delete inventory item (soft delete)
  static Future<bool> deleteInventoryItem(String itemId) async {
    try {
      await _firestore
          .collection(AppConstants.inventoryCollection)
          .doc(itemId)
          .update({
        'activo': false,
        'fechaActualizacion': Timestamp.now(),
      });
      return true;
    } catch (e) {
      print('Error deleting inventory item: $e');
      return false;
    }
  }

  // Search inventory items
  static Stream<List<InventoryModel>> searchInventoryItems(String searchQuery) {
    final query = searchQuery.toLowerCase();
    
    return _firestore
        .collection(AppConstants.inventoryCollection)
        .where('activo', isEqualTo: true)
        .orderBy('nombre')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => InventoryModel.fromFirestore(doc))
          .where((item) =>
              item.nombre.toLowerCase().contains(query) ||
              item.tipo.toLowerCase().contains(query) ||
              item.categoria.toLowerCase().contains(query) ||
              (item.descripcion?.toLowerCase().contains(query) ?? false) ||
              (item.proveedor?.toLowerCase().contains(query) ?? false))
          .toList();
    });
  }

  // Get inventory statistics
  static Future<Map<String, dynamic>> getInventoryStatistics() async {
    try {
      final snapshot = await _firestore
          .collection(AppConstants.inventoryCollection)
          .where('activo', isEqualTo: true)
          .get();

      final items = snapshot.docs
          .map((doc) => InventoryModel.fromFirestore(doc))
          .toList();

      final total = items.length;
      final lowStock = items.where((item) => item.cantidadActual <= item.cantidadMinima).length;
      final outOfStock = items.where((item) => item.cantidadActual == 0).length;
      
      final now = DateTime.now();
      final expired = items.where((item) =>
          item.fechaVencimiento != null && item.fechaVencimiento!.isBefore(now)).length;
      
      final expiringSoon = items.where((item) =>
          item.fechaVencimiento != null && 
          item.fechaVencimiento!.isAfter(now) &&
          item.fechaVencimiento!.difference(now).inDays <= 30).length;

      final categoryCounts = <String, int>{};
      for (final item in items) {
        categoryCounts[item.categoria] = (categoryCounts[item.categoria] ?? 0) + 1;
      }

      final totalValue = items
          .where((item) => item.precioUnitario != null)
          .fold(0.0, (sum, item) => sum + (item.precioUnitario! * item.cantidadActual));

      return {
        'total': total,
        'lowStock': lowStock,
        'outOfStock': outOfStock,
        'expired': expired,
        'expiringSoon': expiringSoon,
        'categoryCounts': categoryCounts,
        'totalValue': totalValue,
      };
    } catch (e) {
      print('Error getting inventory statistics: $e');
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

  // Get inventory by date range
  static Stream<List<InventoryModel>> getInventoryByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) {
    return _firestore
        .collection(AppConstants.inventoryCollection)
        .where('fechaCreacion', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
        .where('fechaCreacion', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
        .where('activo', isEqualTo: true)
        .orderBy('fechaCreacion', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => InventoryModel.fromFirestore(doc)).toList());
  }

  // Get inventory items by provider
  static Stream<List<InventoryModel>> getInventoryByProvider(String proveedor) {
    return _firestore
        .collection(AppConstants.inventoryCollection)
        .where('proveedor', isEqualTo: proveedor)
        .where('activo', isEqualTo: true)
        .orderBy('nombre')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => InventoryModel.fromFirestore(doc)).toList());
  }
}