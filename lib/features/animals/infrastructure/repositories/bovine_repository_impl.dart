// Capa de INFRAESTRUCTURA (animals) — implementación Firestore del repositorio.
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bovidata_new/core/factories/model_factory.dart';
import 'package:bovidata_new/constants/app_constants.dart';
import 'package:bovidata_new/models/bovine_model.dart';
import 'package:bovidata_new/features/animals/domain/ports/bovine_repository.dart';

class BovineRepository implements IBovineRepository {
  final FirebaseFirestore _firestore;
  final ModelFactory _modelFactory;
  final String _collection = AppConstants.bovinesCollection;

  BovineRepository({
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
  Future<BovineModel?> getById(String id) async {
    final doc = await _firestore.collection(_collection).doc(id).get();
    if (!doc.exists) return null;
    return _modelFactory.createFromFirestore<BovineModel>(doc);
  }

  @override
  Future<List<BovineModel>> getAll() async {
    final snapshot = await _firestore
        .collection(_collection)
        .orderBy('fechaCreacion', descending: true)
        .get();
    return snapshot.docs
        .map((doc) => _modelFactory.createFromFirestore<BovineModel>(doc))
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
  Stream<List<BovineModel>> streamAll() {
    return _firestore
        .collection(_collection)
        .orderBy('fechaCreacion', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => _modelFactory.createFromFirestore<BovineModel>(doc))
            .toList());
  }

  @override
  Future<List<BovineModel>> getByOwner(String ownerId) async {
    final snapshot = await _firestore
        .collection(_collection)
        .where('propietarioId', isEqualTo: ownerId)
        .orderBy('fechaCreacion', descending: true)
        .get();
    return snapshot.docs
        .map((doc) => _modelFactory.createFromFirestore<BovineModel>(doc))
        .where((bovine) => bovine.activo) // respeta el borrado lógico
        .toList();
  }

  @override
  Future<List<BovineModel>> getByOwners(List<String> ownerIds) async {
    if (ownerIds.isEmpty) return [];
    final snapshot = await _firestore
        .collection(_collection)
        .where('propietarioId', whereIn: ownerIds)
        .get();
    return snapshot.docs
        .map((doc) => _modelFactory.createFromFirestore<BovineModel>(doc))
        .where((bovine) => bovine.activo)
        .toList()
      ..sort((a, b) => b.fechaCreacion.compareTo(a.fechaCreacion));
  }

  @override
  Future<List<BovineModel>> getByStatus(String status) async {
    final snapshot = await _firestore
        .collection(_collection)
        .where('estado', isEqualTo: status)
        .orderBy('fechaCreacion', descending: true)
        .get();
    return snapshot.docs
        .map((doc) => _modelFactory.createFromFirestore<BovineModel>(doc))
        .toList();
  }

  @override
  Stream<List<BovineModel>> streamByOwner(String ownerId) {
    return _firestore
        .collection(_collection)
        .where('propietarioId', isEqualTo: ownerId)
        .orderBy('fechaCreacion', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => _modelFactory.createFromFirestore<BovineModel>(doc))
            .where((bovine) => bovine.activo)
            .toList());
  }
}
