import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bovidata_new/core/services/solid_services.dart';

void main() {
  late FakeFirebaseFirestore db;
  late ConcreteNotificationService service;

  setUp(() {
    db = FakeFirebaseFirestore();
    service = ConcreteNotificationService(firestore: db);
  });

  test('sendNotification persiste una notificación para el usuario', () async {
    await service.sendNotification('u1', 'Hola', 'Mensaje', type: 'bovino', priority: 'alta');
    final snap = await db.collection('notifications').get();
    expect(snap.docs.length, 1);
    expect(snap.docs.first.data()['usuarioId'], 'u1');
    expect(snap.docs.first.data()['prioridad'], 'alta');
  });

  test('no emite notificaciones a destinatarios inválidos (admin/vacío)', () async {
    await service.sendNotification('admin', 'x', 'y');
    await service.sendNotification('', 'x', 'y');
    final snap = await db.collection('notifications').get();
    expect(snap.docs, isEmpty);
  });
}
