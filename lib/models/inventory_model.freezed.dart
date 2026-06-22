// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'inventory_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$InventoryModel {
  String get id => throw _privateConstructorUsedError;
  String get nombre => throw _privateConstructorUsedError;
  String get tipo => throw _privateConstructorUsedError;
  String get categoria => throw _privateConstructorUsedError;
  int get cantidadActual => throw _privateConstructorUsedError;
  int get cantidadMinima => throw _privateConstructorUsedError;
  String get unidad => throw _privateConstructorUsedError;
  double? get precioUnitario => throw _privateConstructorUsedError;
  DateTime? get fechaVencimiento => throw _privateConstructorUsedError;
  String? get lote => throw _privateConstructorUsedError;
  String? get proveedor => throw _privateConstructorUsedError;
  String? get descripcion => throw _privateConstructorUsedError;
  DateTime get fechaCreacion => throw _privateConstructorUsedError;
  DateTime? get fechaActualizacion => throw _privateConstructorUsedError;
  String? get imagenUrl => throw _privateConstructorUsedError;
  bool get activo => throw _privateConstructorUsedError;
  Map<String, dynamic>? get propiedades => throw _privateConstructorUsedError;
  String get propietarioId => throw _privateConstructorUsedError;

  /// Create a copy of InventoryModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $InventoryModelCopyWith<InventoryModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $InventoryModelCopyWith<$Res> {
  factory $InventoryModelCopyWith(
    InventoryModel value,
    $Res Function(InventoryModel) then,
  ) = _$InventoryModelCopyWithImpl<$Res, InventoryModel>;
  @useResult
  $Res call({
    String id,
    String nombre,
    String tipo,
    String categoria,
    int cantidadActual,
    int cantidadMinima,
    String unidad,
    double? precioUnitario,
    DateTime? fechaVencimiento,
    String? lote,
    String? proveedor,
    String? descripcion,
    DateTime fechaCreacion,
    DateTime? fechaActualizacion,
    String? imagenUrl,
    bool activo,
    Map<String, dynamic>? propiedades,
    String propietarioId,
  });
}

/// @nodoc
class _$InventoryModelCopyWithImpl<$Res, $Val extends InventoryModel>
    implements $InventoryModelCopyWith<$Res> {
  _$InventoryModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of InventoryModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? nombre = null,
    Object? tipo = null,
    Object? categoria = null,
    Object? cantidadActual = null,
    Object? cantidadMinima = null,
    Object? unidad = null,
    Object? precioUnitario = freezed,
    Object? fechaVencimiento = freezed,
    Object? lote = freezed,
    Object? proveedor = freezed,
    Object? descripcion = freezed,
    Object? fechaCreacion = null,
    Object? fechaActualizacion = freezed,
    Object? imagenUrl = freezed,
    Object? activo = null,
    Object? propiedades = freezed,
    Object? propietarioId = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            nombre: null == nombre
                ? _value.nombre
                : nombre // ignore: cast_nullable_to_non_nullable
                      as String,
            tipo: null == tipo
                ? _value.tipo
                : tipo // ignore: cast_nullable_to_non_nullable
                      as String,
            categoria: null == categoria
                ? _value.categoria
                : categoria // ignore: cast_nullable_to_non_nullable
                      as String,
            cantidadActual: null == cantidadActual
                ? _value.cantidadActual
                : cantidadActual // ignore: cast_nullable_to_non_nullable
                      as int,
            cantidadMinima: null == cantidadMinima
                ? _value.cantidadMinima
                : cantidadMinima // ignore: cast_nullable_to_non_nullable
                      as int,
            unidad: null == unidad
                ? _value.unidad
                : unidad // ignore: cast_nullable_to_non_nullable
                      as String,
            precioUnitario: freezed == precioUnitario
                ? _value.precioUnitario
                : precioUnitario // ignore: cast_nullable_to_non_nullable
                      as double?,
            fechaVencimiento: freezed == fechaVencimiento
                ? _value.fechaVencimiento
                : fechaVencimiento // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            lote: freezed == lote
                ? _value.lote
                : lote // ignore: cast_nullable_to_non_nullable
                      as String?,
            proveedor: freezed == proveedor
                ? _value.proveedor
                : proveedor // ignore: cast_nullable_to_non_nullable
                      as String?,
            descripcion: freezed == descripcion
                ? _value.descripcion
                : descripcion // ignore: cast_nullable_to_non_nullable
                      as String?,
            fechaCreacion: null == fechaCreacion
                ? _value.fechaCreacion
                : fechaCreacion // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            fechaActualizacion: freezed == fechaActualizacion
                ? _value.fechaActualizacion
                : fechaActualizacion // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            imagenUrl: freezed == imagenUrl
                ? _value.imagenUrl
                : imagenUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            activo: null == activo
                ? _value.activo
                : activo // ignore: cast_nullable_to_non_nullable
                      as bool,
            propiedades: freezed == propiedades
                ? _value.propiedades
                : propiedades // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>?,
            propietarioId: null == propietarioId
                ? _value.propietarioId
                : propietarioId // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$InventoryModelImplCopyWith<$Res>
    implements $InventoryModelCopyWith<$Res> {
  factory _$$InventoryModelImplCopyWith(
    _$InventoryModelImpl value,
    $Res Function(_$InventoryModelImpl) then,
  ) = __$$InventoryModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String nombre,
    String tipo,
    String categoria,
    int cantidadActual,
    int cantidadMinima,
    String unidad,
    double? precioUnitario,
    DateTime? fechaVencimiento,
    String? lote,
    String? proveedor,
    String? descripcion,
    DateTime fechaCreacion,
    DateTime? fechaActualizacion,
    String? imagenUrl,
    bool activo,
    Map<String, dynamic>? propiedades,
    String propietarioId,
  });
}

