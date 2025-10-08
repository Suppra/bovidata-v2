import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/treatment_model.dart';
import '../constants/app_constants.dart';
import 'activity_service.dart';
import 'notification_service.dart';

class TreatmentService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final ActivityService _activityService = ActivityService();

  // Create a new treatment
  static Future<String?> createTreatment(TreatmentModel treatment) async {
    try {
      final docRef = await _firestore
          .collection(AppConstants.treatmentsCollection)
          .add(treatment.toFirestore());
      
      // Log activity and send notifications
      final currentUserId = _auth.currentUser?.uid;
      if (currentUserId != null && treatment.bovineId.isNotEmpty) {
        try {
          // Get bovine and user information
          final bovineDoc = await _firestore
              .collection(AppConstants.bovinesCollection)
              .doc(treatment.bovineId)
              .get();
          
          final currentUserDoc = await _firestore
              .collection('users')
              .doc(currentUserId)
              .get();
          
          final bovineName = bovineDoc.data()?['nombre'] ?? 'Desconocido';
          final bovineOwnerId = bovineDoc.data()?['propietarioId'];
          final currentUserName = currentUserDoc.data()?['nombre'] ?? 'Usuario';
          final currentUserRole = currentUserDoc.data()?['rol'];
          
          // Log activity
          await _activityService.logTreatmentCreated(
            docRef.id,
            treatment.tipo,
            treatment.bovineId,
            bovineName,
            currentUserId,
          );
          
          // If current user is veterinarian and bovine has different owner, send notification
          if (currentUserRole == 'Veterinario' && 
              bovineOwnerId != null && 
              bovineOwnerId != currentUserId) {
            await NotificationService.notifyTreatmentAdded(
              bovineId: treatment.bovineId,
              bovineName: bovineName,
              treatmentType: treatment.tipo,
              veterinarioNombre: currentUserName,
              ganaderoId: bovineOwnerId,
            );
          }
        } catch (e) {
          print('Error logging treatment activity or sending notification: $e');
        }
      }
      
      return docRef.id;
    } catch (e) {
      print('Error creating treatment: $e');
      return null;
    }
  }

  // Get all treatments
  static Stream<List<TreatmentModel>> getAllTreatments() {
    return _firestore
        .collection(AppConstants.treatmentsCollection)
        .orderBy('fecha', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => TreatmentModel.fromFirestore(doc)).toList());
  }

  // Get treatments for a specific bovine
  static Stream<List<TreatmentModel>> getTreatmentsByBovine(String bovineId) {
    return _firestore
        .collection(AppConstants.treatmentsCollection)
        .where('bovineId', isEqualTo: bovineId)
        .orderBy('fecha', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => TreatmentModel.fromFirestore(doc)).toList());
  }

  // Get treatments by veterinarian
  static Stream<List<TreatmentModel>> getTreatmentsByVeterinarian(String veterinarioId) {
    return _firestore
        .collection(AppConstants.treatmentsCollection)
        .where('veterinarioId', isEqualTo: veterinarioId)
        .orderBy('fecha', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => TreatmentModel.fromFirestore(doc)).toList());
  }

  // Get treatments by type
  static Stream<List<TreatmentModel>> getTreatmentsByType(String tipo) {
    return _firestore
        .collection(AppConstants.treatmentsCollection)
        .where('tipo', isEqualTo: tipo)
        .orderBy('fecha', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => TreatmentModel.fromFirestore(doc)).toList());
  }

  // Get pending treatments (not completed)
  static Stream<List<TreatmentModel>> getPendingTreatments() {
    return _firestore
        .collection(AppConstants.treatmentsCollection)
        .where('completado', isEqualTo: false)
        .orderBy('fecha', descending: false)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => TreatmentModel.fromFirestore(doc)).toList());
  }

  // Get treatments due soon (next 7 days)
  static Stream<List<TreatmentModel>> getTreatmentsDueSoon() {
    final now = DateTime.now();
    final nextWeek = now.add(const Duration(days: 7));
    
    return _firestore
        .collection(AppConstants.treatmentsCollection)
        .where('proximaAplicacion', isGreaterThanOrEqualTo: Timestamp.fromDate(now))
        .where('proximaAplicacion', isLessThanOrEqualTo: Timestamp.fromDate(nextWeek))
        .where('completado', isEqualTo: false)
        .orderBy('proximaAplicacion', descending: false)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => TreatmentModel.fromFirestore(doc)).toList());
  }

  // Get treatment by ID
  static Future<TreatmentModel?> getTreatmentById(String treatmentId) async {
    try {
      final doc = await _firestore
          .collection(AppConstants.treatmentsCollection)
          .doc(treatmentId)
          .get();
      
      if (doc.exists && doc.data() != null) {
        return TreatmentModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Error getting treatment: $e');
      return null;
    }
  }

  // Update treatment
  static Future<bool> updateTreatment(TreatmentModel treatment) async {
    try {
      await _firestore
          .collection(AppConstants.treatmentsCollection)
          .doc(treatment.id)
          .update(treatment.toFirestore());
      return true;
    } catch (e) {
      print('Error updating treatment: $e');
      return false;
    }
  }

  // Mark treatment as completed
  static Future<bool> markTreatmentCompleted(String treatmentId) async {
    try {
      // Get treatment and bovine information before updating
      final treatmentDoc = await _firestore
          .collection(AppConstants.treatmentsCollection)
          .doc(treatmentId)
          .get();
      
      if (!treatmentDoc.exists) return false;
      
      final treatmentData = treatmentDoc.data()!;
      final bovineId = treatmentData['bovineId'];
      final treatmentType = treatmentData['tipo'];
      
      // Get bovine information
      final bovineDoc = await _firestore
          .collection(AppConstants.bovinesCollection)
          .doc(bovineId)
          .get();
      
      final bovineName = bovineDoc.data()?['nombre'] ?? 'Desconocido';
      final ganaderoId = bovineDoc.data()?['propietarioId'];
      
      // Update treatment as completed
      await _firestore
          .collection(AppConstants.treatmentsCollection)
          .doc(treatmentId)
          .update({
        'completado': true,
        'fechaCompletado': Timestamp.now(),
      });
      
      // Send notification to ganadero if completed by veterinarian or employee
      final currentUserId = _auth.currentUser?.uid;
      if (currentUserId != null && ganaderoId != null && currentUserId != ganaderoId) {
        final currentUserDoc = await _firestore
            .collection('users')
            .doc(currentUserId)
            .get();
        
        final currentUserName = currentUserDoc.data()?['nombre'] ?? 'Usuario';
        final currentUserRole = currentUserDoc.data()?['rol'] ?? '';
        
        await NotificationService.notifyTreatmentCompleted(
          treatmentId: treatmentId,
          treatmentType: treatmentType,
          bovineName: bovineName,
          completedBy: '$currentUserName ($currentUserRole)',
          ganaderoId: ganaderoId,
        );
      }
      
      return true;
    } catch (e) {
      print('Error marking treatment as completed: $e');
      return false;
    }
  }

  // Delete treatment
  static Future<bool> deleteTreatment(String treatmentId) async {
    try {
      await _firestore
          .collection(AppConstants.treatmentsCollection)
          .doc(treatmentId)
          .delete();
      return true;
    } catch (e) {
      print('Error deleting treatment: $e');
      return false;
    }
  }

  // Search treatments
  static Stream<List<TreatmentModel>> searchTreatments(String searchQuery) {
    final query = searchQuery.toLowerCase();
    
    return _firestore
        .collection(AppConstants.treatmentsCollection)
        .orderBy('nombre')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => TreatmentModel.fromFirestore(doc))
          .where((treatment) =>
              treatment.nombre.toLowerCase().contains(query) ||
              treatment.tipo.toLowerCase().contains(query) ||
              (treatment.medicamento?.toLowerCase().contains(query) ?? false) ||
              treatment.descripcion.toLowerCase().contains(query))
          .toList();
    });
  }

  // Get treatments by date range
  static Stream<List<TreatmentModel>> getTreatmentsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) {
    return _firestore
        .collection(AppConstants.treatmentsCollection)
        .where('fecha', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
        .where('fecha', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
        .orderBy('fecha', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => TreatmentModel.fromFirestore(doc)).toList());
  }

  // Get treatment statistics
  static Future<Map<String, dynamic>> getTreatmentStatistics() async {
    try {
      final snapshot = await _firestore
          .collection(AppConstants.treatmentsCollection)
          .get();

      final treatments = snapshot.docs
          .map((doc) => TreatmentModel.fromFirestore(doc))
          .toList();

      final total = treatments.length;
      final completed = treatments.where((t) => t.completado).length;
      final pending = treatments.where((t) => !t.completado).length;
      
      final now = DateTime.now();
      final thisMonth = treatments.where((t) =>
          t.fecha.year == now.year && t.fecha.month == now.month).length;
      
      final treatmentsByType = <String, int>{};
      for (final treatment in treatments) {
        treatmentsByType[treatment.tipo] = (treatmentsByType[treatment.tipo] ?? 0) + 1;
      }

      final totalCost = treatments
          .where((t) => t.costo != null)
          .fold(0.0, (sum, t) => sum + t.costo!);

      return {
        'total': total,
        'completed': completed,
        'pending': pending,
        'thisMonth': thisMonth,
        'treatmentsByType': treatmentsByType,
        'totalCost': totalCost,
      };
    } catch (e) {
      print('Error getting treatment statistics: $e');
      return {
        'total': 0,
        'completed': 0,
        'pending': 0,
        'thisMonth': 0,
        'treatmentsByType': <String, int>{},
        'totalCost': 0.0,
      };
    }
  }

  // Get vaccination schedule for a bovine
  static Stream<List<TreatmentModel>> getVaccinationSchedule(String bovineId) {
    return _firestore
        .collection(AppConstants.treatmentsCollection)
        .where('bovineId', isEqualTo: bovineId)
        .where('tipo', isEqualTo: 'Vacunación')
        .orderBy('proximaAplicacion', descending: false)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => TreatmentModel.fromFirestore(doc)).toList());
  }

  // Get overdue treatments
  static Stream<List<TreatmentModel>> getOverdueTreatments() {
    final now = DateTime.now();
    
    return _firestore
        .collection(AppConstants.treatmentsCollection)
        .where('proximaAplicacion', isLessThan: Timestamp.fromDate(now))
        .where('completado', isEqualTo: false)
        .orderBy('proximaAplicacion', descending: false)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => TreatmentModel.fromFirestore(doc)).toList());
  }
}