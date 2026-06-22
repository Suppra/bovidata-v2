import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'treatment_model.freezed.dart';

@freezed
class TreatmentModel with _$TreatmentModel {
  const TreatmentModel._();

  const factory TreatmentModel({
    required String id,
    required String bovineId,
    required String tipo,
    required String nombre,
    required String descripcion,
    required DateTime fecha,
    String? medicamento,
    double? dosis,
    String? unidadDosis,
    required String veterinarioId,
    DateTime? proximaAplicacion,
    @Default(false) bool completado,
    required DateTime fechaCreacion,
    String? observaciones,
    double? costo,
    List<String>? imagenesUrl,
    Map<String, dynamic>? efectosSecundarios,
    @Default('') String propietarioId,
  }) = _TreatmentModel;

  factory TreatmentModel.empty() => TreatmentModel(
        id: '',
        bovineId: '',
        tipo: '',
        nombre: '',
        descripcion: '',
        fecha: DateTime.now(),
        veterinarioId: '',
        fechaCreacion: DateTime.now(),
      );

  factory TreatmentModel.fromMap(Map<String, dynamic> data, String id) =>
      TreatmentModel(
        id: id,
        bovineId: data['bovineId'] ?? '',
        tipo: data['tipo'] ?? '',
        nombre: data['nombre'] ?? '',
        descripcion: data['descripcion'] ?? '',
        fecha: data['fecha'] is DateTime ? data['fecha'] : DateTime.now(),
        medicamento: data['medicamento'],
        dosis: data['dosis']?.toDouble(),
        unidadDosis: data['unidadDosis'],
        veterinarioId: data['veterinarioId'] ?? '',
        proximaAplicacion:
            data['proximaAplicacion'] is DateTime ? data['proximaAplicacion'] : null,
        completado: data['completado'] ?? false,
        fechaCreacion:
            data['fechaCreacion'] is DateTime ? data['fechaCreacion'] : DateTime.now(),
        observaciones: data['observaciones'],
        costo: data['costo']?.toDouble(),
        imagenesUrl:
            data['imagenesUrl'] != null ? List<String>.from(data['imagenesUrl']) : null,
        efectosSecundarios: data['efectosSecundarios'],
        propietarioId: data['propietarioId'] ?? '',
      );

  factory TreatmentModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
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
      imagenesUrl:
          data['imagenesUrl'] != null ? List<String>.from(data['imagenesUrl']) : null,
      efectosSecundarios: data['efectosSecundarios'],
      propietarioId: data['propietarioId'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() => {
        'bovineId': bovineId,
        'tipo': tipo,
        'nombre': nombre,
        'descripcion': descripcion,
        'fecha': Timestamp.fromDate(fecha),
        'medicamento': medicamento,
        'dosis': dosis,
        'unidadDosis': unidadDosis,
        'veterinarioId': veterinarioId,
        'proximaAplicacion':
            proximaAplicacion != null ? Timestamp.fromDate(proximaAplicacion!) : null,
        'completado': completado,
        'fechaCreacion': Timestamp.fromDate(fechaCreacion),
        'observaciones': observaciones,
        'costo': costo,
        'imagenesUrl': imagenesUrl,
        'efectosSecundarios': efectosSecundarios,
        'propietarioId': propietarioId,
      };

  bool get isOverdue {
    if (proximaAplicacion == null || completado) return false;
    return DateTime.now().isAfter(proximaAplicacion!);
  }

  int? get diasParaProxima {
    if (proximaAplicacion == null || completado) return null;
    return proximaAplicacion!.difference(DateTime.now()).inDays;
  }
}
