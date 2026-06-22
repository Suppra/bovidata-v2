// Capa de INFRAESTRUCTURA — implementación Firestore del puerto MembershipRepository.
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bovidata_new/features/membership/domain/entities/membership.dart';
import 'package:bovidata_new/features/membership/domain/ports/membership_repository.dart';
import 'package:bovidata_new/features/membership/infrastructure/dto/membership_dto.dart';

class MembershipRepositoryImpl implements MembershipRepository {
  final FirebaseFirestore _firestore;
  static const String _collection = 'memberships';

  MembershipRepositoryImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _col =>
      _firestore.collection(_collection);

  @override
  Future<void> invite(Membership membership) async {
    // Id determinista: una sola membresía por par (ganadero, miembro).
    await _col.doc(membership.id).set(MembershipDto.toMap(membership));
  }

  @override
  Future<void> updateStatus(String id, MembershipStatus status) async {
    await _col.doc(id).update({
      'estado': status.value,
      'fechaRespuesta': FieldValue.serverTimestamp(),
    });
  }

  @override
  Stream<List<Membership>> watchByGanadero(String ganaderoId) {
    return _col
        .where('ganaderoId', isEqualTo: ganaderoId)
        .snapshots()
        .map((s) => s.docs.map(MembershipDto.fromDoc).toList()
          ..sort((a, b) => b.fechaCreacion.compareTo(a.fechaCreacion)));
  }

  @override
  Stream<List<Membership>> watchInvitationsForMember(String memberId) {
    return _col
        .where('memberId', isEqualTo: memberId)
        .snapshots()
        .map((s) => s.docs.map(MembershipDto.fromDoc).toList()
          ..sort((a, b) => b.fechaCreacion.compareTo(a.fechaCreacion)));
  }

  @override
  Future<List<Membership>> getAcceptedForMember(String memberId) async {
    final snap = await _col
        .where('memberId', isEqualTo: memberId)
        .where('estado', isEqualTo: MembershipStatus.aceptada.value)
        .get();
    return snap.docs.map(MembershipDto.fromDoc).toList();
  }

  @override
  Future<Membership?> getById(String id) async {
    final doc = await _col.doc(id).get();
    if (!doc.exists) return null;
    return MembershipDto.fromDoc(doc);
  }
}
