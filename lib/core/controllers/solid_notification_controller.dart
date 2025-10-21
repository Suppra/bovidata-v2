// Controller moderno para notificaciones usando arquitectura SOLID
import 'dart:async';
import 'package:flutter/material.dart';
import '../locator/service_locator.dart';
import '../services/solid_notification_service.dart';
import '../../models/notification_model.dart';
import '../../models/bovine_model.dart';
import '../../models/treatment_model.dart';
import '../../models/inventory_model.dart';

/// Controller moderno para notificaciones usando arquitectura SOLID
/// Reemplaza NotificationController legacy con principios SOLID aplicados
class SolidNotificationController extends ChangeNotifier {
  final SolidNotificationService _notificationService = ServiceLocator.notificationService;
  
  List<NotificationModel> _notifications = [];
  bool _isLoading = false;
  String? _errorMessage;
  StreamSubscription<List<NotificationModel>>? _notificationsSubscription;

  // Getters
  List<NotificationModel> get notifications => _notifications;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  
  // Estadísticas usando principios SOLID
  List<NotificationModel> get unreadNotifications => _notifications.where((n) => !n.leida).toList();
  List<NotificationModel> get criticalNotifications => _notifications.where((n) => n.tipo == 'crítica').toList();
  List<NotificationModel> get medicationReminders => _notifications.where((n) => n.tipo == 'medicamento').toList();
  List<NotificationModel> get healthAlerts => _notifications.where((n) => n.tipo == 'salud').toList();
  List<NotificationModel> get inventoryAlerts => _notifications.where((n) => n.tipo == 'inventario').toList();
  
  int get unreadCount => unreadNotifications.length;
  int get criticalCount => criticalNotifications.length;

  /// Inicializar controller usando servicios SOLID
  void initialize(String userId) {
    loadNotifications(userId);
  }

