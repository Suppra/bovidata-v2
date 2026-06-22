import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bovidata_new/models/treatment_model.dart';
import 'package:bovidata_new/features/treatments/infrastructure/repositories/treatment_repository_impl.dart';

TreatmentModel _t({
  String bovineId = 'b1',
  String owner = 'owner1',
  bool completado = false,
  DateTime? fecha,
}) {
  return TreatmentModel.empty().copyWith(
    bovineId: bovineId,
    tipo: 'Vacuna',
    nombre: 'Antiaftosa',
    veterinarioId: 'vet1',
    propietarioId: owner,
    completado: completado,
    fecha: fecha ?? DateTime(2026, 1, 1),
  );
}

void main() {
  late FakeFirebaseFirestore db;
  late TreatmentRepository repo;

  setUp(() {
    db = FakeFirebaseFirestore();
    repo = TreatmentRepository(firestore: db);
  });

  test('getByOwners acota al hato y ordena por fecha desc', () async {
    await repo.create(_t(owner: 'A', fecha: DateTime(2025, 1, 1)));
    await repo.create(_t(owner: 'B', fecha: DateTime(2026, 5, 1)));
    await repo.create(_t(owner: 'C'));

    final result = await repo.getByOwners(['A', 'B']);
    expect(result.length, 2);
    expect(result.first.fecha.isAfter(result.last.fecha), isTrue);
  });

  test('getByBovine filtra por bovino', () async {
    await repo.create(_t(bovineId: 'b1'));
    await repo.create(_t(bovineId: 'b2'));
    final result = await repo.getByBovine('b1');
    expect(result.length, 1);
    expect(result.first.bovineId, 'b1');
  });

  test('getPending devuelve solo no completados', () async {
    await repo.create(_t(completado: false));
    await repo.create(_t(completado: true));
    final pending = await repo.getPending();
    expect(pending.length, 1);
    expect(pending.first.completado, isFalse);
  });
}
