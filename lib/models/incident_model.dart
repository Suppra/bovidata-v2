import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'incident_model.freezed.dart';

@freezed
class IncidentModel with _$IncidentModel {
  const IncidentModel._();

  const factory IncidentModel({
    required String id,
    required String bovineId,
    required String tipo,
    required String descripcion,
    required DateTime fecha,
    required String gravedad,
    required String estado,
    required String reportadoPor,
    String? tratamientoId,
    required DateTime fechaCreacion,
    DateTime? fechaResolucion,
    String? observaciones,
    List<String>? imagenesUrl,
    Map<String, dynamic>? datos,
    @Default('') String propietarioId,
  }) = _IncidentModel;

  factory IncidentModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
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
      imagenesUrl:
          data['imagenesUrl'] != null ? List<String>.from(data['imagenesUrl']) : null,
      datos: data['datos'],
      propietarioId: data['propietarioId'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() => {
        'bovineId': bovineId,
        'tipo': tipo,
        'descripcion': descripcion,
        'fecha': Timestamp.fromDate(fecha),
        'gravedad': gravedad,
        'estado': estado,
        'reportadoPor': reportadoPor,
        'tratamientoId': tratamientoId,
        'fechaCreacion': Timestamp.fromDate(fechaCreacion),
        'fechaResolucion':
            fechaResolucion != null ? Timestamp.fromDate(fechaResolucion!) : null,
        'observaciones': observaciones,
        'imagenesUrl': imagenesUrl,
        'datos': datos,
        'propietarioId': propietarioId,
      };

  bool get isResuelto => estado == 'Resuelto';

  int get diasDesdeIncidente => DateTime.now().difference(fecha).inDays;

  Duration? get tiempoResolucion {
    if (fechaResolucion == null) return null;
    return fechaResolucion!.difference(fecha);
  }
}
