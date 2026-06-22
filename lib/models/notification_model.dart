import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'notification_model.freezed.dart';

@freezed
class NotificationModel with _$NotificationModel {
  const NotificationModel._();

  const factory NotificationModel({
    required String id,
    required String titulo,
    required String mensaje,
    required String tipo,
    required String usuarioId,
    @Default(false) bool leida,
    required DateTime fechaCreacion,
    DateTime? fechaLectura,
    String? accionUrl,
    Map<String, dynamic>? datos,
    String? iconoTipo,
    @Default('normal') String prioridad,
  }) = _NotificationModel;

  factory NotificationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
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

  Map<String, dynamic> toFirestore() => {
        'titulo': titulo,
        'mensaje': mensaje,
        'tipo': tipo,
        'usuarioId': usuarioId,
        'leida': leida,
        'fechaCreacion': Timestamp.fromDate(fechaCreacion),
        'fechaLectura': fechaLectura != null ? Timestamp.fromDate(fechaLectura!) : null,
        'accionUrl': accionUrl,
        'datos': datos,
        'iconoTipo': iconoTipo,
        'prioridad': prioridad,
      };

  bool get isRecent => DateTime.now().difference(fechaCreacion).inHours < 24;

  bool get isHighPriority => prioridad == 'alta';

  String get tiempoTranscurrido {
    final difference = DateTime.now().difference(fechaCreacion);
    if (difference.inDays > 0) {
      return 'hace ${difference.inDays} día${difference.inDays > 1 ? 's' : ''}';
    } else if (difference.inHours > 0) {
      return 'hace ${difference.inHours} hora${difference.inHours > 1 ? 's' : ''}';
    } else if (difference.inMinutes > 0) {
      return 'hace ${difference.inMinutes} minuto${difference.inMinutes > 1 ? 's' : ''}';
    }
    return 'ahora';
  }
}
