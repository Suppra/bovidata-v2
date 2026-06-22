// Implementaciones compartidas de servicios transversales (kernel).
// Los servicios de dominio (bovinos/tratamientos/inventario) viven ahora en
// features/<x>/application.
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bovidata_new/core/interfaces/service_interface.dart';
import 'package:bovidata_new/models/notification_model.dart';

/// Servicio de notificaciones respaldado por Firestore (reemplaza el stub
/// `print()` original): los eventos de negocio persisten en `notifications`.
class ConcreteNotificationService implements INotificationService {
  final FirebaseFirestore _firestore;
  static const String _collection = 'notifications';

  ConcreteNotificationService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<void> sendNotification(String userId, String title, String message,
      {String? type, String? priority}) async {
    if (userId.trim().isEmpty || userId == 'admin') return;
    try {
      final docRef = _firestore.collection(_collection).doc();
      final notification = NotificationModel(
        id: docRef.id,
        titulo: title,
        mensaje: message,
        tipo: type ?? 'general',
        usuarioId: userId,
        fechaCreacion: DateTime.now(),
        prioridad: priority ?? 'normal',
      );
      await docRef.set(notification.toFirestore());
    } catch (_) {
      // Best-effort: no debe romper el flujo principal.
    }
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    try {
      await _firestore.collection(_collection).doc(notificationId).update({
        'leida': true,
        'fechaLectura': FieldValue.serverTimestamp(),
      });
    } catch (_) {}
  }

  @override
  Stream<List<NotificationModel>> getNotificationsForUser(String userId) {
    return _firestore
        .collection(_collection)
        .where('usuarioId', isEqualTo: userId)
        .orderBy('fechaCreacion', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => NotificationModel.fromFirestore(doc))
            .toList());
  }
}

class ConcreteValidationService implements IValidationService {
  @override
  bool validateEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  @override
  bool validatePhone(String phone) {
    return RegExp(r'^[\+]?[1-9][\d]{0,15}$').hasMatch(phone);
  }

  @override
  bool validateRequired(String? value) {
    return value != null && value.trim().isNotEmpty;
  }

  @override
  String? validateField(String? value, List<String> rules) {
    for (final rule in rules) {
      switch (rule) {
        case 'required':
          if (!validateRequired(value)) return 'Este campo es requerido';
          break;
        case 'email':
          if (value != null && !validateEmail(value)) {
            return 'Ingrese un email válido';
          }
          break;
        case 'phone':
          if (value != null && !validatePhone(value)) {
            return 'Ingrese un teléfono válido';
          }
          break;
      }
    }
    return null;
  }
}
