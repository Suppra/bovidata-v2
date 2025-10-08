import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../controllers/treatment_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../models/treatment_model.dart';
import '../../constants/app_styles.dart';
import '../../constants/app_constants.dart';
import 'treatment_form_screen.dart';

class TreatmentDetailScreen extends StatelessWidget {
  final TreatmentModel treatment;

  const TreatmentDetailScreen({
    super.key,
    required this.treatment,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(treatment.nombre),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        actions: [
          Consumer<AuthController>(
            builder: (context, authController, child) {
              if (authController.isVeterinario) {
                return PopupMenuButton<String>(
                  onSelected: (value) {
                    switch (value) {
                      case 'edit':
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => TreatmentFormScreen(treatment: treatment),
                          ),
                        );
                        break;
                      case 'complete':
                        if (!treatment.completado) {
                          _showCompleteDialog(context);
                        }
                        break;
                      case 'delete':
                        _showDeleteDialog(context);
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit),
                          SizedBox(width: AppDimensions.marginS),
                          Text('Editar'),
                        ],
                      ),
                    ),
                    if (!treatment.completado)
                      const PopupMenuItem(
                        value: 'complete',
                        child: Row(
                          children: [
                            Icon(Icons.check_circle, color: AppColors.success),
                            SizedBox(width: AppDimensions.marginS),
                            Text('Marcar Completado'),
                          ],
                        ),
                      ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: AppColors.error),
                          SizedBox(width: AppDimensions.marginS),
                          Text('Eliminar', style: TextStyle(color: AppColors.error)),
                        ],
                      ),
                    ),
                  ],
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.paddingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status Card
            Card(
              color: _getStatusColor().withValues(alpha: 0.1),
              child: Padding(
                padding: const EdgeInsets.all(AppDimensions.paddingL),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppDimensions.paddingS),
                      decoration: BoxDecoration(
                        color: _getStatusColor(),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _getStatusIcon(),
                        color: AppColors.white,
                        size: AppDimensions.iconM,
                      ),
                    ),
                    const SizedBox(width: AppDimensions.marginM),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Estado del Tratamiento',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          Text(
                            _getStatusText(),
                            style: AppTextStyles.h5.copyWith(
                              color: _getStatusColor(),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: AppDimensions.marginL),

            // Basic Information Card
            _buildInfoCard(
              'Información del Tratamiento',
              Icons.medical_services,
              [
                _buildInfoRow('Nombre', treatment.nombre, Icons.title),
                _buildInfoRow('Tipo', treatment.tipo, Icons.category),
                _buildInfoRow('Descripción', treatment.descripcion, Icons.description),
              ],
            ),

            const SizedBox(height: AppDimensions.marginM),

            // Medication Information Card
            if (treatment.medicamento != null || treatment.dosis != null)
              _buildInfoCard(
                'Medicamento y Dosis',
                Icons.medication,
                [
                  if (treatment.medicamento != null)
                    _buildInfoRow('Medicamento', treatment.medicamento!, Icons.medication),
                  if (treatment.dosis != null)
                    _buildInfoRow(
                      'Dosis', 
                      '${treatment.dosis} ${treatment.unidadDosis ?? 'mg'}',
                      Icons.monitor_weight,
                    ),
                ],
              ),

            if (treatment.medicamento != null || treatment.dosis != null)
              const SizedBox(height: AppDimensions.marginM),

            // Schedule Information Card
            _buildInfoCard(
              'Programación',
              Icons.schedule,
              [
                _buildInfoRow(
                  'Fecha de Aplicación', 
                  DateFormat(AppConstants.dateFormat).format(treatment.fecha),
                  Icons.calendar_today,
                ),
                if (treatment.proximaAplicacion != null)
                  _buildInfoRow(
                    'Próxima Aplicación', 
                    DateFormat(AppConstants.dateFormat).format(treatment.proximaAplicacion!),
                    Icons.schedule,
                  ),
              ],
            ),

            const SizedBox(height: AppDimensions.marginM),

            // Observations Card
            if (treatment.observaciones != null && treatment.observaciones!.isNotEmpty)
              _buildInfoCard(
                'Observaciones',
                Icons.notes,
                [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: AppDimensions.paddingS),
                    child: Text(
                      treatment.observaciones!,
                      style: AppTextStyles.body2,
                    ),
                  ),
                ],
              ),

            if (treatment.observaciones != null && treatment.observaciones!.isNotEmpty)
              const SizedBox(height: AppDimensions.marginM),

            // Record Information Card
            _buildInfoCard(
              'Información del Registro',
              Icons.history,
              [
                _buildInfoRow(
                  'Fecha de Creación', 
                  DateFormat(AppConstants.dateTimeFormat).format(treatment.fechaCreacion),
                  Icons.add_circle_outline,
                ),
              ],
            ),

            const SizedBox(height: AppDimensions.marginL),

            // Action Buttons
            Consumer<AuthController>(
              builder: (context, authController, child) {
                if (!authController.isVeterinario) return const SizedBox.shrink();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (!treatment.completado)
                      ElevatedButton.icon(
                        onPressed: () => _showCompleteDialog(context),
                        icon: const Icon(Icons.check_circle),
                        label: const Text('Marcar como Completado'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.success,
                        ),
                      ),
                    
                    const SizedBox(height: AppDimensions.marginM),
                    
                    OutlinedButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => TreatmentFormScreen(treatment: treatment),
                          ),
                        );
                      },
                      icon: const Icon(Icons.edit),
                      label: const Text('Editar Tratamiento'),
                    ),

                    if (treatment.proximaAplicacion != null && !treatment.completado) ...[
                      const SizedBox(height: AppDimensions.marginM),
                      
                      Container(
                        padding: const EdgeInsets.all(AppDimensions.paddingM),
                        decoration: BoxDecoration(
                          color: treatment.isOverdue 
                              ? AppColors.error.withValues(alpha: 0.1)
                              : AppColors.info.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                          border: Border.all(
                            color: treatment.isOverdue ? AppColors.error : AppColors.info,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              treatment.isOverdue ? Icons.warning : Icons.info,
                              color: treatment.isOverdue ? AppColors.error : AppColors.info,
                            ),
                            const SizedBox(width: AppDimensions.marginM),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    treatment.isOverdue ? 'Tratamiento Vencido' : 'Recordatorio',
                                    style: AppTextStyles.body1.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: treatment.isOverdue ? AppColors.error : AppColors.info,
                                    ),
                                  ),
                                  Text(
                                    treatment.isOverdue 
                                        ? 'La fecha de aplicación ya pasó'
                                        : 'Próxima aplicación programada',
                                    style: AppTextStyles.body2.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, IconData icon, List<Widget> children) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: AppColors.primary,
                  size: AppDimensions.iconM,
                ),
                const SizedBox(width: AppDimensions.marginS),
                Text(
                  title,
                  style: AppTextStyles.h6.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.marginM),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.marginS),
      child: Row(
        children: [
          Icon(
            icon,
            size: AppDimensions.iconS,
            color: AppColors.textSecondary,
          ),
          const SizedBox(width: AppDimensions.marginS),
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: AppTextStyles.body2.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: AppTextStyles.body2.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
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

  void _showCompleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Completar Tratamiento'),
        content: Text(
          '¿Marcar el tratamiento "${treatment.nombre}" como completado?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              
              final success = await context
                  .read<TreatmentController>()
                  .markTreatmentCompleted(treatment.id);
              
              if (success && context.mounted) {
                Navigator.of(context).pop(); // Volver a la lista
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Tratamiento completado exitosamente'),
                    backgroundColor: AppColors.success,
                  ),
                );
              } else if (context.mounted) {
                final error = context.read<TreatmentController>().errorMessage;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(error ?? 'Error al completar tratamiento'),
                    backgroundColor: AppColors.error,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
            ),
            child: const Text('Completar'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Tratamiento'),
        content: Text(
          '¿Estás seguro de que deseas eliminar el tratamiento "${treatment.nombre}"? Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              
              final success = await context
                  .read<TreatmentController>()
                  .deleteTreatment(treatment.id);
              
              if (success && context.mounted) {
                Navigator.of(context).pop(); // Volver a la lista
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Tratamiento eliminado exitosamente'),
                    backgroundColor: AppColors.success,
                  ),
                );
              } else if (context.mounted) {
                final error = context.read<TreatmentController>().errorMessage;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(error ?? 'Error al eliminar tratamiento'),
                    backgroundColor: AppColors.error,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}