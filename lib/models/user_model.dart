import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_model.freezed.dart';

@freezed
class UserModel with _$UserModel {
  const UserModel._();

  const factory UserModel({
    required String id,
    required String nombre,
    required String apellido,
    required String email,
    required String telefono,
    required String rol,
    String? direccion,
    String? cedula,
    required DateTime fechaCreacion,
    @Default(true) bool activo,
    String? avatarUrl,
  }) = _UserModel;

  factory UserModel.empty() => UserModel(
        id: '',
        nombre: '',
        apellido: '',
        email: '',
        telefono: '',
        rol: '',
        fechaCreacion: DateTime.now(),
      );

  factory UserModel.fromMap(Map<String, dynamic> data, String id) => UserModel(
        id: id,
        nombre: data['nombre'] ?? '',
        apellido: data['apellido'] ?? '',
        email: data['email'] ?? '',
        telefono: data['telefono'] ?? '',
        rol: data['rol'] ?? '',
        direccion: data['direccion'],
        cedula: data['cedula'],
        fechaCreacion:
            data['fechaCreacion'] is DateTime ? data['fechaCreacion'] : DateTime.now(),
        activo: data['activo'] ?? true,
        avatarUrl: data['avatarUrl'],
      );

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      id: doc.id,
      nombre: data['nombre'] ?? '',
      apellido: data['apellido'] ?? '',
      email: data['email'] ?? '',
      telefono: data['telefono'] ?? '',
      rol: data['rol'] ?? '',
      direccion: data['direccion'],
      cedula: data['cedula'],
      fechaCreacion: (data['fechaCreacion'] as Timestamp?)?.toDate() ?? DateTime.now(),
      activo: data['activo'] ?? true,
      avatarUrl: data['avatarUrl'],
    );
  }

  Map<String, dynamic> toFirestore() => {
        'nombre': nombre,
        'apellido': apellido,
        'email': email,
        'telefono': telefono,
        'rol': rol,
        'direccion': direccion,
        'cedula': cedula,
        'fechaCreacion': Timestamp.fromDate(fechaCreacion),
        'activo': activo,
        'avatarUrl': avatarUrl,
      };

  String get nombreCompleto => '$nombre $apellido';
}
