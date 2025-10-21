// Servicio moderno para notificaciones usando arquitectura SOLID
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/notification_model.dart';

/// Servicio moderno para notificaciones usando principios SOLID
/// Aplica Single Responsibility, Open/Closed, Interface Segregation
class SolidNotificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  /// Obtener todas las notificaciones del usuario
  Future<List<NotificationModel>> getNotifications(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('notifications')
          .where('usuarioId', isEqualTo: userId)
          .orderBy('fechaCreacion', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => NotificationModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Error al obtener notificaciones: $e');
    }
  }

  /// Crear una nueva notificación
  Future<void> createNotification(NotificationModel notification) async {
    try {
      final docRef = _firestore.collection('notifications').doc();
      final notificationWithId = NotificationModel(
        id: docRef.id,
        titulo: notification.titulo,
        mensaje: notification.mensaje,
        tipo: notification.tipo,
        usuarioId: notification.usuarioId,
        leida: notification.leida,
        fechaCreacion: notification.fechaCreacion,
        fechaLectura: notification.fechaLectura,
        accionUrl: notification.accionUrl,
        datos: notification.datos,
        iconoTipo: notification.iconoTipo,
        prioridad: notification.prioridad,
      );

      await docRef.set(notificationWithId.toFirestore());
    } catch (e) {
      throw Exception('Error al crear notificación: $e');
    }
  }

  /// Marcar notificación como leída
  Future<void> markAsRead(String notificationId) async {
    try {
      await _firestore
          .collection('notifications')
          .doc(notificationId)
          .update({
        'leida': true,
        'fechaLectura': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Error al marcar como leída: $e');
    }
  }

  /// Marcar todas las notificaciones como leídas
  Future<void> markAllAsRead(String userId) async {
    try {
      final batch = _firestore.batch();
      final querySnapshot = await _firestore
          .collection('notifications')
          .where('usuarioId', isEqualTo: userId)
          .where('leida', isEqualTo: false)
          .get();

      for (final doc in querySnapshot.docs) {
        batch.update(doc.reference, {
          'leida': true,
          'fechaLectura': FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Error al marcar todas como leídas: $e');
    }
  }

  /// Eliminar notificación
  Future<void> deleteNotification(String notificationId) async {
    try {
      await _firestore
          .collection('notifications')
          .doc(notificationId)
          .delete();
    } catch (e) {
      throw Exception('Error al eliminar notificación: $e');
    }
  }

  /// Stream de notificaciones en tiempo real
  Stream<List<NotificationModel>> getNotificationsStream(String userId) {
    return _firestore
        .collection('notifications')
        .where('usuarioId', isEqualTo: userId)
        .orderBy('fechaCreacion', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => NotificationModel.fromFirestore(doc))
            .toList());
  }

  /// Obtener notificaciones no leídas
  Future<List<NotificationModel>> getUnreadNotifications(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('notifications')
          .where('usuarioId', isEqualTo: userId)
          .where('leida', isEqualTo: false)
          .orderBy('fechaCreacion', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => NotificationModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Error al obtener notificaciones no leídas: $e');
    }
  }

  /// Obtener notificaciones por tipo
  Future<List<NotificationModel>> getNotificationsByType(
    String userId, 
    String tipo
  ) async {
    try {
      final querySnapshot = await _firestore
          .collection('notifications')
          .where('usuarioId', isEqualTo: userId)
          .where('tipo', isEqualTo: tipo)
          .orderBy('fechaCreacion', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => NotificationModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Error al obtener notificaciones por tipo: $e');
    }
  }

  /// Obtener conteo de notificaciones no leídas
  Future<int> getUnreadCount(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('notifications')
          .where('usuarioId', isEqualTo: userId)
          .where('leida', isEqualTo: false)
          .get();

      return querySnapshot.size;
    } catch (e) {
      throw Exception('Error al obtener conteo no leído: $e');
    }
  }

  /// Limpiar notificaciones antiguas (más de 30 días)
  Future<void> cleanOldNotifications(String userId) async {
    try {
      final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
      final batch = _firestore.batch();
      
      final querySnapshot = await _firestore
          .collection('notifications')
          .where('usuarioId', isEqualTo: userId)
          .where('fechaCreacion', isLessThan: Timestamp.fromDate(thirtyDaysAgo))
          .get();

      for (final doc in querySnapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Error al limpiar notificaciones antiguas: $e');
    }
  }
}