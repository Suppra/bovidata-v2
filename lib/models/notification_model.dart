import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  final String id;
  final String titulo;
  final String mensaje;
  final String tipo;
  final String usuarioId;
  final bool leida;
  final DateTime fechaCreacion;
  final DateTime? fechaLectura;
  final String? accionUrl;
  final Map<String, dynamic>? datos;
  final String? iconoTipo;
  final String prioridad;

  NotificationModel({
    required this.id,
    required this.titulo,
    required this.mensaje,
    required this.tipo,
    required this.usuarioId,
    this.leida = false,
    required this.fechaCreacion,
    this.fechaLectura,
    this.accionUrl,
    this.datos,
    this.iconoTipo,
    this.prioridad = 'normal',
  });

  // Convert from Firestore Document
  factory NotificationModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return NotificationModel(
      id: doc.id,
      titulo: data['titulo'] ?? '',
      mensaje: data['mensaje'] ?? '',
      tipo: data['tipo'] ?? '',
      usuarioId: data['usuarioId'] ?? '',
      leida: data['leida'] ?? false,
      fechaCreacion: (data['fechaCreacion'] as Timestamp?)?.toDate() ?? DateTime.now(),
      fechaLectura: (data['fechaLectura'] as Timestamp?)?.toDate(),
      accionUrl: data['accionUrl'],
      datos: data['datos'],
      iconoTipo: data['iconoTipo'],
      prioridad: data['prioridad'] ?? 'normal',
    );
  }

  // Convert to Firestore Document
  Map<String, dynamic> toFirestore() {
    return {
      'titulo': titulo,
      'mensaje': mensaje,
      'tipo': tipo,
      'usuarioId': usuarioId,
      'leida': leida,
      'fechaCreacion': Timestamp.fromDate(fechaCreacion),
      'fechaLectura': fechaLectura != null 
          ? Timestamp.fromDate(fechaLectura!) 
          : null,
      'accionUrl': accionUrl,
      'datos': datos,
      'iconoTipo': iconoTipo,
      'prioridad': prioridad,
    };
  }

  // Check if notification is recent (less than 24 hours)
  bool get isRecent {
    final now = DateTime.now();
    return now.difference(fechaCreacion).inHours < 24;
  }

  // Time ago string
  String get tiempoTranscurrido {
    final now = DateTime.now();
    final difference = now.difference(fechaCreacion);
    
    if (difference.inDays > 0) {
      return 'hace ${difference.inDays} día${difference.inDays > 1 ? 's' : ''}';
    } else if (difference.inHours > 0) {
      return 'hace ${difference.inHours} hora${difference.inHours > 1 ? 's' : ''}';
    } else if (difference.inMinutes > 0) {
      return 'hace ${difference.inMinutes} minuto${difference.inMinutes > 1 ? 's' : ''}';
    } else {
      return 'ahora';
    }
  }

  // Check if it's high priority
  bool get isHighPriority => prioridad == 'alta';

  // Copy with method
  NotificationModel copyWith({
    String? id,
    String? titulo,
    String? mensaje,
    String? tipo,
    String? usuarioId,
    bool? leida,
    DateTime? fechaCreacion,
    DateTime? fechaLectura,
    String? accionUrl,
    Map<String, dynamic>? datos,
    String? iconoTipo,
    String? prioridad,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      titulo: titulo ?? this.titulo,
      mensaje: mensaje ?? this.mensaje,
      tipo: tipo ?? this.tipo,
      usuarioId: usuarioId ?? this.usuarioId,
      leida: leida ?? this.leida,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
      fechaLectura: fechaLectura ?? this.fechaLectura,
      accionUrl: accionUrl ?? this.accionUrl,
      datos: datos ?? this.datos,
      iconoTipo: iconoTipo ?? this.iconoTipo,
      prioridad: prioridad ?? this.prioridad,
    );
  }
}