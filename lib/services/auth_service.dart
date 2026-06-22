import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../constants/app_constants.dart';
import 'notification_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Get current user stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Get current user data
  Future<UserModel?> getCurrentUserData() async {
    final user = currentUser;
    if (user == null) return null;

    try {
      final doc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(user.uid)
          .get();
      
      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }
    } catch (e) {
      // Error handled silently in production
    }
    return null;
  }

  // Sign in with email and password
  Future<UserCredential?> signInWithEmailPassword(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return credential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'Error inesperado durante el inicio de sesión';
    }
  }

  // Register with email and password
  Future<UserCredential?> registerWithEmailPassword(
    String email,
    String password,
    UserModel userData,
  ) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      if (credential.user != null) {
        // Create user document in Firestore
        await _createUserDocument(credential.user!.uid, userData);
        
        // Send email verification
        await credential.user!.sendEmailVerification();
      }

      return credential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'Error inesperado durante el registro';
    }
  }

  // Create user document in Firestore
  Future<void> _createUserDocument(String uid, UserModel userData) async {
    try {
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(uid)
          .set(userData.copyWith(id: uid).toFirestore());
    } catch (e) {
      throw 'Error creando perfil de usuario';
    }
  }

  // Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'Error enviando email de recuperación';
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw 'Error cerrando sesión';
    }
  }

  // Update user profile
  Future<void> updateUserProfile(UserModel userData) async {
    final user = currentUser;
    if (user == null) throw 'Usuario no autenticado';

    try {
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(user.uid)
          .update(userData.toFirestore());
    } catch (e) {
      throw 'Error actualizando perfil';
    }
  }

  // Update password
  Future<void> updatePassword(String currentPassword, String newPassword) async {
    final user = currentUser;
    if (user == null) throw 'Usuario no autenticado';

    try {
      // Re-authenticate user
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(credential);

      // Update password
      await user.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'Error actualizando contraseña';
    }
  }

  // Update email
  Future<void> updateEmail(String newEmail) async {
    final user = currentUser;
    if (user == null) throw 'Usuario no autenticado';

    try {
      await user.verifyBeforeUpdateEmail(newEmail.trim());
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'Error actualizando email';
    }
  }

  // Delete account
  Future<void> deleteAccount(String password) async {
    final user = currentUser;
    if (user == null) throw 'Usuario no autenticado';

    try {
      // Re-authenticate user
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );
      await user.reauthenticateWithCredential(credential);

      // Delete user document
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(user.uid)
          .delete();

      // Delete user account
      await user.delete();
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'Error eliminando cuenta';
    }
  }

  // Check if email is verified
  bool get isEmailVerified => currentUser?.emailVerified ?? false;

  // Send email verification
  Future<void> sendEmailVerification() async {
    final user = currentUser;
    if (user == null) throw 'Usuario no autenticado';

    try {
      if (!user.emailVerified) {
        await user.sendEmailVerification();
      }
    } catch (e) {
      throw 'Error enviando verificación de email';
    }
  }

  // Handle Firebase Auth exceptions
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No se encontró una cuenta con este email';
      case 'wrong-password':
        return 'Contraseña incorrecta';
      case 'email-already-in-use':
        return 'Este email ya está registrado';
      case 'weak-password':
        return 'La contraseña es muy débil';
      case 'invalid-email':
        return 'El email no es válido';
      case 'user-disabled':
        return 'Esta cuenta ha sido deshabilitada';
      case 'too-many-requests':
        return 'Demasiados intentos. Intenta más tarde';
      case 'network-request-failed':
        return 'Error de conexión. Verifica tu internet';
      case 'requires-recent-login':
        return 'Por seguridad, debes iniciar sesión nuevamente';
      default:
        return 'Error de autenticación: ${e.message}';
    }
  }

  // Validate user role access
  Future<bool> validateRoleAccess(String requiredRole) async {
    final userData = await getCurrentUserData();
    if (userData == null) return false;

    return userData.rol == requiredRole;
  }

  // Check if user has any of the specified roles
  Future<bool> hasAnyRole(List<String> roles) async {
    final userData = await getCurrentUserData();
    if (userData == null) return false;

    return roles.contains(userData.rol);
  }

  // Update user role (only for admin operations)
  Future<void> updateUserRole(String userId, String newRole, String changedByUserId) async {
    try {
      // Get current user data to compare roles
      final userDoc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .get();
      
      if (!userDoc.exists) throw 'Usuario no encontrado';
      
      final currentUserData = UserModel.fromFirestore(userDoc);
      final oldRole = currentUserData.rol;
      
      // Update the role
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .update({
        'rol': newRole,
        'fechaActualizacion': Timestamp.now(),
      });
      
      // Get information about who made the change
      final changedByDoc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(changedByUserId)
          .get();
      
      final changedByName = changedByDoc.data()?['nombre'] ?? 'Administrador';
      
      // Send notification to the user whose role was changed
      await NotificationService.notifyRoleChange(
        userId: userId,
        newRole: newRole,
        oldRole: oldRole,
        changedBy: changedByName,
      );
      
    } catch (e) {
      throw 'Error actualizando rol de usuario: $e';
    }
  }
}