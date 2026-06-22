// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'incident_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$IncidentModel {
  String get id => throw _privateConstructorUsedError;
  String get bovineId => throw _privateConstructorUsedError;
  String get tipo => throw _privateConstructorUsedError;
  String get descripcion => throw _privateConstructorUsedError;
  DateTime get fecha => throw _privateConstructorUsedError;
  String get gravedad => throw _privateConstructorUsedError;
  String get estado => throw _privateConstructorUsedError;
  String get reportadoPor => throw _privateConstructorUsedError;
  String? get tratamientoId => throw _privateConstructorUsedError;
  DateTime get fechaCreacion => throw _privateConstructorUsedError;
  DateTime? get fechaResolucion => throw _privateConstructorUsedError;
  String? get observaciones => throw _privateConstructorUsedError;
  List<String>? get imagenesUrl => throw _privateConstructorUsedError;
  Map<String, dynamic>? get datos => throw _privateConstructorUsedError;
  String get propietarioId => throw _privateConstructorUsedError;

  /// Create a copy of IncidentModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $IncidentModelCopyWith<IncidentModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $IncidentModelCopyWith<$Res> {
  factory $IncidentModelCopyWith(
    IncidentModel value,
    $Res Function(IncidentModel) then,
  ) = _$IncidentModelCopyWithImpl<$Res, IncidentModel>;
  @useResult
  $Res call({
    String id,
    String bovineId,
    String tipo,
    String descripcion,
    DateTime fecha,
    String gravedad,
    String estado,
    String reportadoPor,
    String? tratamientoId,
    DateTime fechaCreacion,
    DateTime? fechaResolucion,
    String? observaciones,
    List<String>? imagenesUrl,
    Map<String, dynamic>? datos,
    String propietarioId,
  });
}

/// @nodoc
class _$IncidentModelCopyWithImpl<$Res, $Val extends IncidentModel>
    implements $IncidentModelCopyWith<$Res> {
  _$IncidentModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of IncidentModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? bovineId = null,
    Object? tipo = null,
    Object? descripcion = null,
    Object? fecha = null,
    Object? gravedad = null,
    Object? estado = null,
    Object? reportadoPor = null,
    Object? tratamientoId = freezed,
    Object? fechaCreacion = null,
    Object? fechaResolucion = freezed,
    Object? observaciones = freezed,
    Object? imagenesUrl = freezed,
    Object? datos = freezed,
    Object? propietarioId = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            bovineId: null == bovineId
                ? _value.bovineId
                : bovineId // ignore: cast_nullable_to_non_nullable
                      as String,
            tipo: null == tipo
                ? _value.tipo
                : tipo // ignore: cast_nullable_to_non_nullable
                      as String,
            descripcion: null == descripcion
                ? _value.descripcion
                : descripcion // ignore: cast_nullable_to_non_nullable
                      as String,
            fecha: null == fecha
                ? _value.fecha
                : fecha // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            gravedad: null == gravedad
                ? _value.gravedad
                : gravedad // ignore: cast_nullable_to_non_nullable
                      as String,
            estado: null == estado
                ? _value.estado
                : estado // ignore: cast_nullable_to_non_nullable
                      as String,
            reportadoPor: null == reportadoPor
                ? _value.reportadoPor
                : reportadoPor // ignore: cast_nullable_to_non_nullable
                      as String,
            tratamientoId: freezed == tratamientoId
                ? _value.tratamientoId
                : tratamientoId // ignore: cast_nullable_to_non_nullable
                      as String?,
            fechaCreacion: null == fechaCreacion
                ? _value.fechaCreacion
                : fechaCreacion // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            fechaResolucion: freezed == fechaResolucion
                ? _value.fechaResolucion
                : fechaResolucion // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            observaciones: freezed == observaciones
                ? _value.observaciones
                : observaciones // ignore: cast_nullable_to_non_nullable
                      as String?,
            imagenesUrl: freezed == imagenesUrl
                ? _value.imagenesUrl
                : imagenesUrl // ignore: cast_nullable_to_non_nullable
                      as List<String>?,
            datos: freezed == datos
                ? _value.datos
                : datos // ignore: cast_nullable_to_non_nullable
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
abstract class _$$IncidentModelImplCopyWith<$Res>
    implements $IncidentModelCopyWith<$Res> {
  factory _$$IncidentModelImplCopyWith(
    _$IncidentModelImpl value,
    $Res Function(_$IncidentModelImpl) then,
  ) = __$$IncidentModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String bovineId,
    String tipo,
    String descripcion,
    DateTime fecha,
    String gravedad,
    String estado,
    String reportadoPor,
    String? tratamientoId,
    DateTime fechaCreacion,
    DateTime? fechaResolucion,
    String? observaciones,
    List<String>? imagenesUrl,
    Map<String, dynamic>? datos,
    String propietarioId,
  });
}

