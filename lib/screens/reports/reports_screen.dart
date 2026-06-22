import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/controllers/controllers.dart';
import '../../models/bovine_model.dart';
import '../../models/treatment_model.dart';
import '../../models/inventory_model.dart';
import '../../constants/app_styles.dart';
import '../../constants/app_constants.dart';
import 'pdf_generator_screen.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();
  String _selectedReportType = 'general';


  final List<String> _reportTypes = [
    'general',
    'bovinos',
    'tratamientos',
    'inventario',
    'financiero',
  ];

  final Map<String, String> _reportTypeNames = {
    'general': 'Reporte General',
    'bovinos': 'Reporte de Bovinos',
    'tratamientos': 'Reporte de Tratamientos',
    'inventario': 'Reporte de Inventario',
    'financiero': 'Reporte Financiero',
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadData();
  }

  void _loadData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Initialize SOLID controllers
      context.read<SolidBovineController>().initialize();
      context.read<SolidTreatmentController>().initialize();
      context.read<SolidInventoryController>().initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reportes y Estadísticas'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.white,
          unselectedLabelColor: AppColors.white.withOpacity(0.7),
          indicatorColor: AppColors.white,
          tabs: const [
            Tab(icon: Icon(Icons.dashboard), text: 'Resumen'),
            Tab(icon: Icon(Icons.pets), text: 'Bovinos'),
            Tab(icon: Icon(Icons.medical_services), text: 'Tratamientos'),
            Tab(icon: Icon(Icons.inventory), text: 'Inventario'),
          ],
        ),
        actions: [
          // Solo mostrar PDF para veterinarios y ganaderos
          Consumer<AuthController>(
            builder: (context, authController, child) {
              if (authController.isVeterinario || authController.isGanadero) {
                return IconButton(
                  icon: const Icon(Icons.picture_as_pdf),
                  onPressed: () => _navigateToPdfGenerator(),
                  tooltip: 'Generar PDF',
                );
              }
              return const SizedBox.shrink();
            },
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.date_range),
            tooltip: 'Filtros',
            onSelected: (value) => _handleFilterAction(value),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'date_range',
                child: Row(
                  children: [
                    Icon(Icons.date_range),
                    SizedBox(width: 8),
                    Text('Rango de Fechas'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'report_type',
                child: Row(
                  children: [
                    Icon(Icons.assessment),
                    SizedBox(width: 8),
                    Text('Tipo de Reporte'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Date Range Indicator
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppDimensions.paddingM),
            color: AppColors.secondary.withValues(alpha: 0.1),
            child: Row(
              children: [
                const Icon(Icons.calendar_today, size: 16),
                const SizedBox(width: AppDimensions.marginS),
                Text(
                  'Período: ${DateFormat(AppConstants.dateFormat).format(_startDate)} - ${DateFormat(AppConstants.dateFormat).format(_endDate)}',
                  style: AppTextStyles.body2,
                ),
                const Spacer(),
                Text(
                  _reportTypeNames[_selectedReportType]!,
                  style: AppTextStyles.body2.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),

          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildGeneralReportTab(),
                _buildBovineReportTab(),
                _buildTreatmentReportTab(),
                _buildInventoryReportTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGeneralReportTab() {
    return Consumer4<SolidBovineController, SolidTreatmentController, SolidInventoryController, AuthController>(
      builder: (context, solidBovineController, solidTreatmentController, solidInventoryController, authController, child) {
        // Use SOLID controllers data
        final bovines = solidBovineController.bovines;
        final treatments = solidTreatmentController.treatments;
        final inventory = solidInventoryController.inventory;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.paddingL),
          child: Column(
            children: [
              // Summary Cards
              Row(
                children: [
                  Expanded(
                    child: _buildSummaryCard(
                      'Total Bovinos',
                      bovines.length.toString(),
                      Icons.pets,
                      AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: AppDimensions.marginM),
                  Expanded(
                    child: _buildSummaryCard(
                      'Tratamientos Activos',
                      treatments.where((t) => !t.completado).length.toString(),
                      Icons.medical_services,
                      AppColors.info,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppDimensions.marginM),

              Row(
                children: [
                  Expanded(
                    child: _buildSummaryCard(
                      'Items en Inventario',
                      inventory.length.toString(),
                      Icons.inventory,
                      AppColors.success,
                    ),
                  ),
                  const SizedBox(width: AppDimensions.marginM),
                  Expanded(
                    child: _buildSummaryCard(
                      'Stock Bajo',
                      inventory.where((i) => i.cantidadActual <= i.cantidadMinima).length.toString(),
                      Icons.warning,
                      AppColors.warning,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppDimensions.marginL),

              // Bovine Status Distribution
              _buildChartCard(
                'Distribución por Estado de Bovinos',
                _buildBovineStatusChart(bovines),
              ),

              const SizedBox(height: AppDimensions.marginL),

              // Treatment Status Distribution
              _buildChartCard(
                'Estado de Tratamientos',
                _buildTreatmentStatusChart(treatments),
              ),

              const SizedBox(height: AppDimensions.marginL),

              // Inventory Alerts
              _buildInventoryAlertsCard(inventory),

              const SizedBox(height: AppDimensions.marginL),

              // Recent Activity
              _buildRecentActivityCard(bovines, treatments),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBovineReportTab() {
    return Consumer<SolidBovineController>(
      builder: (context, controller, child) {
        final bovines = controller.bovines;
        final filteredBovines = _filterBovinesByDate(bovines);

        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.paddingL),
          child: Column(
            children: [
              // Bovine Statistics
              Row(
                children: [
                  Expanded(
                    child: _buildSummaryCard(
                      'Total Bovinos',
                      filteredBovines.length.toString(),
                      Icons.pets,
                      AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: AppDimensions.marginM),
                  Expanded(
                    child: _buildSummaryCard(
                      'Bovinos Sanos',
                      filteredBovines.where((b) => b.estado == 'Sano').length.toString(),
                      Icons.health_and_safety,
                      AppColors.success,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppDimensions.marginM),

              Row(
                children: [
                  Expanded(
                    child: _buildSummaryCard(
                      'En Tratamiento',
                      filteredBovines.where((b) => b.estado == 'Enfermo').length.toString(),
                      Icons.medical_services,
                      AppColors.warning,
                    ),
                  ),
                  const SizedBox(width: AppDimensions.marginM),
                  Expanded(
                    child: _buildSummaryCard(
                      'Fallecidos',
                      filteredBovines.where((b) => b.estado == 'Fallecido').length.toString(),
                      Icons.dangerous,
                      AppColors.error,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppDimensions.marginL),

              // Age Distribution Chart
              _buildChartCard(
                'Distribución por Edad',
                _buildAgeDistributionChart(filteredBovines),
              ),

              const SizedBox(height: AppDimensions.marginL),

              // Breed Distribution Chart
              _buildChartCard(
                'Distribución por Raza',
                _buildBreedDistributionChart(filteredBovines),
              ),

              const SizedBox(height: AppDimensions.marginL),

              // Bovine List
              _buildBovineListCard(filteredBovines),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTreatmentReportTab() {
    return Consumer<SolidTreatmentController>(
      builder: (context, controller, child) {
        final treatments = controller.treatments;
        final filteredTreatments = _filterTreatmentsByDate(treatments);

        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.paddingL),
          child: Column(
            children: [
              // Treatment Statistics
              Row(
                children: [
                  Expanded(
                    child: _buildSummaryCard(
                      'Total Tratamientos',
                      filteredTreatments.length.toString(),
                      Icons.medical_services,
                      AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: AppDimensions.marginM),
                  Expanded(
                    child: _buildSummaryCard(
                      'Completados',
                      filteredTreatments.where((t) => t.completado).length.toString(),
                      Icons.check_circle,
                      AppColors.success,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppDimensions.marginM),

              Row(
                children: [
                  Expanded(
                    child: _buildSummaryCard(
                      'En Progreso',
                      filteredTreatments.where((t) => !t.completado).length.toString(),
                      Icons.schedule,
                      AppColors.info,
                    ),
                  ),
                  const SizedBox(width: AppDimensions.marginM),
                  Expanded(
                    child: _buildSummaryCard(
                      'Vencidos',
                      filteredTreatments.where((t) => !t.completado && t.proximaAplicacion != null && t.proximaAplicacion!.isBefore(DateTime.now())).length.toString(),
                      Icons.warning,
                      AppColors.error,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppDimensions.marginL),

              // Treatment Type Distribution
              _buildChartCard(
                'Tipos de Tratamiento',
                _buildTreatmentTypeChart(filteredTreatments),
              ),

              const SizedBox(height: AppDimensions.marginL),

              // Treatment Timeline
              _buildTreatmentTimelineCard(filteredTreatments),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInventoryReportTab() {
    return Consumer<SolidInventoryController>(
      builder: (context, controller, child) {
        final inventory = controller.inventory;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.paddingL),
          child: Column(
            children: [
              // Inventory Statistics
              Row(
                children: [
                  Expanded(
                    child: _buildSummaryCard(
                      'Total Items',
                      inventory.length.toString(),
                      Icons.inventory,
                      AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: AppDimensions.marginM),
                  Expanded(
                    child: _buildSummaryCard(
                      'Stock Bajo',
                      inventory.where((i) => i.cantidadActual <= i.cantidadMinima).length.toString(),
                      Icons.warning,
                      AppColors.warning,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppDimensions.marginM),

              Row(
                children: [
                  Expanded(
                    child: _buildSummaryCard(
                      'Agotados',
                      inventory.where((i) => i.cantidadActual == 0).length.toString(),
                      Icons.error,
                      AppColors.error,
                    ),
                  ),
                  const SizedBox(width: AppDimensions.marginM),
                  Expanded(
                    child: _buildSummaryCard(
                      'Por Vencer',
                      inventory.where((i) => i.fechaVencimiento != null && 
                                      i.fechaVencimiento!.difference(DateTime.now()).inDays <= 30).length.toString(),
                      Icons.schedule,
                      AppColors.info,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppDimensions.marginL),

              // Category Distribution
              _buildChartCard(
                'Distribución por Categoría',
                _buildCategoryDistributionChart(inventory),
              ),

              const SizedBox(height: AppDimensions.marginL),

              // Stock Value Chart
              _buildChartCard(
                'Valor del Inventario',
                _buildInventoryValueChart(inventory),
              ),

              const SizedBox(height: AppDimensions.marginL),

              // Expiration Alerts
              _buildExpirationAlertsCard(inventory),

              const SizedBox(height: AppDimensions.marginL),

              // Low Stock Alerts
              _buildLowStockAlertsCard(inventory),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingL),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: AppDimensions.marginM),
            Text(
              value,
              style: AppTextStyles.h4.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: AppDimensions.marginS),
            Text(
              title,
              style: AppTextStyles.body2.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartCard(String title, Widget chart) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: AppTextStyles.h6.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: AppDimensions.marginL),
            chart,
          ],
        ),
      ),
    );
  }

  Widget _buildBovineStatusChart(List<BovineModel> bovines) {
    final statusCounts = <String, int>{};
    for (final bovine in bovines) {
      statusCounts[bovine.estado] = (statusCounts[bovine.estado] ?? 0) + 1;
    }

    return SizedBox(
      height: 200,
      child: ListView.builder(
        itemCount: statusCounts.length,
        itemBuilder: (context, index) {
          final entry = statusCounts.entries.elementAt(index);
          final percentage = bovines.isEmpty ? 0.0 : (entry.value / bovines.length * 100);
          
          Color color;
          switch (entry.key) {
            case 'Sano':
              color = AppColors.success;
              break;
            case 'Enfermo':
              color = AppColors.warning;
              break;
            case 'Fallecido':
              color = AppColors.error;
              break;
            default:
              color = AppColors.info;
          }

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: AppDimensions.marginS),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(entry.key, style: AppTextStyles.body1),
                    Text('${entry.value} (${percentage.toStringAsFixed(1)}%)', 
                         style: AppTextStyles.body2),
                  ],
                ),
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  value: percentage / 100,
                  backgroundColor: color.withValues(alpha: 0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTreatmentStatusChart(List<TreatmentModel> treatments) {
    final completed = treatments.where((t) => t.completado).length;
    final active = treatments.where((t) => !t.completado).length;
    
    return SizedBox(
      height: 120,
      child: Column(
        children: [
          _buildProgressRow('Completados', completed, treatments.length, AppColors.success),
          const SizedBox(height: AppDimensions.marginM),
          _buildProgressRow('Activos', active, treatments.length, AppColors.info),
        ],
      ),
    );
  }

  Widget _buildProgressRow(String label, int value, int total, Color color) {
    final percentage = total == 0 ? 0.0 : (value / total * 100);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: AppTextStyles.body1),
            Text('$value (${percentage.toStringAsFixed(1)}%)', 
                 style: AppTextStyles.body2),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: percentage / 100,
          backgroundColor: color.withValues(alpha: 0.2),
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      ],
    );
  }

  Widget _buildInventoryAlertsCard(List<InventoryModel> inventory) {
    final lowStock = inventory.where((i) => i.cantidadActual <= i.cantidadMinima).toList();
    final expiringSoon = inventory.where((i) => 
        i.fechaVencimiento != null && 
        i.fechaVencimiento!.difference(DateTime.now()).inDays <= 30).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Alertas de Inventario',
              style: AppTextStyles.h6.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: AppDimensions.marginL),
            
            if (lowStock.isNotEmpty) ...[
              Row(
                children: [
                  Icon(Icons.warning, color: AppColors.warning, size: 20),
                  const SizedBox(width: AppDimensions.marginS),
                  Text(
                    'Stock Bajo (${lowStock.length} items)',
                    style: AppTextStyles.body1.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.warning,
                    ),
                  ),
                ],
              ),
              ...lowStock.take(3).map((item) => Padding(
                padding: const EdgeInsets.only(left: 28, top: 4),
                child: Text(
                  '• ${item.nombre} (${item.cantidadActual} ${item.unidad})',
                  style: AppTextStyles.body2,
                ),
              )),
              if (lowStock.length > 3)
                Padding(
                  padding: const EdgeInsets.only(left: 28, top: 4),
                  child: Text(
                    '... y ${lowStock.length - 3} más',
                    style: AppTextStyles.body2.copyWith(
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              const SizedBox(height: AppDimensions.marginM),
            ],

            if (expiringSoon.isNotEmpty) ...[
              Row(
                children: [
                  Icon(Icons.schedule, color: AppColors.info, size: 20),
                  const SizedBox(width: AppDimensions.marginS),
                  Text(
                    'Por Vencer (${expiringSoon.length} items)',
                    style: AppTextStyles.body1.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.info,
                    ),
                  ),
                ],
              ),
              ...expiringSoon.take(3).map((item) => Padding(
                padding: const EdgeInsets.only(left: 28, top: 4),
                child: Text(
                  '• ${item.nombre} (${DateFormat(AppConstants.dateFormat).format(item.fechaVencimiento!)})',
                  style: AppTextStyles.body2,
                ),
              )),
              if (expiringSoon.length > 3)
                Padding(
                  padding: const EdgeInsets.only(left: 28, top: 4),
                  child: Text(
                    '... y ${expiringSoon.length - 3} más',
                    style: AppTextStyles.body2.copyWith(
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
            ],

            if (lowStock.isEmpty && expiringSoon.isEmpty)
              Text(
                'No hay alertas de inventario',
                style: AppTextStyles.body2.copyWith(
                  color: AppColors.success,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivityCard(List<BovineModel> bovines, List<TreatmentModel> treatments) {
    final recentBovines = bovines.where((b) => 
        DateTime.now().difference(b.fechaCreacion).inDays <= 7).toList();
    final recentTreatments = treatments.where((t) => 
        DateTime.now().difference(t.fecha).inDays <= 7).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Actividad Reciente (Últimos 7 días)',
              style: AppTextStyles.h6.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: AppDimensions.marginL),

            if (recentBovines.isNotEmpty) ...[
              Text(
                'Bovinos Registrados (${recentBovines.length}):',
                style: AppTextStyles.body1.copyWith(fontWeight: FontWeight.bold),
              ),
              ...recentBovines.take(3).map((bovine) => Padding(
                padding: const EdgeInsets.only(left: 16, top: 4),
                child: Text(
                  '• ${bovine.nombre} (${DateFormat(AppConstants.dateFormat).format(bovine.fechaCreacion)})',
                  style: AppTextStyles.body2,
                ),
              )),
              const SizedBox(height: AppDimensions.marginM),
            ],

            if (recentTreatments.isNotEmpty) ...[
              Text(
                'Tratamientos Iniciados (${recentTreatments.length}):',
                style: AppTextStyles.body1.copyWith(fontWeight: FontWeight.bold),
              ),
              ...recentTreatments.take(3).map((treatment) => Padding(
                padding: const EdgeInsets.only(left: 16, top: 4),
                child: Text(
                  '• ${treatment.tipo} (${DateFormat(AppConstants.dateFormat).format(treatment.fecha)})',
                  style: AppTextStyles.body2,
                ),
              )),
            ],

            if (recentBovines.isEmpty && recentTreatments.isEmpty)
              Text(
                'No hay actividad reciente',
                style: AppTextStyles.body2.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Additional chart builders...
  Widget _buildAgeDistributionChart(List<BovineModel> bovines) {
    final ageGroups = <String, int>{};
    
    for (final bovine in bovines) {
      final age = DateTime.now().difference(bovine.fechaNacimiento).inDays ~/ 365;
      String ageGroup;
      if (age < 1) {
        ageGroup = 'Menor a 1 año';
      } else if (age < 3) {
        ageGroup = '1-3 años';
      } else if (age < 6) {
        ageGroup = '3-6 años';
      } else {
        ageGroup = 'Mayor a 6 años';
      }
      ageGroups[ageGroup] = (ageGroups[ageGroup] ?? 0) + 1;
    }

    return SizedBox(
      height: 200,
      child: ListView.builder(
        itemCount: ageGroups.length,
        itemBuilder: (context, index) {
          final entry = ageGroups.entries.elementAt(index);
          final percentage = bovines.isEmpty ? 0.0 : (entry.value / bovines.length * 100);
          
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: AppDimensions.marginS),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(entry.key, style: AppTextStyles.body1),
                    Text('${entry.value} (${percentage.toStringAsFixed(1)}%)', 
                         style: AppTextStyles.body2),
                  ],
                ),
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  value: percentage / 100,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBreedDistributionChart(List<BovineModel> bovines) {
    final breedCounts = <String, int>{};
    for (final bovine in bovines) {
      breedCounts[bovine.raza] = (breedCounts[bovine.raza] ?? 0) + 1;
    }

    return SizedBox(
      height: 200,
      child: ListView.builder(
        itemCount: breedCounts.length,
        itemBuilder: (context, index) {
          final entry = breedCounts.entries.elementAt(index);
          final percentage = bovines.isEmpty ? 0.0 : (entry.value / bovines.length * 100);
          
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: AppDimensions.marginS),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(entry.key, style: AppTextStyles.body1),
                    Text('${entry.value} (${percentage.toStringAsFixed(1)}%)', 
                         style: AppTextStyles.body2),
                  ],
                ),
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  value: percentage / 100,
                  backgroundColor: AppColors.success.withValues(alpha: 0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.success),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTreatmentTypeChart(List<TreatmentModel> treatments) {
    final typeCounts = <String, int>{};
    for (final treatment in treatments) {
      typeCounts[treatment.tipo] = (typeCounts[treatment.tipo] ?? 0) + 1;
    }

    return SizedBox(
      height: 200,
      child: ListView.builder(
        itemCount: typeCounts.length,
        itemBuilder: (context, index) {
          final entry = typeCounts.entries.elementAt(index);
          final percentage = treatments.isEmpty ? 0.0 : (entry.value / treatments.length * 100);
          
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: AppDimensions.marginS),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(entry.key, style: AppTextStyles.body1),
                    Text('${entry.value} (${percentage.toStringAsFixed(1)}%)', 
                         style: AppTextStyles.body2),
                  ],
                ),
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  value: percentage / 100,
                  backgroundColor: AppColors.info.withValues(alpha: 0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.info),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategoryDistributionChart(List<InventoryModel> inventory) {
    final categoryCounts = <String, int>{};
    for (final item in inventory) {
      categoryCounts[item.categoria] = (categoryCounts[item.categoria] ?? 0) + 1;
    }

    return SizedBox(
      height: 200,
      child: ListView.builder(
        itemCount: categoryCounts.length,
        itemBuilder: (context, index) {
          final entry = categoryCounts.entries.elementAt(index);
          final percentage = inventory.isEmpty ? 0.0 : (entry.value / inventory.length * 100);
          
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: AppDimensions.marginS),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(entry.key, style: AppTextStyles.body1),
                    Text('${entry.value} (${percentage.toStringAsFixed(1)}%)', 
                         style: AppTextStyles.body2),
                  ],
                ),
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  value: percentage / 100,
                  backgroundColor: AppColors.warning.withValues(alpha: 0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.warning),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInventoryValueChart(List<InventoryModel> inventory) {
    double totalValue = 0;
    final categoryValues = <String, double>{};
    
    for (final item in inventory) {
      if (item.precioUnitario != null) {
        final value = item.precioUnitario! * item.cantidadActual;
        totalValue += value;
        categoryValues[item.categoria] = (categoryValues[item.categoria] ?? 0) + value;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Valor Total: \$${totalValue.toStringAsFixed(2)}',
          style: AppTextStyles.h6.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: AppDimensions.marginL),
        
        SizedBox(
          height: 200,
          child: ListView.builder(
            itemCount: categoryValues.length,
            itemBuilder: (context, index) {
              final entry = categoryValues.entries.elementAt(index);
              final percentage = totalValue == 0 ? 0.0 : (entry.value / totalValue * 100);
              
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: AppDimensions.marginS),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(entry.key, style: AppTextStyles.body1),
                        Text('\$${entry.value.toStringAsFixed(2)} (${percentage.toStringAsFixed(1)}%)', 
                             style: AppTextStyles.body2),
                      ],
                    ),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: percentage / 100,
                      backgroundColor: AppColors.success.withValues(alpha: 0.2),
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.success),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBovineListCard(List<BovineModel> bovines) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Lista de Bovinos (${bovines.length})',
              style: AppTextStyles.h6.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: AppDimensions.marginL),
            
            if (bovines.isEmpty) 
              Text(
                'No hay bovinos registrados en el período seleccionado',
                style: AppTextStyles.body2.copyWith(
                  color: AppColors.textSecondary,
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: bovines.length,
                itemBuilder: (context, index) {
                  final bovine = bovines[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: _getBovineStateColor(bovine.estado),
                      child: Text(
                        bovine.nombre[0].toUpperCase(),
                        style: const TextStyle(color: AppColors.white),
                      ),
                    ),
                    title: Text(bovine.nombre),
                    subtitle: Text('${bovine.raza} • ${bovine.estado}'),
                    trailing: Text(
                      DateFormat(AppConstants.dateFormat).format(bovine.fechaCreacion),
                      style: AppTextStyles.caption,
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTreatmentTimelineCard(List<TreatmentModel> treatments) {
    final sortedTreatments = List<TreatmentModel>.from(treatments)
      ..sort((a, b) => b.fecha.compareTo(a.fecha));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Línea de Tiempo de Tratamientos',
              style: AppTextStyles.h6.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: AppDimensions.marginL),
            
            if (sortedTreatments.isEmpty)
              Text(
                'No hay tratamientos registrados en el período seleccionado',
                style: AppTextStyles.body2.copyWith(
                  color: AppColors.textSecondary,
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: sortedTreatments.take(10).length,
                itemBuilder: (context, index) {
                  final treatment = sortedTreatments[index];
                  return ListTile(
                    leading: Icon(
                      treatment.completado ? Icons.check_circle : Icons.schedule,
                      color: treatment.completado ? AppColors.success : AppColors.warning,
                    ),
                    title: Text(treatment.tipo),
                    subtitle: Text(treatment.descripcion),
                    trailing: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          DateFormat(AppConstants.dateFormat).format(treatment.fecha),
                          style: AppTextStyles.caption,
                        ),
                        if (treatment.completado)
                          Text(
                            'Completado',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.success,
                            ),
                          )
                        else if (treatment.proximaAplicacion != null)
                          Text(
                            'Próxima: ${DateFormat(AppConstants.dateFormat).format(treatment.proximaAplicacion!)}',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.warning,
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            
            if (sortedTreatments.length > 10)
              Padding(
                padding: const EdgeInsets.only(top: AppDimensions.marginM),
                child: Center(
                  child: Text(
                    'Mostrando 10 de ${sortedTreatments.length} tratamientos',
                    style: AppTextStyles.caption.copyWith(
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpirationAlertsCard(List<InventoryModel> inventory) {
    final expiring = inventory.where((item) =>
        item.fechaVencimiento != null &&
        item.fechaVencimiento!.difference(DateTime.now()).inDays <= 30 &&
        item.fechaVencimiento!.isAfter(DateTime.now())).toList();
    
    final expired = inventory.where((item) =>
        item.fechaVencimiento != null &&
        item.fechaVencimiento!.isBefore(DateTime.now())).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Alertas de Vencimiento',
              style: AppTextStyles.h6.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: AppDimensions.marginL),
            
            if (expired.isNotEmpty) ...[
              Text(
                'Productos Vencidos (${expired.length}):',
                style: AppTextStyles.body1.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.error,
                ),
              ),
              ...expired.map((item) => ListTile(
                dense: true,
                leading: Icon(Icons.dangerous, color: AppColors.error, size: 20),
                title: Text(item.nombre),
                trailing: Text(
                  DateFormat(AppConstants.dateFormat).format(item.fechaVencimiento!),
                  style: AppTextStyles.caption.copyWith(color: AppColors.error),
                ),
              )),
              const SizedBox(height: AppDimensions.marginM),
            ],

            if (expiring.isNotEmpty) ...[
              Text(
                'Próximos a Vencer (${expiring.length}):',
                style: AppTextStyles.body1.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.warning,
                ),
              ),
              ...expiring.map((item) => ListTile(
                dense: true,
                leading: Icon(Icons.warning, color: AppColors.warning, size: 20),
                title: Text(item.nombre),
                trailing: Text(
                  '${item.fechaVencimiento!.difference(DateTime.now()).inDays} días',
                  style: AppTextStyles.caption.copyWith(color: AppColors.warning),
                ),
              )),
            ],

            if (expired.isEmpty && expiring.isEmpty)
              Text(
                'No hay productos vencidos o próximos a vencer',
                style: AppTextStyles.body2.copyWith(
                  color: AppColors.success,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLowStockAlertsCard(List<InventoryModel> inventory) {
    final lowStock = inventory.where((item) => 
        item.cantidadActual <= item.cantidadMinima && item.cantidadActual > 0).toList();
    
    final outOfStock = inventory.where((item) => item.cantidadActual == 0).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Alertas de Stock',
              style: AppTextStyles.h6.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: AppDimensions.marginL),
            
            if (outOfStock.isNotEmpty) ...[
              Text(
                'Sin Stock (${outOfStock.length}):',
                style: AppTextStyles.body1.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.error,
                ),
              ),
              ...outOfStock.map((item) => ListTile(
                dense: true,
                leading: Icon(Icons.error, color: AppColors.error, size: 20),
                title: Text(item.nombre),
                trailing: Text(
                  'Agotado',
                  style: AppTextStyles.caption.copyWith(color: AppColors.error),
                ),
              )),
              const SizedBox(height: AppDimensions.marginM),
            ],

            if (lowStock.isNotEmpty) ...[
              Text(
                'Stock Bajo (${lowStock.length}):',
                style: AppTextStyles.body1.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.warning,
                ),
              ),
              ...lowStock.map((item) => ListTile(
                dense: true,
                leading: Icon(Icons.warning, color: AppColors.warning, size: 20),
                title: Text(item.nombre),
                trailing: Text(
                  '${item.cantidadActual} ${item.unidad}',
                  style: AppTextStyles.caption.copyWith(color: AppColors.warning),
                ),
              )),
            ],

            if (outOfStock.isEmpty && lowStock.isEmpty)
              Text(
                'Todos los productos tienen stock suficiente',
                style: AppTextStyles.body2.copyWith(
                  color: AppColors.success,
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Helper methods
  List<BovineModel> _filterBovinesByDate(List<BovineModel> bovines) {
    return bovines.where((bovine) =>
        bovine.fechaCreacion.isAfter(_startDate.subtract(const Duration(days: 1))) &&
        bovine.fechaCreacion.isBefore(_endDate.add(const Duration(days: 1)))).toList();
  }

  List<TreatmentModel> _filterTreatmentsByDate(List<TreatmentModel> treatments) {
    return treatments.where((treatment) =>
        treatment.fecha.isAfter(_startDate.subtract(const Duration(days: 1))) &&
        treatment.fecha.isBefore(_endDate.add(const Duration(days: 1)))).toList();
  }

  Color _getBovineStateColor(String state) {
    switch (state) {
      case 'Sano':
        return AppColors.success;
      case 'Enfermo':
        return AppColors.warning;
      case 'Fallecido':
        return AppColors.error;
      default:
        return AppColors.info;
    }
  }

  void _handleFilterAction(String action) {
    switch (action) {
      case 'date_range':
        _showDateRangePicker();
        break;
      case 'report_type':
        _showReportTypeDialog();
        break;
    }
  }

  void _showDateRangePicker() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(start: _startDate, end: _endDate),
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
    }
  }

  void _showReportTypeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Seleccionar Tipo de Reporte'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: _reportTypes.map((type) => RadioListTile<String>(
            title: Text(_reportTypeNames[type]!),
            value: type,
            groupValue: _selectedReportType,
            onChanged: (value) {
              setState(() {
                _selectedReportType = value!;
              });
              Navigator.of(context).pop();
            },
          )).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );
  }

  void _navigateToPdfGenerator() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const PdfGeneratorScreen(),
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
