// Capa de DOMINIO — entidad pura, sin dependencias de Firebase ni Flutter.
//
// Representa la relación de membresía entre un GANADERO (dueño del hato) y un
// usuario invitado (Veterinario o Empleado). El acceso de los miembros a los
// datos del hato se concede únicamente tras una invitación aceptada.

enum MembershipStatus { pendiente, aceptada, rechazada, revocada }

extension MembershipStatusX on MembershipStatus {
  String get value => name; // 'pendiente' | 'aceptada' | ...

  static MembershipStatus fromValue(String? raw) {
    return MembershipStatus.values.firstWhere(
      (s) => s.name == raw,
      orElse: () => MembershipStatus.pendiente,
    );
  }
}

class Membership {
  final String id; // convención: "${ganaderoId}_${memberId}"
  final String ganaderoId;
  final String ganaderoNombre;
  final String memberId;
  final String memberEmail;
  final String memberNombre;
  final String memberRol; // 'Veterinario' | 'Empleado'
  final MembershipStatus estado;
  final DateTime fechaCreacion;
  final DateTime? fechaRespuesta;

  const Membership({
    required this.id,
    required this.ganaderoId,
    required this.ganaderoNombre,
    required this.memberId,
    required this.memberEmail,
    required this.memberNombre,
    required this.memberRol,
    required this.estado,
    required this.fechaCreacion,
    this.fechaRespuesta,
  });

  bool get isPending => estado == MembershipStatus.pendiente;
  bool get isAccepted => estado == MembershipStatus.aceptada;

  /// Id determinista del documento, para poder verificarlo desde las reglas
  /// de seguridad con `exists()`/`get()` sin consultas adicionales.
  static String buildId(String ganaderoId, String memberId) =>
      '${ganaderoId}_$memberId';

  Membership copyWith({
    MembershipStatus? estado,
    DateTime? fechaRespuesta,
  }) {
    return Membership(
      id: id,
      ganaderoId: ganaderoId,
      ganaderoNombre: ganaderoNombre,
      memberId: memberId,
      memberEmail: memberEmail,
      memberNombre: memberNombre,
      memberRol: memberRol,
      estado: estado ?? this.estado,
      fechaCreacion: fechaCreacion,
      fechaRespuesta: fechaRespuesta ?? this.fechaRespuesta,
    );
  }
}
