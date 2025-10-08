import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/activity_model.dart';
import '../constants/app_constants.dart';

class ActivityService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Registrar nueva actividad
  Future<void> logActivity(ActivityModel activity) async {
    try {
      await _firestore.collection('activities').add(activity.toJson());
    } catch (e) {
      print('Error logging activity: $e');
    }
  }

  // Obtener actividades recientes
  Future<List<ActivityModel>> getRecentActivities({
    String? userId,
    int limit = 10,
  }) async {
    try {
      Query query = _firestore.collection('activities');

      if (userId != null) {
        query = query.where('usuarioId', isEqualTo: userId);
      }

      final snapshot = await query.get();
      List<ActivityModel> activities = snapshot.docs
          .map((doc) => ActivityModel.fromJson({
                'id': doc.id,
                ...doc.data() as Map<String, dynamic>,
              }))
          .toList();
      
      // Ordenar en el cliente
      activities.sort((a, b) => b.fecha.compareTo(a.fecha));
      
      // Limitar en el cliente
      return activities.take(limit).toList();
    } catch (e) {
      print('Error getting recent activities: $e');
      return [];
    }
  }

  // Obtener actividades por tipo
  Future<List<ActivityModel>> getActivitiesByType({
    required String tipo,
    String? userId,
    int limit = 20,
  }) async {
    try {
      Query query = _firestore
          .collection('activities')
          .where('tipo', isEqualTo: tipo)
          .orderBy('fecha', descending: true)
          .limit(limit);

      if (userId != null) {
        query = query.where('usuarioId', isEqualTo: userId);
      }

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => ActivityModel.fromJson({
                'id': doc.id,
                ...doc.data() as Map<String, dynamic>,
              }))
          .toList();
    } catch (e) {
      print('Error getting activities by type: $e');
      return [];
    }
  }

  // Stream de actividades recientes para actualizaciones en tiempo real
  Stream<List<ActivityModel>> getRecentActivitiesStream({
    String? userId,
    int limit = 10,
  }) {
    try {
      Query query = _firestore.collection('activities');

      // Si hay userId, primero filtrar por usuario y luego ordenar
      if (userId != null) {
        query = query.where('usuarioId', isEqualTo: userId);
      }

      return query.snapshots().map((snapshot) {
        List<ActivityModel> activities = snapshot.docs
            .map((doc) => ActivityModel.fromJson({
                  'id': doc.id,
                  ...doc.data() as Map<String, dynamic>,
                }))
            .toList();
        
        // Ordenar en el cliente mientras se construyen los índices
        activities.sort((a, b) => b.fecha.compareTo(a.fecha));
        
        // Limitar en el cliente
        return activities.take(limit).toList();
      });
    } catch (e) {
      print('Error getting activities stream: $e');
      return Stream.value([]);
    }
  }

  // Limpiar actividades antiguas (mantener solo las últimas 100 por usuario)
  Future<void> cleanOldActivities(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('activities')
          .where('usuarioId', isEqualTo: userId)
          .orderBy('fecha', descending: true)
          .get();

      if (snapshot.docs.length > 100) {
        final docsToDelete = snapshot.docs.skip(100);
        final batch = _firestore.batch();

        for (final doc in docsToDelete) {
          batch.delete(doc.reference);
        }

        await batch.commit();
      }
    } catch (e) {
      print('Error cleaning old activities: $e');
    }
  }

  // Métodos de conveniencia para logging automático

  Future<void> logBovineCreated(String bovineId, String bovineName, String userId) async {
    final activity = ActivityModel.fromBovine(
      bovineId: bovineId,
      bovineName: bovineName,
      userId: userId,
      action: 'Registró',
    );
    await logActivity(activity);
  }

  Future<void> logBovineUpdated(String bovineId, String bovineName, String userId) async {
    final activity = ActivityModel.fromBovine(
      bovineId: bovineId,
      bovineName: bovineName,
      userId: userId,
      action: 'Actualizó',
    );
    await logActivity(activity);
  }

  Future<void> logBovineDeleted(String bovineId, String bovineName, String userId) async {
    final activity = ActivityModel.fromBovine(
      bovineId: bovineId,
      bovineName: bovineName,
      userId: userId,
      action: 'Eliminó',
    );
    await logActivity(activity);
  }

  Future<void> logTreatmentCreated(
    String treatmentId,
    String treatmentType,
    String bovineId,
    String bovineName,
    String userId,
  ) async {
    final activity = ActivityModel.fromTreatment(
      treatmentId: treatmentId,
      treatmentType: treatmentType,
      bovineId: bovineId,
      bovineName: bovineName,
      userId: userId,
      action: 'Aplicó',
    );
    await logActivity(activity);
  }

  Future<void> logInventoryAdded(String itemId, String itemName, String userId) async {
    final activity = ActivityModel.fromInventory(
      itemId: itemId,
      itemName: itemName,
      userId: userId,
      action: 'Agregó',
    );
    await logActivity(activity);
  }

  Future<void> logInventoryUpdated(String itemId, String itemName, String userId) async {
    final activity = ActivityModel.fromInventory(
      itemId: itemId,
      itemName: itemName,
      userId: userId,
      action: 'Actualizó',
    );
    await logActivity(activity);
  }
}