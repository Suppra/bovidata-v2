import 'package:flutter/material.dart';
import '../models/bovine_model.dart';
import '../constants/app_styles.dart';

class BovineCard extends StatelessWidget {
  final BovineModel bovine;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const BovineCard({
    super.key,
    required this.bovine,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppDimensions.marginM),
      elevation: AppDimensions.elevationS,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingM),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                children: [
                  // Status Indicator
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: _getStatusColor(bovine.estado),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: AppDimensions.marginS),
                  
                  // Name and ID
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          bovine.nombre,
                          style: AppTextStyles.h6.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'ID: ${bovine.numeroIdentificacion}',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Actions
                  if (onEdit != null || onDelete != null)
                    PopupMenuButton<String>(
                      onSelected: (value) {
                        switch (value) {
                          case 'edit':
                            onEdit?.call();
                            break;
                          case 'delete':
                            onDelete?.call();
                            break;
                        }
                      },
                      itemBuilder: (context) => [
                        if (onEdit != null)
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
                        if (onDelete != null)
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
                    ),
                ],
              ),
              
              const SizedBox(height: AppDimensions.marginM),
              
              // Info Grid
              Row(
                children: [
                  Expanded(
                    child: _buildInfoItem(
                      'Raza',
                      bovine.raza,
                      Icons.pets,
                    ),
                  ),
                  Expanded(
                    child: _buildInfoItem(
                      'Sexo',
                      bovine.sexo,
                      bovine.sexo.toLowerCase() == 'macho' ? Icons.male : Icons.female,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: AppDimensions.marginS),
              
              Row(
                children: [
                  Expanded(
                    child: _buildInfoItem(
                      'Edad',
                      '${bovine.edad} años',
                      Icons.cake,
                    ),
                  ),
                  Expanded(
                    child: _buildInfoItem(
                      'Peso',
                      '${bovine.peso.toStringAsFixed(0)} kg',
                      Icons.monitor_weight,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: AppDimensions.marginM),
              
              // Status Badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.paddingS,
                  vertical: AppDimensions.paddingXS,
                ),
                decoration: BoxDecoration(
                  color: _getStatusColor(bovine.estado).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                  border: Border.all(
                    color: _getStatusColor(bovine.estado).withOpacity(0.3),
                  ),
                ),
                child: Text(
                  bovine.estado,
                  style: AppTextStyles.caption.copyWith(
                    color: _getStatusColor(bovine.estado),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, IconData icon) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: AppDimensions.iconXS,
          color: AppColors.textSecondary,
        ),
        const SizedBox(width: AppDimensions.marginXS),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                value,
                style: AppTextStyles.body3.copyWith(
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
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
}