// Implementaciones concretas de repositorios siguiendo principios SOLID
import 'package:cloud_firestore/cloud_firestore.dart';
import '../interfaces/repository_interface.dart';
import '../factories/model_factory.dart';
import '../../models/bovine_model.dart';
import '../../models/treatment_model.dart';
import '../../models/inventory_model.dart';
import '../../models/user_model.dart';
import '../../constants/app_constants.dart';

// Single Responsibility Principle (SRP) - Cada repositorio tiene una única responsabilidad
// Open/Closed Principle (OCP) - Abierto para extensión, cerrado para modificación
// Liskov Substitution Principle (LSP) - Implementaciones sustituibles
// Dependency Inversion Principle (DIP) - Dependemos de abstracciones

class BovineRepository implements IBovineRepository {
  final FirebaseFirestore _firestore;
  final ModelFactory _modelFactory;
  final String _collection = AppConstants.bovinesCollection;

  BovineRepository({
    FirebaseFirestore? firestore,
    ModelFactory? modelFactory,
  })
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _modelFactory = modelFactory ?? ConcreteModelFactory();

  @override
  Future<String> create(entity) async {
    final docRef = await _firestore
        .collection(_collection)
        .add(entity.toFirestore());
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
        .toList();
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
            .toList());
  }
}

class TreatmentRepository implements ITreatmentRepository {
  final FirebaseFirestore _firestore;
  final ModelFactory _modelFactory;
  final String _collection = AppConstants.treatmentsCollection;

  TreatmentRepository({
    FirebaseFirestore? firestore,
    ModelFactory? modelFactory,
  })
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _modelFactory = modelFactory ?? ConcreteModelFactory();

  @override
  Future<String> create(entity) async {
    final docRef = await _firestore
        .collection(_collection)
        .add(entity.toFirestore());
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

class InventoryRepository implements IInventoryRepository {
  final FirebaseFirestore _firestore;
  final ModelFactory _modelFactory;
  final String _collection = AppConstants.inventoryCollection;

  InventoryRepository({
    FirebaseFirestore? firestore,
    ModelFactory? modelFactory,
  })
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _modelFactory = modelFactory ?? ConcreteModelFactory();

  @override
  Future<String> create(entity) async {
    final docRef = await _firestore
        .collection(_collection)
        .add(entity.toFirestore());
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
    final snapshot = await _firestore
        .collection(_collection)
        .where('cantidadActual', isLessThanOrEqualTo: 10)
        .orderBy('cantidadActual')
        .get();
    return snapshot.docs
        .map((doc) => _modelFactory.createFromFirestore<InventoryModel>(doc))
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
}

class UserRepository implements IUserRepository {
  final FirebaseFirestore _firestore;
  final ModelFactory _modelFactory;
  final String _collection = AppConstants.usersCollection;

  UserRepository({
    FirebaseFirestore? firestore,
    ModelFactory? modelFactory,
  })
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _modelFactory = modelFactory ?? ConcreteModelFactory();

  @override
  Future<String> create(entity) async {
    final docRef = await _firestore
        .collection(_collection)
        .add(entity.toFirestore());
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
