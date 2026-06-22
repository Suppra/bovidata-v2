// Capa de DOMINIO — Puerto de autenticación. La infraestructura lo implementa.
// Mantiene los tipos de Firebase fuera de las capas superiores.
import 'package:bovidata_new/models/user_model.dart';

abstract interface class AuthRepository {
  /// Emite `true` cuando hay sesión activa, `false` cuando no.
  Stream<bool> authStateChanges();

  /// Indica si el correo del usuario actual está verificado.
  bool get isEmailVerified;

  /// Perfil del usuario autenticado (o `null`).
  Future<UserModel?> getCurrentUserData();

  /// Inicia sesión. Lanza un mensaje de error (String) si falla.
  Future<void> signIn(String email, String password);

  /// Registra un usuario y crea su perfil. Lanza un mensaje si falla.
  Future<void> register(String email, String password, UserModel userData);

  Future<void> sendPasswordResetEmail(String email);
  Future<void> signOut();
  Future<void> updateUserProfile(UserModel userData);
  Future<void> updatePassword(String currentPassword, String newPassword);
  Future<void> updateEmail(String newEmail);
  Future<void> sendEmailVerification();
  Future<void> deleteAccount(String password);

  Future<bool> validateRoleAccess(String requiredRole);
  Future<bool> hasAnyRole(List<String> roles);
}
