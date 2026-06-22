// Capa de PRESENTACIÓN — estado de UI para membresías (Provider/ChangeNotifier).
import 'package:flutter/foundation.dart';
import 'package:bovidata_new/features/membership/application/membership_interactor.dart';
import 'package:bovidata_new/features/membership/domain/entities/membership.dart';
import 'package:bovidata_new/features/membership/domain/ports/membership_repository.dart';

class MembershipController extends ChangeNotifier {
  final MembershipInteractor _interactor;
  final MembershipRepository _repository;

  MembershipController({
    required MembershipInteractor interactor,
    required MembershipRepository repository,
  })  : _interactor = interactor,
        _repository = repository;

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Miembros del hato de un ganadero (en tiempo real).
  Stream<List<Membership>> watchFarmMembers(String ganaderoId) =>
      _repository.watchByGanadero(ganaderoId);

  /// Invitaciones recibidas por un miembro (en tiempo real).
  Stream<List<Membership>> watchMyInvitations(String memberId) =>
      _repository.watchInvitationsForMember(memberId);

  /// Solo las invitaciones pendientes (para badges/acciones).
  Stream<List<Membership>> watchMyPendingInvitations(String memberId) =>
      watchMyInvitations(memberId).map(
        (list) => list.where((m) => m.isPending).toList(),
      );

  Future<bool> invite({
    required String ganaderoId,
    required String ganaderoNombre,
    required String memberEmail,
  }) async {
    return _run(() => _interactor.invite(
          ganaderoId: ganaderoId,
          ganaderoNombre: ganaderoNombre,
          memberEmail: memberEmail,
        ));
  }

  Future<bool> respond({required String membershipId, required bool accept}) {
    return _run(() => _interactor.respond(membershipId: membershipId, accept: accept));
  }

  Future<bool> revoke(String membershipId) {
    return _run(() => _interactor.revoke(membershipId));
  }

  Future<bool> _run(Future<MembershipResult> Function() action) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final result = await action();
      if (!result.success) _errorMessage = result.error;
      return result.success;
    } catch (e) {
      _errorMessage = 'Error: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
