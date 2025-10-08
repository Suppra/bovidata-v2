import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/bovine_controller.dart';
import '../../controllers/treatment_controller.dart';
import '../../controllers/inventory_controller.dart';
import '../../constants/app_styles.dart';
import '../../constants/app_constants.dart';
import '../treatments/treatment_list_screen.dart';
import '../inventory/inventory_list_screen.dart';
import '../reports/reports_screen.dart';
import '../notifications/notifications_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  
  @override
  void initState() {
    super.initState();
    // Initialize bovine controller
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authController = context.read<AuthController>();
      final bovineController = context.read<BovineController>();
      
      if (authController.isVeterinario) {
        bovineController.loadBovinesForVeterinarian();
      } else {
        bovineController.initialize();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthController>(
      builder: (context, authController, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text('${AppConstants.appName} - ${authController.currentUser?.rol ?? ''}'),
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.white,
            actions: [
              // Notification Icon
              IconButton(
                icon: Stack(
                  children: [
                    const Icon(Icons.notifications_outlined),
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          color: AppColors.error,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 12,
                          minHeight: 12,
                        ),
                        child: const Text(
                          '3',
                          style: TextStyle(
                            color: AppColors.white,
                            fontSize: 10,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                ),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const NotificationsScreen(),
                    ),
                  );
                },
              ),
              
              // Profile Menu
              PopupMenuButton<String>(
                icon: CircleAvatar(
                  backgroundColor: AppColors.white,
                  child: Text(
                    authController.currentUser?.nombre.substring(0, 1).toUpperCase() ?? 'U',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                onSelected: (value) {
                  switch (value) {
                    case 'profile':
                      // TODO: Navigate to profile
                      break;
                    case 'settings':
                      // TODO: Navigate to settings
                      break;
                    case 'logout':
                      _showLogoutDialog(context, authController);
                      break;
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'profile',
                    child: Row(
                      children: [
                        const Icon(Icons.person_outline),
                        const SizedBox(width: AppDimensions.marginS),
                        Text('Perfil', style: AppTextStyles.body2),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'settings',
                    child: Row(
                      children: [
                        const Icon(Icons.settings_outlined),
                        const SizedBox(width: AppDimensions.marginS),
                        Text('Configuración', style: AppTextStyles.body2),
                      ],
                    ),
                  ),
                  const PopupMenuDivider(),
                  PopupMenuItem(
                    value: 'logout',
                    child: Row(
                      children: [
                        const Icon(Icons.logout, color: AppColors.error),
                        const SizedBox(width: AppDimensions.marginS),
                        Text(
                          'Cerrar Sesión',
                          style: AppTextStyles.body2.copyWith(color: AppColors.error),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          body: _buildBody(),
          bottomNavigationBar: _buildBottomNavigationBar(authController),
        );
      },
    );
  }

  Widget _buildBody() {
    switch (_currentIndex) {
      case 0:
        return _buildDashboard();
      case 1:
        return _buildBovinesView();
      case 2:
        return _buildTreatmentsView();
      case 3:
        return _buildInventoryView();
      case 4:
        return _buildReportsView();
      default:
        return _buildDashboard();
    }
  }

  Widget _buildBottomNavigationBar(AuthController authController) {
    final items = <BottomNavigationBarItem>[
      const BottomNavigationBarItem(
        icon: Icon(Icons.dashboard_outlined),
        activeIcon: Icon(Icons.dashboard),
        label: 'Dashboard',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.pets_outlined),
        activeIcon: Icon(Icons.pets),
        label: 'Bovinos',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.medical_services_outlined),
        activeIcon: Icon(Icons.medical_services),
        label: 'Tratamientos',
      ),
    ];

    // Add inventory and reports for specific roles
    if (authController.isGanadero || authController.isVeterinario) {
      items.add(
        const BottomNavigationBarItem(
          icon: Icon(Icons.inventory_outlined),
          activeIcon: Icon(Icons.inventory),
          label: 'Inventario',
        ),
      );
    }

    if (authController.isGanadero) {
      items.add(
        const BottomNavigationBarItem(
          icon: Icon(Icons.analytics_outlined),
          activeIcon: Icon(Icons.analytics),
          label: 'Reportes',
        ),
      );
    }

    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: (index) {
        setState(() {
          _currentIndex = index;
        });
      },
      type: BottomNavigationBarType.fixed,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.grey500,
      items: items,
    );
  }

  Widget _buildDashboard() {
    return Consumer2<AuthController, BovineController>(
      builder: (context, authController, bovineController, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.paddingM),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppDimensions.paddingL),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundColor: AppColors.primary.withOpacity(0.1),
                            child: Text(
                              authController.currentUser?.nombre.substring(0, 1).toUpperCase() ?? 'U',
                              style: AppTextStyles.h3.copyWith(color: AppColors.primary),
                            ),
                          ),
                          const SizedBox(width: AppDimensions.marginM),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Bienvenido, ${authController.currentUser?.nombre ?? 'Usuario'}',
                                  style: AppTextStyles.h4,
                                ),
                                const SizedBox(height: AppDimensions.marginXS),
                                Text(
                                  authController.currentUser?.rol ?? '',
                                  style: AppTextStyles.body2.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppDimensions.marginM),
                      Text(
                        'Gestiona tu ganado de manera eficiente con ${AppConstants.appName}',
                        style: AppTextStyles.body2,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppDimensions.marginL),

              // Statistics Cards
              Text(
                'Resumen',
                style: AppTextStyles.h5,
              ),
              const SizedBox(height: AppDimensions.marginM),
              
              _buildStatisticsGrid(bovineController),
              
              const SizedBox(height: AppDimensions.marginL),

              // Recent Activity
              Text(
                'Actividad Reciente',
                style: AppTextStyles.h5,
              ),
              const SizedBox(height: AppDimensions.marginM),
              
              _buildRecentActivity(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatisticsGrid(BovineController bovineController) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: AppDimensions.marginM,
      crossAxisSpacing: AppDimensions.marginM,
      childAspectRatio: 1.5,
      children: [
        _buildStatCard(
          'Total Bovinos',
          '${bovineController.bovines.length}',
          Icons.pets,
          AppColors.primary,
        ),
        _buildStatCard(
          'Sanos',
          '${bovineController.healthyBovines.length}',
          Icons.health_and_safety,
          AppColors.success,
        ),
        _buildStatCard(
          'Enfermos',
          '${bovineController.sickBovines.length}',
          Icons.sick,
          AppColors.error,
        ),
        _buildStatCard(
          'En Tratamiento',
          '${bovineController.recoveringBovines.length}',
          Icons.medical_services,
          AppColors.warning,
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingM),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: AppDimensions.iconL, color: color),
            const SizedBox(height: AppDimensions.marginS),
            Text(
              value,
              style: AppTextStyles.h3.copyWith(color: color),
            ),
            const SizedBox(height: AppDimensions.marginXS),
            Text(
              title,
              style: AppTextStyles.caption,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivity() {
    // Mock data for recent activity
    return Card(
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 3,
        itemBuilder: (context, index) {
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: AppColors.primary.withOpacity(0.1),
              child: Icon(
                Icons.pets,
                color: AppColors.primary,
                size: AppDimensions.iconS,
              ),
            ),
            title: Text('Bovino registrado', style: AppTextStyles.body2),
            subtitle: Text('Hace 2 horas', style: AppTextStyles.caption),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: Navigate to detail
            },
          );
        },
      ),
    );
  }

  Widget _buildBovinesView() {
    return const Center(
      child: Text('Vista de Bovinos - En desarrollo'),
    );
  }

  Widget _buildTreatmentsView() {
    return const TreatmentListScreen(
      title: 'Tratamientos',
    );
  }

  Widget _buildInventoryView() {
    return const InventoryListScreen(
      title: 'Inventario',
    );
  }

  Widget _buildReportsView() {
    return const ReportsScreen();
  }

  void _showLogoutDialog(BuildContext context, AuthController authController) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar Sesión'),
        content: const Text('¿Estás seguro de que deseas cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              authController.signOut();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Cerrar Sesión'),
          ),
        ],
      ),
    );
  }
}