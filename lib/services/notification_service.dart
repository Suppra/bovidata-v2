import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/notification_model.dart';

class NotificationService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Create a new notification
  static Future<String?> createNotification(NotificationModel notification) async {
    try {
      final docRef = await _firestore
          .collection('notifications')
          .add(notification.toFirestore());
      return docRef.id;
    } catch (e) {
      print('Error creating notification: $e');
      return null;
    }
  }

  // Get notifications for a user
  static Stream<List<NotificationModel>> getNotificationsForUser(String userId) {
    return _firestore
        .collection('notifications')
        .where('usuarioId', isEqualTo: userId)
        .orderBy('fechaCreacion', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => NotificationModel.fromFirestore(doc))
            .toList());
  }

  // Mark notification as read
  static Future<bool> markAsRead(String notificationId) async {
    try {
      await _firestore
          .collection('notifications')
          .doc(notificationId)
          .update({
        'leida': true,
        'fechaLectura': Timestamp.now(),
      });
      return true;
    } catch (e) {
      print('Error marking notification as read: $e');
      return false;
    }
  }

  // Mark all notifications as read for a user
  static Future<bool> markAllAsReadForUser(String userId) async {
    try {
      final batch = _firestore.batch();
      final notifications = await _firestore
          .collection('notifications')
          .where('usuarioId', isEqualTo: userId)
          .where('leida', isEqualTo: false)
          .get();

      for (final doc in notifications.docs) {
        batch.update(doc.reference, {
          'leida': true,
          'fechaLectura': Timestamp.now(),
        });
      }

      await batch.commit();
      return true;
    } catch (e) {
      print('Error marking all notifications as read: $e');
      return false;
    }
  }

  // Delete notification
  static Future<bool> deleteNotification(String notificationId) async {
    try {
      await _firestore
          .collection('notifications')
          .doc(notificationId)
          .delete();
      return true;
    } catch (e) {
      print('Error deleting notification: $e');
      return false;
    }
  }

  // Send notification when veterinarian adds treatment
  static Future<void> notifyTreatmentAdded({
    required String bovineId,
    required String bovineName,
    required String treatmentType,
    required String veterinarioNombre,
    required String ganaderoId,
  }) async {
    try {
      final notification = NotificationModel(
        id: '',
        titulo: 'Nuevo Tratamiento Aplicado',
        mensaje: 'El veterinario $veterinarioNombre ha aplicado un tratamiento de "$treatmentType" al bovino "$bovineName"',
        tipo: 'tratamiento',
        usuarioId: ganaderoId,
        fechaCreacion: DateTime.now(),
        prioridad: 'alta',
        iconoTipo: 'medical_services',
        datos: {
          'bovineId': bovineId,
          'bovineName': bovineName,
          'treatmentType': treatmentType,
          'veterinarioNombre': veterinarioNombre,
        },
      );

      await createNotification(notification);
    } catch (e) {
      print('Error sending treatment notification: $e');
    }
  }

  // Send notification when treatment is due
  static Future<void> notifyTreatmentDue({
    required String treatmentId,
    required String treatmentType,
    required String bovineName,
    required String userId,
    required int daysUntilDue,
  }) async {
    try {
      String titulo;
      String mensaje;
      String prioridad;

      if (daysUntilDue < 0) {
        titulo = 'Tratamiento Vencido';
        mensaje = 'El tratamiento de "$treatmentType" para "$bovineName" está vencido hace ${-daysUntilDue} días';
        prioridad = 'urgente';
      } else if (daysUntilDue == 0) {
        titulo = 'Tratamiento Vence Hoy';
        mensaje = 'El tratamiento de "$treatmentType" para "$bovineName" vence hoy';
        prioridad = 'alta';
      } else {
        titulo = 'Tratamiento Próximo a Vencer';
        mensaje = 'El tratamiento de "$treatmentType" para "$bovineName" vence en $daysUntilDue días';
        prioridad = 'normal';
      }

      final notification = NotificationModel(
        id: '',
        titulo: titulo,
        mensaje: mensaje,
        tipo: 'tratamiento',
        usuarioId: userId,
        fechaCreacion: DateTime.now(),
        prioridad: prioridad,
        iconoTipo: 'schedule',
        datos: {
          'treatmentId': treatmentId,
          'treatmentType': treatmentType,
          'bovineName': bovineName,
          'daysUntilDue': daysUntilDue,
        },
      );

      await createNotification(notification);
    } catch (e) {
      print('Error sending treatment due notification: $e');
    }
  }

  // Send notification for low inventory
  static Future<void> notifyLowInventory({
    required String itemId,
    required String itemName,
    required int currentQuantity,
    required String unit,
    required String userId,
  }) async {
    try {
      final notification = NotificationModel(
        id: '',
        titulo: currentQuantity == 0 ? 'Inventario Agotado' : 'Stock Bajo',
        mensaje: currentQuantity == 0 
            ? 'El producto "$itemName" está completamente agotado'
            : 'El producto "$itemName" tiene stock bajo ($currentQuantity $unit)',
        tipo: 'inventario',
        usuarioId: userId,
        fechaCreacion: DateTime.now(),
        prioridad: currentQuantity == 0 ? 'urgente' : 'alta',
        iconoTipo: 'inventory',
        datos: {
          'itemId': itemId,
          'itemName': itemName,
          'currentQuantity': currentQuantity,
          'unit': unit,
        },
      );

      await createNotification(notification);
    } catch (e) {
      print('Error sending low inventory notification: $e');
    }
  }

  // Send notification when bovine health status changes
  static Future<void> notifyBovineHealthChange({
    required String bovineId,
    required String bovineName,
    required String newStatus,
    required String userId,
    String? veterinarioNombre,
  }) async {
    try {
      String titulo;
      String mensaje;
      String prioridad;

      if (newStatus.toLowerCase() == 'enfermo') {
        titulo = 'Bovino Reportado Enfermo';
        mensaje = veterinarioNombre != null
            ? 'El veterinario $veterinarioNombre ha reportado que "$bovineName" está enfermo'
            : 'El bovino "$bovineName" ha sido reportado como enfermo';
        prioridad = 'alta';
      } else if (newStatus.toLowerCase() == 'sano') {
        titulo = 'Bovino Recuperado';
        mensaje = veterinarioNombre != null
            ? 'El veterinario $veterinarioNombre ha reportado que "$bovineName" se ha recuperado'
            : 'El bovino "$bovineName" ha sido reportado como sano';
        prioridad = 'normal';
      } else {
        titulo = 'Cambio de Estado del Bovino';
        mensaje = veterinarioNombre != null
            ? 'El veterinario $veterinarioNombre ha cambiado el estado de "$bovineName" a "$newStatus"'
            : 'El estado del bovino "$bovineName" ha cambiado a "$newStatus"';
        prioridad = 'normal';
      }

      final notification = NotificationModel(
        id: '',
        titulo: titulo,
        mensaje: mensaje,
        tipo: 'bovino',
        usuarioId: userId,
        fechaCreacion: DateTime.now(),
        prioridad: prioridad,
        iconoTipo: 'pets',
        datos: {
          'bovineId': bovineId,
          'bovineName': bovineName,
          'newStatus': newStatus,
          'veterinarioNombre': veterinarioNombre,
        },
      );

      await createNotification(notification);
    } catch (e) {
      print('Error sending bovine health change notification: $e');
    }
  }

  // Send notification when new bovine is registered
  static Future<void> notifyBovineRegistered({
    required String bovineId,
    required String bovineName,
    required String registeredBy,
    required List<String> notifyUsers, // Ganaderos y Veterinarios
  }) async {
    try {
      for (final userId in notifyUsers) {
        final notification = NotificationModel(
          id: '',
          titulo: 'Nuevo Bovino Registrado',
          mensaje: '$registeredBy ha registrado un nuevo bovino: "$bovineName"',
          tipo: 'bovino',
          usuarioId: userId,
          fechaCreacion: DateTime.now(),
          prioridad: 'normal',
          iconoTipo: 'pets',
          datos: {
            'bovineId': bovineId,
            'bovineName': bovineName,
            'registeredBy': registeredBy,
          },
        );

        await createNotification(notification);
      }
    } catch (e) {
      print('Error sending bovine registration notification: $e');
    }
  }

  // Send notification when bovine is deleted
  static Future<void> notifyBovineDeleted({
    required String bovineName,
    required String deletedBy,
    required List<String> notifyUsers,
  }) async {
    try {
      for (final userId in notifyUsers) {
        final notification = NotificationModel(
          id: '',
          titulo: 'Bovino Eliminado',
          mensaje: '$deletedBy ha eliminado el bovino "$bovineName" del sistema',
          tipo: 'bovino',
          usuarioId: userId,
          fechaCreacion: DateTime.now(),
          prioridad: 'alta',
          iconoTipo: 'delete',
          datos: {
            'bovineName': bovineName,
            'deletedBy': deletedBy,
          },
        );

        await createNotification(notification);
      }
    } catch (e) {
      print('Error sending bovine deletion notification: $e');
    }
  }

  // Send notification when treatment is completed
  static Future<void> notifyTreatmentCompleted({
    required String treatmentId,
    required String treatmentType,
    required String bovineName,
    required String completedBy,
    required String ganaderoId,
  }) async {
    try {
      final notification = NotificationModel(
        id: '',
        titulo: 'Tratamiento Completado',
        mensaje: '$completedBy ha completado el tratamiento de "$treatmentType" en "$bovineName"',
        tipo: 'tratamiento',
        usuarioId: ganaderoId,
        fechaCreacion: DateTime.now(),
        prioridad: 'normal',
        iconoTipo: 'check_circle',
        datos: {
          'treatmentId': treatmentId,
          'treatmentType': treatmentType,
          'bovineName': bovineName,
          'completedBy': completedBy,
        },
      );

      await createNotification(notification);
    } catch (e) {
      print('Error sending treatment completed notification: $e');
    }
  }

  // Send notification for inventory expiration warning
  static Future<void> notifyInventoryExpiring({
    required String itemId,
    required String itemName,
    required DateTime expirationDate,
    required int daysUntilExpiry,
    required List<String> notifyUsers, // Ganaderos y empleados encargados
  }) async {
    try {
      String titulo;
      String mensaje;
      String prioridad;

      if (daysUntilExpiry < 0) {
        titulo = 'Medicamento Vencido';
        mensaje = 'El medicamento "$itemName" está vencido hace ${-daysUntilExpiry} días';
        prioridad = 'urgente';
      } else if (daysUntilExpiry == 0) {
        titulo = 'Medicamento Vence Hoy';
        mensaje = 'El medicamento "$itemName" vence hoy';
        prioridad = 'alta';
      } else if (daysUntilExpiry <= 7) {
        titulo = 'Medicamento Por Vencer';
        mensaje = 'El medicamento "$itemName" vence en $daysUntilExpiry días';
        prioridad = 'alta';
      } else {
        titulo = 'Recordatorio de Vencimiento';
        mensaje = 'El medicamento "$itemName" vence en $daysUntilExpiry días';
        prioridad = 'normal';
      }

      for (final userId in notifyUsers) {
        final notification = NotificationModel(
          id: '',
          titulo: titulo,
          mensaje: mensaje,
          tipo: 'inventario',
          usuarioId: userId,
          fechaCreacion: DateTime.now(),
          prioridad: prioridad,
          iconoTipo: 'schedule',
          datos: {
            'itemId': itemId,
            'itemName': itemName,
            'expirationDate': expirationDate.toIso8601String(),
            'daysUntilExpiry': daysUntilExpiry,
          },
        );

        await createNotification(notification);
      }
    } catch (e) {
      print('Error sending inventory expiration notification: $e');
    }
  }

  // Send notification when user is assigned to bovine
  static Future<void> notifyUserAssignment({
    required String bovineId,
    required String bovineName,
    required String assignedUserId,
    required String assignedUserName,
    required String assignedBy,
    required String role, // Veterinario o Empleado
  }) async {
    try {
      final notification = NotificationModel(
        id: '',
        titulo: 'Asignación de Responsabilidad',
        mensaje: '$assignedBy te ha asignado como $role responsable del bovino "$bovineName"',
        tipo: 'asignacion',
        usuarioId: assignedUserId,
        fechaCreacion: DateTime.now(),
        prioridad: 'alta',
        iconoTipo: 'assignment',
        datos: {
          'bovineId': bovineId,
          'bovineName': bovineName,
          'assignedBy': assignedBy,
          'role': role,
        },
      );

      await createNotification(notification);
    } catch (e) {
      print('Error sending user assignment notification: $e');
    }
  }

  // Send notification for system maintenance
  static Future<void> notifySystemMaintenance({
    required String title,
    required String message,
    required DateTime scheduledTime,
    required List<String> notifyUsers, // Todos los usuarios activos
  }) async {
    try {
      for (final userId in notifyUsers) {
        final notification = NotificationModel(
          id: '',
          titulo: title,
          mensaje: message,
          tipo: 'sistema',
          usuarioId: userId,
          fechaCreacion: DateTime.now(),
          prioridad: 'normal',
          iconoTipo: 'build',
          datos: {
            'scheduledTime': scheduledTime.toIso8601String(),
            'maintenanceType': 'scheduled',
          },
        );

        await createNotification(notification);
      }
    } catch (e) {
      print('Error sending system maintenance notification: $e');
    }
  }

  // Send notification when user role changes
  static Future<void> notifyRoleChange({
    required String userId,
    required String newRole,
    required String oldRole,
    required String changedBy,
  }) async {
    try {
      final notification = NotificationModel(
        id: '',
        titulo: 'Cambio de Rol',
        mensaje: '$changedBy ha cambiado tu rol de $oldRole a $newRole',
        tipo: 'sistema',
        usuarioId: userId,
        fechaCreacion: DateTime.now(),
        prioridad: 'alta',
        iconoTipo: 'admin_panel_settings',
        datos: {
          'newRole': newRole,
          'oldRole': oldRole,
          'changedBy': changedBy,
        },
      );

      await createNotification(notification);
    } catch (e) {
      print('Error sending role change notification: $e');
    }
  }

  // Send notification for upcoming treatment reminder
  static Future<void> notifyUpcomingTreatment({
    required String treatmentId,
    required String treatmentType,
    required String bovineName,
    required DateTime scheduledDate,
    required String userId,
    required int daysUntil,
  }) async {
    try {
      String titulo;
      String mensaje;
      String prioridad;

      if (daysUntil < 0) {
        titulo = 'Tratamiento Atrasado';
        mensaje = 'El tratamiento de "$treatmentType" para "$bovineName" está atrasado ${-daysUntil} días';
        prioridad = 'urgente';
      } else if (daysUntil == 0) {
        titulo = 'Tratamiento Hoy';
        mensaje = 'Recordatorio: Aplicar "$treatmentType" a "$bovineName" hoy';
        prioridad = 'alta';
      } else if (daysUntil == 1) {
        titulo = 'Tratamiento Mañana';
        mensaje = 'Recordatorio: Aplicar "$treatmentType" a "$bovineName" mañana';
        prioridad = 'alta';
      } else {
        titulo = 'Tratamiento Próximo';
        mensaje = 'Recordatorio: Aplicar "$treatmentType" a "$bovineName" en $daysUntil días';
        prioridad = 'normal';
      }

      final notification = NotificationModel(
        id: '',
        titulo: titulo,
        mensaje: mensaje,
        tipo: 'tratamiento',
        usuarioId: userId,
        fechaCreacion: DateTime.now(),
        prioridad: prioridad,
        iconoTipo: 'schedule',
        datos: {
          'treatmentId': treatmentId,
          'treatmentType': treatmentType,
          'bovineName': bovineName,
          'scheduledDate': scheduledDate.toIso8601String(),
          'daysUntil': daysUntil,
        },
      );

      await createNotification(notification);
    } catch (e) {
      print('Error sending upcoming treatment notification: $e');
    }
  }

  // Clean old notifications (older than 30 days)
  static Future<void> cleanOldNotifications() async {
    try {
      final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
      final oldNotifications = await _firestore
          .collection('notifications')
          .where('fechaCreacion', isLessThan: Timestamp.fromDate(thirtyDaysAgo))
          .get();

      final batch = _firestore.batch();
      for (final doc in oldNotifications.docs) {
        batch.delete(doc.reference);
      }

      if (oldNotifications.docs.isNotEmpty) {
        await batch.commit();
        print('Cleaned ${oldNotifications.docs.length} old notifications');
      }
    } catch (e) {
      print('Error cleaning old notifications: $e');
    }
  }

  // Get unread notification count for user
  static Stream<int> getUnreadCountForUser(String userId) {
    return _firestore
        .collection('notifications')
        .where('usuarioId', isEqualTo: userId)
        .where('leida', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }
}