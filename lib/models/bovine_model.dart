import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'bovine_model.freezed.dart';

@freezed
class BovineModel with _$BovineModel {
  const BovineModel._(); // habilita getters y métodos personalizados

  const factory BovineModel({
    required String id,
    required String nombre,
    required String raza,
    required String sexo,
    required DateTime fechaNacimiento,
    required String color,
    required double peso,
    required String numeroIdentificacion,
    required String estado,
    required String propietarioId,
    required DateTime fechaCreacion,
    DateTime? fechaActualizacion,
    String? imagenUrl,
    String? observaciones,
    String? padre,
    String? madre,
    @Default(true) bool activo,
  }) = _BovineModel;

  factory BovineModel.empty() => BovineModel(
        id: '',
        nombre: '',
        raza: '',
        sexo: '',
        fechaNacimiento: DateTime.now(),
        color: '',
        peso: 0.0,
        numeroIdentificacion: '',
        estado: 'Sano',
        propietarioId: '',
        fechaCreacion: DateTime.now(),
      );

  factory BovineModel.fromMap(Map<String, dynamic> data, String id) =>
      BovineModel(
        id: id,
        nombre: data['nombre'] ?? '',
        raza: data['raza'] ?? '',
        sexo: data['sexo'] ?? '',
        fechaNacimiento:
            data['fechaNacimiento'] is DateTime ? data['fechaNacimiento'] : DateTime.now(),
        color: data['color'] ?? '',
        peso: (data['peso'] ?? 0.0).toDouble(),
        numeroIdentificacion: data['numeroIdentificacion'] ?? '',
        estado: data['estado'] ?? 'Sano',
        propietarioId: data['propietarioId'] ?? '',
        fechaCreacion:
            data['fechaCreacion'] is DateTime ? data['fechaCreacion'] : DateTime.now(),
        fechaActualizacion:
            data['fechaActualizacion'] is DateTime ? data['fechaActualizacion'] : null,
        imagenUrl: data['imagenUrl'],
        observaciones: data['observaciones'],
        padre: data['padre'],
        madre: data['madre'],
        activo: data['activo'] ?? true,
      );

  factory BovineModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return BovineModel(
      id: doc.id,
      nombre: data['nombre'] ?? '',
      raza: data['raza'] ?? '',
      sexo: data['sexo'] ?? '',
      fechaNacimiento: (data['fechaNacimiento'] as Timestamp?)?.toDate() ?? DateTime.now(),
      color: data['color'] ?? '',
      peso: (data['peso'] ?? 0).toDouble(),
      numeroIdentificacion: data['numeroIdentificacion'] ?? '',
      estado: data['estado'] ?? 'Sano',
      propietarioId: data['propietarioId'] ?? '',
      fechaCreacion: (data['fechaCreacion'] as Timestamp?)?.toDate() ?? DateTime.now(),
      fechaActualizacion: (data['fechaActualizacion'] as Timestamp?)?.toDate(),
      imagenUrl: data['imagenUrl'],
      observaciones: data['observaciones'],
      padre: data['padre'],
      madre: data['madre'],
      activo: data['activo'] ?? true,
    );
  }

  Map<String, dynamic> toFirestore() => {
        'nombre': nombre,
        'raza': raza,
        'sexo': sexo,
        'fechaNacimiento': Timestamp.fromDate(fechaNacimiento),
        'color': color,
        'peso': peso,
        'numeroIdentificacion': numeroIdentificacion,
        'estado': estado,
        'propietarioId': propietarioId,
        'fechaCreacion': Timestamp.fromDate(fechaCreacion),
        'fechaActualizacion':
            fechaActualizacion != null ? Timestamp.fromDate(fechaActualizacion!) : null,
        'imagenUrl': imagenUrl,
        'observaciones': observaciones,
        'padre': padre,
        'madre': madre,
        'activo': activo,
      };

  int get edad {
    final now = DateTime.now();
    int age = now.year - fechaNacimiento.year;
    if (now.month < fechaNacimiento.month ||
        (now.month == fechaNacimiento.month && now.day < fechaNacimiento.day)) {
      age--;
    }
    return age;
  }

  int get edadMeses {
    final now = DateTime.now();
    return (now.year - fechaNacimiento.year) * 12 + now.month - fechaNacimiento.month;
  }
}
