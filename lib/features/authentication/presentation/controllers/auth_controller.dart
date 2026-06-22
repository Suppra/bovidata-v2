// Capa de PRESENTACIÓN — estado de autenticación (Provider/ChangeNotifier).
// Depende del puerto AuthRepository (no de Firebase directamente).
import 'package:flutter/material.dart';
import 'package:bovidata_new/models/user_model.dart';
import 'package:bovidata_new/constants/app_constants.dart';
import 'package:bovidata_new/features/authentication/domain/ports/auth_repository.dart';
import 'package:bovidata_new/features/authentication/infrastructure/repositories/auth_repository_impl.dart';

class AuthController extends ChangeNotifier {
  final AuthRepository _authService;

  AuthController({AuthRepository? authRepository})
      : _authService = authRepository ?? AuthRepositoryImpl() {
    _initAuthListener();
  }

  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _currentUser != null;
  bool get isEmailVerified => _authService.isEmailVerified;

  // Role checkers
  bool get isGanadero => _currentUser?.rol == AppConstants.roleGanadero;
  bool get isVeterinario => _currentUser?.rol == AppConstants.roleVeterinario;
  bool get isEmpleado => _currentUser?.rol == AppConstants.roleEmpleado;

  // Initialize auth state listener
  void _initAuthListener() {
    _authService.authStateChanges().listen((signedIn) async {
      if (signedIn) {
        await _loadUserData();
      } else {
        _currentUser = null;
        notifyListeners();
      }
    });
  }

  // Load current user data
  Future<void> _loadUserData() async {
    try {
      _currentUser = await _authService.getCurrentUserData();
      notifyListeners();
    } catch (e) {
      _setError('Error cargando datos del usuario');
    }
  }

  // Sign in with email and password
  Future<bool> signIn(String email, String password) async {
    _setLoading(true);
    _clearError();
    try {
      await _authService.signIn(email, password);
      await _loadUserData();
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  // Register new user
  Future<bool> register({
    required String email,
    required String password,
    required String nombre,
    required String apellido,
    required String telefono,
    required String rol,
    String? direccion,
    String? cedula,
  }) async {
    _setLoading(true);
    _clearError();
    try {
      final userData = UserModel(
        id: '',
        nombre: nombre,
        apellido: apellido,
        email: email,
        telefono: telefono,
        rol: rol,
        direccion: direccion,
        cedula: cedula,
        fechaCreacion: DateTime.now(),
      );
      await _authService.register(email, password, userData);
      await _loadUserData();
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  // Send password reset email
  Future<bool> sendPasswordResetEmail(String email) async {
    _setLoading(true);
    _clearError();
    try {
      await _authService.sendPasswordResetEmail(email);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  // Sign out
  Future<void> signOut() async {
    _setLoading(true);
    try {
      await _authService.signOut();
      _currentUser = null;
      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
    }
  }

  // Update user profile
  Future<bool> updateProfile({
    required String nombre,
    required String apellido,
    required String telefono,
    String? direccion,
    String? cedula,
    String? avatarUrl,
  }) async {
    if (_currentUser == null) return false;
    _setLoading(true);
    _clearError();
    try {
      final updatedUser = _currentUser!.copyWith(
        nombre: nombre,
        apellido: apellido,
        telefono: telefono,
        direccion: direccion,
        cedula: cedula,
        avatarUrl: avatarUrl,
      );
      await _authService.updateUserProfile(updatedUser);
      _currentUser = updatedUser;
      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  // Update password
  Future<bool> updatePassword(String currentPassword, String newPassword) async {
    _setLoading(true);
    _clearError();
    try {
      await _authService.updatePassword(currentPassword, newPassword);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  // Update email
  Future<bool> updateEmail(String newEmail) async {
    _setLoading(true);
    _clearError();
    try {
      await _authService.updateEmail(newEmail);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  // Send email verification
  Future<bool> sendEmailVerification() async {
    _setLoading(true);
    _clearError();
    try {
      await _authService.sendEmailVerification();
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  // Delete account
  Future<bool> deleteAccount(String password) async {
    _setLoading(true);
    _clearError();
    try {
      await _authService.deleteAccount(password);
      _currentUser = null;
      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  // Validate role access
  Future<bool> validateRoleAccess(String requiredRole) async {
    return _authService.validateRoleAccess(requiredRole);
  }

  // Check if user has any of the specified roles
  Future<bool> hasAnyRole(List<String> roles) async {
    return _authService.hasAnyRole(roles);
  }

  // Private helpers
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
    notifyListeners();
  }

  void clearError() => _clearError();

  Future<void> refreshUserData() async => _loadUserData();
}