/// @nodoc
class __$$IncidentModelImplCopyWithImpl<$Res>
    extends _$IncidentModelCopyWithImpl<$Res, _$IncidentModelImpl>
    implements _$$IncidentModelImplCopyWith<$Res> {
  __$$IncidentModelImplCopyWithImpl(
    _$IncidentModelImpl _value,
    $Res Function(_$IncidentModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of IncidentModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? bovineId = null,
    Object? tipo = null,
    Object? descripcion = null,
    Object? fecha = null,
    Object? gravedad = null,
    Object? estado = null,
    Object? reportadoPor = null,
    Object? tratamientoId = freezed,
    Object? fechaCreacion = null,
    Object? fechaResolucion = freezed,
    Object? observaciones = freezed,
    Object? imagenesUrl = freezed,
    Object? datos = freezed,
    Object? propietarioId = null,
  }) {
    return _then(
      _$IncidentModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        bovineId: null == bovineId
            ? _value.bovineId
            : bovineId // ignore: cast_nullable_to_non_nullable
                  as String,
        tipo: null == tipo
            ? _value.tipo
            : tipo // ignore: cast_nullable_to_non_nullable
                  as String,
        descripcion: null == descripcion
            ? _value.descripcion
            : descripcion // ignore: cast_nullable_to_non_nullable
                  as String,
        fecha: null == fecha
            ? _value.fecha
            : fecha // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        gravedad: null == gravedad
            ? _value.gravedad
            : gravedad // ignore: cast_nullable_to_non_nullable
                  as String,
        estado: null == estado
            ? _value.estado
            : estado // ignore: cast_nullable_to_non_nullable
                  as String,
        reportadoPor: null == reportadoPor
            ? _value.reportadoPor
            : reportadoPor // ignore: cast_nullable_to_non_nullable
                  as String,
        tratamientoId: freezed == tratamientoId
            ? _value.tratamientoId
            : tratamientoId // ignore: cast_nullable_to_non_nullable
                  as String?,
        fechaCreacion: null == fechaCreacion
            ? _value.fechaCreacion
            : fechaCreacion // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        fechaResolucion: freezed == fechaResolucion
            ? _value.fechaResolucion
            : fechaResolucion // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        observaciones: freezed == observaciones
            ? _value.observaciones
            : observaciones // ignore: cast_nullable_to_non_nullable
                  as String?,
        imagenesUrl: freezed == imagenesUrl
            ? _value._imagenesUrl
            : imagenesUrl // ignore: cast_nullable_to_non_nullable
                  as List<String>?,
        datos: freezed == datos
            ? _value._datos
            : datos // ignore: cast_nullable_to_non_nullable
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

class _$IncidentModelImpl extends _IncidentModel {
  const _$IncidentModelImpl({
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
    final List<String>? imagenesUrl,
    final Map<String, dynamic>? datos,
    this.propietarioId = '',
  }) : _imagenesUrl = imagenesUrl,
       _datos = datos,
       super._();

  @override
  final String id;
  @override
  final String bovineId;
  @override
  final String tipo;
  @override
  final String descripcion;
  @override
  final DateTime fecha;
  @override
  final String gravedad;
  @override
  final String estado;
  @override
  final String reportadoPor;
  @override
  final String? tratamientoId;
  @override
  final DateTime fechaCreacion;
  @override
  final DateTime? fechaResolucion;
  @override
  final String? observaciones;
  final List<String>? _imagenesUrl;
  @override
  List<String>? get imagenesUrl {
    final value = _imagenesUrl;
    if (value == null) return null;
    if (_imagenesUrl is EqualUnmodifiableListView) return _imagenesUrl;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final Map<String, dynamic>? _datos;
  @override
  Map<String, dynamic>? get datos {
    final value = _datos;
    if (value == null) return null;
    if (_datos is EqualUnmodifiableMapView) return _datos;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  @JsonKey()
  final String propietarioId;

  @override
  String toString() {
    return 'IncidentModel(id: $id, bovineId: $bovineId, tipo: $tipo, descripcion: $descripcion, fecha: $fecha, gravedad: $gravedad, estado: $estado, reportadoPor: $reportadoPor, tratamientoId: $tratamientoId, fechaCreacion: $fechaCreacion, fechaResolucion: $fechaResolucion, observaciones: $observaciones, imagenesUrl: $imagenesUrl, datos: $datos, propietarioId: $propietarioId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$IncidentModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.bovineId, bovineId) ||
                other.bovineId == bovineId) &&
            (identical(other.tipo, tipo) || other.tipo == tipo) &&
            (identical(other.descripcion, descripcion) ||
                other.descripcion == descripcion) &&
            (identical(other.fecha, fecha) || other.fecha == fecha) &&
            (identical(other.gravedad, gravedad) ||
                other.gravedad == gravedad) &&
            (identical(other.estado, estado) || other.estado == estado) &&
            (identical(other.reportadoPor, reportadoPor) ||
                other.reportadoPor == reportadoPor) &&
            (identical(other.tratamientoId, tratamientoId) ||
                other.tratamientoId == tratamientoId) &&
            (identical(other.fechaCreacion, fechaCreacion) ||
                other.fechaCreacion == fechaCreacion) &&
            (identical(other.fechaResolucion, fechaResolucion) ||
                other.fechaResolucion == fechaResolucion) &&
            (identical(other.observaciones, observaciones) ||
                other.observaciones == observaciones) &&
            const DeepCollectionEquality().equals(
              other._imagenesUrl,
              _imagenesUrl,
            ) &&
            const DeepCollectionEquality().equals(other._datos, _datos) &&
            (identical(other.propietarioId, propietarioId) ||
                other.propietarioId == propietarioId));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    bovineId,
    tipo,
    descripcion,
    fecha,
    gravedad,
    estado,
    reportadoPor,
    tratamientoId,
    fechaCreacion,
    fechaResolucion,
    observaciones,
    const DeepCollectionEquality().hash(_imagenesUrl),
    const DeepCollectionEquality().hash(_datos),
    propietarioId,
  );

  /// Create a copy of IncidentModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$IncidentModelImplCopyWith<_$IncidentModelImpl> get copyWith =>
      __$$IncidentModelImplCopyWithImpl<_$IncidentModelImpl>(this, _$identity);
}

abstract class _IncidentModel extends IncidentModel {
  const factory _IncidentModel({
    required final String id,
    required final String bovineId,
    required final String tipo,
    required final String descripcion,
    required final DateTime fecha,
    required final String gravedad,
    required final String estado,
    required final String reportadoPor,
    final String? tratamientoId,
    required final DateTime fechaCreacion,
    final DateTime? fechaResolucion,
    final String? observaciones,
    final List<String>? imagenesUrl,
    final Map<String, dynamic>? datos,
    final String propietarioId,
  }) = _$IncidentModelImpl;
  const _IncidentModel._() : super._();

  @override
  String get id;
  @override
  String get bovineId;
  @override
  String get tipo;
  @override
  String get descripcion;
  @override
  DateTime get fecha;
  @override
  String get gravedad;
  @override
  String get estado;
  @override
  String get reportadoPor;
  @override
  String? get tratamientoId;
  @override
  DateTime get fechaCreacion;
  @override
  DateTime? get fechaResolucion;
  @override
  String? get observaciones;
  @override
  List<String>? get imagenesUrl;
  @override
  Map<String, dynamic>? get datos;
  @override
  String get propietarioId;

  /// Create a copy of IncidentModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$IncidentModelImplCopyWith<_$IncidentModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
