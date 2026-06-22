// Capa de INFRAESTRUCTURA (inventory) — implementación Firestore.
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bovidata_new/core/factories/model_factory.dart';
import 'package:bovidata_new/constants/app_constants.dart';
import 'package:bovidata_new/models/inventory_model.dart';
import 'package:bovidata_new/features/inventory/domain/ports/inventory_repository.dart';

class InventoryRepository implements IInventoryRepository {
  final FirebaseFirestore _firestore;
  final ModelFactory _modelFactory;
  final String _collection = AppConstants.inventoryCollection;

  InventoryRepository({
    FirebaseFirestore? firestore,
    ModelFactory? modelFactory,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _modelFactory = modelFactory ?? ConcreteModelFactory();

  @override
  Future<String> create(entity) async {
    final docRef =
        await _firestore.collection(_collection).add(entity.toFirestore());
    return docRef.id;
  }

  @override
  Future<InventoryModel?> getById(String id) async {
    final doc = await _firestore.collection(_collection).doc(id).get();
    if (!doc.exists) return null;
    return _modelFactory.createFromFirestore<InventoryModel>(doc);
  }

  @override
  Future<List<InventoryModel>> getAll() async {
    final snapshot = await _firestore
        .collection(_collection)
        .orderBy('fechaCreacion', descending: true)
        .get();
    return snapshot.docs
        .map((doc) => _modelFactory.createFromFirestore<InventoryModel>(doc))
        .toList();
  }

  @override
  Future<bool> update(String id, entity) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(id)
          .update(entity.toFirestore());
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> delete(String id) async {
    try {
      await _firestore.collection(_collection).doc(id).delete();
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Stream<List<InventoryModel>> streamAll() {
    return _firestore
        .collection(_collection)
        .orderBy('fechaCreacion', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => _modelFactory.createFromFirestore<InventoryModel>(doc))
            .toList());
  }

  @override
  Future<List<InventoryModel>> getLowStock() async {
    // Firestore no permite comparar dos campos en una query; se filtra en
    // cliente con la regla de negocio del modelo (cantidadActual <= cantidadMinima).
    final snapshot = await _firestore
        .collection(_collection)
        .orderBy('cantidadActual')
        .get();
    return snapshot.docs
        .map((doc) => _modelFactory.createFromFirestore<InventoryModel>(doc))
        .where((item) => item.isLowStock)
        .toList();
  }

  @override
  Future<List<InventoryModel>> getExpiring(DateTime date) async {
    final snapshot = await _firestore
        .collection(_collection)
        .where('fechaVencimiento', isLessThanOrEqualTo: Timestamp.fromDate(date))
        .orderBy('fechaVencimiento')
        .get();
    return snapshot.docs
        .map((doc) => _modelFactory.createFromFirestore<InventoryModel>(doc))
        .toList();
  }

  @override
  Future<List<InventoryModel>> getByCategory(String category) async {
    final snapshot = await _firestore
        .collection(_collection)
        .where('categoria', isEqualTo: category)
        .orderBy('fechaCreacion', descending: true)
        .get();
    return snapshot.docs
        .map((doc) => _modelFactory.createFromFirestore<InventoryModel>(doc))
        .toList();
  }

  @override
  Future<List<InventoryModel>> getByOwners(List<String> ownerIds) async {
    if (ownerIds.isEmpty) return [];
    final snapshot = await _firestore
        .collection(_collection)
        .where('propietarioId', whereIn: ownerIds)
        .get();
    return snapshot.docs
        .map((doc) => _modelFactory.createFromFirestore<InventoryModel>(doc))
        .where((item) => item.activo)
        .toList()
      ..sort((a, b) => b.fechaCreacion.compareTo(a.fechaCreacion));
  }
}
