import 'package:cloud_firestore/cloud_firestore.dart';

class TreatmentModel {
  final String id;
  final String bovineId;
  final String tipo;
  final String nombre;
  final String descripcion;
  final DateTime fecha;
  final String? medicamento;
  final double? dosis;
  final String? unidadDosis;
  final String veterinarioId;
  final DateTime? proximaAplicacion;
  final bool completado;
  final DateTime fechaCreacion;
  final String? observaciones;
  final double? costo;
  final List<String>? imagenesUrl;
  final Map<String, dynamic>? efectosSecundarios;

  TreatmentModel({
    required this.id,
    required this.bovineId,
    required this.tipo,
    required this.nombre,
    required this.descripcion,
    required this.fecha,
    this.medicamento,
    this.dosis,
    this.unidadDosis,
    required this.veterinarioId,
    this.proximaAplicacion,
    this.completado = false,
    required this.fechaCreacion,
    this.observaciones,
    this.costo,
    this.imagenesUrl,
    this.efectosSecundarios,
  });

  // Convert from Firestore Document
  factory TreatmentModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return TreatmentModel(
      id: doc.id,
      bovineId: data['bovineId'] ?? '',
      tipo: data['tipo'] ?? '',
      nombre: data['nombre'] ?? '',
      descripcion: data['descripcion'] ?? '',
      fecha: (data['fecha'] as Timestamp?)?.toDate() ?? DateTime.now(),
      medicamento: data['medicamento'],
      dosis: data['dosis']?.toDouble(),
      unidadDosis: data['unidadDosis'],
      veterinarioId: data['veterinarioId'] ?? '',
      proximaAplicacion: (data['proximaAplicacion'] as Timestamp?)?.toDate(),
      completado: data['completado'] ?? false,
      fechaCreacion: (data['fechaCreacion'] as Timestamp?)?.toDate() ?? DateTime.now(),
      observaciones: data['observaciones'],
      costo: data['costo']?.toDouble(),
      imagenesUrl: data['imagenesUrl'] != null 
          ? List<String>.from(data['imagenesUrl']) 
          : null,
      efectosSecundarios: data['efectosSecundarios'],
    );
  }

  // Convert to Firestore Document
  Map<String, dynamic> toFirestore() {
    return {
      'bovineId': bovineId,
      'tipo': tipo,
      'nombre': nombre,
      'descripcion': descripcion,
      'fecha': Timestamp.fromDate(fecha),
      'medicamento': medicamento,
      'dosis': dosis,
      'unidadDosis': unidadDosis,
      'veterinarioId': veterinarioId,
      'proximaAplicacion': proximaAplicacion != null 
          ? Timestamp.fromDate(proximaAplicacion!) 
          : null,
      'completado': completado,
      'fechaCreacion': Timestamp.fromDate(fechaCreacion),
      'observaciones': observaciones,
      'costo': costo,
      'imagenesUrl': imagenesUrl,
      'efectosSecundarios': efectosSecundarios,
    };
  }

  // Check if treatment is overdue
  bool get isOverdue {
    if (proximaAplicacion == null || completado) return false;
    return DateTime.now().isAfter(proximaAplicacion!);
  }

  // Days until next application
  int? get diasParaProxima {
    if (proximaAplicacion == null || completado) return null;
    return proximaAplicacion!.difference(DateTime.now()).inDays;
  }

  // Copy with method
  TreatmentModel copyWith({
    String? id,
    String? bovineId,
    String? tipo,
    String? nombre,
    String? descripcion,
    DateTime? fecha,
    String? medicamento,
    double? dosis,
    String? unidadDosis,
    String? veterinarioId,
    DateTime? proximaAplicacion,
    bool? completado,
    DateTime? fechaCreacion,
    String? observaciones,
    double? costo,
    List<String>? imagenesUrl,
    Map<String, dynamic>? efectosSecundarios,
  }) {
    return TreatmentModel(
      id: id ?? this.id,
      bovineId: bovineId ?? this.bovineId,
      tipo: tipo ?? this.tipo,
      nombre: nombre ?? this.nombre,
      descripcion: descripcion ?? this.descripcion,
      fecha: fecha ?? this.fecha,
      medicamento: medicamento ?? this.medicamento,
      dosis: dosis ?? this.dosis,
      unidadDosis: unidadDosis ?? this.unidadDosis,
      veterinarioId: veterinarioId ?? this.veterinarioId,
      proximaAplicacion: proximaAplicacion ?? this.proximaAplicacion,
      completado: completado ?? this.completado,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
      observaciones: observaciones ?? this.observaciones,
      costo: costo ?? this.costo,
      imagenesUrl: imagenesUrl ?? this.imagenesUrl,
      efectosSecundarios: efectosSecundarios ?? this.efectosSecundarios,
    );
  }
}