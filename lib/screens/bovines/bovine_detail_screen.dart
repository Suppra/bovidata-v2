import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/bovine_controller.dart';
import '../../core/controllers/controllers.dart';
import '../../models/bovine_model.dart';
import '../../constants/app_styles.dart';
import '../../constants/app_constants.dart';
import 'bovine_form_screen.dart';

class BovineDetailScreen extends StatelessWidget {
  final BovineModel bovine;

  const BovineDetailScreen({
    super.key,
    required this.bovine,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(bovine.nombre),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        actions: [
          Consumer<AuthController>(
            builder: (context, authController, child) {
              if (authController.isGanadero || authController.isEmpleado) {
                return PopupMenuButton<String>(
                  onSelected: (value) {
                    switch (value) {
                      case 'edit':
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => BovineFormScreen(bovine: bovine),
                          ),
                        );
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
              color: _getStatusColor(bovine.estado).withOpacity(0.1),
              child: Padding(
                padding: const EdgeInsets.all(AppDimensions.paddingL),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppDimensions.paddingS),
                      decoration: BoxDecoration(
                        color: _getStatusColor(bovine.estado),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _getStatusIcon(bovine.estado),
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
                            'Estado de Salud',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          Text(
                            bovine.estado,
                            style: AppTextStyles.h5.copyWith(
                              color: _getStatusColor(bovine.estado),
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
              'Información Básica',
              Icons.info_outline,
              [
                _buildInfoRow('Nombre', bovine.nombre, Icons.pets),
                _buildInfoRow('Identificación', bovine.numeroIdentificacion, Icons.tag),
                _buildInfoRow('Raza', bovine.raza, Icons.category),
                _buildInfoRow('Sexo', bovine.sexo, 
                    bovine.sexo.toLowerCase() == 'macho' ? Icons.male : Icons.female),
              ],
            ),

            const SizedBox(height: AppDimensions.marginM),

            // Physical Information Card
            _buildInfoCard(
              'Información Física',
              Icons.monitor_weight_outlined,
              [
                _buildInfoRow('Edad', '${bovine.edad} años', Icons.cake),
                _buildInfoRow('Peso', '${bovine.peso.toStringAsFixed(1)} kg', Icons.monitor_weight),
                _buildInfoRow('Color', bovine.color, Icons.palette),
                _buildInfoRow(
                  'Fecha de Nacimiento', 
                  DateFormat(AppConstants.dateFormat).format(bovine.fechaNacimiento),
                  Icons.calendar_today,
                ),
              ],
            ),

            const SizedBox(height: AppDimensions.marginM),

            // Genealogy Card (if has parents)
            if (bovine.padre != null || bovine.madre != null)
              _buildInfoCard(
                'Genealogía',
                Icons.family_restroom,
                [
                  if (bovine.padre != null)
                    _buildInfoRow('Padre', bovine.padre!, Icons.male),
                  if (bovine.madre != null)
                    _buildInfoRow('Madre', bovine.madre!, Icons.female),
                ],
              ),

            if (bovine.padre != null || bovine.madre != null)
              const SizedBox(height: AppDimensions.marginM),

            // Observations Card (if has observations)
            if (bovine.observaciones != null && bovine.observaciones!.isNotEmpty)
              _buildInfoCard(
                'Observaciones',
                Icons.notes,
                [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: AppDimensions.paddingS),
                    child: Text(
                      bovine.observaciones!,
                      style: AppTextStyles.body2,
                    ),
                  ),
                ],
              ),

            if (bovine.observaciones != null && bovine.observaciones!.isNotEmpty)
              const SizedBox(height: AppDimensions.marginM),

            // Timestamps Card
            _buildInfoCard(
              'Registro',
              Icons.history,
              [
                _buildInfoRow(
                  'Fecha de Registro', 
                  DateFormat(AppConstants.dateTimeFormat).format(bovine.fechaCreacion),
                  Icons.add_circle_outline,
                ),
                if (bovine.fechaActualizacion != null)
                  _buildInfoRow(
                    'Última Actualización', 
                    DateFormat(AppConstants.dateTimeFormat).format(bovine.fechaActualizacion!),
                    Icons.update,
                  ),
              ],
            ),

            const SizedBox(height: AppDimensions.marginL),

            // Action Buttons
            Consumer<AuthController>(
              builder: (context, authController, child) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (authController.isVeterinario)
                      ElevatedButton.icon(
                        onPressed: () {
                          // TODO: Navigate to add treatment
                        },
                        icon: const Icon(Icons.medical_services),
                        label: const Text('Agregar Tratamiento'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.info,
                        ),
                      ),
                    
                    const SizedBox(height: AppDimensions.marginM),
                    
                    OutlinedButton.icon(
                      onPressed: () {
                        // TODO: Navigate to medical history
                      },
                      icon: const Icon(Icons.history_edu),
                      label: const Text('Ver Historial Médico'),
                    ),
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

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Sano':
        return AppColors.statusSano;
      case 'Enfermo':
        return AppColors.statusEnfermo;
      case 'En recuperación':
        return AppColors.statusRecuperacion;
      case 'Muerto':
        return AppColors.statusMuerto;
      default:
        return AppColors.grey500;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'Sano':
        return Icons.health_and_safety;
      case 'Enfermo':
        return Icons.sick;
      case 'En recuperación':
        return Icons.healing;
      case 'Muerto':
        return Icons.dangerous;
      default:
        return Icons.help_outline;
    }
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Bovino'),
        content: Text(
          '¿Estás seguro de que deseas eliminar a ${bovine.nombre}? Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              
              final bovineController = context.read<BovineController>();
              final solidBovineController = context.read<SolidBovineController>();
              
              // Try SOLID controller first, fallback to legacy
              bool success = await solidBovineController.deleteBovine(bovine.id);
              if (!success) {
                success = await bovineController.deleteBovine(bovine.id);
              }
              
              if (success && context.mounted) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Bovino eliminado exitosamente'),
                    backgroundColor: AppColors.success,
                  ),
                );
              } else if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(solidBovineController.errorMessage ?? bovineController.errorMessage ?? 'Error al eliminar bovino'),
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