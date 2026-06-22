import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'inventory_model.freezed.dart';

@freezed
class InventoryModel with _$InventoryModel {
  const InventoryModel._();

  const factory InventoryModel({
    required String id,
    required String nombre,
    required String tipo,
    required String categoria,
    required int cantidadActual,
    required int cantidadMinima,
    required String unidad,
    double? precioUnitario,
    DateTime? fechaVencimiento,
    String? lote,
    String? proveedor,
    String? descripcion,
    required DateTime fechaCreacion,
    DateTime? fechaActualizacion,
    String? imagenUrl,
    @Default(true) bool activo,
    Map<String, dynamic>? propiedades,
    @Default('') String propietarioId,
  }) = _InventoryModel;

  factory InventoryModel.empty() => InventoryModel(
        id: '',
        nombre: '',
        tipo: '',
        categoria: '',
        cantidadActual: 0,
        cantidadMinima: 0,
        unidad: '',
        fechaCreacion: DateTime.now(),
      );

  factory InventoryModel.fromMap(Map<String, dynamic> data, String id) =>
      InventoryModel(
        id: id,
        nombre: data['nombre'] ?? '',
        tipo: data['tipo'] ?? '',
        categoria: data['categoria'] ?? '',
        cantidadActual: data['cantidadActual'] ?? 0,
        cantidadMinima: data['cantidadMinima'] ?? 0,
        unidad: data['unidad'] ?? '',
        precioUnitario: data['precioUnitario']?.toDouble(),
        fechaVencimiento:
            data['fechaVencimiento'] is DateTime ? data['fechaVencimiento'] : null,
        lote: data['lote'],
        proveedor: data['proveedor'],
        descripcion: data['descripcion'],
        fechaCreacion:
            data['fechaCreacion'] is DateTime ? data['fechaCreacion'] : DateTime.now(),
        fechaActualizacion:
            data['fechaActualizacion'] is DateTime ? data['fechaActualizacion'] : null,
        imagenUrl: data['imagenUrl'],
        activo: data['activo'] ?? true,
        propiedades: data['propiedades'],
        propietarioId: data['propietarioId'] ?? '',
      );

  factory InventoryModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return InventoryModel(
      id: doc.id,
      nombre: data['nombre'] ?? '',
      tipo: data['tipo'] ?? '',
      categoria: data['categoria'] ?? '',
      cantidadActual: data['cantidadActual'] ?? 0,
      cantidadMinima: data['cantidadMinima'] ?? 0,
      unidad: data['unidad'] ?? '',
      precioUnitario: data['precioUnitario']?.toDouble(),
      fechaVencimiento: (data['fechaVencimiento'] as Timestamp?)?.toDate(),
      lote: data['lote'],
      proveedor: data['proveedor'],
      descripcion: data['descripcion'],
      fechaCreacion: (data['fechaCreacion'] as Timestamp?)?.toDate() ?? DateTime.now(),
      fechaActualizacion: (data['fechaActualizacion'] as Timestamp?)?.toDate(),
      imagenUrl: data['imagenUrl'],
      activo: data['activo'] ?? true,
      propiedades: data['propiedades'],
      propietarioId: data['propietarioId'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() => {
        'nombre': nombre,
        'tipo': tipo,
        'categoria': categoria,
        'cantidadActual': cantidadActual,
        'cantidadMinima': cantidadMinima,
        'unidad': unidad,
        'precioUnitario': precioUnitario,
        'fechaVencimiento':
            fechaVencimiento != null ? Timestamp.fromDate(fechaVencimiento!) : null,
        'lote': lote,
        'proveedor': proveedor,
        'descripcion': descripcion,
        'fechaCreacion': Timestamp.fromDate(fechaCreacion),
        'fechaActualizacion':
            fechaActualizacion != null ? Timestamp.fromDate(fechaActualizacion!) : null,
        'imagenUrl': imagenUrl,
        'activo': activo,
        'propiedades': propiedades,
        'propietarioId': propietarioId,
      };

  bool get isLowStock => cantidadActual <= cantidadMinima;

  bool get isExpired {
    if (fechaVencimiento == null) return false;
    return DateTime.now().isAfter(fechaVencimiento!);
  }

  bool get isExpiringSoon {
    if (fechaVencimiento == null) return false;
    final thirtyDaysFromNow = DateTime.now().add(const Duration(days: 30));
    return fechaVencimiento!.isBefore(thirtyDaysFromNow) && !isExpired;
  }

  int? get diasParaVencimiento {
    if (fechaVencimiento == null) return null;
    return fechaVencimiento!.difference(DateTime.now()).inDays;
  }

  double get valorTotal => (precioUnitario ?? 0) * cantidadActual;
}
