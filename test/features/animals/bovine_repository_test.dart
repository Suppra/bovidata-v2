import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bovidata_new/models/bovine_model.dart';
import 'package:bovidata_new/features/animals/infrastructure/repositories/bovine_repository_impl.dart';

BovineModel _bovine({
  String nombre = 'Lola',
  String owner = 'owner1',
  String estado = 'Sano',
  bool activo = true,
  DateTime? creado,
}) {
  return BovineModel.empty().copyWith(
    nombre: nombre,
    raza: 'Holstein',
    propietarioId: owner,
    estado: estado,
    activo: activo,
    fechaCreacion: creado ?? DateTime(2026),
  );
}

void main() {
  late FakeFirebaseFirestore db;
  late BovineRepository repo;

  setUp(() {
    db = FakeFirebaseFirestore();
    repo = BovineRepository(firestore: db);
  });

  test('create devuelve id y getById lo recupera', () async {
    final id = await repo.create(_bovine(nombre: 'Manchas'));
    expect(id, isNotEmpty);
    final found = await repo.getById(id);
    expect(found, isNotNull);
    expect(found!.nombre, 'Manchas');
  });

  test('getByOwner filtra por propietario y excluye inactivos (borrado lógico)',
      () async {
    await repo.create(_bovine(owner: 'A', nombre: 'A1'));
    await repo.create(_bovine(owner: 'A', nombre: 'A2', activo: false));
    await repo.create(_bovine(owner: 'B', nombre: 'B1'));

    final result = await repo.getByOwner('A');
    expect(result.map((b) => b.nombre), ['A1']); // A2 inactivo excluido, B1 ajeno
  });

  test('getByOwners (scoping por hato) une varios dueños y ordena por fecha',
      () async {
    await repo.create(_bovine(owner: 'A', nombre: 'viejo', creado: DateTime(2025)));
    await repo.create(_bovine(owner: 'B', nombre: 'nuevo', creado: DateTime(2026, 6)));
    await repo.create(_bovine(owner: 'C', nombre: 'ajeno'));

    final result = await repo.getByOwners(['A', 'B']);
    expect(result.map((b) => b.nombre), ['nuevo', 'viejo']); // desc por fecha, sin C
  });

  test('getByOwners con lista vacía devuelve vacío sin consultar', () async {
    await repo.create(_bovine(owner: 'A'));
    expect(await repo.getByOwners([]), isEmpty);
  });

  test('update modifica y delete elimina', () async {
    final id = await repo.create(_bovine(nombre: 'Pre'));
    final ok = await repo.update(id, _bovine(nombre: 'Post'));
    expect(ok, isTrue);
    expect((await repo.getById(id))!.nombre, 'Post');

    expect(await repo.delete(id), isTrue);
    expect(await repo.getById(id), isNull);
  });

  test('getByStatus filtra por estado', () async {
    await repo.create(_bovine());
    await repo.create(_bovine(estado: 'Enfermo'));
    final enfermos = await repo.getByStatus('Enfermo');
    expect(enfermos.length, 1);
    expect(enfermos.first.estado, 'Enfermo');
  });
}
