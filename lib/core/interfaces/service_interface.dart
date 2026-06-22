// Dependency Inversion Principle (DIP) - Abstracciones para servicios
import '../../models/notification_model.dart';
import '../../models/activity_model.dart';

abstract class INotificationService {
  Future<void> sendNotification(String userId, String title, String message, {String? type, String? priority});
  Future<void> markAsRead(String notificationId);
  Stream<List<NotificationModel>> getNotificationsForUser(String userId);
}

abstract class IActivityService {
  Future<void> logActivity(String type, String description, String entityId, String userId);
  Future<List<ActivityModel>> getActivitiesByUser(String userId);
  Future<List<ActivityModel>> getActivitiesByEntity(String entityId);
}

abstract class IValidationService {
  bool validateEmail(String email);
  bool validatePhone(String phone);
  bool validateRequired(String? value);
  String? validateField(String? value, List<String> rules);
}

abstract class IFileService {
  Future<String?> uploadImage(String path, List<int> bytes);
  Future<bool> deleteImage(String url);
  Future<List<int>?> downloadImage(String url);
}
