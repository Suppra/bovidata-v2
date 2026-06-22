import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../controllers/auth_controller.dart';
import '../../core/controllers/controllers.dart';
import '../../models/inventory_model.dart';
import '../../constants/app_styles.dart';
import '../../constants/app_constants.dart';
import 'inventory_form_screen.dart';
import 'inventory_detail_screen.dart';

class InventoryListScreen extends StatefulWidget {
  final String? title;

  const InventoryListScreen({
    super.key,
    this.title,
  });

  @override
  State<InventoryListScreen> createState() => _InventoryListScreenState();
}

class _InventoryListScreenState extends State<InventoryListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'Todos';
  bool _showLowStock = false;
  bool _showExpired = false;
  bool _showExpiringSoon = false;

  final List<String> _categories = [
    'Todos',
    'Medicamento',
    'Alimento', 
    'Equipo',
    'Suministro',
    'Vacuna',
    'Antiparasitario',
    'Vitaminas',
    'Otro',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SolidInventoryController>().loadInventory();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title ?? 'Inventario'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        actions: [
          Consumer<AuthController>(
            builder: (context, authController, child) {
              if (authController.isGanadero || authController.isEmpleado) {
                return IconButton(
                  icon: const Icon(Icons.add_box_rounded),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const InventoryFormScreen(),
                      ),
                    );
                  },
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and Filter Section
          Container(
            padding: const EdgeInsets.all(AppDimensions.paddingM),
            color: AppColors.surface,
            child: Column(
              children: [
                // Search Bar
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Buscar en inventario...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              context.read<SolidInventoryController>().search('');
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                    ),
                  ),
                  onChanged: (value) {
                    context.read<SolidInventoryController>().search(value);
                  },
                ),

                const SizedBox(height: AppDimensions.marginM),

                // Filters Row
                Row(
                  children: [
                    // Category Filter
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedCategory,
                        decoration: const InputDecoration(
                          labelText: 'Categoría',
                          border: OutlineInputBorder(),
                        ),
                        items: _categories.map((category) {
                          return DropdownMenuItem(
                            value: category,
                            child: Text(category),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedCategory = value!;
                          });
                          context.read<SolidInventoryController>().filterByCategory(
                            value == 'Todos' ? '' : value!,
                          );
                        },
                      ),
                    ),

                    const SizedBox(width: AppDimensions.marginM),

                    // Status Filter
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.filter_list),
                      onSelected: (value) {
                        setState(() {
                          switch (value) {
                            case 'lowStock':
                              _showLowStock = !_showLowStock;
                              break;
                            case 'expired':
                              _showExpired = !_showExpired;
                              break;
                            case 'expiringSoon':
                              _showExpiringSoon = !_showExpiringSoon;
                              break;
                          }
                        });
                        
                        final controller = context.read<SolidInventoryController>();
                        controller.toggleShowLowStock(_showLowStock);
                        controller.toggleShowExpired(_showExpired);
                        controller.toggleShowExpiringSoon(_showExpiringSoon);
                      },
                      itemBuilder: (context) => [
                        CheckedPopupMenuItem(
                          value: 'lowStock',
                          checked: _showLowStock,
                          child: const Text('Stock bajo'),
                        ),
                        CheckedPopupMenuItem(
                          value: 'expired',
                          checked: _showExpired,
                          child: const Text('Vencidos'),
                        ),
                        CheckedPopupMenuItem(
                          value: 'expiringSoon',
                          checked: _showExpiringSoon,
                          child: const Text('Por vencer'),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Statistics Section
          Consumer<SolidInventoryController>(
            builder: (context, controller, child) {

              return Container(
                padding: const EdgeInsets.all(AppDimensions.paddingM),
                margin: const EdgeInsets.all(AppDimensions.marginM),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                  boxShadow: const [
                    BoxShadow(
                      color: AppColors.grey200,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem(
                      'Total',
                      controller.totalItems.toString(),
                      Icons.inventory,
                      AppColors.primary,
                    ),
                    _buildStatItem(
                      'Stock Bajo',
                      controller.lowStockItems.toString(),
                      Icons.warning,
                      AppColors.warning,
                    ),
                    _buildStatItem(
                      'Sin Stock',
                      controller.outOfStockItems.toString(),
                      Icons.remove_circle,
                      AppColors.error,
                    ),
                    _buildStatItem(
                      'Vencidos',
                      controller.expiredItems.toString(),
                      Icons.dangerous,
                      AppColors.error,
                    ),
                  ],
                ),
              );
            },
          ),

          // Inventory List
          Expanded(
            child: Consumer<SolidInventoryController>(
              builder: (context, controller, child) {
                if (controller.isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (controller.errorMessage != null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error,
                          size: 64,
                          color: AppColors.error,
                        ),
                        const SizedBox(height: AppDimensions.marginM),
                        Text(
                          controller.errorMessage!,
                          style: AppTextStyles.h6,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppDimensions.marginL),
                        ElevatedButton(
                          onPressed: () {
                            controller.clearError();
                            controller.loadInventory();
                          },
                          child: const Text('Reintentar'),
                        ),
                      ],
                    ),
                  );
                }

                if (controller.inventory.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inventory_2_outlined,
                          size: 64,
                          color: AppColors.grey400,
                        ),
                        const SizedBox(height: AppDimensions.marginM),
                        Text(
                          'No hay items en el inventario',
                          style: AppTextStyles.h6.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: AppDimensions.marginS),
                        Text(
                          'Los items aparecerán aquí una vez que sean agregados',
                          style: AppTextStyles.body2.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        if (context.watch<AuthController>().isGanadero || 
                            context.watch<AuthController>().isEmpleado)
                          Column(
                            children: [
                              const SizedBox(height: AppDimensions.marginL),
                              ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => const InventoryFormScreen(),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.inventory_2),
                                label: const Text('Agregar Item'),
                              ),
                            ],
                          ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    await controller.loadInventory();
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.all(AppDimensions.paddingM),
                    itemCount: controller.inventory.length,
                    itemBuilder: (context, index) {
                      final item = controller.inventory[index];
                      return InventoryCard(
                        item: item,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => InventoryDetailScreen(item: item),
                            ),
                          );
                        },
                        onEdit: (context.watch<AuthController>().isGanadero || 
                                context.watch<AuthController>().isEmpleado)
                            ? () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => InventoryFormScreen(item: item),
                                  ),
                                );
                              }
                            : null,
                        onAdjustStock: (context.watch<AuthController>().isGanadero || 
                                       context.watch<AuthController>().isEmpleado)
                            ? () => _showAdjustStockDialog(item)
                            : null,
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(
          icon,
          color: color,
          size: AppDimensions.iconM,
        ),
        const SizedBox(height: AppDimensions.marginS),
        Text(
          value,
          style: AppTextStyles.h5.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Future<void> _showAdjustStockDialog(InventoryModel item) async {
    final TextEditingController quantityController = TextEditingController();
    String operation = 'add';

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Ajustar Stock: ${item.nombre}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Stock actual: ${item.cantidadActual} ${item.unidad}'),
              const SizedBox(height: AppDimensions.marginM),
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text('Agregar'),
                      value: 'add',
                      groupValue: operation,
                      onChanged: (value) {
                        setState(() {
                          operation = value!;
                        });
                      },
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text('Quitar'),
                      value: 'remove',
                      groupValue: operation,
                      onChanged: (value) {
                        setState(() {
                          operation = value!;
                        });
                      },
                    ),
                  ),
                ],
              ),
              TextField(
                controller: quantityController,
                decoration: const InputDecoration(
                  labelText: 'Cantidad',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                final quantity = int.tryParse(quantityController.text);
                if (quantity != null && quantity > 0) {
                  Navigator.of(context).pop({
                    'operation': operation,
                    'quantity': quantity,
                  });
                }
              },
              child: const Text('Ajustar'),
            ),
          ],
        ),
      ),
    );

    if (result != null && mounted) {
      final operation = result['operation'] as String;
      final quantity = result['quantity'] as int;
      
      bool success = false;
      if (operation == 'add') {
        success = await context.read<SolidInventoryController>().addStock(item.id, quantity);
      } else {
        success = await context.read<SolidInventoryController>().removeStock(item.id, quantity);
      }

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Stock ajustado exitosamente'),
            backgroundColor: AppColors.success,
          ),
        );
      } else if (mounted) {
        final error = context.read<SolidInventoryController>().errorMessage;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error ?? 'Error al ajustar stock'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}

