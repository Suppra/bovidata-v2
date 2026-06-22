import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/controllers/controllers.dart';
import '../../models/inventory_model.dart';
import '../../constants/app_styles.dart';
import '../../constants/app_constants.dart';

class InventoryFormScreen extends StatefulWidget {
  final InventoryModel? item;

  const InventoryFormScreen({
    super.key,
    this.item,
  });

  @override
  State<InventoryFormScreen> createState() => _InventoryFormScreenState();
}

class _InventoryFormScreenState extends State<InventoryFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _cantidadActualController = TextEditingController();
  final _cantidadMinimaController = TextEditingController();
  final _precioUnitarioController = TextEditingController();
  final _loteController = TextEditingController();
  final _proveedorController = TextEditingController();
  
  String _selectedCategoria = '';
  String _selectedTipo = '';
  String _selectedUnidad = '';
  DateTime? _fechaVencimiento;

  final List<String> _categorias = [
    'Medicamento',
    'Alimento',
    'Equipo',
    'Suministro',
    'Vacuna',
    'Antiparasitario',
    'Vitaminas',
    'Material de limpieza',
    'Herramientas',
    'Otro',
  ];

  final List<String> _tipos = [
    'Medicamento Injectable',
    'Medicamento Oral',
    'Alimento Balanceado',
    'Suplemento',
    'Equipo Médico',
    'Herramienta',
    'Material Veterinario',
    'Producto de Limpieza',
    'Otro',
  ];

  final List<String> _unidades = [
    'Unidad',
    'Kilogramo',
    'Gramo',
    'Litro',
    'Mililitro',
    'Metro',
    'Centímetro',
    'Caja',
    'Bolsa',
    'Frasco',
    'Dosis',
    'Tableta',
    'Ampolla',
  ];

  @override
  void initState() {
    super.initState();
    
    if (widget.item != null) {
      _loadItemData();
    }
  }

  void _loadItemData() {
    final item = widget.item!;
    _nombreController.text = item.nombre;
    _descripcionController.text = item.descripcion ?? '';
    _cantidadActualController.text = item.cantidadActual.toString();
    _cantidadMinimaController.text = item.cantidadMinima.toString();
    _precioUnitarioController.text = item.precioUnitario?.toString() ?? '';
    _loteController.text = item.lote ?? '';
    _proveedorController.text = item.proveedor ?? '';
    _selectedCategoria = item.categoria;
    _selectedTipo = item.tipo;
    _selectedUnidad = item.unidad;
    _fechaVencimiento = item.fechaVencimiento;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.item == null ? 'Nuevo Item' : 'Editar Item'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
      ),
      body: Consumer2<SolidInventoryController, AuthController>(
        builder: (context, SolidInventoryController, authController, child) {
          return Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppDimensions.paddingL),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Información Básica
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
                          const SizedBox(height: AppDimensions.marginM),

                          // Nombre
                          TextFormField(
                            controller: _nombreController,
                            decoration: const InputDecoration(
                              labelText: 'Nombre del Producto *',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.inventory_2),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor ingresa el nombre del producto';
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: AppDimensions.marginM),

                          // Categoría
                          DropdownButtonFormField<String>(
                            value: _selectedCategoria.isEmpty ? null : _selectedCategoria,
                            decoration: const InputDecoration(
                              labelText: 'Categoría *',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.category),
                            ),
                            items: _categorias.map((categoria) {
                              return DropdownMenuItem(
                                value: categoria,
                                child: Text(categoria),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedCategoria = value ?? '';
                              });
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor selecciona una categoría';
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: AppDimensions.marginM),

                          // Tipo
                          DropdownButtonFormField<String>(
                            value: _selectedTipo.isEmpty ? null : _selectedTipo,
                            decoration: const InputDecoration(
                              labelText: 'Tipo *',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.type_specimen),
                            ),
                            items: _tipos.map((tipo) {
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
                                return 'Por favor selecciona un tipo';
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: AppDimensions.marginM),

                          // Descripción
                          TextFormField(
                            controller: _descripcionController,
                            decoration: const InputDecoration(
                              labelText: 'Descripción',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.description),
                            ),
                            maxLines: 3,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: AppDimensions.marginL),

                  // Stock y Cantidades
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(AppDimensions.paddingL),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Stock y Cantidades',
                            style: AppTextStyles.h6.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: AppDimensions.marginM),

                          Row(
                            children: [
                              // Cantidad Actual
                              Expanded(
                                child: TextFormField(
                                  controller: _cantidadActualController,
                                  decoration: const InputDecoration(
                                    labelText: 'Cantidad Actual *',
                                    border: OutlineInputBorder(),
                                    prefixIcon: Icon(Icons.inventory),
                                  ),
                                  keyboardType: TextInputType.number,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Ingresa la cantidad';
                                    }
                                    if (int.tryParse(value) == null || int.parse(value) < 0) {
                                      return 'Cantidad inválida';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              
                              const SizedBox(width: AppDimensions.marginM),

                              // Cantidad Mínima
                              Expanded(
                                child: TextFormField(
                                  controller: _cantidadMinimaController,
                                  decoration: const InputDecoration(
                                    labelText: 'Stock Mínimo *',
                                    border: OutlineInputBorder(),
                                    prefixIcon: Icon(Icons.warning),
                                  ),
                                  keyboardType: TextInputType.number,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Ingresa el mínimo';
                                    }
                                    if (int.tryParse(value) == null || int.parse(value) < 0) {
                                      return 'Cantidad inválida';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: AppDimensions.marginM),

                          // Unidad de Medida
                          DropdownButtonFormField<String>(
                            value: _selectedUnidad.isEmpty ? null : _selectedUnidad,
                            decoration: const InputDecoration(
                              labelText: 'Unidad de Medida *',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.straighten),
                            ),
                            items: _unidades.map((unidad) {
                              return DropdownMenuItem(
                                value: unidad,
                                child: Text(unidad),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedUnidad = value ?? '';
                              });
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Selecciona una unidad';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: AppDimensions.marginL),

                  // Información Comercial
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(AppDimensions.paddingL),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Información Comercial',
                            style: AppTextStyles.h6.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: AppDimensions.marginM),

                          Row(
                            children: [
                              // Precio Unitario
                              Expanded(
                                child: TextFormField(
                                  controller: _precioUnitarioController,
                                  decoration: const InputDecoration(
                                    labelText: 'Precio Unitario',
                                    border: OutlineInputBorder(),
                                    prefixIcon: Icon(Icons.attach_money),
                                  ),
                                  keyboardType: TextInputType.number,
                                  validator: (value) {
                                    if (value != null && value.isNotEmpty) {
                                      if (double.tryParse(value) == null || double.parse(value) < 0) {
                                        return 'Precio inválido';
                                      }
                                    }
                                    return null;
                                  },
                                ),
                              ),

                              const SizedBox(width: AppDimensions.marginM),

                              // Lote
                              Expanded(
                                child: TextFormField(
                                  controller: _loteController,
                                  decoration: const InputDecoration(
                                    labelText: 'Lote',
                                    border: OutlineInputBorder(),
                                    prefixIcon: Icon(Icons.qr_code),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: AppDimensions.marginM),

                          // Proveedor
                          TextFormField(
                            controller: _proveedorController,
                            decoration: const InputDecoration(
                              labelText: 'Proveedor',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.business),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: AppDimensions.marginL),

                  // Fecha de Vencimiento
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(AppDimensions.paddingL),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Fecha de Vencimiento',
                            style: AppTextStyles.h6.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: AppDimensions.marginM),

                          InkWell(
                            onTap: () => _selectDate(context),
                            child: InputDecorator(
                              decoration: InputDecoration(
                                labelText: 'Fecha de Vencimiento (Opcional)',
                                border: const OutlineInputBorder(),
                                prefixIcon: const Icon(Icons.calendar_today),
                                suffixIcon: _fechaVencimiento != null
                                    ? IconButton(
                                        icon: const Icon(Icons.clear),
                                        onPressed: () {
                                          setState(() {
                                            _fechaVencimiento = null;
                                          });
                                        },
                                      )
                                    : null,
                              ),
                              child: Text(
                                _fechaVencimiento != null
                                    ? DateFormat(AppConstants.dateFormat).format(_fechaVencimiento!)
                                    : 'Sin fecha de vencimiento',
                              ),
                            ),
                          ),

                          if (_fechaVencimiento != null) ...[
                            const SizedBox(height: AppDimensions.marginM),
                            
                            Container(
                              padding: const EdgeInsets.all(AppDimensions.paddingM),
                              decoration: BoxDecoration(
                                color: _getExpirationWarningColor().withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                                border: Border.all(color: _getExpirationWarningColor()),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    _getExpirationWarningIcon(),
                                    color: _getExpirationWarningColor(),
                                  ),
                                  const SizedBox(width: AppDimensions.marginM),
                                  Expanded(
                                    child: Text(
                                      _getExpirationWarningText(),
                                      style: AppTextStyles.body2.copyWith(
                                        color: _getExpirationWarningColor(),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
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
                          onPressed: SolidInventoryController.isLoading ? null : _saveItem,
                          child: SolidInventoryController.isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : Text(widget.item == null ? 'Crear Item' : 'Actualizar'),
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

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _fechaVencimiento ?? DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );

    if (picked != null) {
      setState(() {
        _fechaVencimiento = picked;
      });
    }
  }

  Color _getExpirationWarningColor() {
    if (_fechaVencimiento == null) return AppColors.textSecondary;
    
    final daysUntilExpiry = _fechaVencimiento!.difference(DateTime.now()).inDays;
    
    if (daysUntilExpiry < 0) return AppColors.error;
    if (daysUntilExpiry <= 30) return AppColors.warning;
    return AppColors.success;
  }

  IconData _getExpirationWarningIcon() {
    if (_fechaVencimiento == null) return Icons.info;
    
    final daysUntilExpiry = _fechaVencimiento!.difference(DateTime.now()).inDays;
    
    if (daysUntilExpiry < 0) return Icons.dangerous;
    if (daysUntilExpiry <= 30) return Icons.warning;
    return Icons.check_circle;
  }

  String _getExpirationWarningText() {
    if (_fechaVencimiento == null) return 'Sin fecha de vencimiento';
    
    final daysUntilExpiry = _fechaVencimiento!.difference(DateTime.now()).inDays;
    
    if (daysUntilExpiry < 0) {
      return 'Producto vencido hace ${(-daysUntilExpiry)} días';
    } else if (daysUntilExpiry == 0) {
      return 'Producto vence hoy';
    } else if (daysUntilExpiry <= 30) {
      return 'Vence en $daysUntilExpiry días';
    } else {
      return 'Vence en $daysUntilExpiry días';
    }
  }

  Future<void> _saveItem() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final inventoryController = context.read<SolidInventoryController>();

    final item = InventoryModel(
      id: widget.item?.id ?? '',
      nombre: _nombreController.text.trim(),
      tipo: _selectedTipo,
      categoria: _selectedCategoria,
      cantidadActual: int.parse(_cantidadActualController.text.trim()),
      cantidadMinima: int.parse(_cantidadMinimaController.text.trim()),
      unidad: _selectedUnidad,
      precioUnitario: _precioUnitarioController.text.trim().isEmpty 
          ? null 
          : double.parse(_precioUnitarioController.text.trim()),
      fechaVencimiento: _fechaVencimiento,
      lote: _loteController.text.trim().isEmpty ? null : _loteController.text.trim(),
      proveedor: _proveedorController.text.trim().isEmpty ? null : _proveedorController.text.trim(),
      descripcion: _descripcionController.text.trim().isEmpty ? null : _descripcionController.text.trim(),
      fechaCreacion: widget.item?.fechaCreacion ?? DateTime.now(),
      activo: widget.item?.activo ?? true,
    );

    bool success;
    if (widget.item == null) {
      success = await inventoryController.createItem(item);
    } else {
      success = await inventoryController.updateItem(item);
    }

    if (success && mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.item == null 
              ? 'Item creado exitosamente'
              : 'Item actualizado exitosamente'),
          backgroundColor: AppColors.success,
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(inventoryController.errorMessage ?? 
              'Error al ${widget.item == null ? 'crear' : 'actualizar'} el item'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _descripcionController.dispose();
    _cantidadActualController.dispose();
    _cantidadMinimaController.dispose();
    _precioUnitarioController.dispose();
    _loteController.dispose();
    _proveedorController.dispose();
    super.dispose();
  }
}
