// Pruebas de la entidad de dominio Membership (pura, sin Firebase).
import 'package:flutter_test/flutter_test.dart';
import 'package:bovidata_new/features/membership/domain/entities/membership.dart';

void main() {
  group('Membership — dominio', () {
    Membership sample(MembershipStatus estado) => Membership(
          id: Membership.buildId('gan1', 'mem1'),
          ganaderoId: 'gan1',
          ganaderoNombre: 'Don Ganadero',
          memberId: 'mem1',
          memberEmail: 'vet@mail.com',
          memberNombre: 'Vet Uno',
          memberRol: 'Veterinario',
          estado: estado,
          fechaCreacion: DateTime(2026),
        );

    test('buildId genera un id determinista por par (ganadero, miembro)', () {
      expect(Membership.buildId('gan1', 'mem1'), 'gan1_mem1');
    });

    test('isPending / isAccepted reflejan el estado', () {
      expect(sample(MembershipStatus.pendiente).isPending, isTrue);
      expect(sample(MembershipStatus.pendiente).isAccepted, isFalse);
      expect(sample(MembershipStatus.aceptada).isAccepted, isTrue);
    });

    test('copyWith cambia el estado conservando el resto', () {
      final aceptada = sample(MembershipStatus.pendiente)
          .copyWith(estado: MembershipStatus.aceptada);
      expect(aceptada.isAccepted, isTrue);
      expect(aceptada.memberId, 'mem1');
      expect(aceptada.ganaderoId, 'gan1');
    });

    test('MembershipStatusX serializa y deserializa', () {
      expect(MembershipStatus.aceptada.value, 'aceptada');
      expect(MembershipStatusX.fromValue('rechazada'), MembershipStatus.rechazada);
      expect(MembershipStatusX.fromValue(null), MembershipStatus.pendiente);
    });
  });
}
