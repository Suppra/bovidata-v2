// Builder Pattern - Construcción fluida de entidades complejas
import '../../models/bovine_model.dart';
import '../../models/treatment_model.dart';

// Builder abstracto
abstract class EntityBuilder<T> {
  T build();
  EntityBuilder<T> reset();
}

// Builder para Bovino
class BovineBuilder implements EntityBuilder<BovineModel> {
  String _id = '';
  String _nombre = '';
  String _raza = '';
  String _sexo = '';
  DateTime? _fechaNacimiento;
  String _color = '';
  double _peso = 0.0;
  String _numeroIdentificacion = '';
  String _estado = 'Sano';
  String _propietarioId = '';
  DateTime? _fechaCreacion;
  DateTime? _fechaActualizacion;
  String? _imagenUrl;
  String? _observaciones;
  String? _padre;
  String? _madre;
  bool _activo = true;

  BovineBuilder setId(String id) {
    _id = id;
    return this;
  }

  BovineBuilder setNombre(String nombre) {
    _nombre = nombre;
    return this;
  }

  BovineBuilder setRaza(String raza) {
    _raza = raza;
    return this;
  }

  BovineBuilder setSexo(String sexo) {
    _sexo = sexo;
    return this;
  }

  BovineBuilder setFechaNacimiento(DateTime fecha) {
    _fechaNacimiento = fecha;
    return this;
  }

  BovineBuilder setColor(String color) {
    _color = color;
    return this;
  }

  BovineBuilder setPeso(double peso) {
    _peso = peso;
    return this;
  }

  BovineBuilder setNumeroIdentificacion(String numero) {
    _numeroIdentificacion = numero;
    return this;
  }

  BovineBuilder setEstado(String estado) {
    _estado = estado;
    return this;
  }

  BovineBuilder setPropietarioId(String propietarioId) {
    _propietarioId = propietarioId;
    return this;
  }

  BovineBuilder setFechaCreacion(DateTime fecha) {
    _fechaCreacion = fecha;
    return this;
  }

  BovineBuilder setImagenUrl(String? url) {
    _imagenUrl = url;
    return this;
  }

  BovineBuilder setObservaciones(String? observaciones) {
    _observaciones = observaciones;
    return this;
  }

  BovineBuilder setPadre(String? padre) {
    _padre = padre;
    return this;
  }

  BovineBuilder setMadre(String? madre) {
    _madre = madre;
    return this;
  }

  BovineBuilder setActivo(bool activo) {
    _activo = activo;
    return this;
  }

  @override
  BovineModel build() {
    return BovineModel(
      id: _id,
      nombre: _nombre,
      raza: _raza,
      sexo: _sexo,
      fechaNacimiento: _fechaNacimiento ?? DateTime.now(),
      color: _color,
      peso: _peso,
      numeroIdentificacion: _numeroIdentificacion,
      estado: _estado,
      propietarioId: _propietarioId,
      fechaCreacion: _fechaCreacion ?? DateTime.now(),
      fechaActualizacion: _fechaActualizacion,
      imagenUrl: _imagenUrl,
      observaciones: _observaciones,
      padre: _padre,
      madre: _madre,
      activo: _activo,
    );
  }

  @override
  BovineBuilder reset() {
    _id = '';
    _nombre = '';
    _raza = '';
    _sexo = '';
    _fechaNacimiento = null;
    _color = '';
    _peso = 0.0;
    _numeroIdentificacion = '';
    _estado = 'Sano';
    _propietarioId = '';
    _fechaCreacion = null;
    _fechaActualizacion = null;
    _imagenUrl = null;
    _observaciones = null;
    _padre = null;
    _madre = null;
    _activo = true;
    return this;
  }
}

// Builder para Tratamiento
class TreatmentBuilder implements EntityBuilder<TreatmentModel> {
  String _id = '';
  String _bovineId = '';
  String _tipo = '';
  String _nombre = '';
  String _descripcion = '';
  DateTime? _fecha;
  String? _medicamento;
  double? _dosis;
  String? _unidadDosis;
  String _veterinarioId = '';
  DateTime? _proximaAplicacion;
  bool _completado = false;
  DateTime? _fechaCreacion;
  String? _observaciones;
  double? _costo;
  List<String>? _imagenesUrl;
  Map<String, dynamic>? _efectosSecundarios;

