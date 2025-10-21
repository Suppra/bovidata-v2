import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/controllers/controllers.dart';
import '../../models/bovine_model.dart';
import '../../constants/app_styles.dart';
import '../../constants/app_constants.dart';

class BovineFormScreen extends StatefulWidget {
  final BovineModel? bovine;
  final bool isEditing;

  const BovineFormScreen({
    super.key,
    this.bovine,
  }) : isEditing = bovine != null;

  @override
  State<BovineFormScreen> createState() => _BovineFormScreenState();
}

class _BovineFormScreenState extends State<BovineFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _razaController = TextEditingController();
  final _colorController = TextEditingController();
  final _pesoController = TextEditingController();
  final _numeroIdentificacionController = TextEditingController();
  final _observacionesController = TextEditingController();
  final _padreController = TextEditingController();
  final _madreController = TextEditingController();

  String _selectedSexo = 'Macho';
  String _selectedEstado = AppConstants.statusSano;
  DateTime _fechaNacimiento = DateTime.now().subtract(const Duration(days: 365));
  bool _isLoading = false;

  final List<String> _sexoOptions = ['Macho', 'Hembra'];
  final List<String> _estadoOptions = [
    AppConstants.statusSano,
    AppConstants.statusEnfermo,
    AppConstants.statusRecuperacion,
  ];

  final List<String> _razasComunes = [
    'Holstein',
    'Angus',
    'Brahman',
    'Charolais',
    'Hereford',
    'Simmental',
    'Limousin',
    'Gyr',
    'Nelore',
    'Cebú',
    'Jersey',
    'Normando',
    'Pardo Suizo',
    'Santa Gertrudis',
    'Brangus',
    'Otra',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.isEditing) {
      _loadBovineData();
    }
  }

  void _loadBovineData() {
    final bovine = widget.bovine!;
    _nombreController.text = bovine.nombre;
    _razaController.text = bovine.raza;
    _colorController.text = bovine.color;
    _pesoController.text = bovine.peso.toString();
    _numeroIdentificacionController.text = bovine.numeroIdentificacion;
    _observacionesController.text = bovine.observaciones ?? '';
    _padreController.text = bovine.padre ?? '';
    _madreController.text = bovine.madre ?? '';
    _selectedSexo = bovine.sexo;
    _selectedEstado = bovine.estado;
    _fechaNacimiento = bovine.fechaNacimiento;
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _razaController.dispose();
    _colorController.dispose();
    _pesoController.dispose();
    _numeroIdentificacionController.dispose();
    _observacionesController.dispose();
    _padreController.dispose();
    _madreController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _fechaNacimiento,
      firstDate: DateTime.now().subtract(const Duration(days: 365 * 20)),
      lastDate: DateTime.now(),
      locale: const Locale('es', 'ES'),
    );
    if (picked != null && picked != _fechaNacimiento) {
      setState(() {
        _fechaNacimiento = picked;
      });
    }
  }

  Future<void> _saveBovine() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final authController = context.read<AuthController>();
      final solidBovineController = context.read<SolidBovineController>();

      final bovineData = BovineModel(
        id: widget.bovine?.id ?? '',
        nombre: _nombreController.text.trim(),
        raza: _razaController.text.trim(),
        sexo: _selectedSexo,
        fechaNacimiento: _fechaNacimiento,
        color: _colorController.text.trim(),
        peso: double.parse(_pesoController.text),
        numeroIdentificacion: _numeroIdentificacionController.text.trim(),
        estado: _selectedEstado,
        propietarioId: authController.currentUser!.id,
        fechaCreacion: widget.bovine?.fechaCreacion ?? DateTime.now(),
        fechaActualizacion: widget.isEditing ? DateTime.now() : null,
        observaciones: _observacionesController.text.trim().isNotEmpty 
            ? _observacionesController.text.trim() 
            : null,
        padre: _padreController.text.trim().isNotEmpty 
            ? _padreController.text.trim() 
            : null,
        madre: _madreController.text.trim().isNotEmpty 
            ? _madreController.text.trim() 
            : null,
      );

      bool success;
      if (widget.isEditing) {
        // Using SOLID controller for update
        success = await solidBovineController.updateBovine(widget.bovine!.id, bovineData);
      } else {
        // Using SOLID controller for creation
        success = await solidBovineController.createBovine(bovineData);
      }

      if (success && mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.isEditing 
                  ? 'Bovino actualizado exitosamente'
                  : 'Bovino registrado exitosamente',
            ),
            backgroundColor: AppColors.success,
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(solidBovineController.errorMessage ?? 'Error al guardar bovino'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Editar Bovino' : 'Nuevo Bovino'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        actions: [
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(AppDimensions.paddingM),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: AppColors.white,
                    strokeWidth: 2,
                  ),
                ),
              ),
            )
          else
            TextButton(
              onPressed: _saveBovine,
              child: Text(
                'GUARDAR',
                style: AppTextStyles.button.copyWith(color: AppColors.white),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.paddingM),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Basic Information Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppDimensions.paddingL),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Información Básica',
                        style: AppTextStyles.h6.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.marginL),

                      // Name
                      TextFormField(
                        controller: _nombreController,
                        textCapitalization: TextCapitalization.words,
                        decoration: const InputDecoration(
                          labelText: 'Nombre del Bovino',
                          prefixIcon: Icon(Icons.pets),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Ingresa el nombre del bovino';
                          }
                          if (value.trim().length > AppConstants.maxBovineName) {
                            return 'El nombre es muy largo';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppDimensions.marginM),

                      // Identification Number
                      TextFormField(
                        controller: _numeroIdentificacionController,
                        decoration: const InputDecoration(
                          labelText: 'Número de Identificación',
                          prefixIcon: Icon(Icons.tag),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Ingresa el número de identificación';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppDimensions.marginM),

                      // Race and Sex Row
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _razasComunes.contains(_razaController.text) 
                                  ? _razaController.text 
                                  : 'Otra',
                              decoration: const InputDecoration(
                                labelText: 'Raza',
                                prefixIcon: Icon(Icons.category),
                              ),
                              items: _razasComunes.map((raza) {
                                return DropdownMenuItem(
                                  value: raza,
                                  child: Text(raza),
                                );
                              }).toList(),
                              onChanged: (value) {
                                if (value == 'Otra') {
                                  _razaController.clear();
                                } else {
                                  _razaController.text = value!;
                                }
                              },
                              validator: (value) {
                                if (value == 'Otra' && _razaController.text.trim().isEmpty) {
                                  return 'Especifica la raza';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: AppDimensions.marginM),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _selectedSexo,
                              decoration: const InputDecoration(
                                labelText: 'Sexo',
                                prefixIcon: Icon(Icons.male),
                              ),
                              items: _sexoOptions.map((sexo) {
                                return DropdownMenuItem(
                                  value: sexo,
                                  child: Text(sexo),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedSexo = value!;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppDimensions.marginM),

                      // Custom Race Field (if "Otra" is selected)
                      if (_razaController.text.isEmpty || !_razasComunes.contains(_razaController.text))
                        Column(
                          children: [
                            TextFormField(
                              controller: _razaController,
                              textCapitalization: TextCapitalization.words,
                              decoration: const InputDecoration(
                                labelText: 'Especificar Raza',
                                prefixIcon: Icon(Icons.edit),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Ingresa la raza del bovino';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: AppDimensions.marginM),
                          ],
                        ),

                      // Birth Date
                      InkWell(
                        onTap: _selectDate,
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Fecha de Nacimiento',
                            prefixIcon: Icon(Icons.cake),
                            suffixIcon: Icon(Icons.calendar_today),
                          ),
                          child: Text(
                            DateFormat(AppConstants.dateFormat).format(_fechaNacimiento),
                            style: AppTextStyles.body2,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: AppDimensions.marginL),

              // Physical Information Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppDimensions.paddingL),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Información Física',
                        style: AppTextStyles.h6.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.marginL),

                      // Color and Weight Row
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _colorController,
                              textCapitalization: TextCapitalization.words,
                              decoration: const InputDecoration(
                                labelText: 'Color',
                                prefixIcon: Icon(Icons.palette),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Ingresa el color del bovino';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: AppDimensions.marginM),
                          Expanded(
                            child: TextFormField(
                              controller: _pesoController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Peso (kg)',
                                prefixIcon: Icon(Icons.monitor_weight),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Ingresa el peso';
                                }
                                final peso = double.tryParse(value);
                                if (peso == null || peso <= 0) {
                                  return 'Peso inválido';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppDimensions.marginM),

                      // Status
                      DropdownButtonFormField<String>(
                        value: _selectedEstado,
                        decoration: const InputDecoration(
                          labelText: 'Estado de Salud',
                          prefixIcon: Icon(Icons.health_and_safety),
                        ),
                        items: _estadoOptions.map((estado) {
                          return DropdownMenuItem(
                            value: estado,
                            child: Text(estado),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedEstado = value!;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: AppDimensions.marginL),

              // Additional Information Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppDimensions.paddingL),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Información Adicional',
                        style: AppTextStyles.h6.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.marginL),

                      // Parents Row
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _padreController,
                              textCapitalization: TextCapitalization.words,
                              decoration: const InputDecoration(
                                labelText: 'Padre (Opcional)',
                                prefixIcon: Icon(Icons.male),
                              ),
                            ),
                          ),
                          const SizedBox(width: AppDimensions.marginM),
                          Expanded(
                            child: TextFormField(
                              controller: _madreController,
                              textCapitalization: TextCapitalization.words,
                              decoration: const InputDecoration(
                                labelText: 'Madre (Opcional)',
                                prefixIcon: Icon(Icons.female),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppDimensions.marginM),

                      // Observations
                      TextFormField(
                        controller: _observacionesController,
                        maxLines: 3,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: const InputDecoration(
                          labelText: 'Observaciones (Opcional)',
                          prefixIcon: Icon(Icons.notes),
                          alignLabelWithHint: true,
                        ),
                        validator: (value) {
                          if (value != null && value.length > AppConstants.maxTreatmentDescription) {
                            return 'Las observaciones son muy largas';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: AppDimensions.marginXL),

              // Save Button
              ElevatedButton(
                onPressed: _isLoading ? null : _saveBovine,
                child: _isLoading
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: AppColors.white,
                              strokeWidth: 2,
                            ),
                          ),
                          SizedBox(width: AppDimensions.marginS),
                          Text('Guardando...'),
                        ],
                      )
                    : Text(widget.isEditing ? 'Actualizar Bovino' : 'Guardar Bovino'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
