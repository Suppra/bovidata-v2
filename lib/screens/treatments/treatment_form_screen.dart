import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/controllers/controllers.dart';
import '../../models/treatment_model.dart';
import '../../models/bovine_model.dart';
import '../../constants/app_styles.dart';
import '../../constants/app_constants.dart';

class TreatmentFormScreen extends StatefulWidget {
  final TreatmentModel? treatment;
  final String? bovineId;

  const TreatmentFormScreen({
    super.key,
    this.treatment,
    this.bovineId,
  });

  @override
  State<TreatmentFormScreen> createState() => _TreatmentFormScreenState();
}

class _TreatmentFormScreenState extends State<TreatmentFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _medicamentoController = TextEditingController();
  final _dosisController = TextEditingController();
  final _observacionesController = TextEditingController();
  
  String _selectedBovineId = '';
  String _selectedTipo = '';
  DateTime _fechaTratamiento = DateTime.now();
  DateTime? _proximaAplicacion;
  bool _completado = false;

  final List<String> _tiposTratamiento = [
    'Vacunación',
    'Antiparasitario',
    'Antibiótico',
    'Antiinflamatorio',
    'Vitaminas',
    'Desparasitación',
    'Tratamiento reproductivo',
    'Tratamiento dermatológico',
    'Tratamiento respiratorio',
    'Tratamiento digestivo',
    'Otro',
  ];

  @override
  void initState() {
    super.initState();
    
    // Si hay un bovineId específico, seleccionarlo
    if (widget.bovineId != null) {
      _selectedBovineId = widget.bovineId!;
    }
    
    // Si estamos editando un tratamiento existente
    if (widget.treatment != null) {
      _loadTreatmentData();
    }
    
    // Cargar bovinos si no están cargados
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final solidBovineController = context.read<SolidBovineController>();
      if (solidBovineController.bovines.isEmpty) {
        solidBovineController.initialize();
      }
    });
  }

  void _loadTreatmentData() {
    final treatment = widget.treatment!;
    _nombreController.text = treatment.nombre;
    _descripcionController.text = treatment.descripcion;
    _medicamentoController.text = treatment.medicamento ?? '';
    _dosisController.text = treatment.dosis?.toString() ?? '';
    _observacionesController.text = treatment.observaciones ?? '';
    _selectedBovineId = treatment.bovineId;
    _selectedTipo = treatment.tipo;
    _fechaTratamiento = treatment.fecha;
    _proximaAplicacion = treatment.proximaAplicacion;
    _completado = treatment.completado;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.treatment == null ? 'Nuevo Tratamiento' : 'Editar Tratamiento'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
      ),
      body: Consumer3<SolidTreatmentController, SolidBovineController, AuthController>(
        builder: (context, treatmentController, solidBovineController, authController, child) {
          return Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppDimensions.paddingL),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Información del Bovino
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(AppDimensions.paddingL),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Información del Bovino',
                            style: AppTextStyles.h6.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: AppDimensions.marginM),
                          
                          // Selector de Bovino
                          DropdownButtonFormField<String>(
                            value: _selectedBovineId.isEmpty ? null : _selectedBovineId,
                            decoration: const InputDecoration(
                              labelText: 'Bovino *',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.pets),
                            ),
                            items: solidBovineController.bovines.map((bovine) {
                              return DropdownMenuItem(
                                value: bovine.id,
                                child: Text('${bovine.nombre} (${bovine.numeroIdentificacion})'),
                              );
                            }).toList(),
                            onChanged: widget.bovineId == null ? (value) {
                              setState(() {
                                _selectedBovineId = value ?? '';
                              });
                            } : null,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor selecciona un bovino';
                              }
                              return null;
                            },
                          ),
                          
                          if (_selectedBovineId.isNotEmpty) ...[
                            const SizedBox(height: AppDimensions.marginM),
                            Consumer<SolidBovineController>(
                              builder: (context, controller, child) {
                                final bovine = controller.bovines.firstWhere(
                                  (b) => b.id == _selectedBovineId,
                                  orElse: () => BovineModel(
                                    id: '',
                                    nombre: '',
                                    numeroIdentificacion: '',
                                    raza: '',
                                    sexo: '',
                                    fechaNacimiento: DateTime.now(),
                                    peso: 0,
                                    color: '',
                                    estado: '',
                                    fechaCreacion: DateTime.now(),
                                    propietarioId: '',
                                  ),
                                );
                                
                                if (bovine.id.isEmpty) return const SizedBox.shrink();
                                
                                return Container(
                                  padding: const EdgeInsets.all(AppDimensions.paddingM),
                                  decoration: BoxDecoration(
                                    color: AppColors.surface,
                                    borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.pets,
                                        color: AppColors.primary,
                                      ),
                                      const SizedBox(width: AppDimensions.marginM),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              bovine.nombre,
                                              style: AppTextStyles.body1.copyWith(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Text(
                                              '${bovine.raza} • ${bovine.estado}',
                                              style: AppTextStyles.body2.copyWith(
                                                color: AppColors.textSecondary,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: AppDimensions.marginL),

                  // Información del Tratamiento
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(AppDimensions.paddingL),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Detalles del Tratamiento',
                            style: AppTextStyles.h6.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: AppDimensions.marginM),

                          // Tipo de Tratamiento
                          DropdownButtonFormField<String>(
                            value: _selectedTipo.isEmpty ? null : _selectedTipo,
                            decoration: const InputDecoration(
                              labelText: 'Tipo de Tratamiento *',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.medical_services),
                            ),
                            items: _tiposTratamiento.map((tipo) {
                              return DropdownMenuItem(
                                value: tipo,
                                child: Text(tipo),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedTipo = value ?? '';
                              });
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor selecciona el tipo de tratamiento';
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: AppDimensions.marginM),

                          // Nombre del Tratamiento
                          TextFormField(
                            controller: _nombreController,
                            decoration: const InputDecoration(
                              labelText: 'Nombre del Tratamiento *',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.title),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor ingresa el nombre del tratamiento';
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: AppDimensions.marginM),

                          // Descripción
                          TextFormField(
                            controller: _descripcionController,
                            decoration: const InputDecoration(
                              labelText: 'Descripción *',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.description),
                            ),
                            maxLines: 3,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor ingresa una descripción';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: AppDimensions.marginL),

                  // Información del Medicamento
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(AppDimensions.paddingL),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Medicamento y Dosis',
                            style: AppTextStyles.h6.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: AppDimensions.marginM),

                          // Medicamento
                          TextFormField(
                            controller: _medicamentoController,
                            decoration: const InputDecoration(
                              labelText: 'Medicamento',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.medication),
                            ),
                          ),

                          const SizedBox(height: AppDimensions.marginM),

                          // Dosis
                          TextFormField(
                            controller: _dosisController,
                            decoration: const InputDecoration(
                              labelText: 'Dosis (mg)',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.monitor_weight),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: AppDimensions.marginL),

                  // Fechas
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(AppDimensions.paddingL),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Programación',
                            style: AppTextStyles.h6.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: AppDimensions.marginM),

                          // Fecha del Tratamiento
                          InkWell(
                            onTap: () => _selectDate(context, true),
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                labelText: 'Fecha del Tratamiento *',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.calendar_today),
                              ),
                              child: Text(
                                DateFormat(AppConstants.dateFormat).format(_fechaTratamiento),
                              ),
                            ),
                          ),

                          const SizedBox(height: AppDimensions.marginM),

                          // Próxima Aplicación
                          InkWell(
                            onTap: () => _selectDate(context, false),
                            child: InputDecorator(
                              decoration: InputDecoration(
                                labelText: 'Próxima Aplicación (Opcional)',
                                border: const OutlineInputBorder(),
                                prefixIcon: const Icon(Icons.schedule),
                                suffixIcon: _proximaAplicacion != null
                                    ? IconButton(
                                        icon: const Icon(Icons.clear),
                                        onPressed: () {
                                          setState(() {
                                            _proximaAplicacion = null;
                                          });
                                        },
                                      )
                                    : null,
                              ),
                              child: Text(
                                _proximaAplicacion != null
                                    ? DateFormat(AppConstants.dateFormat).format(_proximaAplicacion!)
                                    : 'Seleccionar fecha',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: AppDimensions.marginL),

                  // Estado y Observaciones
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(AppDimensions.paddingL),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Estado y Notas',
                            style: AppTextStyles.h6.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: AppDimensions.marginM),

                          // Estado Completado
                          SwitchListTile(
                            title: const Text('Tratamiento Completado'),
                            subtitle: Text(_completado 
                                ? 'El tratamiento ha sido aplicado'
                                : 'El tratamiento está pendiente'),
                            value: _completado,
                            onChanged: (value) {
                              setState(() {
                                _completado = value;
                              });
                            },
                          ),

                          const SizedBox(height: AppDimensions.marginM),

                          // Observaciones
                          TextFormField(
                            controller: _observacionesController,
                            decoration: const InputDecoration(
                              labelText: 'Observaciones',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.notes),
                            ),
                            maxLines: 3,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: AppDimensions.marginXL),

                  // Botones de Acción
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Cancelar'),
                        ),
                      ),
                      const SizedBox(width: AppDimensions.marginM),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed: treatmentController.isLoading ? null : _saveTreatment,
                          child: treatmentController.isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : Text(widget.treatment == null ? 'Crear Tratamiento' : 'Actualizar'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _selectDate(BuildContext context, bool isMainDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isMainDate ? _fechaTratamiento : (_proximaAplicacion ?? DateTime.now()),
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );

    if (picked != null) {
      setState(() {
        if (isMainDate) {
          _fechaTratamiento = picked;
        } else {
          _proximaAplicacion = picked;
        }
      });
    }
  }

  Future<void> _saveTreatment() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final authController = context.read<AuthController>();
    final treatmentController = context.read<SolidTreatmentController>();

    final treatment = TreatmentModel(
      id: widget.treatment?.id ?? '',
      bovineId: _selectedBovineId,
      tipo: _selectedTipo,
      nombre: _nombreController.text.trim(),
      descripcion: _descripcionController.text.trim(),
      fecha: _fechaTratamiento,
      medicamento: _medicamentoController.text.trim().isEmpty 
          ? null 
          : _medicamentoController.text.trim(),
      dosis: _dosisController.text.trim().isEmpty 
          ? null 
          : double.tryParse(_dosisController.text.trim()),
      unidadDosis: _dosisController.text.trim().isEmpty ? null : 'mg',
      veterinarioId: authController.currentUser!.id,
      proximaAplicacion: _proximaAplicacion,
      completado: _completado,
      fechaCreacion: widget.treatment?.fechaCreacion ?? DateTime.now(),
      observaciones: _observacionesController.text.trim().isEmpty 
          ? null 
          : _observacionesController.text.trim(),
    );

    bool success;
    if (widget.treatment == null) {
      success = await treatmentController.createTreatment(treatment);
    } else {
      success = await treatmentController.updateTreatment(treatment);
    }

    if (success && mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.treatment == null 
              ? 'Tratamiento creado exitosamente'
              : 'Tratamiento actualizado exitosamente'),
          backgroundColor: AppColors.success,
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(treatmentController.errorMessage ?? 
              'Error al ${widget.treatment == null ? 'crear' : 'actualizar'} el tratamiento'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _descripcionController.dispose();
    _medicamentoController.dispose();
    _dosisController.dispose();
    _observacionesController.dispose();
    super.dispose();
  }
}
