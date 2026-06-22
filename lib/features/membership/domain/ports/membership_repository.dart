// Capa de DOMINIO — Puerto (interfaz). La infraestructura lo implementa.
import 'package:bovidata_new/features/membership/domain/entities/membership.dart';

abstract interface class MembershipRepository {
  /// Crea (o reenvía) una invitación.
  Future<void> invite(Membership membership);

  /// Cambia el estado de una membresía (aceptar / rechazar / revocar).
  Future<void> updateStatus(String id, MembershipStatus status);

  /// Membresías creadas por un ganadero (su lista de miembros del hato).
  Stream<List<Membership>> watchByGanadero(String ganaderoId);

  /// Invitaciones dirigidas a un miembro (para aceptar/rechazar).
  Stream<List<Membership>> watchInvitationsForMember(String memberId);

  /// Membresías ACEPTADAS de un miembro (para resolver acceso a hatos).
  Future<List<Membership>> getAcceptedForMember(String memberId);

  Future<Membership?> getById(String id);
}
