import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/controllers/solid_treatment_controller.dart';
import '../../models/models.dart';
import '../../constants/app_styles.dart';
import '../treatments/treatment_detail_screen.dart';

class MedicalHistoryScreen extends StatefulWidget {
  final BovineModel bovine;

  const MedicalHistoryScreen({
    super.key,
    required this.bovine,
  });

  @override
  State<MedicalHistoryScreen> createState() => _MedicalHistoryScreenState();
}

class _MedicalHistoryScreenState extends State<MedicalHistoryScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  String _selectedRecordType = 'Todos';
  String _selectedTreatmentType = 'Todos';
  String _selectedIncidentType = 'Todos';
  String _selectedStatus = 'Todos';
  DateTimeRange? _selectedDateRange;
  
  List<dynamic> _allRecords = [];
  List<TreatmentModel> _treatments = [];
  List<IncidentModel> _incidents = [];
  List<ActivityModel> _activities = [];
  
  final List<String> _recordTypes = [
    'Todos',
    'Tratamientos',
    'Incidentes',
    'Vacunas',
    'Actividades Veterinarias'
  ];
  
  final List<String> _treatmentTypes = [
    'Todos',
    'Vacunación',
    'Desparasitación',
    'Antibiótico',
    'Vitaminas',
    'Reproducción',
    'Cirugía',
    'Preventivo',
    'Emergencia'
  ];

  final List<String> _incidentTypes = [
    'Todos',
    'Enfermedad',
    'Lesión',
    'Accidente',
    'Emergencia',
    'Muerte',
    'Otros'
  ];
  
  final List<String> _statusOptions = [
    'Todos',
    'Completado',
    'Pendiente',
    'Vencido'
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAllMedicalRecords();
    });
  }

  Future<void> _loadAllMedicalRecords() async {
    // Cargar tratamientos
    await context.read<SolidTreatmentController>().loadTreatmentsByBovine(widget.bovine.id);
    
    // Cargar incidentes
    await _loadIncidents();
    
    // Cargar actividades veterinarias
    await _loadActivities();
    
    if (mounted) {
      setState(() {
        // Los datos se actualizarán automáticamente a través de los controllers
      });
    }
  }

  Future<void> _loadIncidents() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('incidents')
          .where('bovineId', isEqualTo: widget.bovine.id)
          .orderBy('fecha', descending: true)
          .get();
      
      _incidents = querySnapshot.docs
          .map((doc) => IncidentModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error cargando incidentes: $e');
    }
  }

  Future<void> _loadActivities() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('activities')
          .where('entidadId', isEqualTo: widget.bovine.id)
          .where('tipo', whereIn: ['Vacunación', 'Checkup', 'Consulta Veterinaria'])
          .orderBy('fecha', descending: true)
          .get();
      
      _activities = querySnapshot.docs
          .map((doc) => ActivityModel.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e) {
      print('Error cargando actividades: $e');
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Historial Médico - ${widget.bovine.nombre}'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.white,
          labelColor: AppColors.white,
          unselectedLabelColor: AppColors.white.withOpacity(0.7),
          tabs: const [
            Tab(icon: Icon(Icons.list_alt), text: 'Tratamientos'),
            Tab(icon: Icon(Icons.analytics), text: 'Estadísticas'),
            Tab(icon: Icon(Icons.timeline), text: 'Cronología'),
          ],
        ),
      ),
      body: Column(
        children: [
          _buildFiltersSection(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildTreatmentsList(),
                _buildStatistics(),
                _buildTimeline(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFiltersSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.grey500.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Filtros',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip(
                  'Registro: ${_getRecordTypeDisplayName(_selectedRecordType)}',
                  () => _showRecordTypeDialog(),
                ),
                const SizedBox(width: 8),
                if (_selectedRecordType == 'todos' || _selectedRecordType == 'treatments')
                  _buildFilterChip(
                    'Tipo: $_selectedTreatmentType',
                    () => _showTreatmentTypeDialog(),
                  ),
                if (_selectedRecordType == 'todos' || _selectedRecordType == 'treatments')
                  const SizedBox(width: 8),
                _buildFilterChip(
                  'Estado: $_selectedStatus',
                  () => _showStatusDialog(),
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  _selectedDateRange == null
                      ? 'Fecha: Todas'
                      : 'Fecha: ${DateFormat('dd/MM/yy').format(_selectedDateRange!.start)} - ${DateFormat('dd/MM/yy').format(_selectedDateRange!.end)}',
                  () => _showDateRangeDialog(),
                ),
                const SizedBox(width: 8),
                if (_hasActiveFilters())
                  _buildFilterChip(
                    'Limpiar filtros',
                    () => _clearFilters(),
                    isAction: true,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, VoidCallback onTap, {bool isAction = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isAction ? AppColors.error : AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isAction ? AppColors.error : AppColors.primary,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: isAction ? AppColors.white : AppColors.primary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              isAction ? Icons.clear : Icons.keyboard_arrow_down,
              size: 16,
              color: isAction ? AppColors.white : AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }

  String _getRecordTypeDisplayName(String recordType) {
    switch (recordType) {
      case 'todos':
        return 'Todos';
      case 'treatments':
        return 'Tratamientos';
      case 'incidents':
        return 'Incidentes';
      case 'activities':
        return 'Actividades';
      default:
        return 'Todos';
    }
  }

  void _showRecordTypeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tipo de Registro'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDialogOption('Todos', 'todos'),
            _buildDialogOption('Tratamientos', 'treatments'),
            _buildDialogOption('Incidentes', 'incidents'),
            _buildDialogOption('Actividades', 'activities'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  Widget _buildDialogOption(String displayName, String value) {
    return RadioListTile<String>(
      title: Text(displayName),
      value: value,
      groupValue: _selectedRecordType,
      onChanged: (value) {
        setState(() {
          _selectedRecordType = value!;
        });
        Navigator.pop(context);
      },
    );
  }

  Widget _buildTreatmentsList() {
    return Consumer<SolidTreatmentController>(
      builder: (context, controller, child) {
        if (controller.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final allRecords = _getAllFilteredRecords(controller.treatments);

        if (allRecords.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.medical_services_outlined,
                  size: 64,
                  color: AppColors.grey500,
                ),
                const SizedBox(height: 16),
                Text(
                  'No hay tratamientos registrados',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.grey500,
                  ),
                ),
                if (_hasActiveFilters()) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Intenta cambiar los filtros aplicados',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.grey500,
                    ),
                  ),
                ],
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: allRecords.length,
          itemBuilder: (context, index) {
            return _buildRecordCard(allRecords[index], index);
          },
        );
      },
    );
  }

  Widget _buildStatistics() {
    return Consumer<SolidTreatmentController>(
      builder: (context, controller, child) {
        final treatments = _getFilteredTreatments(controller.treatments);
        
        final completed = treatments.where((t) => t.completado).length;
        final pending = treatments.where((t) => !t.completado && 
          (t.proximaAplicacion?.isAfter(DateTime.now()) ?? true)).length;
        final overdue = treatments.where((t) => !t.completado && 
          (t.proximaAplicacion?.isBefore(DateTime.now()) ?? false)).length;
        
        final typeStats = <String, int>{};
        for (final treatment in treatments) {
          typeStats[treatment.tipo] = (typeStats[treatment.tipo] ?? 0) + 1;
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStatCard(
                'Resumen General',
                [
                  _buildStatItem('Total de Tratamientos', treatments.length.toString(), Icons.medical_services),
                  _buildStatItem('Completados', completed.toString(), Icons.check_circle, AppColors.success),
                  _buildStatItem('Pendientes', pending.toString(), Icons.schedule, AppColors.warning),
                  _buildStatItem('Vencidos', overdue.toString(), Icons.warning, AppColors.error),
                ],
              ),
              const SizedBox(height: 16),
              _buildStatCard(
                'Por Tipo de Tratamiento',
                typeStats.entries.map((entry) =>
                  _buildStatItem(entry.key, entry.value.toString(), _getTreatmentIcon(entry.key))
                ).toList(),
              ),
              const SizedBox(height: 16),
              _buildStatCard(
                'Tendencias',
                [
                  _buildStatItem(
                    'Último Tratamiento',
                    treatments.isNotEmpty 
                      ? DateFormat('dd/MM/yyyy').format(
                          treatments.map((t) => t.fecha).reduce((a, b) => a.isAfter(b) ? a : b)
                        )
                      : 'N/A',
                    Icons.access_time,
                  ),
                  _buildStatItem(
                    'Próximo Programado',
                    _getNextScheduledDate(treatments),
                    Icons.calendar_today,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatCard(String title, List<Widget> children) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, [Color? color]) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: color ?? AppColors.primary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label, style: const TextStyle(fontSize: 14)),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color ?? AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeline() {
    return Consumer<SolidTreatmentController>(
      builder: (context, controller, child) {
        final treatments = _getFilteredTreatments(controller.treatments)
          ..sort((a, b) => b.fecha.compareTo(a.fecha));

        if (treatments.isEmpty) {
          return const Center(
            child: Text('No hay tratamientos para mostrar en la cronología'),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: treatments.length,
          itemBuilder: (context, index) {
            final treatment = treatments[index];
            final isLast = index == treatments.length - 1;

            return IntrinsicHeight(
              child: Row(
                children: [
                  Column(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: _getTreatmentStatusColor(treatment),
                          shape: BoxShape.circle,
                        ),
                      ),
                      if (!isLast)
                        Expanded(
                          child: Container(
                            width: 2,
                            color: AppColors.grey500.withOpacity(0.3),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    treatment.nombre,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                                Chip(
                                  label: Text(
                                    treatment.tipo,
                                    style: const TextStyle(fontSize: 10),
                                  ),
                                  backgroundColor: _getTreatmentStatusColor(treatment).withOpacity(0.2),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Fecha: ${DateFormat('dd/MM/yyyy').format(treatment.fecha)}',
                              style: TextStyle(color: AppColors.grey600),
                            ),
                            if (treatment.descripcion.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                treatment.descripcion,
                                style: TextStyle(color: AppColors.grey600),
                              ),
                            ],
                            if (treatment.proximaAplicacion != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                'Próxima aplicación: ${DateFormat('dd/MM/yyyy').format(treatment.proximaAplicacion!)}',
                                style: TextStyle(
                                  color: treatment.proximaAplicacion!.isBefore(DateTime.now())
                                    ? AppColors.error
                                    : AppColors.primary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  List<TreatmentModel> _getFilteredTreatments(List<TreatmentModel> treatments) {
    return treatments.where((treatment) {
      // Filtrar por bovino
      if (treatment.bovineId != widget.bovine.id) return false;
      
      // Filtrar por tipo
      if (_selectedTreatmentType != 'Todos' && treatment.tipo != _selectedTreatmentType) {
        return false;
      }
      
      // Filtrar por estado
      if (_selectedStatus != 'Todos') {
        switch (_selectedStatus) {
          case 'Completado':
            if (!treatment.completado) return false;
            break;
          case 'Pendiente':
            if (treatment.completado || 
                (treatment.proximaAplicacion?.isBefore(DateTime.now()) ?? false)) {
              return false;
            }
            break;
          case 'Vencido':
            if (treatment.completado || 
                !(treatment.proximaAplicacion?.isBefore(DateTime.now()) ?? false)) {
              return false;
            }
            break;
        }
      }
      
      // Filtrar por rango de fechas
      if (_selectedDateRange != null) {
        if (treatment.fecha.isBefore(_selectedDateRange!.start) ||
            treatment.fecha.isAfter(_selectedDateRange!.end.add(const Duration(days: 1)))) {
          return false;
        }
      }
      
      return true;
    }).toList();
  }

  Color _getTreatmentStatusColor(TreatmentModel treatment) {
    if (treatment.completado) return AppColors.success;
    if (treatment.proximaAplicacion?.isBefore(DateTime.now()) ?? false) {
      return AppColors.error;
    }
    return AppColors.warning;
  }

  String _getTreatmentStatusText(TreatmentModel treatment) {
    if (treatment.completado) return 'Completado';
    if (treatment.proximaAplicacion?.isBefore(DateTime.now()) ?? false) {
      return 'Vencido';
    }
    return 'Pendiente';
  }

  IconData _getTreatmentIcon(String type) {
    switch (type) {
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

  String _getNextScheduledDate(List<TreatmentModel> treatments) {
    final upcomingTreatments = treatments
        .where((t) => !t.completado && t.proximaAplicacion != null && t.proximaAplicacion!.isAfter(DateTime.now()))
        .toList();
    
    if (upcomingTreatments.isEmpty) return 'N/A';
    
    final nextDate = upcomingTreatments
        .map((t) => t.proximaAplicacion!)
        .reduce((a, b) => a.isBefore(b) ? a : b);
    
    return DateFormat('dd/MM/yyyy').format(nextDate);
  }

  bool _hasActiveFilters() {
    return _selectedRecordType != 'todos' ||
           _selectedTreatmentType != 'Todos' ||
           _selectedStatus != 'Todos' ||
           _selectedDateRange != null;
  }

  void _clearFilters() {
    setState(() {
      _selectedRecordType = 'todos';
      _selectedTreatmentType = 'Todos';
      _selectedStatus = 'Todos';
      _selectedDateRange = null;
    });
  }

  void _showTreatmentTypeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Seleccionar Tipo de Tratamiento'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: _treatmentTypes.map((type) => RadioListTile(
            title: Text(type),
            value: type,
            groupValue: _selectedTreatmentType,
            onChanged: (value) {
              setState(() {
                _selectedTreatmentType = value!;
              });
              Navigator.of(context).pop();
            },
          )).toList(),
        ),
      ),
    );
  }

  void _showStatusDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Seleccionar Estado'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: _statusOptions.map((status) => RadioListTile(
            title: Text(status),
            value: status,
            groupValue: _selectedStatus,
            onChanged: (value) {
              setState(() {
                _selectedStatus = value!;
              });
              Navigator.of(context).pop();
            },
          )).toList(),
        ),
      ),
    );
  }

  void _showDateRangeDialog() async {
    final dateRange = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: _selectedDateRange,
    );
    
    if (dateRange != null) {
      setState(() {
        _selectedDateRange = dateRange;
      });
    }
  }

  List<dynamic> _getAllFilteredRecords(List<TreatmentModel> treatments) {
    List<dynamic> allRecords = [];
    
    // Agregar tratamientos
    allRecords.addAll(treatments.where((treatment) => treatment.bovineId == widget.bovine.id));
    
    // Agregar incidentes
    allRecords.addAll(_incidents);
    
    // Agregar actividades
    allRecords.addAll(_activities);
    
    // Aplicar filtros
    allRecords = allRecords.where((record) {
      // Filtrar por tipo de registro
      if (_selectedRecordType != 'Todos') {
        if (_selectedRecordType == 'Tratamientos' && record is! TreatmentModel) return false;
        if (_selectedRecordType == 'Incidentes' && record is! IncidentModel) return false;
        if (_selectedRecordType == 'Vacunas' && (record is! TreatmentModel || record.tipo != 'Vacunación')) return false;
        if (_selectedRecordType == 'Actividades Veterinarias' && record is! ActivityModel) return false;
      }
      
      // Filtrar por rango de fechas
      if (_selectedDateRange != null) {
        DateTime recordDate;
        if (record is TreatmentModel) {
          recordDate = record.fecha;
        } else if (record is IncidentModel) {
          recordDate = record.fecha;
        } else if (record is ActivityModel) {
          recordDate = record.fecha;
        } else {
          return false;
        }
        
        if (recordDate.isBefore(_selectedDateRange!.start) ||
            recordDate.isAfter(_selectedDateRange!.end.add(const Duration(days: 1)))) {
          return false;
        }
      }
      
      return true;
    }).toList();
    
    // Ordenar por fecha (más reciente primero)
    allRecords.sort((a, b) {
      DateTime dateA, dateB;
      
      if (a is TreatmentModel) dateA = a.fecha;
      else if (a is IncidentModel) dateA = a.fecha;
      else if (a is ActivityModel) dateA = a.fecha;
      else dateA = DateTime.now();
      
      if (b is TreatmentModel) dateB = b.fecha;
      else if (b is IncidentModel) dateB = b.fecha;
      else if (b is ActivityModel) dateB = b.fecha;
      else dateB = DateTime.now();
      
      return dateB.compareTo(dateA);
    });
    
    return allRecords;
  }

  Widget _buildRecordCard(dynamic record, int index) {
    if (record is TreatmentModel) {
      return _buildTreatmentCard(record);
    } else if (record is IncidentModel) {
      return _buildIncidentCard(record);
    } else if (record is ActivityModel) {
      return _buildActivityCard(record);
    }
    return const SizedBox.shrink();
  }

  Widget _buildTreatmentCard(TreatmentModel treatment) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getTreatmentStatusColor(treatment),
          child: Icon(
            _getTreatmentIcon(treatment.tipo),
            color: AppColors.white,
            size: 20,
          ),
        ),
        title: Text(
          treatment.nombre,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tipo: ${treatment.tipo}'),
            Text('Fecha: ${DateFormat('dd/MM/yyyy').format(treatment.fecha)}'),
            if (treatment.proximaAplicacion != null)
              Text('Próxima: ${DateFormat('dd/MM/yyyy').format(treatment.proximaAplicacion!)}'),
          ],
        ),
        trailing: Chip(
          label: Text(
            _getTreatmentStatusText(treatment),
            style: const TextStyle(fontSize: 12),
          ),
          backgroundColor: _getTreatmentStatusColor(treatment),
        ),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => TreatmentDetailScreen(treatment: treatment),
            ),
          );
        },
      ),
    );
  }

  Widget _buildIncidentCard(IncidentModel incident) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getIncidentStatusColor(incident),
          child: Icon(
            _getIncidentIcon(incident.tipo),
            color: AppColors.white,
            size: 20,
          ),
        ),
        title: Text(
          incident.descripcion,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tipo: ${incident.tipo}'),
            Text('Fecha: ${DateFormat('dd/MM/yyyy').format(incident.fecha)}'),
            Text('Gravedad: ${incident.gravedad}'),
            Text('Estado: ${incident.estado}'),
          ],
        ),
        trailing: Chip(
          label: Text(
            incident.estado,
            style: const TextStyle(fontSize: 12),
          ),
          backgroundColor: _getIncidentStatusColor(incident),
        ),
        onTap: () {
          // Aquí podrías navegar a detalles del incidente si tienes esa pantalla
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Incidente: ${incident.descripcion}')),
          );
        },
      ),
    );
  }

  Widget _buildActivityCard(ActivityModel activity) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.primary,
          child: Icon(
            _getActivityIcon(activity.tipo),
            color: AppColors.white,
            size: 20,
          ),
        ),
        title: Text(
          activity.descripcion,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tipo: ${activity.tipo}'),
            Text('Fecha: ${DateFormat('dd/MM/yyyy').format(activity.fecha)}'),
            if (activity.metadata?['observaciones'] != null)
              Text('Observaciones: ${activity.metadata!['observaciones']}'),
          ],
        ),
        trailing: const Chip(
          label: Text(
            'Actividad',
            style: TextStyle(fontSize: 12),
          ),
          backgroundColor: AppColors.primary,
        ),
      ),
    );
  }

  Color _getIncidentStatusColor(IncidentModel incident) {
    switch (incident.gravedad.toLowerCase()) {
      case 'alta':
      case 'crítica':
        return AppColors.error;
      case 'media':
        return AppColors.warning;
      case 'baja':
        return AppColors.success;
      default:
        return AppColors.grey500;
    }
  }

  IconData _getIncidentIcon(String type) {
    switch (type.toLowerCase()) {
      case 'enfermedad':
        return Icons.sick;
      case 'lesión':
        return Icons.healing;
      case 'accidente':
        return Icons.warning;
      case 'emergencia':
        return Icons.emergency;
      case 'muerte':
        return Icons.dangerous;
      default:
        return Icons.report_problem;
    }
  }

  IconData _getActivityIcon(String type) {
    switch (type.toLowerCase()) {
      case 'vacunación':
        return Icons.vaccines;
      case 'checkup':
        return Icons.health_and_safety;
      case 'consulta veterinaria':
        return Icons.medical_services;
      default:
        return Icons.assignment;
    }
  }
}