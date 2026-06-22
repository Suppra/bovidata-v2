// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'treatment_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$TreatmentModel {
  String get id => throw _privateConstructorUsedError;
  String get bovineId => throw _privateConstructorUsedError;
  String get tipo => throw _privateConstructorUsedError;
  String get nombre => throw _privateConstructorUsedError;
  String get descripcion => throw _privateConstructorUsedError;
  DateTime get fecha => throw _privateConstructorUsedError;
  String? get medicamento => throw _privateConstructorUsedError;
  double? get dosis => throw _privateConstructorUsedError;
  String? get unidadDosis => throw _privateConstructorUsedError;
  String get veterinarioId => throw _privateConstructorUsedError;
  DateTime? get proximaAplicacion => throw _privateConstructorUsedError;
  bool get completado => throw _privateConstructorUsedError;
  DateTime get fechaCreacion => throw _privateConstructorUsedError;
  String? get observaciones => throw _privateConstructorUsedError;
  double? get costo => throw _privateConstructorUsedError;
  List<String>? get imagenesUrl => throw _privateConstructorUsedError;
  Map<String, dynamic>? get efectosSecundarios =>
      throw _privateConstructorUsedError;
  String get propietarioId => throw _privateConstructorUsedError;

  /// Create a copy of TreatmentModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TreatmentModelCopyWith<TreatmentModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TreatmentModelCopyWith<$Res> {
  factory $TreatmentModelCopyWith(
    TreatmentModel value,
    $Res Function(TreatmentModel) then,
  ) = _$TreatmentModelCopyWithImpl<$Res, TreatmentModel>;
  @useResult
  $Res call({
    String id,
    String bovineId,
    String tipo,
    String nombre,
    String descripcion,
    DateTime fecha,
    String? medicamento,
    double? dosis,
    String? unidadDosis,
    String veterinarioId,
    DateTime? proximaAplicacion,
    bool completado,
    DateTime fechaCreacion,
    String? observaciones,
    double? costo,
    List<String>? imagenesUrl,
    Map<String, dynamic>? efectosSecundarios,
    String propietarioId,
  });
}

/// @nodoc
class _$TreatmentModelCopyWithImpl<$Res, $Val extends TreatmentModel>
    implements $TreatmentModelCopyWith<$Res> {
  _$TreatmentModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TreatmentModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? bovineId = null,
    Object? tipo = null,
    Object? nombre = null,
    Object? descripcion = null,
    Object? fecha = null,
    Object? medicamento = freezed,
    Object? dosis = freezed,
    Object? unidadDosis = freezed,
    Object? veterinarioId = null,
    Object? proximaAplicacion = freezed,
    Object? completado = null,
    Object? fechaCreacion = null,
    Object? observaciones = freezed,
    Object? costo = freezed,
    Object? imagenesUrl = freezed,
    Object? efectosSecundarios = freezed,
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
            nombre: null == nombre
                ? _value.nombre
                : nombre // ignore: cast_nullable_to_non_nullable
                      as String,
            descripcion: null == descripcion
                ? _value.descripcion
                : descripcion // ignore: cast_nullable_to_non_nullable
                      as String,
            fecha: null == fecha
                ? _value.fecha
                : fecha // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            medicamento: freezed == medicamento
                ? _value.medicamento
                : medicamento // ignore: cast_nullable_to_non_nullable
                      as String?,
            dosis: freezed == dosis
                ? _value.dosis
                : dosis // ignore: cast_nullable_to_non_nullable
                      as double?,
            unidadDosis: freezed == unidadDosis
                ? _value.unidadDosis
                : unidadDosis // ignore: cast_nullable_to_non_nullable
                      as String?,
            veterinarioId: null == veterinarioId
                ? _value.veterinarioId
                : veterinarioId // ignore: cast_nullable_to_non_nullable
                      as String,
            proximaAplicacion: freezed == proximaAplicacion
                ? _value.proximaAplicacion
                : proximaAplicacion // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            completado: null == completado
                ? _value.completado
                : completado // ignore: cast_nullable_to_non_nullable
                      as bool,
            fechaCreacion: null == fechaCreacion
                ? _value.fechaCreacion
                : fechaCreacion // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            observaciones: freezed == observaciones
                ? _value.observaciones
                : observaciones // ignore: cast_nullable_to_non_nullable
                      as String?,
            costo: freezed == costo
                ? _value.costo
                : costo // ignore: cast_nullable_to_non_nullable
                      as double?,
            imagenesUrl: freezed == imagenesUrl
                ? _value.imagenesUrl
                : imagenesUrl // ignore: cast_nullable_to_non_nullable
                      as List<String>?,
            efectosSecundarios: freezed == efectosSecundarios
                ? _value.efectosSecundarios
                : efectosSecundarios // ignore: cast_nullable_to_non_nullable
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
abstract class _$$TreatmentModelImplCopyWith<$Res>
    implements $TreatmentModelCopyWith<$Res> {
  factory _$$TreatmentModelImplCopyWith(
    _$TreatmentModelImpl value,
    $Res Function(_$TreatmentModelImpl) then,
  ) = __$$TreatmentModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String bovineId,
    String tipo,
    String nombre,
    String descripcion,
    DateTime fecha,
    String? medicamento,
    double? dosis,
    String? unidadDosis,
    String veterinarioId,
    DateTime? proximaAplicacion,
    bool completado,
    DateTime fechaCreacion,
    String? observaciones,
    double? costo,
    List<String>? imagenesUrl,
    Map<String, dynamic>? efectosSecundarios,
    String propietarioId,
  });
}