class InventoryCard extends StatelessWidget {
  final InventoryModel item;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onAdjustStock;

  const InventoryCard({
    super.key,
    required this.item,
    this.onTap,
    this.onEdit,
    this.onAdjustStock,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppDimensions.marginM),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with status indicators
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.nombre,
                          style: AppTextStyles.h6.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: AppDimensions.marginS),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppDimensions.paddingS,
                            vertical: AppDimensions.paddingXS,
                          ),
                          decoration: BoxDecoration(
                            color: _getCategoryColor(item.categoria).withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                          ),
                          child: Text(
                            item.categoria,
                            style: AppTextStyles.caption.copyWith(
                              color: _getCategoryColor(item.categoria),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Status indicators
                      if (_isLowStock())
                        Container(
                          margin: const EdgeInsets.only(bottom: AppDimensions.marginXS),
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppDimensions.paddingS,
                            vertical: AppDimensions.paddingXS,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.warning.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.warning,
                                size: AppDimensions.iconXS,
                                color: AppColors.warning,
                              ),
                              const SizedBox(width: AppDimensions.marginXS),
                              Text(
                                'Stock Bajo',
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.warning,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (_isExpired())
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppDimensions.paddingS,
                            vertical: AppDimensions.paddingXS,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.error.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.dangerous,
                                size: AppDimensions.iconXS,
                                color: AppColors.error,
                              ),
                              const SizedBox(width: AppDimensions.marginXS),
                              Text(
                                'Vencido',
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.error,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: AppDimensions.marginM),

              // Content
              if (item.descripcion != null) ...[
                Text(
                  item.descripcion!,
                  style: AppTextStyles.body2.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppDimensions.marginS),
              ],

              // Stock information
              Row(
                children: [
                  Icon(
                    Icons.inventory_2,
                    size: AppDimensions.iconS,
                    color: _getStockColor(),
                  ),
                  const SizedBox(width: AppDimensions.marginS),
                  Text(
                    'Stock: ${item.cantidadActual} ${item.unidad}',
                    style: AppTextStyles.body2.copyWith(
                      color: _getStockColor(),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  if (item.precioUnitario != null)
                    Text(
                      '\$${item.precioUnitario!.toStringAsFixed(2)}/${item.unidad}',
                      style: AppTextStyles.body2.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                ],
              ),

              const SizedBox(height: AppDimensions.marginS),

              // Footer with expiration date and actions
              Row(
                children: [
                  if (item.fechaVencimiento != null) ...[
                    Icon(
                      Icons.schedule,
                      size: AppDimensions.iconS,
                      color: _getExpirationColor(),
                    ),
                    const SizedBox(width: AppDimensions.marginS),
                    Text(
                      'Vence: ${DateFormat(AppConstants.dateFormat).format(item.fechaVencimiento!)}',
                      style: AppTextStyles.caption.copyWith(
                        color: _getExpirationColor(),
                      ),
                    ),
                  ] else ...[
                    Icon(
                      Icons.schedule,
                      size: AppDimensions.iconS,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: AppDimensions.marginS),
                    Text(
                      'Sin fecha de vencimiento',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],

                  const Spacer(),

                  // Action buttons
                  if (onAdjustStock != null)
                    IconButton(
                      icon: const Icon(Icons.inventory),
                      onPressed: onAdjustStock,
                      color: AppColors.primary,
                      tooltip: 'Ajustar Stock',
                    ),
                  if (onEdit != null)
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: onEdit,
                      color: AppColors.primary,
                      tooltip: 'Editar',
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getCategoryColor(String categoria) {
    switch (categoria) {
      case 'Medicamento':
        return AppColors.error;
      case 'Alimento':
        return AppColors.success;
      case 'Equipo':
        return AppColors.info;
      case 'Suministro':
        return AppColors.warning;
      case 'Vacuna':
        return AppColors.primary;
      default:
        return AppColors.grey500;
    }
  }

  Color _getStockColor() {
    if (item.cantidadActual == 0) return AppColors.error;
    if (item.cantidadActual <= item.cantidadMinima) return AppColors.warning;
    return AppColors.success;
  }

  Color _getExpirationColor() {
    if (item.fechaVencimiento == null) return AppColors.textSecondary;
    if (_isExpired()) return AppColors.error;
    if (_isExpiringSoon()) return AppColors.warning;
    return AppColors.textSecondary;
  }

  bool _isLowStock() {
    return item.cantidadActual <= item.cantidadMinima;
  }

  bool _isExpired() {
    if (item.fechaVencimiento == null) return false;
    return DateTime.now().isAfter(item.fechaVencimiento!);
  }

  bool _isExpiringSoon() {
    if (item.fechaVencimiento == null) return false;
    final daysUntilExpiry = item.fechaVencimiento!.difference(DateTime.now()).inDays;
    return daysUntilExpiry <= 30 && daysUntilExpiry >= 0;
  }
}
