// Capa de APLICACIÓN — casos de uso de membresías.
//
// Orquesta el puerto MembershipRepository con la búsqueda de usuarios y el
// envío de notificaciones, sin conocer detalles de Firestore.
import 'package:bovidata_new/core/interfaces/repository_interface.dart';
import 'package:bovidata_new/features/notifications/infrastructure/solid_notification_service.dart';
import 'package:bovidata_new/models/notification_model.dart';
import 'package:bovidata_new/features/membership/domain/entities/membership.dart';
import 'package:bovidata_new/features/membership/domain/ports/membership_repository.dart';

class MembershipResult {
  final bool success;
  final String? error;
  const MembershipResult.ok() : success = true, error = null;
  const MembershipResult.fail(this.error) : success = false;
}

class MembershipInteractor {
  final MembershipRepository _memberships;
  final IUserRepository _users;
  final SolidNotificationService _notifications;

  MembershipInteractor({
    required MembershipRepository membershipRepository,
    required IUserRepository userRepository,
    required SolidNotificationService notificationService,
  })  : _memberships = membershipRepository,
        _users = userRepository,
        _notifications = notificationService;

  /// Un ganadero invita a un veterinario/empleado (identificado por su correo).
  Future<MembershipResult> invite({
    required String ganaderoId,
    required String ganaderoNombre,
    required String memberEmail,
  }) async {
    final email = memberEmail.trim().toLowerCase();
    if (email.isEmpty) {
      return const MembershipResult.fail('Ingresa el correo del usuario a invitar');
    }

    final user = await _users.getByEmail(email);
    if (user == null) {
      return const MembershipResult.fail('No existe un usuario registrado con ese correo');
    }
    if (user.id == ganaderoId) {
      return const MembershipResult.fail('No puedes invitarte a ti mismo');
    }
    if (user.rol != 'Veterinario' && user.rol != 'Empleado') {
      return const MembershipResult.fail(
          'Solo puedes invitar usuarios con rol Veterinario o Empleado');
    }

    final id = Membership.buildId(ganaderoId, user.id);
    final existing = await _memberships.getById(id);
    if (existing != null && existing.isAccepted) {
      return const MembershipResult.fail('Ese usuario ya forma parte de tu hato');
    }

    final membership = Membership(
      id: id,
      ganaderoId: ganaderoId,
      ganaderoNombre: ganaderoNombre,
      memberId: user.id,
      memberEmail: user.email,
      memberNombre: user.nombreCompleto,
      memberRol: user.rol,
      estado: MembershipStatus.pendiente,
      fechaCreacion: DateTime.now(),
    );
    await _memberships.invite(membership);

    await _notifyMember(
      userId: user.id,
      titulo: 'Invitación a un hato',
      mensaje: '$ganaderoNombre te invitó a su hato como ${user.rol}.',
      datos: {'membershipId': id, 'accion': 'invitacion'},
    );

    return const MembershipResult.ok();
  }

  /// El miembro acepta o rechaza una invitación.
  Future<MembershipResult> respond({
    required String membershipId,
    required bool accept,
  }) async {
    final m = await _memberships.getById(membershipId);
    if (m == null) {
      return const MembershipResult.fail('La invitación ya no existe');
    }
    await _memberships.updateStatus(
      membershipId,
      accept ? MembershipStatus.aceptada : MembershipStatus.rechazada,
    );

    await _notifyMember(
      userId: m.ganaderoId,
      titulo: accept ? 'Invitación aceptada' : 'Invitación rechazada',
      mensaje:
          '${m.memberNombre} ${accept ? 'aceptó' : 'rechazó'} unirse a tu hato.',
      datos: {'membershipId': membershipId, 'accion': 'respuesta'},
    );

    return const MembershipResult.ok();
  }

  /// El ganadero revoca el acceso de un miembro.
  Future<MembershipResult> revoke(String membershipId) async {
    final m = await _memberships.getById(membershipId);
    if (m == null) return const MembershipResult.fail('La membresía no existe');
    await _memberships.updateStatus(membershipId, MembershipStatus.revocada);
    await _notifyMember(
      userId: m.memberId,
      titulo: 'Acceso revocado',
      mensaje: '${m.ganaderoNombre} revocó tu acceso a su hato.',
      datos: {'membershipId': membershipId, 'accion': 'revocacion'},
    );
    return const MembershipResult.ok();
  }

  Future<void> _notifyMember({
    required String userId,
    required String titulo,
    required String mensaje,
    Map<String, dynamic>? datos,
  }) async {
    try {
      await _notifications.createNotification(
        NotificationModel(
          id: '',
          titulo: titulo,
          mensaje: mensaje,
          tipo: 'membresia',
          usuarioId: userId,
          fechaCreacion: DateTime.now(),
          datos: datos,
          prioridad: 'alta',
        ),
      );
    } catch (_) {
      // Best-effort: la notificación no debe bloquear el flujo principal.
    }
  }
}