  TreatmentBuilder setId(String id) {
    _id = id;
    return this;
  }

  TreatmentBuilder setBovineId(String bovineId) {
    _bovineId = bovineId;
    return this;
  }

  TreatmentBuilder setTipo(String tipo) {
    _tipo = tipo;
    return this;
  }

  TreatmentBuilder setNombre(String nombre) {
    _nombre = nombre;
    return this;
  }

  TreatmentBuilder setDescripcion(String descripcion) {
    _descripcion = descripcion;
    return this;
  }

  TreatmentBuilder setFecha(DateTime fecha) {
    _fecha = fecha;
    return this;
  }

  TreatmentBuilder setMedicamento(String? medicamento) {
    _medicamento = medicamento;
    return this;
  }

  TreatmentBuilder setDosis(double? dosis) {
    _dosis = dosis;
    return this;
  }

  TreatmentBuilder setVeterinarioId(String veterinarioId) {
    _veterinarioId = veterinarioId;
    return this;
  }

  TreatmentBuilder setProximaAplicacion(DateTime? fecha) {
    _proximaAplicacion = fecha;
    return this;
  }

  TreatmentBuilder setCompletado(bool completado) {
    _completado = completado;
    return this;
  }

  TreatmentBuilder setObservaciones(String? observaciones) {
    _observaciones = observaciones;
    return this;
  }

  TreatmentBuilder setCosto(double? costo) {
    _costo = costo;
    return this;
  }

  @override
  TreatmentModel build() {
    return TreatmentModel(
      id: _id,
      bovineId: _bovineId,
      tipo: _tipo,
      nombre: _nombre,
      descripcion: _descripcion,
      fecha: _fecha ?? DateTime.now(),
      medicamento: _medicamento,
      dosis: _dosis,
      unidadDosis: _unidadDosis,
      veterinarioId: _veterinarioId,
      proximaAplicacion: _proximaAplicacion,
      completado: _completado,
      fechaCreacion: _fechaCreacion ?? DateTime.now(),
      observaciones: _observaciones,
      costo: _costo,
      imagenesUrl: _imagenesUrl,
      efectosSecundarios: _efectosSecundarios,
    );
  }

  @override
  TreatmentBuilder reset() {
    _id = '';
    _bovineId = '';
    _tipo = '';
    _nombre = '';
    _descripcion = '';
    _fecha = null;
    _medicamento = null;
    _dosis = null;
    _unidadDosis = null;
    _veterinarioId = '';
    _proximaAplicacion = null;
    _completado = false;
    _fechaCreacion = null;
    _observaciones = null;
    _costo = null;
    _imagenesUrl = null;
    _efectosSecundarios = null;
    return this;
  }
}

// Director para construir entidades complejas con configuraciones predeterminadas
class EntityDirector {
  static BovineModel createStandardBovine({
    required String nombre,
    required String raza,
    required String sexo,
    required DateTime fechaNacimiento,
    required String propietarioId,
  }) {
    return BovineBuilder()
        .setNombre(nombre)
        .setRaza(raza)
        .setSexo(sexo)
        .setFechaNacimiento(fechaNacimiento)
        .setPropietarioId(propietarioId)
        .setEstado('Sano')
        .setActivo(true)
        .setFechaCreacion(DateTime.now())
        .build();
  }

  static TreatmentModel createVaccination({
    required String bovineId,
    required String veterinarioId,
    required String nombre,
    required String medicamento,
  }) {
    return TreatmentBuilder()
        .setBovineId(bovineId)
        .setVeterinarioId(veterinarioId)
        .setTipo('Vacunación')
        .setNombre(nombre)
        .setDescripcion('Vacunación preventiva')
        .setMedicamento(medicamento)
        .setFecha(DateTime.now())
        .setCompletado(false)
        .build();
  }

  static TreatmentModel createMedicalTreatment({
    required String bovineId,
    required String veterinarioId,
    required String tipo,
    required String nombre,
    required String descripcion,
  }) {
    return TreatmentBuilder()
        .setBovineId(bovineId)
        .setVeterinarioId(veterinarioId)
        .setTipo(tipo)
        .setNombre(nombre)
        .setDescripcion(descripcion)
        .setFecha(DateTime.now())
        .setCompletado(false)
        .build();
  }
}