/// @nodoc
class __$$TreatmentModelImplCopyWithImpl<$Res>
    extends _$TreatmentModelCopyWithImpl<$Res, _$TreatmentModelImpl>
    implements _$$TreatmentModelImplCopyWith<$Res> {
  __$$TreatmentModelImplCopyWithImpl(
    _$TreatmentModelImpl _value,
    $Res Function(_$TreatmentModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TreatmentModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? bovineId = null,
    Object? tipo = null,
    Object? nombre = null,
    Object? descripcion = null,
    Object? fecha = null,
    Object? medicamento = freezed,
    Object? dosis = freezed,
    Object? unidadDosis = freezed,
    Object? veterinarioId = null,
    Object? proximaAplicacion = freezed,
    Object? completado = null,
    Object? fechaCreacion = null,
    Object? observaciones = freezed,
    Object? costo = freezed,
    Object? imagenesUrl = freezed,
    Object? efectosSecundarios = freezed,
    Object? propietarioId = null,
  }) {
    return _then(
      _$TreatmentModelImpl(
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
        nombre: null == nombre
            ? _value.nombre
            : nombre // ignore: cast_nullable_to_non_nullable
                  as String,
        descripcion: null == descripcion
            ? _value.descripcion
            : descripcion // ignore: cast_nullable_to_non_nullable
                  as String,
        fecha: null == fecha
            ? _value.fecha
            : fecha // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        medicamento: freezed == medicamento
            ? _value.medicamento
            : medicamento // ignore: cast_nullable_to_non_nullable
                  as String?,
        dosis: freezed == dosis
            ? _value.dosis
            : dosis // ignore: cast_nullable_to_non_nullable
                  as double?,
        unidadDosis: freezed == unidadDosis
            ? _value.unidadDosis
            : unidadDosis // ignore: cast_nullable_to_non_nullable
                  as String?,
        veterinarioId: null == veterinarioId
            ? _value.veterinarioId
            : veterinarioId // ignore: cast_nullable_to_non_nullable
                  as String,
        proximaAplicacion: freezed == proximaAplicacion
            ? _value.proximaAplicacion
            : proximaAplicacion // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        completado: null == completado
            ? _value.completado
            : completado // ignore: cast_nullable_to_non_nullable
                  as bool,
        fechaCreacion: null == fechaCreacion
            ? _value.fechaCreacion
            : fechaCreacion // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        observaciones: freezed == observaciones
            ? _value.observaciones
            : observaciones // ignore: cast_nullable_to_non_nullable
                  as String?,
        costo: freezed == costo
            ? _value.costo
            : costo // ignore: cast_nullable_to_non_nullable
                  as double?,
        imagenesUrl: freezed == imagenesUrl
            ? _value._imagenesUrl
            : imagenesUrl // ignore: cast_nullable_to_non_nullable
                  as List<String>?,
        efectosSecundarios: freezed == efectosSecundarios
            ? _value._efectosSecundarios
            : efectosSecundarios // ignore: cast_nullable_to_non_nullable
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

class _$TreatmentModelImpl extends _TreatmentModel {
  const _$TreatmentModelImpl({
    required this.id,
    required this.bovineId,
    required this.tipo,
    required this.nombre,
    required this.descripcion,
    required this.fecha,
    this.medicamento,
    this.dosis,
    this.unidadDosis,
    required this.veterinarioId,
    this.proximaAplicacion,
    this.completado = false,
    required this.fechaCreacion,
    this.observaciones,
    this.costo,
    final List<String>? imagenesUrl,
    final Map<String, dynamic>? efectosSecundarios,
    this.propietarioId = '',
  }) : _imagenesUrl = imagenesUrl,
       _efectosSecundarios = efectosSecundarios,
       super._();

  @override
  final String id;
  @override
  final String bovineId;
  @override
  final String tipo;
  @override
  final String nombre;
  @override
  final String descripcion;
  @override
  final DateTime fecha;
  @override
  final String? medicamento;
  @override
  final double? dosis;
  @override
  final String? unidadDosis;
  @override
  final String veterinarioId;
  @override
  final DateTime? proximaAplicacion;
  @override
  @JsonKey()
  final bool completado;
  @override
  final DateTime fechaCreacion;
  @override
  final String? observaciones;
  @override
  final double? costo;
  final List<String>? _imagenesUrl;
  @override
  List<String>? get imagenesUrl {
    final value = _imagenesUrl;
    if (value == null) return null;
    if (_imagenesUrl is EqualUnmodifiableListView) return _imagenesUrl;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final Map<String, dynamic>? _efectosSecundarios;
  @override
  Map<String, dynamic>? get efectosSecundarios {
    final value = _efectosSecundarios;
    if (value == null) return null;
    if (_efectosSecundarios is EqualUnmodifiableMapView)
      return _efectosSecundarios;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  @JsonKey()
  final String propietarioId;

  @override
  String toString() {
    return 'TreatmentModel(id: $id, bovineId: $bovineId, tipo: $tipo, nombre: $nombre, descripcion: $descripcion, fecha: $fecha, medicamento: $medicamento, dosis: $dosis, unidadDosis: $unidadDosis, veterinarioId: $veterinarioId, proximaAplicacion: $proximaAplicacion, completado: $completado, fechaCreacion: $fechaCreacion, observaciones: $observaciones, costo: $costo, imagenesUrl: $imagenesUrl, efectosSecundarios: $efectosSecundarios, propietarioId: $propietarioId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TreatmentModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.bovineId, bovineId) ||
                other.bovineId == bovineId) &&
            (identical(other.tipo, tipo) || other.tipo == tipo) &&
            (identical(other.nombre, nombre) || other.nombre == nombre) &&
            (identical(other.descripcion, descripcion) ||
                other.descripcion == descripcion) &&
            (identical(other.fecha, fecha) || other.fecha == fecha) &&
            (identical(other.medicamento, medicamento) ||
                other.medicamento == medicamento) &&
            (identical(other.dosis, dosis) || other.dosis == dosis) &&
            (identical(other.unidadDosis, unidadDosis) ||
                other.unidadDosis == unidadDosis) &&
            (identical(other.veterinarioId, veterinarioId) ||
                other.veterinarioId == veterinarioId) &&
            (identical(other.proximaAplicacion, proximaAplicacion) ||
                other.proximaAplicacion == proximaAplicacion) &&
            (identical(other.completado, completado) ||
                other.completado == completado) &&
            (identical(other.fechaCreacion, fechaCreacion) ||
                other.fechaCreacion == fechaCreacion) &&
            (identical(other.observaciones, observaciones) ||
                other.observaciones == observaciones) &&
            (identical(other.costo, costo) || other.costo == costo) &&
            const DeepCollectionEquality().equals(
              other._imagenesUrl,
              _imagenesUrl,
            ) &&
            const DeepCollectionEquality().equals(
              other._efectosSecundarios,
              _efectosSecundarios,
            ) &&
            (identical(other.propietarioId, propietarioId) ||
                other.propietarioId == propietarioId));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    bovineId,
    tipo,
    nombre,
    descripcion,
    fecha,
    medicamento,
    dosis,
    unidadDosis,
    veterinarioId,
    proximaAplicacion,
    completado,
    fechaCreacion,
    observaciones,
    costo,
    const DeepCollectionEquality().hash(_imagenesUrl),
    const DeepCollectionEquality().hash(_efectosSecundarios),
    propietarioId,
  );

  /// Create a copy of TreatmentModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TreatmentModelImplCopyWith<_$TreatmentModelImpl> get copyWith =>
      __$$TreatmentModelImplCopyWithImpl<_$TreatmentModelImpl>(
        this,
        _$identity,
      );
}

abstract class _TreatmentModel extends TreatmentModel {
  const factory _TreatmentModel({
    required final String id,
    required final String bovineId,
    required final String tipo,
    required final String nombre,
    required final String descripcion,
    required final DateTime fecha,
    final String? medicamento,
    final double? dosis,
    final String? unidadDosis,
    required final String veterinarioId,
    final DateTime? proximaAplicacion,
    final bool completado,
    required final DateTime fechaCreacion,
    final String? observaciones,
    final double? costo,
    final List<String>? imagenesUrl,
    final Map<String, dynamic>? efectosSecundarios,
    final String propietarioId,
  }) = _$TreatmentModelImpl;
  const _TreatmentModel._() : super._();

  @override
  String get id;
  @override
  String get bovineId;
  @override
  String get tipo;
  @override
  String get nombre;
  @override
  String get descripcion;
  @override
  DateTime get fecha;
  @override
  String? get medicamento;
  @override
  double? get dosis;
  @override
  String? get unidadDosis;
  @override
  String get veterinarioId;
  @override
  DateTime? get proximaAplicacion;
  @override
  bool get completado;
  @override
  DateTime get fechaCreacion;
  @override
  String? get observaciones;
  @override
  double? get costo;
  @override
  List<String>? get imagenesUrl;
  @override
  Map<String, dynamic>? get efectosSecundarios;
  @override
  String get propietarioId;

  /// Create a copy of TreatmentModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TreatmentModelImplCopyWith<_$TreatmentModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
