import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/auth_controller.dart';
import '../../core/controllers/controllers.dart';
import '../../models/bovine_model.dart';
import '../../constants/app_styles.dart';

import '../../widgets/bovine_card.dart';
import '../../widgets/search_filter_bar.dart';
import 'bovine_form_screen.dart';
import 'bovine_detail_screen.dart';

class BovineListScreen extends StatefulWidget {
  const BovineListScreen({super.key});

  @override
  State<BovineListScreen> createState() => _BovineListScreenState();
}

class _BovineListScreenState extends State<BovineListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedStatus = 'Todos';
  String _selectedRace = 'Todas';
  List<BovineModel> _filteredBovines = [];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    _filterBovines();
  }

  void _filterBovines() {
    final solidBovineController = context.read<SolidBovineController>();
    
    // Use SOLID controller data only
    final bovines = solidBovineController.bovines;
    List<BovineModel> filtered = List.from(bovines);

    // Filter by search text
    if (_searchController.text.isNotEmpty) {
      filtered = filtered.where((bovine) {
        final query = _searchController.text.toLowerCase();
        return bovine.nombre.toLowerCase().contains(query) ||
            bovine.numeroIdentificacion.toLowerCase().contains(query) ||
            bovine.raza.toLowerCase().contains(query);
      }).toList();
    }

    // Filter by status
    if (_selectedStatus != 'Todos') {
      filtered = filtered.where((bovine) => bovine.estado == _selectedStatus).toList();
    }

    // Filter by race
    if (_selectedRace != 'Todas') {
      filtered = filtered.where((bovine) => bovine.raza == _selectedRace).toList();
    }

    setState(() {
      _filteredBovines = filtered;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Bovinos'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        actions: [
          Consumer<AuthController>(
            builder: (context, authController, child) {
              if (authController.isGanadero || authController.isEmpleado) {
                return IconButton(
                  icon: const Icon(Icons.add_circle),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const BovineFormScreen(),
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
      body: Consumer<SolidBovineController>(
        builder: (context, solidBovineController, child) {
          // Use SOLID controller status with fallback
          final isLoading = solidBovineController.isLoading;
          final errorMessage = solidBovineController.errorMessage;
          
          if (isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: AppColors.error,
                  ),
                  const SizedBox(height: AppDimensions.marginM),
                  Text(
                    'Error al cargar bovinos',
                    style: AppTextStyles.h5.copyWith(color: AppColors.error),
                  ),
                  const SizedBox(height: AppDimensions.marginS),
                  Text(
                    errorMessage,
                    style: AppTextStyles.body2,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppDimensions.marginM),
                  ElevatedButton(
                    onPressed: () {
                      solidBovineController.refresh();
                    },
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          // Use SOLID controller data with fallback
          final allBovines = solidBovineController.bovines;
              
          if (_filteredBovines.isEmpty && allBovines.isNotEmpty) {
            _filteredBovines = allBovines;
          }

          return Column(
            children: [
              // Search and Filter Bar
              SearchFilterBar(
                searchController: _searchController,
                selectedStatus: _selectedStatus,
                selectedRace: _selectedRace,
                availableRaces: solidBovineController.availableRaces,
                onStatusChanged: (status) {
                  setState(() {
                    _selectedStatus = status ?? 'Todos';
                  });
                  _filterBovines();
                },
                onRaceChanged: (race) {
                  setState(() {
                    _selectedRace = race ?? 'Todas';
                  });
                  _filterBovines();
                },
              ),

              // Statistics Summary
              _buildStatisticsSummary(solidBovineController),

              // Bovines List
              Expanded(
                child: _filteredBovines.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: () async {
                          solidBovineController.refresh();
                        },
                        child: ListView.builder(
                          padding: const EdgeInsets.all(AppDimensions.paddingM),
                          itemCount: _filteredBovines.length,
                          itemBuilder: (context, index) {
                            final bovine = _filteredBovines[index];
                            return BovineCard(
                              bovine: bovine,
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => BovineDetailScreen(bovine: bovine),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatisticsSummary(SolidBovineController solidController) {
    // Use SOLID data only
    final bovines = solidController.bovines;
    final healthyBovines = solidController.healthyBovines;
    final sickBovines = solidController.sickBovines;
    final recoveringBovines = solidController.recoveringBovines;
    
    return Container(
      margin: const EdgeInsets.all(AppDimensions.marginM),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingM),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                'Total',
                '${bovines.length}',
                AppColors.primary,
              ),
              _buildStatItem(
                'Sanos',
                '${healthyBovines.length}',
                AppColors.success,
              ),
              _buildStatItem(
                'Enfermos',
                '${sickBovines.length}',
                AppColors.error,
              ),
              _buildStatItem(
                'En Trat.',
                '${recoveringBovines.length}',
                AppColors.warning,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: AppTextStyles.h4.copyWith(color: color).merge(AppTextStyles.bodyBold),
        ),
        const SizedBox(height: AppDimensions.marginXS),
        Text(
          label,
          style: AppTextStyles.caption,
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.pets_outlined,
            size: 80,
            color: AppColors.grey400,
          ),
          const SizedBox(height: AppDimensions.marginL),
          Text(
            'No hay bovinos registrados',
            style: AppTextStyles.h5.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppDimensions.marginS),
          Text(
            'Agrega tu primer bovino para comenzar',
            style: AppTextStyles.body2.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppDimensions.marginL),
          Consumer<AuthController>(
            builder: (context, authController, child) {
              if (authController.isGanadero || authController.isEmpleado) {
                return ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const BovineFormScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.pets),
                  label: const Text('Agregar Bovino'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    elevation: 3,
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }
}
