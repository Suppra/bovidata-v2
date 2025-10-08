import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/bovine_controller.dart';
import '../../models/bovine_model.dart';
import '../../constants/app_styles.dart';
import '../../constants/app_constants.dart';
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
    final bovineController = context.read<BovineController>();
    List<BovineModel> filtered = List.from(bovineController.bovines);

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
                  icon: const Icon(Icons.add),
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
      body: Consumer<BovineController>(
        builder: (context, bovineController, child) {
          if (bovineController.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (bovineController.errorMessage != null) {
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
                    bovineController.errorMessage!,
                    style: AppTextStyles.body2,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppDimensions.marginM),
                  ElevatedButton(
                    onPressed: () => bovineController.refresh(),
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          if (_filteredBovines.isEmpty && bovineController.bovines.isNotEmpty) {
            _filteredBovines = bovineController.bovines;
          }

          return Column(
            children: [
              // Search and Filter Bar
              SearchFilterBar(
                searchController: _searchController,
                selectedStatus: _selectedStatus,
                selectedRace: _selectedRace,
                availableRaces: bovineController.availableRaces,
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
              _buildStatisticsSummary(bovineController),

              // Bovines List
              Expanded(
                child: _filteredBovines.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: () async {
                          bovineController.refresh();
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

  Widget _buildStatisticsSummary(BovineController bovineController) {
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
                '${bovineController.bovines.length}',
                AppColors.primary,
              ),
              _buildStatItem(
                'Sanos',
                '${bovineController.healthyBovines.length}',
                AppColors.success,
              ),
              _buildStatItem(
                'Enfermos',
                '${bovineController.sickBovines.length}',
                AppColors.error,
              ),
              _buildStatItem(
                'En Trat.',
                '${bovineController.recoveringBovines.length}',
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
          style: AppTextStyles.h4.copyWith(color: color, fontWeight: FontWeight.bold),
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
                  icon: const Icon(Icons.add),
                  label: const Text('Agregar Bovino'),
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