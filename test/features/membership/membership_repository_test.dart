import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bovidata_new/features/membership/domain/entities/membership.dart';
import 'package:bovidata_new/features/membership/infrastructure/repositories/membership_repository_impl.dart';

Membership _m(String ganadero, String member, MembershipStatus estado) =>
    Membership(
      id: Membership.buildId(ganadero, member),
      ganaderoId: ganadero,
      ganaderoNombre: 'Don $ganadero',
      memberId: member,
      memberEmail: '$member@mail.com',
      memberNombre: 'M $member',
      memberRol: 'Veterinario',
      estado: estado,
      fechaCreacion: DateTime(2026, 1, 1),
    );

void main() {
  late FakeFirebaseFirestore db;
  late MembershipRepositoryImpl repo;

  setUp(() {
    db = FakeFirebaseFirestore();
    repo = MembershipRepositoryImpl(firestore: db);
  });

  test('invite usa id determinista y getById lo recupera', () async {
    await repo.invite(_m('g1', 'v1', MembershipStatus.pendiente));
    final found = await repo.getById('g1_v1');
    expect(found, isNotNull);
    expect(found!.estado, MembershipStatus.pendiente);
  });

  test('updateStatus cambia el estado (aceptar invitación)', () async {
    await repo.invite(_m('g1', 'v1', MembershipStatus.pendiente));
    await repo.updateStatus('g1_v1', MembershipStatus.aceptada);
    expect((await repo.getById('g1_v1'))!.estado, MembershipStatus.aceptada);
  });

  test('getAcceptedForMember solo devuelve membresías aceptadas del miembro',
      () async {
    await repo.invite(_m('g1', 'v1', MembershipStatus.aceptada));
    await repo.invite(_m('g2', 'v1', MembershipStatus.pendiente));
    await repo.invite(_m('g3', 'otro', MembershipStatus.aceptada));

    final accepted = await repo.getAcceptedForMember('v1');
    expect(accepted.length, 1);
    expect(accepted.first.ganaderoId, 'g1');
  });
}
