import 'package:cloud_firestore/cloud_firestore.dart';

class BovineModel {
  final String id;
  final String nombre;
  final String raza;
  final String sexo;
  final DateTime fechaNacimiento;
  final String color;
  final double peso;
  final String numeroIdentificacion;
  final String estado;
  final String propietarioId;
  final DateTime fechaCreacion;
  final DateTime? fechaActualizacion;
  final String? imagenUrl;
  final String? observaciones;
  final String? padre;
  final String? madre;
  final bool activo;

  BovineModel({
    required this.id,
    required this.nombre,
    required this.raza,
    required this.sexo,
    required this.fechaNacimiento,
    required this.color,
    required this.peso,
    required this.numeroIdentificacion,
    required this.estado,
    required this.propietarioId,
    required this.fechaCreacion,
    this.fechaActualizacion,
    this.imagenUrl,
    this.observaciones,
    this.padre,
    this.madre,
    this.activo = true,
  });

  // Convert from Firestore Document
  factory BovineModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
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

  // Convert to Firestore Document
  Map<String, dynamic> toFirestore() {
    return {
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
      'fechaActualizacion': fechaActualizacion != null 
          ? Timestamp.fromDate(fechaActualizacion!) 
          : null,
      'imagenUrl': imagenUrl,
      'observaciones': observaciones,
      'padre': padre,
      'madre': madre,
      'activo': activo,
    };
  }

  // Calculate age
  int get edad {
    final now = DateTime.now();
    int age = now.year - fechaNacimiento.year;
    if (now.month < fechaNacimiento.month || 
        (now.month == fechaNacimiento.month && now.day < fechaNacimiento.day)) {
      age--;
    }
    return age;
  }

  // Get age in months for young animals
  int get edadMeses {
    final now = DateTime.now();
    return (now.year - fechaNacimiento.year) * 12 + now.month - fechaNacimiento.month;
  }

  // Copy with method
  BovineModel copyWith({
    String? id,
    String? nombre,
    String? raza,
    String? sexo,
    DateTime? fechaNacimiento,
    String? color,
    double? peso,
    String? numeroIdentificacion,
    String? estado,
    String? propietarioId,
    DateTime? fechaCreacion,
    DateTime? fechaActualizacion,
    String? imagenUrl,
    String? observaciones,
    String? padre,
    String? madre,
    bool? activo,
  }) {
    return BovineModel(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      raza: raza ?? this.raza,
      sexo: sexo ?? this.sexo,
      fechaNacimiento: fechaNacimiento ?? this.fechaNacimiento,
      color: color ?? this.color,
      peso: peso ?? this.peso,
      numeroIdentificacion: numeroIdentificacion ?? this.numeroIdentificacion,
      estado: estado ?? this.estado,
      propietarioId: propietarioId ?? this.propietarioId,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
      fechaActualizacion: fechaActualizacion ?? this.fechaActualizacion,
      imagenUrl: imagenUrl ?? this.imagenUrl,
      observaciones: observaciones ?? this.observaciones,
      padre: padre ?? this.padre,
      madre: madre ?? this.madre,
      activo: activo ?? this.activo,
    );
  }
}