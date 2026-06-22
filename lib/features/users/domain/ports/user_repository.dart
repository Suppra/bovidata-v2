// Capa de DOMINIO (users) — puerto del repositorio de usuarios.
import 'package:bovidata_new/core/interfaces/repository_interface.dart' show IRepository;
import 'package:bovidata_new/models/user_model.dart';

abstract class IUserRepository extends IRepository<UserModel> {
  Future<List<UserModel>> getByRole(String role);
  Future<UserModel?> getByEmail(String email);
}
