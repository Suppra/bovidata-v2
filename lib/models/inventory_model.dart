import 'package:cloud_firestore/cloud_firestore.dart';

class InventoryModel {
  final String id;
  final String nombre;
  final String tipo;
  final String categoria;
  final int cantidadActual;
  final int cantidadMinima;
  final String unidad;
  final double? precioUnitario;
  final DateTime? fechaVencimiento;
  final String? lote;
  final String? proveedor;
  final String? descripcion;
  final DateTime fechaCreacion;
  final DateTime? fechaActualizacion;
  final String? imagenUrl;
  final bool activo;
  final Map<String, dynamic>? propiedades;

  InventoryModel({
    required this.id,
    required this.nombre,
    required this.tipo,
    required this.categoria,
    required this.cantidadActual,
    required this.cantidadMinima,
    required this.unidad,
    this.precioUnitario,
    this.fechaVencimiento,
    this.lote,
    this.proveedor,
    this.descripcion,
    required this.fechaCreacion,
    this.fechaActualizacion,
    this.imagenUrl,
    this.activo = true,
    this.propiedades,
  });

  // Convert from Firestore Document
  factory InventoryModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
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
    );
  }

  // Convert to Firestore Document
  Map<String, dynamic> toFirestore() {
    return {
      'nombre': nombre,
      'tipo': tipo,
      'categoria': categoria,
      'cantidadActual': cantidadActual,
      'cantidadMinima': cantidadMinima,
      'unidad': unidad,
      'precioUnitario': precioUnitario,
      'fechaVencimiento': fechaVencimiento != null 
          ? Timestamp.fromDate(fechaVencimiento!) 
          : null,
      'lote': lote,
      'proveedor': proveedor,
      'descripcion': descripcion,
      'fechaCreacion': Timestamp.fromDate(fechaCreacion),
      'fechaActualizacion': fechaActualizacion != null 
          ? Timestamp.fromDate(fechaActualizacion!) 
          : null,
      'imagenUrl': imagenUrl,
      'activo': activo,
      'propiedades': propiedades,
    };
  }

  // Check if stock is low
  bool get isLowStock => cantidadActual <= cantidadMinima;

  // Check if item is expired
  bool get isExpired {
    if (fechaVencimiento == null) return false;
    return DateTime.now().isAfter(fechaVencimiento!);
  }

  // Check if item is expiring soon (within 30 days)
  bool get isExpiringSoon {
    if (fechaVencimiento == null) return false;
    final now = DateTime.now();
    final thirtyDaysFromNow = now.add(const Duration(days: 30));
    return fechaVencimiento!.isBefore(thirtyDaysFromNow) && !isExpired;
  }

  // Days until expiration
  int? get diasParaVencimiento {
    if (fechaVencimiento == null) return null;
    return fechaVencimiento!.difference(DateTime.now()).inDays;
  }

  // Total value in inventory
  double get valorTotal {
    return (precioUnitario ?? 0) * cantidadActual;
  }

  // Copy with method
  InventoryModel copyWith({
    String? id,
    String? nombre,
    String? tipo,
    String? categoria,
    int? cantidadActual,
    int? cantidadMinima,
    String? unidad,
    double? precioUnitario,
    DateTime? fechaVencimiento,
    String? lote,
    String? proveedor,
    String? descripcion,
    DateTime? fechaCreacion,
    DateTime? fechaActualizacion,
    String? imagenUrl,
    bool? activo,
    Map<String, dynamic>? propiedades,
  }) {
    return InventoryModel(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      tipo: tipo ?? this.tipo,
      categoria: categoria ?? this.categoria,
      cantidadActual: cantidadActual ?? this.cantidadActual,
      cantidadMinima: cantidadMinima ?? this.cantidadMinima,
      unidad: unidad ?? this.unidad,
      precioUnitario: precioUnitario ?? this.precioUnitario,
      fechaVencimiento: fechaVencimiento ?? this.fechaVencimiento,
      lote: lote ?? this.lote,
      proveedor: proveedor ?? this.proveedor,
      descripcion: descripcion ?? this.descripcion,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
      fechaActualizacion: fechaActualizacion ?? this.fechaActualizacion,
      imagenUrl: imagenUrl ?? this.imagenUrl,
      activo: activo ?? this.activo,
      propiedades: propiedades ?? this.propiedades,
    );
  }

  // Factory method para crear inventario vacío (Pattern: Factory Method)
  factory InventoryModel.empty() {
    return InventoryModel(
      id: '',
      nombre: '',
      tipo: '',
      categoria: '',
      cantidadActual: 0,
      cantidadMinima: 0,
      unidad: '',
      fechaCreacion: DateTime.now(),
    );
  }

  // Factory method desde Map (Pattern: Factory Method)
  factory InventoryModel.fromMap(Map<String, dynamic> data, String id) {
    return InventoryModel(
      id: id,
      nombre: data['nombre'] ?? '',
      tipo: data['tipo'] ?? '',
      categoria: data['categoria'] ?? '',
      cantidadActual: data['cantidadActual'] ?? 0,
      cantidadMinima: data['cantidadMinima'] ?? 0,
      unidad: data['unidad'] ?? '',
      precioUnitario: data['precioUnitario']?.toDouble(),
      fechaVencimiento: data['fechaVencimiento'] is DateTime
          ? data['fechaVencimiento']
          : null,
      lote: data['lote'],
      proveedor: data['proveedor'],
      descripcion: data['descripcion'],
      fechaCreacion: data['fechaCreacion'] is DateTime
          ? data['fechaCreacion']
          : DateTime.now(),
      fechaActualizacion: data['fechaActualizacion'] is DateTime
          ? data['fechaActualizacion']
          : null,
      imagenUrl: data['imagenUrl'],
      activo: data['activo'] ?? true,
      propiedades: data['propiedades'],
    );
  }
}