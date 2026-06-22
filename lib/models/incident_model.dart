import 'package:cloud_firestore/cloud_firestore.dart';

class IncidentModel {
  final String id;
  final String bovineId;
  final String tipo;
  final String descripcion;
  final DateTime fecha;
  final String gravedad;
  final String estado;
  final String reportadoPor;
  final String? tratamientoId;
  final DateTime fechaCreacion;
  final DateTime? fechaResolucion;
  final String? observaciones;
  final List<String>? imagenesUrl;
  final Map<String, dynamic>? datos;

  IncidentModel({
    required this.id,
    required this.bovineId,
    required this.tipo,
    required this.descripcion,
    required this.fecha,
    required this.gravedad,
    required this.estado,
    required this.reportadoPor,
    this.tratamientoId,
    required this.fechaCreacion,
    this.fechaResolucion,
    this.observaciones,
    this.imagenesUrl,
    this.datos,
  });

  // Convert from Firestore Document
  factory IncidentModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return IncidentModel(
      id: doc.id,
      bovineId: data['bovineId'] ?? '',
      tipo: data['tipo'] ?? '',
      descripcion: data['descripcion'] ?? '',
      fecha: (data['fecha'] as Timestamp?)?.toDate() ?? DateTime.now(),
      gravedad: data['gravedad'] ?? '',
      estado: data['estado'] ?? 'Pendiente',
      reportadoPor: data['reportadoPor'] ?? '',
      tratamientoId: data['tratamientoId'],
      fechaCreacion: (data['fechaCreacion'] as Timestamp?)?.toDate() ?? DateTime.now(),
      fechaResolucion: (data['fechaResolucion'] as Timestamp?)?.toDate(),
      observaciones: data['observaciones'],
      imagenesUrl: data['imagenesUrl'] != null 
          ? List<String>.from(data['imagenesUrl']) 
          : null,
      datos: data['datos'],
    );
  }

  // Convert to Firestore Document
  Map<String, dynamic> toFirestore() {
    return {
      'bovineId': bovineId,
      'tipo': tipo,
      'descripcion': descripcion,
      'fecha': Timestamp.fromDate(fecha),
      'gravedad': gravedad,
      'estado': estado,
      'reportadoPor': reportadoPor,
      'tratamientoId': tratamientoId,
      'fechaCreacion': Timestamp.fromDate(fechaCreacion),
      'fechaResolucion': fechaResolucion != null 
          ? Timestamp.fromDate(fechaResolucion!) 
          : null,
      'observaciones': observaciones,
      'imagenesUrl': imagenesUrl,
      'datos': datos,
    };
  }

  // Check if incident is resolved
  bool get isResuelto => estado == 'Resuelto';

  // Days since incident
  int get diasDesdeIncidente {
    return DateTime.now().difference(fecha).inDays;
  }

  // Duration to resolution
  Duration? get tiempoResolucion {
    if (fechaResolucion == null) return null;
    return fechaResolucion!.difference(fecha);
  }

  // Copy with method
  IncidentModel copyWith({
    String? id,
    String? bovineId,
    String? tipo,
    String? descripcion,
    DateTime? fecha,
    String? gravedad,
    String? estado,
    String? reportadoPor,
    String? tratamientoId,
    DateTime? fechaCreacion,
    DateTime? fechaResolucion,
    String? observaciones,
    List<String>? imagenesUrl,
    Map<String, dynamic>? datos,
  }) {
    return IncidentModel(
      id: id ?? this.id,
      bovineId: bovineId ?? this.bovineId,
      tipo: tipo ?? this.tipo,
      descripcion: descripcion ?? this.descripcion,
      fecha: fecha ?? this.fecha,
      gravedad: gravedad ?? this.gravedad,
      estado: estado ?? this.estado,
      reportadoPor: reportadoPor ?? this.reportadoPor,
      tratamientoId: tratamientoId ?? this.tratamientoId,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
      fechaResolucion: fechaResolucion ?? this.fechaResolucion,
      observaciones: observaciones ?? this.observaciones,
      imagenesUrl: imagenesUrl ?? this.imagenesUrl,
      datos: datos ?? this.datos,
    );
  }
}