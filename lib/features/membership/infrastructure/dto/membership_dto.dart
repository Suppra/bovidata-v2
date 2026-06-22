// Capa de INFRAESTRUCTURA — adaptador entre Firestore y la entidad de dominio.
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bovidata_new/features/membership/domain/entities/membership.dart';

class MembershipDto {
  static Membership fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Membership(
      id: doc.id,
      ganaderoId: data['ganaderoId'] ?? '',
      ganaderoNombre: data['ganaderoNombre'] ?? '',
      memberId: data['memberId'] ?? '',
      memberEmail: data['memberEmail'] ?? '',
      memberNombre: data['memberNombre'] ?? '',
      memberRol: data['memberRol'] ?? '',
      estado: MembershipStatusX.fromValue(data['estado']),
      fechaCreacion: (data['fechaCreacion'] as Timestamp?)?.toDate() ?? DateTime.now(),
      fechaRespuesta: (data['fechaRespuesta'] as Timestamp?)?.toDate(),
    );
  }

  static Map<String, dynamic> toMap(Membership m) {
    return {
      'ganaderoId': m.ganaderoId,
      'ganaderoNombre': m.ganaderoNombre,
      'memberId': m.memberId,
      'memberEmail': m.memberEmail,
      'memberNombre': m.memberNombre,
      'memberRol': m.memberRol,
      'estado': m.estado.value,
      'fechaCreacion': Timestamp.fromDate(m.fechaCreacion),
      'fechaRespuesta':
          m.fechaRespuesta != null ? Timestamp.fromDate(m.fechaRespuesta!) : null,
    };
  }
}
