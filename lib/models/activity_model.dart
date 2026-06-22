// Modelo de actividad (audit log). Clase inmutable simple: usa JSON propio
// (no Firestore Timestamp), por lo que no se modela con freezed para evitar el
// acoplamiento con json_serializable.
class ActivityModel {
  final String id;
  final String tipo;
  final String descripcion;
  final String entidadId;
  final String entidadNombre;
  final String usuarioId;
  final DateTime fecha;
  final Map<String, dynamic>? metadata;

  const ActivityModel({
    required this.id,
    required this.tipo,
    required this.descripcion,
    required this.entidadId,
    required this.entidadNombre,
    required this.usuarioId,
    required this.fecha,
    this.metadata,
  });

  factory ActivityModel.fromJson(Map<String, dynamic> json) => ActivityModel(
        id: json['id'] ?? '',
        tipo: json['tipo'] ?? '',
        descripcion: json['descripcion'] ?? '',
        entidadId: json['entidadId'] ?? '',
        entidadNombre: json['entidadNombre'] ?? '',
        usuarioId: json['usuarioId'] ?? '',
        fecha: DateTime.parse(json['fecha']),
        metadata: json['metadata'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'tipo': tipo,
        'descripcion': descripcion,
        'entidadId': entidadId,
        'entidadNombre': entidadNombre,
        'usuarioId': usuarioId,
        'fecha': fecha.toIso8601String(),
        'metadata': metadata,
      };

  factory ActivityModel.fromBovine({
    required String bovineId,
    required String bovineName,
    required String userId,
    required String action,
  }) =>
      ActivityModel(
        id: '',
        tipo: 'bovino',
        descripcion: '$action bovino "$bovineName"',
        entidadId: bovineId,
        entidadNombre: bovineName,
        usuarioId: userId,
        fecha: DateTime.now(),
      );

  factory ActivityModel.fromTreatment({
    required String treatmentId,
    required String treatmentType,
    required String bovineId,
    required String bovineName,
    required String userId,
    required String action,
  }) =>
      ActivityModel(
        id: '',
        tipo: 'tratamiento',
        descripcion: '$action tratamiento de $treatmentType para "$bovineName"',
        entidadId: treatmentId,
        entidadNombre: treatmentType,
        usuarioId: userId,
        fecha: DateTime.now(),
        metadata: {'bovineId': bovineId, 'bovineName': bovineName},
      );

  factory ActivityModel.fromInventory({
    required String itemId,
    required String itemName,
    required String userId,
    required String action,
  }) =>
      ActivityModel(
        id: '',
        tipo: 'inventario',
        descripcion: '$action item de inventario "$itemName"',
        entidadId: itemId,
        entidadNombre: itemName,
        usuarioId: userId,
        fecha: DateTime.now(),
      );
}
