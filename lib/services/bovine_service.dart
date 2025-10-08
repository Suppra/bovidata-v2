import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/bovine_model.dart';
import '../constants/app_constants.dart';

class BovineService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user ID
  String? get _currentUserId => _auth.currentUser?.uid;

  // Add new bovine
  Future<String> addBovine(BovineModel bovine) async {
    try {
      final docRef = await _firestore
          .collection(AppConstants.bovinesCollection)
          .add(bovine.toFirestore());
      return docRef.id;
    } catch (e) {
      throw 'Error agregando bovino: $e';
    }
  }

  // Update bovine
  Future<void> updateBovine(String id, BovineModel bovine) async {
    try {
      await _firestore
          .collection(AppConstants.bovinesCollection)
          .doc(id)
          .update(bovine.copyWith(
            fechaActualizacion: DateTime.now(),
          ).toFirestore());
    } catch (e) {
      throw 'Error actualizando bovino: $e';
    }
  }

  // Delete bovine (soft delete)
  Future<void> deleteBovine(String id) async {
    try {
      await _firestore
          .collection(AppConstants.bovinesCollection)
          .doc(id)
          .update({
            'activo': false,
            'fechaActualizacion': Timestamp.now(),
          });
    } catch (e) {
      throw 'Error eliminando bovino: $e';
    }
  }

  // Get bovine by ID
  Future<BovineModel?> getBovineById(String id) async {
    try {
      final doc = await _firestore
          .collection(AppConstants.bovinesCollection)
          .doc(id)
          .get();
      
      if (doc.exists) {
        return BovineModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw 'Error obteniendo bovino: $e';
    }
  }

  // Get all bovines for current user
  Stream<List<BovineModel>> getBovinesStream() {
    if (_currentUserId == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection(AppConstants.bovinesCollection)
        .where('propietarioId', isEqualTo: _currentUserId)
        .where('activo', isEqualTo: true)
        .orderBy('fechaCreacion', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => BovineModel.fromFirestore(doc))
            .toList());
  }

  // Get bovines by status
  Stream<List<BovineModel>> getBovinesByStatus(String status) {
    if (_currentUserId == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection(AppConstants.bovinesCollection)
        .where('propietarioId', isEqualTo: _currentUserId)
        .where('estado', isEqualTo: status)
        .where('activo', isEqualTo: true)
        .orderBy('fechaCreacion', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => BovineModel.fromFirestore(doc))
            .toList());
  }

  // Get bovines by race
  Stream<List<BovineModel>> getBovinesByRace(String race) {
    if (_currentUserId == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection(AppConstants.bovinesCollection)
        .where('propietarioId', isEqualTo: _currentUserId)
        .where('raza', isEqualTo: race)
        .where('activo', isEqualTo: true)
        .orderBy('fechaCreacion', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => BovineModel.fromFirestore(doc))
            .toList());
  }

  // Get bovines by sex
  Stream<List<BovineModel>> getBovinesBySex(String sex) {
    if (_currentUserId == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection(AppConstants.bovinesCollection)
        .where('propietarioId', isEqualTo: _currentUserId)
        .where('sexo', isEqualTo: sex)
        .where('activo', isEqualTo: true)
        .orderBy('fechaCreacion', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => BovineModel.fromFirestore(doc))
            .toList());
  }

  // Search bovines by name or identification
  Future<List<BovineModel>> searchBovines(String query) async {
    if (_currentUserId == null) return [];

    try {
      final nameQuery = await _firestore
          .collection(AppConstants.bovinesCollection)
          .where('propietarioId', isEqualTo: _currentUserId)
          .where('activo', isEqualTo: true)
          .where('nombre', isGreaterThanOrEqualTo: query)
          .where('nombre', isLessThanOrEqualTo: query + '\uf8ff')
          .get();

      final identificationQuery = await _firestore
          .collection(AppConstants.bovinesCollection)
          .where('propietarioId', isEqualTo: _currentUserId)
          .where('activo', isEqualTo: true)
          .where('numeroIdentificacion', isGreaterThanOrEqualTo: query)
          .where('numeroIdentificacion', isLessThanOrEqualTo: query + '\uf8ff')
          .get();

      final Set<String> addedIds = {};
      final List<BovineModel> results = [];

      // Add results from name query
      for (var doc in nameQuery.docs) {
        if (!addedIds.contains(doc.id)) {
          results.add(BovineModel.fromFirestore(doc));
          addedIds.add(doc.id);
        }
      }

      // Add results from identification query
      for (var doc in identificationQuery.docs) {
        if (!addedIds.contains(doc.id)) {
          results.add(BovineModel.fromFirestore(doc));
          addedIds.add(doc.id);
        }
      }

      return results;
    } catch (e) {
      throw 'Error buscando bovinos: $e';
    }
  }

  // Get bovines count by status
  Future<Map<String, int>> getBovinesCountByStatus() async {
    if (_currentUserId == null) return {};

    try {
      final snapshot = await _firestore
          .collection(AppConstants.bovinesCollection)
          .where('propietarioId', isEqualTo: _currentUserId)
          .where('activo', isEqualTo: true)
          .get();

      final Map<String, int> counts = {};
      
      for (var doc in snapshot.docs) {
        final bovine = BovineModel.fromFirestore(doc);
        counts[bovine.estado] = (counts[bovine.estado] ?? 0) + 1;
      }

      return counts;
    } catch (e) {
      throw 'Error obteniendo estadísticas: $e';
    }
  }

  // Get all races used
  Future<List<String>> getAllRaces() async {
    if (_currentUserId == null) return [];

    try {
      final snapshot = await _firestore
          .collection(AppConstants.bovinesCollection)
          .where('propietarioId', isEqualTo: _currentUserId)
          .where('activo', isEqualTo: true)
          .get();

      final Set<String> races = {};
      for (var doc in snapshot.docs) {
        final bovine = BovineModel.fromFirestore(doc);
        races.add(bovine.raza);
      }

      return races.toList()..sort();
    } catch (e) {
      throw 'Error obteniendo razas: $e';
    }
  }

  // Update bovine status
  Future<void> updateBovineStatus(String id, String newStatus) async {
    try {
      await _firestore
          .collection(AppConstants.bovinesCollection)
          .doc(id)
          .update({
            'estado': newStatus,
            'fechaActualizacion': Timestamp.now(),
          });
    } catch (e) {
      throw 'Error actualizando estado del bovino: $e';
    }
  }

  // Update bovine weight
  Future<void> updateBovineWeight(String id, double newWeight) async {
    try {
      await _firestore
          .collection(AppConstants.bovinesCollection)
          .doc(id)
          .update({
            'peso': newWeight,
            'fechaActualizacion': Timestamp.now(),
          });
    } catch (e) {
      throw 'Error actualizando peso del bovino: $e';
    }
  }

  // Check if identification number exists
  Future<bool> identificationExists(String identification, {String? excludeId}) async {
    if (_currentUserId == null) return false;

    try {
      var query = _firestore
          .collection(AppConstants.bovinesCollection)
          .where('propietarioId', isEqualTo: _currentUserId)
          .where('numeroIdentificacion', isEqualTo: identification)
          .where('activo', isEqualTo: true);

      final snapshot = await query.get();
      
      if (excludeId != null) {
        return snapshot.docs.any((doc) => doc.id != excludeId);
      }
      
      return snapshot.docs.isNotEmpty;
    } catch (e) {
      throw 'Error verificando número de identificación: $e';
    }
  }

  // Get bovines for veterinarian (all bovines they can access)
  Stream<List<BovineModel>> getBovinesForVeterinarian() {
    return _firestore
        .collection(AppConstants.bovinesCollection)
        .where('activo', isEqualTo: true)
        .orderBy('fechaCreacion', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => BovineModel.fromFirestore(doc))
            .toList());
  }

  // Get bovines statistics
  Future<Map<String, dynamic>> getBovinesStatistics() async {
    if (_currentUserId == null) return {};

    try {
      final snapshot = await _firestore
          .collection(AppConstants.bovinesCollection)
          .where('propietarioId', isEqualTo: _currentUserId)
          .where('activo', isEqualTo: true)
          .get();

      int totalBovines = 0;
      int males = 0;
      int females = 0;
      double totalWeight = 0;
      final Map<String, int> statusCount = {};
      final Map<String, int> raceCount = {};

      for (var doc in snapshot.docs) {
        final bovine = BovineModel.fromFirestore(doc);
        totalBovines++;
        
        if (bovine.sexo.toLowerCase() == 'macho') {
          males++;
        } else {
          females++;
        }
        
        totalWeight += bovine.peso;
        statusCount[bovine.estado] = (statusCount[bovine.estado] ?? 0) + 1;
        raceCount[bovine.raza] = (raceCount[bovine.raza] ?? 0) + 1;
      }

      return {
        'totalBovines': totalBovines,
        'males': males,
        'females': females,
        'averageWeight': totalBovines > 0 ? totalWeight / totalBovines : 0,
        'statusCount': statusCount,
        'raceCount': raceCount,
      };
    } catch (e) {
      throw 'Error obteniendo estadísticas: $e';
    }
  }
}