  /// Cargar notificaciones usando servicio SOLID
  Future<void> loadNotifications(String userId) async {
    _setLoading(true);
    _clearError();
    
    try {
      _notifications = await _notificationService.getNotifications(userId);
      _sortNotificationsByPriority();
    } catch (e) {
      _setError('Error al cargar notificaciones: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Crear notificación usando servicio SOLID
  Future<bool> createNotification(NotificationModel notification) async {
    _setLoading(true);
    _clearError();
    
    try {
      await _notificationService.createNotification(notification);
      await loadNotifications(notification.usuarioId); // Recargar lista
      return true;
    } catch (e) {
      _setError('Error al crear notificación: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Marcar notificación como leída
  Future<bool> markAsRead(String notificationId) async {
    _clearError();
    
    try {
      await _notificationService.markAsRead(notificationId);
      
      // Actualizar localmente
      final index = _notifications.indexWhere((n) => n.id == notificationId);
      if (index >= 0) {
        _notifications[index] = _notifications[index].copyWith(leida: true);
        notifyListeners();
      }
      
      return true;
    } catch (e) {
      _setError('Error al marcar notificación como leída: $e');
      return false;
    }
  }

  /// Marcar todas como leídas
  Future<bool> markAllAsRead(String userId) async {
    _setLoading(true);
    _clearError();
    
    try {
      await _notificationService.markAllAsRead(userId);
      
      // Actualizar localmente
      _notifications = _notifications.map((n) => n.copyWith(leida: true)).toList();
      notifyListeners();
      
      return true;
    } catch (e) {
      _setError('Error al marcar todas como leídas: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Eliminar notificación
  Future<bool> deleteNotification(String notificationId) async {
    _clearError();
    
    try {
      await _notificationService.deleteNotification(notificationId);
      
      // Remover localmente
      _notifications.removeWhere((n) => n.id == notificationId);
      notifyListeners();
      
      return true;
    } catch (e) {
      _setError('Error al eliminar notificación: $e');
      return false;
    }
  }

  /// Stream de notificaciones en tiempo real
  Stream<List<NotificationModel>> getNotificationsStream(String userId) {
    return _notificationService.getNotificationsStream(userId);
  }

  /// Suscribirse a notificaciones en tiempo real
  void subscribeToNotifications(String userId) {
    _notificationsSubscription?.cancel();
    _notificationsSubscription = getNotificationsStream(userId).listen(
      (notifications) {
        _notifications = notifications;
        _sortNotificationsByPriority();
        notifyListeners();
      },
      onError: (error) {
        _setError('Error en stream de notificaciones: $error');
      },
    );
  }

  /// Crear notificaciones automáticas basadas en datos
  Future<void> generateAutoNotifications({
    required String userId,
    required List<BovineModel> bovines,
    required List<TreatmentModel> treatments,
    required List<InventoryModel> inventory,
  }) async {
    final notifications = <NotificationModel>[];
    final now = DateTime.now();

    // Notificaciones de tratamientos pendientes
    for (final treatment in treatments) {
      if (treatment.proximaAplicacion != null) {
        final daysDiff = treatment.proximaAplicacion!.difference(now).inDays;
        
        if (daysDiff <= 1 && daysDiff >= 0) {
          notifications.add(NotificationModel(
            id: '',
            usuarioId: userId,
            tipo: 'medicamento',
            titulo: 'Tratamiento Próximo',
            mensaje: 'El tratamiento ${treatment.nombre} debe aplicarse ${daysDiff == 0 ? 'hoy' : 'mañana'}',
            fechaCreacion: now,
            leida: false,
            prioridad: daysDiff == 0 ? 'alta' : 'media',
            datos: {'treatmentId': treatment.id, 'bovineId': treatment.bovineId},
          ));
        }
      }
    }

    // Notificaciones de inventario bajo
    for (final item in inventory) {
      if (item.cantidadActual <= item.cantidadMinima) {
        notifications.add(NotificationModel(
          id: '',
          usuarioId: userId,
          tipo: 'inventario',
          titulo: 'Stock Bajo',
          mensaje: 'El item ${item.nombre} tiene stock bajo (${item.cantidadActual}/${item.cantidadMinima})',
          fechaCreacion: now,
          leida: false,
          prioridad: item.cantidadActual == 0 ? 'crítica' : 'media',
          datos: {'inventoryId': item.id},
        ));
      }

      // Notificaciones de vencimiento
      if (item.fechaVencimiento != null) {
        final daysDiff = item.fechaVencimiento!.difference(now).inDays;
        
        if (daysDiff <= 7 && daysDiff >= 0) {
          notifications.add(NotificationModel(
            id: '',
            usuarioId: userId,
            tipo: 'inventario',
            titulo: 'Producto por Vencer',
            mensaje: 'El item ${item.nombre} vence ${daysDiff == 0 ? 'hoy' : 'en $daysDiff días'}',
            fechaCreacion: now,
            leida: false,
            prioridad: daysDiff <= 2 ? 'alta' : 'media',
            datos: {'inventoryId': item.id},
          ));
        }
      }
    }

    // Notificaciones de salud animal
    for (final bovine in bovines) {
      if (bovine.estado == 'Enfermo') {
        notifications.add(NotificationModel(
          id: '',
          usuarioId: userId,
          tipo: 'salud',
          titulo: 'Animal Enfermo',
          mensaje: 'El bovino ${bovine.nombre} (${bovine.numeroIdentificacion}) requiere atención médica',
          fechaCreacion: now,
          leida: false,
          prioridad: 'alta',
          datos: {'bovineId': bovine.id},
        ));
      }
    }

    // Crear todas las notificaciones
    for (final notification in notifications) {
      await createNotification(notification);
    }
  }

  /// Refrescar notificaciones
  Future<void> refresh(String userId) async {
    await loadNotifications(userId);
  }

  /// Filtrar notificaciones por tipo
  List<NotificationModel> filterByType(String type) {
    return _notifications.where((n) => n.tipo == type).toList();
  }

  /// Filtrar notificaciones por prioridad
  List<NotificationModel> filterByPriority(String priority) {
    return _notifications.where((n) => n.prioridad == priority).toList();
  }

  /// Ordenar notificaciones por prioridad
  void _sortNotificationsByPriority() {
    _notifications.sort((a, b) {
      // Primero por leída/no leída
      if (a.leida != b.leida) {
        return a.leida ? 1 : -1;
      }
      
      // Luego por prioridad
      const priorityOrder = {'crítica': 0, 'alta': 1, 'media': 2, 'baja': 3};
      final priorityA = priorityOrder[a.prioridad] ?? 3;
      final priorityB = priorityOrder[b.prioridad] ?? 3;
      
      if (priorityA != priorityB) {
        return priorityA.compareTo(priorityB);
      }
      
      // Finalmente por fecha (más reciente primero)
      return b.fechaCreacion.compareTo(a.fechaCreacion);
    });
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  /// Limpiar error
  void clearError() {
    _clearError();
    notifyListeners();
  }

  @override
  void dispose() {
    _notificationsSubscription?.cancel();
    super.dispose();
  }
}