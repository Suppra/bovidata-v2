// Servicio transversal de control de acceso por HATO.
//
// Resuelve, para el usuario autenticado, el conjunto de "dueños de hato"
// (propietarioId) cuyos datos puede leer, y el hato al que pertenecen los
// datos que crea. Es la pieza central del scoping seguro por membresías:
//
//  - Un GANADERO accede a su propio hato (su uid).
//  - Un VETERINARIO/EMPLEADO accede a los hatos de los ganaderos que lo han
//    invitado y cuya invitación aceptó.
import 'package:firebase_auth/firebase_auth.dart';
import '../../features/membership/domain/ports/membership_repository.dart';

class FarmAccessService {
  final MembershipRepository _memberships;
  final FirebaseAuth _auth;

  FarmAccessService({
    required MembershipRepository membershipRepository,
    FirebaseAuth? auth,
  })  : _memberships = membershipRepository,
        _auth = auth ?? FirebaseAuth.instance;

  String? get _uid => _auth.currentUser?.uid;

  /// Ids de los dueños de hato cuyos datos puede leer el usuario actual.
  /// Incluye siempre su propio uid (su hato si es ganadero) y los hatos de
  /// las membresías aceptadas. Nunca vacío si hay sesión.
  Future<List<String>> accessibleOwnerIds() async {
    final uid = _uid;
    if (uid == null) return const [];
    final ids = <String>{uid};
    final accepted = await _memberships.getAcceptedForMember(uid);
    ids.addAll(accepted.map((m) => m.ganaderoId));
    // Firestore `whereIn` admite hasta 30 valores; se acota por seguridad.
    return ids.take(30).toList();
  }

  /// Hato al que deben pertenecer los datos creados por el usuario actual.
  ///  - Ganadero (sin membresías) → su propio uid.
  ///  - Miembro con membresía aceptada → el hato del ganadero que lo invitó.
  Future<String> currentFarmOwnerId() async {
    final uid = _uid;
    if (uid == null) return '';
    final accepted = await _memberships.getAcceptedForMember(uid);
    if (accepted.isNotEmpty) return accepted.first.ganaderoId;
    return uid;
  }
}
