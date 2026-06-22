// Capa de INFRAESTRUCTURA (treatments) — implementación Firestore.
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bovidata_new/core/factories/model_factory.dart';
import 'package:bovidata_new/constants/app_constants.dart';
import 'package:bovidata_new/models/treatment_model.dart';
import 'package:bovidata_new/features/treatments/domain/ports/treatment_repository.dart';

class TreatmentRepository implements ITreatmentRepository {
  final FirebaseFirestore _firestore;
  final ModelFactory _modelFactory;
  final String _collection = AppConstants.treatmentsCollection;

  TreatmentRepository({
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
  Future<TreatmentModel?> getById(String id) async {
    final doc = await _firestore.collection(_collection).doc(id).get();
    if (!doc.exists) return null;
    return _modelFactory.createFromFirestore<TreatmentModel>(doc);
  }

  @override
  Future<List<TreatmentModel>> getAll() async {
    final snapshot = await _firestore
        .collection(_collection)
        .orderBy('fecha', descending: true)
        .get();
    return snapshot.docs
        .map((doc) => _modelFactory.createFromFirestore<TreatmentModel>(doc))
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
  Stream<List<TreatmentModel>> streamAll() {
    return _firestore
        .collection(_collection)
        .orderBy('fecha', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => _modelFactory.createFromFirestore<TreatmentModel>(doc))
            .toList());
  }

  @override
  Future<List<TreatmentModel>> getByBovine(String bovineId) async {
    final snapshot = await _firestore
        .collection(_collection)
        .where('bovineId', isEqualTo: bovineId)
        .orderBy('fecha', descending: true)
        .get();
    return snapshot.docs
        .map((doc) => _modelFactory.createFromFirestore<TreatmentModel>(doc))
        .toList();
  }

  @override
  Future<List<TreatmentModel>> getByVeterinarian(String veterinarianId) async {
    final snapshot = await _firestore
        .collection(_collection)
        .where('veterinarioId', isEqualTo: veterinarianId)
        .orderBy('fecha', descending: true)
        .get();
    return snapshot.docs
        .map((doc) => _modelFactory.createFromFirestore<TreatmentModel>(doc))
        .toList();
  }

  @override
  Future<List<TreatmentModel>> getPending() async {
    final snapshot = await _firestore
        .collection(_collection)
        .where('completado', isEqualTo: false)
        .orderBy('fecha', descending: true)
        .get();
    return snapshot.docs
        .map((doc) => _modelFactory.createFromFirestore<TreatmentModel>(doc))
        .toList();
  }

  @override
  Future<List<TreatmentModel>> getByOwners(List<String> ownerIds) async {
    if (ownerIds.isEmpty) return [];
    final snapshot = await _firestore
        .collection(_collection)
        .where('propietarioId', whereIn: ownerIds)
        .get();
    return snapshot.docs
        .map((doc) => _modelFactory.createFromFirestore<TreatmentModel>(doc))
        .toList()
      ..sort((a, b) => b.fecha.compareTo(a.fecha));
  }

  @override
  Stream<List<TreatmentModel>> streamByBovine(String bovineId) {
    return _firestore
        .collection(_collection)
        .where('bovineId', isEqualTo: bovineId)
        .orderBy('fecha', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => _modelFactory.createFromFirestore<TreatmentModel>(doc))
            .toList());
  }
}
