import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../controllers/auth_controller.dart';
import '../../core/controllers/controllers.dart';
import '../../models/treatment_model.dart';
import '../../constants/app_styles.dart';
import '../../constants/app_constants.dart';
import 'treatment_form_screen.dart';
import 'treatment_detail_screen.dart';

class TreatmentListScreen extends StatefulWidget {
  final String? bovineId;
  final String? title;

  const TreatmentListScreen({
    super.key,
    this.bovineId,
    this.title,
  });

  @override
  State<TreatmentListScreen> createState() => _TreatmentListScreenState();
}

class _TreatmentListScreenState extends State<TreatmentListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'Todos';
  bool _showCompleted = true;
  bool _showPending = true;

  final List<String> _treatmentTypes = [
    'Todos',
    'Vacunación',
    'Antiparasitario', 
    'Antibiótico',
    'Antiinflamatorio',
    'Vitaminas',
    'Desparasitación',
    'Tratamiento reproductivo',
    'Otro',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final solidTreatmentController = context.read<SolidTreatmentController>();
      
      if (widget.bovineId != null) {
        solidTreatmentController.loadTreatmentsByBovine(widget.bovineId!);
      } else {
        solidTreatmentController.loadTreatments();
        solidTreatmentController.initialize();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title ?? 'Tratamientos'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        actions: [
          Consumer<AuthController>(
            builder: (context, authController, child) {
              if (authController.isVeterinario) {
                return IconButton(
                  icon: const Icon(Icons.medical_services_rounded),
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => TreatmentFormScreen(
                        bovineId: widget.bovineId,
                      ),
                    ),
                  ),
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
                    hintText: 'Buscar tratamientos...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              context.read<SolidTreatmentController>().searchTreatments('');
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                    ),
                  ),
                  onChanged: (value) {
                    context.read<SolidTreatmentController>().searchTreatments(value);
                  },
                ),

                const SizedBox(height: AppDimensions.marginM),

                // Filters Row
                Row(
                  children: [
                    // Type Filter
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedFilter,
                        decoration: const InputDecoration(
                          labelText: 'Tipo de Tratamiento',
                          border: OutlineInputBorder(),
                        ),
                        items: _treatmentTypes.map((type) {
                          return DropdownMenuItem(
                            value: type,
                            child: Text(type),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedFilter = value!;
                          });
                          context.read<SolidTreatmentController>().filterByType(
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
                            case 'completed':
                              _showCompleted = !_showCompleted;
                              break;
                            case 'pending':
                              _showPending = !_showPending;
                              break;
                          }
                        });
                        
                        final controller = context.read<SolidTreatmentController>();
                        controller.toggleShowCompleted(_showCompleted);
                        controller.toggleShowPending(_showPending);
                      },
                      itemBuilder: (context) => [
                        CheckedPopupMenuItem(
                          value: 'completed',
                          checked: _showCompleted,
                          child: const Text('Completados'),
                        ),
                        CheckedPopupMenuItem(
                          value: 'pending',
                          checked: _showPending,
                          child: const Text('Pendientes'),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Statistics Section
          if (widget.bovineId == null)
            Consumer<SolidTreatmentController>(
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
                        controller.totalTreatments.toString(),
                        Icons.medical_services,
                        AppColors.primary,
                      ),
                      _buildStatItem(
                        'Completados',
                        controller.completedTreatments.toString(),
                        Icons.check_circle,
                        AppColors.success,
                      ),
                      _buildStatItem(
                        'Pendientes',
                        controller.pendingTreatments.toString(),
                        Icons.pending,
                        AppColors.warning,
                      ),
                      _buildStatItem(
                        'Vencidos',
                        controller.overdueTreatments.toString(),
                        Icons.warning,
                        AppColors.error,
                      ),
                    ],
                  ),
                );
              },
            ),

          // Treatment List
          Expanded(
            child: Consumer<SolidTreatmentController>(
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
                            if (widget.bovineId != null) {
                              controller.loadTreatmentsByBovine(widget.bovineId!);
                            } else {
                              controller.loadTreatments();
                            }
                          },
                          child: const Text('Reintentar'),
                        ),
                      ],
                    ),
                  );
                }

                if (controller.treatments.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.medical_services_outlined,
                          size: 64,
                          color: AppColors.grey400,
                        ),
                        const SizedBox(height: AppDimensions.marginM),
                        Text(
                          'No hay tratamientos registrados',
                          style: AppTextStyles.h6.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: AppDimensions.marginS),
                        Text(
                          'Los tratamientos aparecerán aquí una vez que sean registrados',
                          style: AppTextStyles.body2.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        if (context.watch<AuthController>().isVeterinario)
                          Column(
                            children: [
                              const SizedBox(height: AppDimensions.marginL),
                              ElevatedButton.icon(
                                onPressed: () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => TreatmentFormScreen(
                                      bovineId: widget.bovineId,
                                    ),
                                  ),
                                ),
                                icon: const Icon(Icons.medical_services),
                                label: const Text('Agregar Tratamiento'),
                              ),
                            ],
                          ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    if (widget.bovineId != null) {
                      await controller.loadTreatmentsByBovine(widget.bovineId!);
                    } else {
                      await controller.loadTreatments();
                    }
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.all(AppDimensions.paddingM),
                    itemCount: controller.treatments.length,
                    itemBuilder: (context, index) {
                      final treatment = controller.treatments[index];
                      return TreatmentCard(
                        treatment: treatment,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => TreatmentDetailScreen(treatment: treatment),
                            ),
                          );
                        },
                        onComplete: context.watch<AuthController>().isVeterinario
                            ? () => _completeTreatment(treatment)
                            : null,
                        onEdit: context.watch<AuthController>().isVeterinario
                            ? () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => TreatmentFormScreen(treatment: treatment),
                                  ),
                                );
                              }
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

  Future<void> _completeTreatment(TreatmentModel treatment) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Completar Tratamiento'),
        content: Text(
          '¿Marcar el tratamiento "${treatment.nombre}" como completado?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Completar'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      final success = await context
          .read<SolidTreatmentController>()
          .markTreatmentCompleted(treatment.id);

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tratamiento completado exitosamente'),
            backgroundColor: AppColors.success,
          ),
        );
      } else if (mounted) {
        final error = context.read<SolidTreatmentController>().errorMessage;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error ?? 'Error al completar tratamiento'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}

