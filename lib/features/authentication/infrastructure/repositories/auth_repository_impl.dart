// Capa de INFRAESTRUCTURA — implementación del puerto AuthRepository sobre
// Firebase Auth + Firestore. Es el único punto que conoce los tipos de Firebase.
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bovidata_new/models/user_model.dart';
import 'package:bovidata_new/constants/app_constants.dart';
import 'package:bovidata_new/features/authentication/domain/ports/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  AuthRepositoryImpl({FirebaseAuth? auth, FirebaseFirestore? firestore})
      : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Stream<bool> authStateChanges() =>
      _auth.authStateChanges().map((user) => user != null);

  @override
  bool get isEmailVerified => _auth.currentUser?.emailVerified ?? false;

  @override
  Future<UserModel?> getCurrentUserData() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    try {
      final doc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(user.uid)
          .get();
      if (doc.exists) return UserModel.fromFirestore(doc);
    } catch (_) {
      // Error silenciado en producción.
    }
    return null;
  }

  @override
  Future<void> signIn(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (_) {
      throw 'Error inesperado durante el inicio de sesión';
    }
  }

  @override
  Future<void> register(String email, String password, UserModel userData) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = credential.user;
      if (user != null) {
        await _createUserDocument(user.uid, userData);
        await user.sendEmailVerification();
      }
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (_) {
      throw 'Error inesperado durante el registro';
    }
  }

  Future<void> _createUserDocument(String uid, UserModel userData) async {
    try {
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(uid)
          .set(userData.copyWith(id: uid).toFirestore());
    } catch (_) {
      throw 'Error creando perfil de usuario';
    }
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (_) {
      throw 'Error enviando email de recuperación';
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (_) {
      throw 'Error cerrando sesión';
    }
  }

  @override
  Future<void> updateUserProfile(UserModel userData) async {
    final user = _auth.currentUser;
    if (user == null) throw 'Usuario no autenticado';
    try {
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(user.uid)
          .update(userData.toFirestore());
    } catch (_) {
      throw 'Error actualizando perfil';
    }
  }

  @override
  Future<void> updatePassword(String currentPassword, String newPassword) async {
    final user = _auth.currentUser;
    if (user == null) throw 'Usuario no autenticado';
    try {
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (_) {
      throw 'Error actualizando contraseña';
    }
  }

  @override
  Future<void> updateEmail(String newEmail) async {
    final user = _auth.currentUser;
    if (user == null) throw 'Usuario no autenticado';
    try {
      await user.verifyBeforeUpdateEmail(newEmail.trim());
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (_) {
      throw 'Error actualizando email';
    }
  }

  @override
  Future<void> deleteAccount(String password) async {
    final user = _auth.currentUser;
    if (user == null) throw 'Usuario no autenticado';
    try {
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );
      await user.reauthenticateWithCredential(credential);
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(user.uid)
          .delete();
      await user.delete();
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (_) {
      throw 'Error eliminando cuenta';
    }
  }

  @override
  Future<void> sendEmailVerification() async {
    final user = _auth.currentUser;
    if (user == null) throw 'Usuario no autenticado';
    try {
      if (!user.emailVerified) await user.sendEmailVerification();
    } catch (_) {
      throw 'Error enviando verificación de email';
    }
  }

  @override
  Future<bool> validateRoleAccess(String requiredRole) async {
    final userData = await getCurrentUserData();
    return userData?.rol == requiredRole;
  }

  @override
  Future<bool> hasAnyRole(List<String> roles) async {
    final userData = await getCurrentUserData();
    if (userData == null) return false;
    return roles.contains(userData.rol);
  }

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
}
