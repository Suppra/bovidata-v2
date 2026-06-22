import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../core/controllers/controllers.dart';
import '../../models/models.dart';
import '../../constants/app_styles.dart';
import '../../services/pdf_service.dart';

class PdfGeneratorScreen extends StatefulWidget {
  const PdfGeneratorScreen({super.key});

  @override
  State<PdfGeneratorScreen> createState() => _PdfGeneratorScreenState();
}

class _PdfGeneratorScreenState extends State<PdfGeneratorScreen> {
  BovineModel? _selectedBovine;
  bool _isGenerating = false;
  bool _includeIncidents = true;
  bool _includeActivities = true;
  String _reportType = 'Completo';
  
  final List<String> _reportTypes = [
    'Completo',
    'Solo Tratamientos',
    'Solo Incidentes',
    'Resumen Ejecutivo'
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SolidBovineController>().loadBovines();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Generar Reporte PDF'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header con icono
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withOpacity(0.1),
                    AppColors.primary.withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primary.withOpacity(0.2)),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.picture_as_pdf,
                    size: 64,
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Generador de Reportes PDF',
                    style: AppTextStyles.h5.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Selecciona un bovino y configura las opciones del reporte',
                    style: AppTextStyles.body2.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Selección de bovino
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.pets, color: AppColors.primary),
                        const SizedBox(width: 8),
                        Text(
                          'Seleccionar Bovino',
                          style: AppTextStyles.h6.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    Consumer<SolidBovineController>(
                      builder: (context, controller, child) {
                        if (controller.isLoading) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        
                        if (controller.bovines.isEmpty) {
                          return Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.warning.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.warning),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.warning, color: AppColors.warning),
                                const SizedBox(width: 8),
                                const Expanded(
                                  child: Text('No hay bovinos registrados'),
                                ),
                              ],
                            ),
                          );
                        }
                        
                        return Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.grey300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: DropdownButtonFormField<BovineModel>(
                            value: _selectedBovine,
                            decoration: const InputDecoration(
                              hintText: 'Selecciona un bovino',
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            ),
                            items: controller.bovines.map((bovine) {
                              return DropdownMenuItem(
                                value: bovine,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 36,
                                      height: 36,
                                      decoration: BoxDecoration(
                                        color: _getStatusColor(bovine.estado),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.pets,
                                        color: AppColors.white,
                                        size: 18,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Flexible(
                                      child: SingleChildScrollView(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                          Text(
                                            bovine.nombre,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 9,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                          ),
                                          Text(
                                            'ID: ${bovine.numeroIdentificacion} • ${bovine.raza}',
                                            style: TextStyle(
                                              color: AppColors.textSecondary,
                                              fontSize: 7,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                          ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _getStatusColor(bovine.estado).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        bovine.estado,
                                        style: TextStyle(
                                          color: _getStatusColor(bovine.estado),
                                          fontSize: 8,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                            onChanged: (bovine) {
                              setState(() {
                                _selectedBovine = bovine;
                              });
                            },
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Opciones del reporte
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.settings, color: AppColors.primary),
                        const SizedBox(width: 8),
                        Text(
                          'Opciones del Reporte',
                          style: AppTextStyles.h6.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Tipo de reporte
                    Text(
                      'Tipo de Reporte:',
                      style: AppTextStyles.body1.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.grey300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButtonFormField<String>(
                        value: _reportType,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                        items: _reportTypes.map((type) {
                          return DropdownMenuItem(
                            value: type,
                            child: Row(
                              children: [
                                Icon(_getReportTypeIcon(type), size: 20),
                                const SizedBox(width: 8),
                                Text(type),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (type) {
                          setState(() {
                            _reportType = type!;
                          });
                        },
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Opciones adicionales
                    if (_reportType == 'Completo') ...[
                      CheckboxListTile(
                        title: const Text('Incluir Incidentes'),
                        subtitle: const Text('Agregar historial de incidentes y emergencias'),
                        value: _includeIncidents,
                        onChanged: (value) {
                          setState(() {
                            _includeIncidents = value!;
                          });
                        },
                        activeColor: AppColors.primary,
                      ),
                      CheckboxListTile(
                        title: const Text('Incluir Actividades Veterinarias'),
                        subtitle: const Text('Agregar actividades y consultas veterinarias'),
                        value: _includeActivities,
                        onChanged: (value) {
                          setState(() {
                            _includeActivities = value!;
                          });
                        },
                        activeColor: AppColors.primary,
                      ),
                    ],
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Preview de información
            if (_selectedBovine != null) ...[
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.preview, color: AppColors.primary),
                          const SizedBox(width: 8),
                          Text(
                            'Vista Previa',
                            style: AppTextStyles.h6.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      FutureBuilder<Map<String, int>>(
                        future: _getRecordCounts(_selectedBovine!),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          
                          final counts = snapshot.data ?? {};
                          
                          return Column(
                            children: [
                              _buildPreviewItem(
                                'Tratamientos registrados',
                                counts['treatments']?.toString() ?? '0',
                                Icons.medical_services,
                                AppColors.primary,
                              ),
                              _buildPreviewItem(
                                'Incidentes registrados',
                                counts['incidents']?.toString() ?? '0',
                                Icons.warning,
                                AppColors.error,
                              ),
                              _buildPreviewItem(
                                'Actividades veterinarias',
                                counts['activities']?.toString() ?? '0',
                                Icons.assignment,
                                AppColors.success,
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
            ],
            
            // Botones de acción
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _selectedBovine != null && !_isGenerating 
                        ? () => _previewPdf() 
                        : null,
                    icon: const Icon(Icons.visibility),
                    label: const Text('Vista Previa'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: _selectedBovine != null && !_isGenerating 
                        ? () => _generatePdf() 
                        : null,
                    icon: _isGenerating 
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Icon(Icons.picture_as_pdf),
                    label: Text(_isGenerating ? 'Generando...' : 'Generar PDF'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildPreviewItem(String title, String value, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.body2,
                ),
                Text(
                  value,
                  style: AppTextStyles.h6.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Future<Map<String, int>> _getRecordCounts(BovineModel bovine) async {
    try {
      // Contar tratamientos
      final treatmentsQuery = await FirebaseFirestore.instance
          .collection('treatments')
          .where('bovineId', isEqualTo: bovine.id)
          .get();
      
      // Contar incidentes
      final incidentsQuery = await FirebaseFirestore.instance
          .collection('incidents')
          .where('bovineId', isEqualTo: bovine.id)
          .get();
      
      // Contar actividades
      final activitiesQuery = await FirebaseFirestore.instance
          .collection('activities')
          .where('entidadId', isEqualTo: bovine.id)
          .where('tipo', whereIn: ['Vacunación', 'Checkup', 'Consulta Veterinaria'])
          .get();
      
      return {
        'treatments': treatmentsQuery.docs.length,
        'incidents': incidentsQuery.docs.length,
        'activities': activitiesQuery.docs.length,
      };
    } catch (e) {
      return {'treatments': 0, 'incidents': 0, 'activities': 0};
    }
  }
  
  Future<void> _generatePdf() async {
    if (_selectedBovine == null) return;
    
    setState(() {
      _isGenerating = true;
    });
    
    try {
      // Obtener datos necesarios
      final data = await _getAllData(_selectedBovine!);
      
      // Generar PDF
      final pdfData = await PdfService.generateMedicalHistoryPdf(
        bovine: _selectedBovine!,
        treatments: data['treatments'] as List<TreatmentModel>,
        incidents: data['incidents'] as List<IncidentModel>,
        activities: data['activities'] as List<ActivityModel>,
        veterinarian: data['veterinarian'] as UserModel,
        owner: data['owner'] as UserModel,
      );
      
      // Compartir PDF
      final fileName = 'historial_medico_${_selectedBovine!.nombre}_${DateFormat('ddMMyyyy').format(DateTime.now())}.pdf';
      await PdfService.sharePdf(pdfData, fileName);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('PDF generado exitosamente'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al generar PDF: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isGenerating = false;
        });
      }
    }
  }
  
  Future<void> _previewPdf() async {
    if (_selectedBovine == null) return;
    
    try {
      final data = await _getAllData(_selectedBovine!);
      
      final pdfData = await PdfService.generateMedicalHistoryPdf(
        bovine: _selectedBovine!,
        treatments: data['treatments'] as List<TreatmentModel>,
        incidents: data['incidents'] as List<IncidentModel>,
        activities: data['activities'] as List<ActivityModel>,
        veterinarian: data['veterinarian'] as UserModel,
        owner: data['owner'] as UserModel,
      );
      
      await PdfService.printPdf(pdfData);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error en vista previa: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
  
  Future<Map<String, dynamic>> _getAllData(BovineModel bovine) async {
    // Obtener tratamientos
    List<TreatmentModel> treatments = [];
    if (_reportType == 'Completo' || _reportType == 'Solo Tratamientos') {
      final treatmentsQuery = await FirebaseFirestore.instance
          .collection('treatments')
          .where('bovineId', isEqualTo: bovine.id)
          .orderBy('fecha', descending: true)
          .get();
      
      treatments = treatmentsQuery.docs
          .map((doc) => TreatmentModel.fromFirestore(doc))
          .toList();
    }
    
    // Obtener incidentes
    List<IncidentModel> incidents = [];
    if ((_reportType == 'Completo' && _includeIncidents) || _reportType == 'Solo Incidentes') {
      final incidentsQuery = await FirebaseFirestore.instance
          .collection('incidents')
          .where('bovineId', isEqualTo: bovine.id)
          .orderBy('fecha', descending: true)
          .get();
      
      incidents = incidentsQuery.docs
          .map((doc) => IncidentModel.fromFirestore(doc))
          .toList();
    }
    
    // Obtener actividades
    List<ActivityModel> activities = [];
    if (_reportType == 'Completo' && _includeActivities) {
      final activitiesQuery = await FirebaseFirestore.instance
          .collection('activities')
          .where('entidadId', isEqualTo: bovine.id)
          .where('tipo', whereIn: ['Vacunación', 'Checkup', 'Consulta Veterinaria'])
          .orderBy('fecha', descending: true)
          .get();
      
      activities = activitiesQuery.docs
          .map((doc) => ActivityModel.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
    }
    
    // Obtener veterinario (usuario actual si es veterinario, o buscar uno)
    UserModel veterinarian;
    final authController = context.read<AuthController>();
    if (authController.isVeterinario) {
      veterinarian = authController.currentUser!;
    } else {
      // Buscar un veterinario que haya tratado este bovino
      final vetQuery = await FirebaseFirestore.instance
          .collection('users')
          .where('rol', isEqualTo: 'Veterinario')
          .limit(1)
          .get();
      
      if (vetQuery.docs.isNotEmpty) {
        veterinarian = UserModel.fromFirestore(vetQuery.docs.first);
      } else {
        // Crear un veterinario por defecto si no hay ninguno
        veterinarian = UserModel(
          id: 'default',
          nombre: 'Veterinario',
          apellido: 'No asignado',
          email: 'veterinario@bovidata.com',
          rol: 'Veterinario',
          telefono: 'No disponible',
          fechaCreacion: DateTime.now(),
        );
      }
    }
    
    // Obtener ganadero (propietario)
    UserModel owner;
    if (authController.isGanadero) {
      owner = authController.currentUser!;
    } else {
      // Obtener el propietario del bovino
      final ownerQuery = await FirebaseFirestore.instance
          .collection('users')
          .doc(bovine.propietarioId)
          .get();
      
      if (ownerQuery.exists) {
        owner = UserModel.fromFirestore(ownerQuery);
      } else {
        owner = UserModel(
          id: bovine.propietarioId,
          nombre: 'Propietario',
          apellido: 'No encontrado',
          email: 'propietario@bovidata.com',
          rol: 'Ganadero',
          telefono: 'No disponible',
          fechaCreacion: DateTime.now(),
        );
      }
    }
    
    return {
      'treatments': treatments,
      'incidents': incidents,
      'activities': activities,
      'veterinarian': veterinarian,
      'owner': owner,
    };
  }
  
  Color _getStatusColor(String status) {
    switch (status) {
      case 'Sano':
        return AppColors.success;
      case 'Enfermo':
        return AppColors.error;
      case 'En recuperación':
        return AppColors.warning;
      case 'Muerto':
        return AppColors.grey700;
      default:
        return AppColors.grey500;
    }
  }
  
  IconData _getReportTypeIcon(String type) {
    switch (type) {
      case 'Completo':
        return Icons.description;
      case 'Solo Tratamientos':
        return Icons.medical_services;
      case 'Solo Incidentes':
        return Icons.warning;
      case 'Resumen Ejecutivo':
        return Icons.summarize;
      default:
        return Icons.description;
    }
  }
}