class TreatmentCard extends StatelessWidget {
  final TreatmentModel treatment;
  final VoidCallback? onTap;
  final VoidCallback? onComplete;
  final VoidCallback? onEdit;

  const TreatmentCard({
    super.key,
    required this.treatment,
    this.onTap,
    this.onComplete,
    this.onEdit,
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
              // Header with status
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          treatment.nombre,
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
                            color: _getTypeColor(treatment.tipo).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(
                              AppDimensions.radiusS,
                            ),
                          ),
                          child: Text(
                            treatment.tipo,
                            style: AppTextStyles.caption.copyWith(
                              color: _getTypeColor(treatment.tipo),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.paddingS,
                      vertical: AppDimensions.paddingXS,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor().withOpacity(0.2),
                      borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getStatusIcon(),
                          size: AppDimensions.iconXS,
                          color: _getStatusColor(),
                        ),
                        const SizedBox(width: AppDimensions.marginXS),
                        Text(
                          _getStatusText(),
                          style: AppTextStyles.caption.copyWith(
                            color: _getStatusColor(),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppDimensions.marginM),

              // Content
              Text(
                treatment.descripcion,
                style: AppTextStyles.body2.copyWith(
                  color: AppColors.textSecondary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              if (treatment.medicamento != null) ...[
                const SizedBox(height: AppDimensions.marginS),
                Row(
                  children: [
                    Icon(
                      Icons.medication,
                      size: AppDimensions.iconS,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: AppDimensions.marginS),
                    Expanded(
                      child: Text(
                        '${treatment.medicamento}',
                        style: AppTextStyles.body2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (treatment.dosis != null)
                      Text(
                        '${treatment.dosis} ${treatment.unidadDosis ?? ''}',
                        style: AppTextStyles.body2.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                  ],
                ),
              ],

              const SizedBox(height: AppDimensions.marginM),

              // Footer with date and actions
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: AppDimensions.iconS,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: AppDimensions.marginS),
                  Text(
                    DateFormat(AppConstants.dateFormat).format(treatment.fecha),
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  
                  if (treatment.proximaAplicacion != null) ...[
                    const SizedBox(width: AppDimensions.marginM),
                    Icon(
                      Icons.schedule,
                      size: AppDimensions.iconS,
                      color: treatment.isOverdue ? AppColors.error : AppColors.textSecondary,
                    ),
                    const SizedBox(width: AppDimensions.marginXS),
                    Text(
                      'Próx: ${DateFormat(AppConstants.dateFormat).format(treatment.proximaAplicacion!)}',
                      style: AppTextStyles.caption.copyWith(
                        color: treatment.isOverdue ? AppColors.error : AppColors.textSecondary,
                      ),
                    ),
                  ],

                  const Spacer(),

                  // Action buttons
                  if (onComplete != null && !treatment.completado)
                    IconButton(
                      icon: const Icon(Icons.check_circle_outline),
                      onPressed: onComplete,
                      color: AppColors.success,
                      tooltip: 'Completar',
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

  Color _getStatusColor() {
    if (treatment.completado) return AppColors.success;
    if (treatment.isOverdue) return AppColors.error;
    return AppColors.warning;
  }

  IconData _getStatusIcon() {
    if (treatment.completado) return Icons.check_circle;
    if (treatment.isOverdue) return Icons.warning;
    return Icons.pending;
  }

  String _getStatusText() {
    if (treatment.completado) return 'Completado';
    if (treatment.isOverdue) return 'Vencido';
    return 'Pendiente';
  }

  Color _getTypeColor(String tipo) {
    switch (tipo) {
      case 'Vacunación':
        return AppColors.info;
      case 'Antiparasitario':
        return AppColors.warning;
      case 'Antibiótico':
        return AppColors.error;
      case 'Antiinflamatorio':
        return AppColors.success;
      case 'Vitaminas':
        return AppColors.primary;
      default:
        return AppColors.grey500;
    }
  }
}