/// @nodoc
class __$$InventoryModelImplCopyWithImpl<$Res>
    extends _$InventoryModelCopyWithImpl<$Res, _$InventoryModelImpl>
    implements _$$InventoryModelImplCopyWith<$Res> {
  __$$InventoryModelImplCopyWithImpl(
    _$InventoryModelImpl _value,
    $Res Function(_$InventoryModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of InventoryModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? nombre = null,
    Object? tipo = null,
    Object? categoria = null,
    Object? cantidadActual = null,
    Object? cantidadMinima = null,
    Object? unidad = null,
    Object? precioUnitario = freezed,
    Object? fechaVencimiento = freezed,
    Object? lote = freezed,
    Object? proveedor = freezed,
    Object? descripcion = freezed,
    Object? fechaCreacion = null,
    Object? fechaActualizacion = freezed,
    Object? imagenUrl = freezed,
    Object? activo = null,
    Object? propiedades = freezed,
    Object? propietarioId = null,
  }) {
    return _then(
      _$InventoryModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        nombre: null == nombre
            ? _value.nombre
            : nombre // ignore: cast_nullable_to_non_nullable
                  as String,
        tipo: null == tipo
            ? _value.tipo
            : tipo // ignore: cast_nullable_to_non_nullable
                  as String,
        categoria: null == categoria
            ? _value.categoria
            : categoria // ignore: cast_nullable_to_non_nullable
                  as String,
        cantidadActual: null == cantidadActual
            ? _value.cantidadActual
            : cantidadActual // ignore: cast_nullable_to_non_nullable
                  as int,
        cantidadMinima: null == cantidadMinima
            ? _value.cantidadMinima
            : cantidadMinima // ignore: cast_nullable_to_non_nullable
                  as int,
        unidad: null == unidad
            ? _value.unidad
            : unidad // ignore: cast_nullable_to_non_nullable
                  as String,
        precioUnitario: freezed == precioUnitario
            ? _value.precioUnitario
            : precioUnitario // ignore: cast_nullable_to_non_nullable
                  as double?,
        fechaVencimiento: freezed == fechaVencimiento
            ? _value.fechaVencimiento
            : fechaVencimiento // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        lote: freezed == lote
            ? _value.lote
            : lote // ignore: cast_nullable_to_non_nullable
                  as String?,
        proveedor: freezed == proveedor
            ? _value.proveedor
            : proveedor // ignore: cast_nullable_to_non_nullable
                  as String?,
        descripcion: freezed == descripcion
            ? _value.descripcion
            : descripcion // ignore: cast_nullable_to_non_nullable
                  as String?,
        fechaCreacion: null == fechaCreacion
            ? _value.fechaCreacion
            : fechaCreacion // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        fechaActualizacion: freezed == fechaActualizacion
            ? _value.fechaActualizacion
            : fechaActualizacion // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        imagenUrl: freezed == imagenUrl
            ? _value.imagenUrl
            : imagenUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        activo: null == activo
            ? _value.activo
            : activo // ignore: cast_nullable_to_non_nullable
                  as bool,
        propiedades: freezed == propiedades
            ? _value._propiedades
            : propiedades // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>?,
        propietarioId: null == propietarioId
            ? _value.propietarioId
            : propietarioId // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc

class _$InventoryModelImpl extends _InventoryModel {
  const _$InventoryModelImpl({
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
    final Map<String, dynamic>? propiedades,
    this.propietarioId = '',
  }) : _propiedades = propiedades,
       super._();

  @override
  final String id;
  @override
  final String nombre;
  @override
  final String tipo;
  @override
  final String categoria;
  @override
  final int cantidadActual;
  @override
  final int cantidadMinima;
  @override
  final String unidad;
  @override
  final double? precioUnitario;
  @override
  final DateTime? fechaVencimiento;
  @override
  final String? lote;
  @override
  final String? proveedor;
  @override
  final String? descripcion;
  @override
  final DateTime fechaCreacion;
  @override
  final DateTime? fechaActualizacion;
  @override
  final String? imagenUrl;
  @override
  @JsonKey()
  final bool activo;
  final Map<String, dynamic>? _propiedades;
  @override
  Map<String, dynamic>? get propiedades {
    final value = _propiedades;
    if (value == null) return null;
    if (_propiedades is EqualUnmodifiableMapView) return _propiedades;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  @JsonKey()
  final String propietarioId;

  @override
  String toString() {
    return 'InventoryModel(id: $id, nombre: $nombre, tipo: $tipo, categoria: $categoria, cantidadActual: $cantidadActual, cantidadMinima: $cantidadMinima, unidad: $unidad, precioUnitario: $precioUnitario, fechaVencimiento: $fechaVencimiento, lote: $lote, proveedor: $proveedor, descripcion: $descripcion, fechaCreacion: $fechaCreacion, fechaActualizacion: $fechaActualizacion, imagenUrl: $imagenUrl, activo: $activo, propiedades: $propiedades, propietarioId: $propietarioId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$InventoryModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.nombre, nombre) || other.nombre == nombre) &&
            (identical(other.tipo, tipo) || other.tipo == tipo) &&
            (identical(other.categoria, categoria) ||
                other.categoria == categoria) &&
            (identical(other.cantidadActual, cantidadActual) ||
                other.cantidadActual == cantidadActual) &&
            (identical(other.cantidadMinima, cantidadMinima) ||
                other.cantidadMinima == cantidadMinima) &&
            (identical(other.unidad, unidad) || other.unidad == unidad) &&
            (identical(other.precioUnitario, precioUnitario) ||
                other.precioUnitario == precioUnitario) &&
            (identical(other.fechaVencimiento, fechaVencimiento) ||
                other.fechaVencimiento == fechaVencimiento) &&
            (identical(other.lote, lote) || other.lote == lote) &&
            (identical(other.proveedor, proveedor) ||
                other.proveedor == proveedor) &&
            (identical(other.descripcion, descripcion) ||
                other.descripcion == descripcion) &&
            (identical(other.fechaCreacion, fechaCreacion) ||
                other.fechaCreacion == fechaCreacion) &&
            (identical(other.fechaActualizacion, fechaActualizacion) ||
                other.fechaActualizacion == fechaActualizacion) &&
            (identical(other.imagenUrl, imagenUrl) ||
                other.imagenUrl == imagenUrl) &&
            (identical(other.activo, activo) || other.activo == activo) &&
            const DeepCollectionEquality().equals(
              other._propiedades,
              _propiedades,
            ) &&
            (identical(other.propietarioId, propietarioId) ||
                other.propietarioId == propietarioId));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    nombre,
    tipo,
    categoria,
    cantidadActual,
    cantidadMinima,
    unidad,
    precioUnitario,
    fechaVencimiento,
    lote,
    proveedor,
    descripcion,
    fechaCreacion,
    fechaActualizacion,
    imagenUrl,
    activo,
    const DeepCollectionEquality().hash(_propiedades),
    propietarioId,
  );

  /// Create a copy of InventoryModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$InventoryModelImplCopyWith<_$InventoryModelImpl> get copyWith =>
      __$$InventoryModelImplCopyWithImpl<_$InventoryModelImpl>(
        this,
        _$identity,
      );
}

abstract class _InventoryModel extends InventoryModel {
  const factory _InventoryModel({
    required final String id,
    required final String nombre,
    required final String tipo,
    required final String categoria,
    required final int cantidadActual,
    required final int cantidadMinima,
    required final String unidad,
    final double? precioUnitario,
    final DateTime? fechaVencimiento,
    final String? lote,
    final String? proveedor,
    final String? descripcion,
    required final DateTime fechaCreacion,
    final DateTime? fechaActualizacion,
    final String? imagenUrl,
    final bool activo,
    final Map<String, dynamic>? propiedades,
    final String propietarioId,
  }) = _$InventoryModelImpl;
  const _InventoryModel._() : super._();

  @override
  String get id;
  @override
  String get nombre;
  @override
  String get tipo;
  @override
  String get categoria;
  @override
  int get cantidadActual;
  @override
  int get cantidadMinima;
  @override
  String get unidad;
  @override
  double? get precioUnitario;
  @override
  DateTime? get fechaVencimiento;
  @override
  String? get lote;
  @override
  String? get proveedor;
  @override
  String? get descripcion;
  @override
  DateTime get fechaCreacion;
  @override
  DateTime? get fechaActualizacion;
  @override
  String? get imagenUrl;
  @override
  bool get activo;
  @override
  Map<String, dynamic>? get propiedades;
  @override
  String get propietarioId;

  /// Create a copy of InventoryModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$InventoryModelImplCopyWith<_$InventoryModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
