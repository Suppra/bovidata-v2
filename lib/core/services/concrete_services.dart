// Implementaciones concretas de servicios siguiendo principios SOLID
import '../interfaces/service_interface.dart';
import '../../models/notification_model.dart';
import '../../models/activity_model.dart';
import '../../services/notification_service.dart';
import '../../services/activity_service.dart';

// Single Responsibility Principle - Cada servicio tiene una responsabilidad única
// Dependency Inversion Principle - Implementamos abstracciones

class ConcreteNotificationService implements INotificationService {
  @override
  Future<void> sendNotification(
    String userId,
    String title,
    String message, {
    String? type,
    String? priority,
  }) async {
    final notification = NotificationModel(
      id: '',
      titulo: title,
      mensaje: message,
      tipo: type ?? 'general',
      usuarioId: userId,
      fechaCreacion: DateTime.now(),
      prioridad: priority ?? 'media',
      iconoTipo: 'info',
      datos: {},
    );
    
    await NotificationService.createNotification(notification);
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    await NotificationService.markAsRead(notificationId);
  }

  @override
  Stream<List<NotificationModel>> getNotificationsForUser(String userId) {
    return NotificationService.getNotificationsForUser(userId);
  }
}

class ConcreteActivityService implements IActivityService {
  final ActivityService _activityService = ActivityService();

  @override
  Future<void> logActivity(
    String type,
    String description,
    String entityId,
    String userId,
  ) async {
    final activity = ActivityModel(
      id: '',
      tipo: type,
      descripcion: description,
      entidadId: entityId,
      entidadNombre: description,
      usuarioId: userId,
      fecha: DateTime.now(),
    );
    
    await _activityService.logActivity(activity);
  }

  @override
  Future<List<ActivityModel>> getActivitiesByUser(String userId) async {
    return await _activityService.getRecentActivities(userId: userId);
  }

  @override
  Future<List<ActivityModel>> getActivitiesByEntity(String entityId) async {
    // ActivityService no tiene este método, usar getRecentActivities y filtrar
    final activities = await _activityService.getRecentActivities();
    return activities.where((activity) => activity.entidadId == entityId).toList();
  }
}

class ConcreteValidationService implements IValidationService {
  @override
  bool validateEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  @override
  bool validatePhone(String phone) {
    final phoneRegex = RegExp(r'^[\+]?[1-9][\d]{0,15}$');
    return phoneRegex.hasMatch(phone.replaceAll(RegExp(r'[\s\-\(\)]'), ''));
  }

  @override
  bool validateRequired(String? value) {
    return value != null && value.trim().isNotEmpty;
  }

  @override
  String? validateField(String? value, List<String> rules) {
    if (rules.contains('required') && !validateRequired(value)) {
      return 'Este campo es requerido';
    }
    
    if (value != null && value.isNotEmpty) {
      if (rules.contains('email') && !validateEmail(value)) {
        return 'Ingrese un email válido';
      }
      
      if (rules.contains('phone') && !validatePhone(value)) {
        return 'Ingrese un teléfono válido';
      }
      
      for (String rule in rules) {
        if (rule.startsWith('min:')) {
          final minLength = int.tryParse(rule.split(':')[1]) ?? 0;
          if (value.length < minLength) {
            return 'Mínimo $minLength caracteres';
          }
        }
        
        if (rule.startsWith('max:')) {
          final maxLength = int.tryParse(rule.split(':')[1]) ?? 0;
          if (value.length > maxLength) {
            return 'Máximo $maxLength caracteres';
          }
        }
      }
    }
    
    return null;
  }
}

// Implementación mock para FileService (placeholder)
class MockFileService implements IFileService {
  @override
  Future<String?> uploadImage(String path, List<int> bytes) async {
    // Implementación mock - en producción usar Firebase Storage
    await Future.delayed(const Duration(milliseconds: 500));
    return 'https://mockurl.com/$path';
  }

  @override
  Future<bool> deleteImage(String url) async {
    // Implementación mock
    await Future.delayed(const Duration(milliseconds: 300));
    return true;
  }

  @override
  Future<List<int>?> downloadImage(String url) async {
    // Implementación mock
    await Future.delayed(const Duration(milliseconds: 400));
    return []; // Retornar bytes de imagen
  }
}
