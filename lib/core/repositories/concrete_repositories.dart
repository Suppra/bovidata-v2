// Repositorio de usuarios (pendiente de mover a features/users).
// Los repositorios de bovinos/tratamientos/inventario ya viven en sus features.
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bovidata_new/core/interfaces/repository_interface.dart';
import 'package:bovidata_new/core/factories/model_factory.dart';
import 'package:bovidata_new/models/user_model.dart';
import 'package:bovidata_new/constants/app_constants.dart';

class UserRepository implements IUserRepository {
  final FirebaseFirestore _firestore;
  final ModelFactory _modelFactory;
  final String _collection = AppConstants.usersCollection;

  UserRepository({
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
  Future<UserModel?> getById(String id) async {
    final doc = await _firestore.collection(_collection).doc(id).get();
    if (!doc.exists) return null;
    return _modelFactory.createFromFirestore<UserModel>(doc);
  }

  @override
  Future<List<UserModel>> getAll() async {
    final snapshot = await _firestore
        .collection(_collection)
        .orderBy('fechaCreacion', descending: true)
        .get();
    return snapshot.docs
        .map((doc) => _modelFactory.createFromFirestore<UserModel>(doc))
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
  Stream<List<UserModel>> streamAll() {
    return _firestore
        .collection(_collection)
        .orderBy('fechaCreacion', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => _modelFactory.createFromFirestore<UserModel>(doc))
            .toList());
  }

  @override
  Future<List<UserModel>> getByRole(String role) async {
    final snapshot = await _firestore
        .collection(_collection)
        .where('rol', isEqualTo: role)
        .orderBy('fechaCreacion', descending: true)
        .get();
    return snapshot.docs
        .map((doc) => _modelFactory.createFromFirestore<UserModel>(doc))
        .toList();
  }

  @override
  Future<UserModel?> getByEmail(String email) async {
    final snapshot = await _firestore
        .collection(_collection)
        .where('email', isEqualTo: email)
        .limit(1)
        .get();
    if (snapshot.docs.isEmpty) return null;
    return _modelFactory.createFromFirestore<UserModel>(snapshot.docs.first);
  }
}
