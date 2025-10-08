import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String nombre;
  final String apellido;
  final String email;
  final String telefono;
  final String rol;
  final String? direccion;
  final String? cedula;
  final DateTime fechaCreacion;
  final bool activo;
  final String? avatarUrl;

  UserModel({
    required this.id,
    required this.nombre,
    required this.apellido,
    required this.email,
    required this.telefono,
    required this.rol,
    this.direccion,
    this.cedula,
    required this.fechaCreacion,
    this.activo = true,
    this.avatarUrl,
  });

  // Convert from Firestore Document
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
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

  // Convert to Firestore Document
  Map<String, dynamic> toFirestore() {
    return {
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
  }

  // Get full name
  String get nombreCompleto => '$nombre $apellido';

  // Copy with method
  UserModel copyWith({
    String? id,
    String? nombre,
    String? apellido,
    String? email,
    String? telefono,
    String? rol,
    String? direccion,
    String? cedula,
    DateTime? fechaCreacion,
    bool? activo,
    String? avatarUrl,
  }) {
    return UserModel(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      apellido: apellido ?? this.apellido,
      email: email ?? this.email,
      telefono: telefono ?? this.telefono,
      rol: rol ?? this.rol,
      direccion: direccion ?? this.direccion,
      cedula: cedula ?? this.cedula,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
      activo: activo ?? this.activo,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }
}