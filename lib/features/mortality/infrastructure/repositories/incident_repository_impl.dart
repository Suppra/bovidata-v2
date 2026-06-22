// Capa de INFRAESTRUCTURA (mortality) — implementación Firestore.
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bovidata_new/constants/app_constants.dart';
import 'package:bovidata_new/models/incident_model.dart';
import 'package:bovidata_new/features/mortality/domain/ports/incident_repository.dart';

class IncidentRepository implements IIncidentRepository {
  final FirebaseFirestore _firestore;
  final String _collection = AppConstants.incidentsCollection;

  IncidentRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<List<IncidentModel>> getByBovine(String bovineId) async {
    final snap = await _firestore
        .collection(_collection)
        .where('bovineId', isEqualTo: bovineId)
        .orderBy('fecha', descending: true)
        .get();
    return snap.docs.map(IncidentModel.fromFirestore).toList();
  }

  @override
  Future<List<IncidentModel>> getByOwners(List<String> ownerIds) async {
    if (ownerIds.isEmpty) return [];
    final snap = await _firestore
        .collection(_collection)
        .where('propietarioId', whereIn: ownerIds)
        .get();
    return snap.docs.map(IncidentModel.fromFirestore).toList()
      ..sort((a, b) => b.fecha.compareTo(a.fecha));
  }
}
