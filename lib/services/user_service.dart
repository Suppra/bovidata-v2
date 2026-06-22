import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants/app_constants.dart';

class UserService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get all users by role
  static Future<List<String>> getUserIdsByRole(String role) async {
    try {
      final snapshot = await _firestore
          .collection(AppConstants.usersCollection)
          .where('rol', isEqualTo: role)
          .where('activo', isEqualTo: true)
          .get();

      return snapshot.docs.map((doc) => doc.id).toList();
    } catch (e) {
      print('Error getting users by role: $e');
      return [];
    }
  }

  // Get all active users except the current user
  static Future<List<String>> getAllActiveUsersExcept(String excludeUserId) async {
    try {
      final snapshot = await _firestore
          .collection(AppConstants.usersCollection)
          .where('activo', isEqualTo: true)
          .get();

      return snapshot.docs
          .where((doc) => doc.id != excludeUserId)
          .map((doc) => doc.id)
          .toList();
    } catch (e) {
      print('Error getting all active users: $e');
      return [];
    }
  }

  // Get users who should be notified about bovine operations (Ganaderos and Veterinarios)
  static Future<List<String>> getBovineNotificationUsers() async {
    try {
      final ganaderos = await getUserIdsByRole(AppConstants.roleGanadero);
      final veterinarios = await getUserIdsByRole(AppConstants.roleVeterinario);
      
      return [...ganaderos, ...veterinarios];
    } catch (e) {
      print('Error getting bovine notification users: $e');
      return [];
    }
  }

  // Get users who should be notified about inventory (Ganaderos and Empleados)
  static Future<List<String>> getInventoryNotificationUsers() async {
    try {
      final ganaderos = await getUserIdsByRole(AppConstants.roleGanadero);
      final empleados = await getUserIdsByRole(AppConstants.roleEmpleado);
      
      return [...ganaderos, ...empleados];
    } catch (e) {
      print('Error getting inventory notification users: $e');
      return [];
    }
  }

  // Get all users for system-wide notifications
  static Future<List<String>> getAllActiveUsers() async {
    try {
      final snapshot = await _firestore
          .collection(AppConstants.usersCollection)
          .where('activo', isEqualTo: true)
          .get();

      return snapshot.docs.map((doc) => doc.id).toList();
    } catch (e) {
      print('Error getting all active users: $e');
      return [];
    }
  }

  // Get user information by ID
  static Future<Map<String, dynamic>?> getUserInfo(String userId) async {
    try {
      final doc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .get();

      if (doc.exists) {
        return doc.data();
      }
      return null;
    } catch (e) {
      print('Error getting user info: $e');
      return null;
    }
  }

  // Get owner of a bovine
  static Future<String?> getBovineOwner(String bovineId) async {
    try {
      final doc = await _firestore
          .collection(AppConstants.bovinesCollection)
          .doc(bovineId)
          .get();

      if (doc.exists) {
        return doc.data()?['propietarioId'];
      }
      return null;
    } catch (e) {
      print('Error getting bovine owner: $e');
      return null;
    }
  }
}