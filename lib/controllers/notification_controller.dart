import 'package:flutter/material.dart';
import '../services/notification_service.dart';
import '../models/notification_model.dart';

class NotificationController extends ChangeNotifier {
  List<NotificationModel> _notifications = [];
  bool _isLoading = false;
  String? _error;

  List<NotificationModel> get notifications => _notifications;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Get unread notifications count
  int get unreadCount => _notifications.where((n) => !n.leida).length;

  // Load notifications for current user
  Future<void> loadNotifications(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // For now, we'll use a stream subscription
      // In a production app, you might want to implement proper stream handling
      final stream = NotificationService.getNotificationsForUser(userId);
      
      await for (final notifications in stream.take(1)) {
        _notifications = notifications;
        _isLoading = false;
        notifyListeners();
        break;
      }
    } catch (e) {
      _error = 'Error cargando notificaciones: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      await NotificationService.markAsRead(notificationId);
      
      // Update local state
      final index = _notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        _notifications[index] = _notifications[index].copyWith(
          leida: true,
          fechaLectura: DateTime.now(),
        );
        notifyListeners();
      }
    } catch (e) {
      _error = 'Error marcando notificación como leída: $e';
      notifyListeners();
    }
  }

  // Mark all notifications as read
  Future<void> markAllAsRead(String userId) async {
    try {
      await NotificationService.markAllAsReadForUser(userId);
      
      // Update local state
      for (int i = 0; i < _notifications.length; i++) {
        if (!_notifications[i].leida) {
          _notifications[i] = _notifications[i].copyWith(
            leida: true,
            fechaLectura: DateTime.now(),
          );
        }
      }
      notifyListeners();
    } catch (e) {
      _error = 'Error marcando todas las notificaciones como leídas: $e';
      notifyListeners();
    }
  }

  // Delete notification
  Future<void> deleteNotification(String notificationId) async {
    try {
      await NotificationService.deleteNotification(notificationId);
      
      // Remove from local state
      _notifications.removeWhere((n) => n.id == notificationId);
      notifyListeners();
    } catch (e) {
      _error = 'Error eliminando notificación: $e';
      notifyListeners();
    }
  }

  // Get notifications stream for real-time updates
  Stream<List<NotificationModel>> getNotificationsStream(String userId) {
    return NotificationService.getNotificationsForUser(userId);
  }

  // Get unread count stream
  Stream<int> getUnreadCountStream(String userId) {
    return NotificationService.getUnreadCountForUser(userId);
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Refresh notifications
  Future<void> refresh(String userId) async {
    await loadNotifications(userId);
  }
}