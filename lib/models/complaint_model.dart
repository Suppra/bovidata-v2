import 'package:cloud_firestore/cloud_firestore.dart';

class ComplaintModel {
  final String id;
  final String titulo;
  final String descripcion;
  final String tipo;
  final String estado;
  final String usuarioId;
  final DateTime fechaCreacion;
  final DateTime? fechaRespuesta;
  final String? respuesta;
  final String? respondidoPor;
  final String prioridad;
  final String categoria;
  final List<String>? imagenesUrl;
  final Map<String, dynamic>? datos;

  ComplaintModel({
    required this.id,
    required this.titulo,
    required this.descripcion,
    required this.tipo,
    required this.estado,
    required this.usuarioId,
    required this.fechaCreacion,
    this.fechaRespuesta,
    this.respuesta,
    this.respondidoPor,
    this.prioridad = 'media',
    required this.categoria,
    this.imagenesUrl,
    this.datos,
  });

  // Convert from Firestore Document
  factory ComplaintModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return ComplaintModel(
      id: doc.id,
      titulo: data['titulo'] ?? '',
      descripcion: data['descripcion'] ?? '',
      tipo: data['tipo'] ?? '',
      estado: data['estado'] ?? 'Pendiente',
      usuarioId: data['usuarioId'] ?? '',
      fechaCreacion: (data['fechaCreacion'] as Timestamp?)?.toDate() ?? DateTime.now(),
      fechaRespuesta: (data['fechaRespuesta'] as Timestamp?)?.toDate(),
      respuesta: data['respuesta'],
      respondidoPor: data['respondidoPor'],
      prioridad: data['prioridad'] ?? 'media',
      categoria: data['categoria'] ?? '',
      imagenesUrl: data['imagenesUrl'] != null 
          ? List<String>.from(data['imagenesUrl']) 
          : null,
      datos: data['datos'],
    );
  }

  // Convert to Firestore Document
  Map<String, dynamic> toFirestore() {
    return {
      'titulo': titulo,
      'descripcion': descripcion,
      'tipo': tipo,
      'estado': estado,
      'usuarioId': usuarioId,
      'fechaCreacion': Timestamp.fromDate(fechaCreacion),
      'fechaRespuesta': fechaRespuesta != null 
          ? Timestamp.fromDate(fechaRespuesta!) 
          : null,
      'respuesta': respuesta,
      'respondidoPor': respondidoPor,
      'prioridad': prioridad,
      'categoria': categoria,
      'imagenesUrl': imagenesUrl,
      'datos': datos,
    };
  }

  // Check if complaint is resolved
  bool get isResuelta => estado == 'Resuelta';

  // Check if complaint is in progress
  bool get isEnProceso => estado == 'En proceso';

  // Days since complaint was created
  int get diasDesdeCreacion {
    return DateTime.now().difference(fechaCreacion).inDays;
  }

  // Time to resolution
  Duration? get tiempoResolucion {
    if (fechaRespuesta == null) return null;
    return fechaRespuesta!.difference(fechaCreacion);
  }

  // Check if it's high priority
  bool get isHighPriority => prioridad == 'alta';

  // Check if it's a complaint or suggestion
  bool get isQueja => tipo == 'Queja';
  bool get isSugerencia => tipo == 'Sugerencia';

  // Copy with method
  ComplaintModel copyWith({
    String? id,
    String? titulo,
    String? descripcion,
    String? tipo,
    String? estado,
    String? usuarioId,
    DateTime? fechaCreacion,
    DateTime? fechaRespuesta,
    String? respuesta,
    String? respondidoPor,
    String? prioridad,
    String? categoria,
    List<String>? imagenesUrl,
    Map<String, dynamic>? datos,
  }) {
    return ComplaintModel(
      id: id ?? this.id,
      titulo: titulo ?? this.titulo,
      descripcion: descripcion ?? this.descripcion,
      tipo: tipo ?? this.tipo,
      estado: estado ?? this.estado,
      usuarioId: usuarioId ?? this.usuarioId,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
      fechaRespuesta: fechaRespuesta ?? this.fechaRespuesta,
      respuesta: respuesta ?? this.respuesta,
      respondidoPor: respondidoPor ?? this.respondidoPor,
      prioridad: prioridad ?? this.prioridad,
      categoria: categoria ?? this.categoria,
      imagenesUrl: imagenesUrl ?? this.imagenesUrl,
      datos: datos ?? this.datos,
    );
  }
}