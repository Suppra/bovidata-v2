// Capa de INFRAESTRUCTURA (dashboard) — lectura de actividades (audit log).
// Centraliza las consultas a `activities` para que la presentación no toque
// Firestore directamente.
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bovidata_new/models/activity_model.dart';

class ActivityRepository {
  final FirebaseFirestore _firestore;
  static const String _collection = 'activities';

  ActivityRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Actividades de una entidad (p. ej. un bovino), opcionalmente por tipo.
  Future<List<ActivityModel>> getByEntity(
    String entidadId, {
    List<String>? tipos,
  }) async {
    Query<Map<String, dynamic>> query =
        _firestore.collection(_collection).where('entidadId', isEqualTo: entidadId);
    if (tipos != null && tipos.isNotEmpty) {
      query = query.where('tipo', whereIn: tipos);
    }
    final snap = await query.orderBy('fecha', descending: true).get();
    return snap.docs
        .map((doc) => ActivityModel.fromJson({...doc.data(), 'id': doc.id}))
        .toList();
  }
}
