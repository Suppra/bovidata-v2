import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bovidata_new/models/inventory_model.dart';
import 'package:bovidata_new/features/inventory/infrastructure/repositories/inventory_repository_impl.dart';

InventoryModel _i({
  String nombre = 'Item',
  String owner = 'owner1',
  int actual = 10,
  int minimo = 5,
  bool activo = true,
}) {
  return InventoryModel.empty().copyWith(
    nombre: nombre,
    categoria: 'Medicamento',
    cantidadActual: actual,
    cantidadMinima: minimo,
    propietarioId: owner,
    activo: activo,
  );
}

void main() {
  late FakeFirebaseFirestore db;
  late InventoryRepository repo;

  setUp(() {
    db = FakeFirebaseFirestore();
    repo = InventoryRepository(firestore: db);
  });

  test('getLowStock usa cantidadMinima por ítem (no un umbral fijo)', () async {
    await repo.create(_i(nombre: 'bajo', actual: 3)); // low
    await repo.create(_i(nombre: 'justo', actual: 5)); // low (<=)
    await repo.create(_i(nombre: 'ok', actual: 20)); // ok

    final low = await repo.getLowStock();
    expect(low.map((i) => i.nombre).toSet(), {'bajo', 'justo'});
  });

  test('getByOwners acota al hato y excluye inactivos', () async {
    await repo.create(_i(nombre: 'A', owner: 'A'));
    await repo.create(_i(nombre: 'Ainactivo', owner: 'A', activo: false));
    await repo.create(_i(nombre: 'C', owner: 'C'));

    final result = await repo.getByOwners(['A']);
    expect(result.map((i) => i.nombre), ['A']);
  });
}
