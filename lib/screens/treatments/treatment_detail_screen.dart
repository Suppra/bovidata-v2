import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/controllers/controllers.dart';
import '../../models/models.dart';
import '../../constants/app_styles.dart';
import '../../constants/app_constants.dart';
import 'treatment_form_screen.dart';

class TreatmentDetailScreen extends StatefulWidget {
  final TreatmentModel treatment;

  const TreatmentDetailScreen({
    super.key,
    required this.treatment,
  });

  @override
  State<TreatmentDetailScreen> createState() => _TreatmentDetailScreenState();
}

class _TreatmentDetailScreenState extends State<TreatmentDetailScreen> {
  TreatmentModel get treatment => widget.treatment;

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
            // Header Card con información principal
            Card(
              elevation: 4,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: LinearGradient(
                    colors: [
                      _getStatusColor().withValues(alpha: 0.1),
                      _getStatusColor().withValues(alpha: 0.05),
                    ],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(AppDimensions.paddingL),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: _getStatusColor(),
                            radius: 24,
                            child: Icon(
                              _getTreatmentIcon(),
                              color: AppColors.white,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  treatment.nombre,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _getStatusColor(),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Text(
                                    _getStatusText(),
                                    style: const TextStyle(
                                      color: AppColors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildInfoItem(
                              Icons.category,
                              'Tipo',
                              treatment.tipo,
                            ),
                          ),
                          Expanded(
                            child: _buildInfoItem(
                              Icons.calendar_today,
                              'Fecha',
                              DateFormat('dd/MM/yyyy').format(treatment.fecha),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Información del bovino
            _buildSectionCard(
              'Información del Bovino',
              Icons.pets,
              [
                FutureBuilder<BovineModel?>(
                  future: _getBovineInfo(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData && snapshot.data != null) {
                      final bovine = snapshot.data!;
                      return Column(
                        children: [
                          _buildDetailRow(Icons.tag, 'Nombre', bovine.nombre),
                          _buildDetailRow(Icons.numbers, 'Número', bovine.numeroIdentificacion),
                          _buildDetailRow(Icons.cake, 'Edad', _calculateAge(bovine.fechaNacimiento)),
                          _buildDetailRow(Icons.scale, 'Peso', '${bovine.peso} kg'),
                        ],
                      );
                    }
                    return const CircularProgressIndicator();
                  },
                ),
              ],
            ),
            
            // Detalles del tratamiento
            _buildSectionCard(
              'Detalles del Tratamiento',
              Icons.medical_services,
              [
                _buildDetailRow(Icons.description, 'Descripción', 
                    treatment.descripcion.isEmpty ? 'Sin descripción' : treatment.descripcion),
                _buildDetailRow(Icons.medication, 'Medicamento', treatment.medicamento ?? 'No especificado'),
                _buildDetailRow(Icons.straighten, 'Dosis', 
                    treatment.dosis != null ? '${treatment.dosis} ${treatment.unidadDosis ?? ''}' : 'No especificada'),
                if (treatment.observaciones?.isNotEmpty == true)
                  _buildDetailRow(Icons.notes, 'Observaciones', treatment.observaciones!),
                if (treatment.costo != null)
                  _buildDetailRow(Icons.attach_money, 'Costo', '\$${treatment.costo!.toStringAsFixed(2)}'),
              ],
            ),
            
            // Programación y fechas
            _buildSectionCard(
              'Programación',
              Icons.schedule,
              [
                _buildDetailRow(Icons.event, 'Fecha de Aplicación', 
                    DateFormat('dd/MM/yyyy HH:mm').format(treatment.fecha)),
                if (treatment.proximaAplicacion != null)
                  _buildDetailRow(
                    Icons.event_available, 
                    'Próxima Aplicación', 
                    DateFormat('dd/MM/yyyy').format(treatment.proximaAplicacion!),
                    valueColor: treatment.proximaAplicacion!.isBefore(DateTime.now()) 
                        ? AppColors.error : AppColors.success,
                  ),
                if (treatment.completado)
                  _buildDetailRow(Icons.check_circle, 'Estado', 'Completado'),
              ],
            ),
            
            // Información del veterinario
            if (treatment.veterinarioId.isNotEmpty)
              _buildSectionCard(
                'Veterinario Responsable',
                Icons.person_2,
                [
                  FutureBuilder<Map<String, String>?>(
                    future: _getVeterinarianInfo(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      
                      if (snapshot.hasData && snapshot.data != null) {
                        final vet = snapshot.data!;
                        return Column(
                          children: [
                            _buildDetailRow(Icons.person, 'Nombre', vet['nombre'] ?? 'Información no disponible'),
                            _buildDetailRow(Icons.email, 'Email', vet['email'] ?? 'No especificado'),
                            _buildDetailRow(Icons.phone, 'Teléfono', vet['telefono'] ?? 'No disponible'),
                            if (vet['rol']?.isNotEmpty == true)
                              _buildDetailRow(Icons.work, 'Rol', vet['rol']!),
                            if (vet['cedula']?.isNotEmpty == true && vet['cedula'] != 'No disponible')
                              _buildDetailRow(Icons.badge, 'Cédula', vet['cedula']!),
                          ],
                        );
                      }
                      
                      return Column(
                        children: [
                          _buildDetailRow(Icons.person, 'Nombre', 'Información no disponible'),
                          _buildDetailRow(Icons.email, 'Email', 'No especificado'),
                          _buildDetailRow(Icons.phone, 'Teléfono', 'No disponible'),
                        ],
                      );
                    },
                  ),
                ],
              ),
            
            // Status Card con progreso
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
                  .read<SolidTreatmentController>()
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
                final error = context.read<SolidTreatmentController>().errorMessage;
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
                  .read<SolidTreatmentController>()
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
                final error = context.read<SolidTreatmentController>().errorMessage;
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

  // Métodos helper para la UI mejorada
  IconData _getTreatmentIcon() {
    switch (treatment.tipo) {
      case 'Vacunación':
        return Icons.vaccines;
      case 'Desparasitación':
        return Icons.bug_report;
      case 'Antibiótico':
        return Icons.medication;
      case 'Vitaminas':
        return Icons.health_and_safety;
      case 'Reproducción':
        return Icons.pregnant_woman;
      case 'Cirugía':
        return Icons.medical_services;
      case 'Preventivo':
        return Icons.shield;
      case 'Emergencia':
        return Icons.emergency;
      default:
        return Icons.medical_services;
    }
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: AppColors.grey600),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.grey600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionCard(String title, IconData icon, List<Widget> children) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppColors.primary, size: 24),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppColors.grey600),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.grey700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: valueColor ?? AppColors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<BovineModel?> _getBovineInfo() async {
    try {
      final bovineController = context.read<SolidBovineController>();
      await bovineController.loadBovines();
      return bovineController.bovines.firstWhere(
        (bovine) => bovine.id == treatment.bovineId,
        orElse: () => throw Exception('Bovino no encontrado'),
      );
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, String>?> _getVeterinarianInfo() async {
    try {
      if (treatment.veterinarioId.isEmpty) {
        return {
          'nombre': 'Información no disponible',
          'email': 'No especificado',
          'telefono': 'No disponible',
        };
      }

      // Obtener información real del veterinario desde Firestore
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(treatment.veterinarioId)
          .get();
      
      if (userDoc.exists) {
        final user = UserModel.fromFirestore(userDoc);
        
        return {
          'nombre': '${user.nombre} ${user.apellido}'.trim(),
          'email': user.email,
          'telefono': user.telefono.isNotEmpty ? user.telefono : 'No disponible',
          'rol': user.rol,
          'cedula': user.cedula ?? 'No disponible',
        };
      } else {
        return {
          'nombre': 'Veterinario no encontrado',
          'email': 'Información no disponible',
          'telefono': 'No disponible',
        };
      }
    } catch (e) {
      print('Error obteniendo información del veterinario: $e');
      return {
        'nombre': 'Error al cargar información',
        'email': 'No disponible',
        'telefono': 'No disponible',
      };
    }
  }

  String _calculateAge(DateTime birthDate) {
    final now = DateTime.now();
    final difference = now.difference(birthDate);
    final years = difference.inDays ~/ 365;
    final months = (difference.inDays % 365) ~/ 30;
    
    if (years > 0) {
      return months > 0 ? '$years años, $months meses' : '$years años';
    } else if (months > 0) {
      return '$months meses';
    } else {
      final days = difference.inDays;
      return '$days días';
    }
  }
}
