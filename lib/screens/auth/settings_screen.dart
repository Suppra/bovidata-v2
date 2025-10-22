import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/settings_controller.dart';
import '../../constants/app_styles.dart';
import '../../constants/app_constants.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {

  @override
  Widget build(BuildContext context) {
    final authController = Provider.of<AuthController>(context);
    final settingsController = Provider.of<SettingsController>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.marginL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sección de Usuario
            _buildSectionCard(
              title: 'Usuario',
              icon: Icons.person,
              child: Column(
                children: [
                  ListTile(
                    title: const Text('Mi Perfil'),
                    subtitle: const Text('Actualizar información personal'),
                    leading: const Icon(Icons.account_circle_outlined),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.pushNamed(context, '/profile');
                    },
                  ),
                  const Divider(),
                  ListTile(
                    title: const Text('Cambiar Contraseña'),
                    subtitle: const Text('Actualizar contraseña de acceso'),
                    leading: const Icon(Icons.lock_outline),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      _showChangePasswordDialog(context);
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppDimensions.marginL),

            // Sección de Aplicación
            _buildSectionCard(
              title: 'Configuración',
              icon: Icons.settings,
              child: Column(
                children: [
                  ListTile(
                    title: const Text('Tema de la Aplicación'),
                    subtitle: Text('Actual: ${settingsController.getThemeModeText()}'),
                    leading: Icon(settingsController.getThemeModeIcon()),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      _showThemeDialog(context, settingsController);
                    },
                  ),
                  const Divider(),
                  SwitchListTile(
                    title: const Text('Notificaciones'),
                    subtitle: const Text('Recibir alertas y recordatorios'),
                    value: settingsController.notificationsEnabled,
                    onChanged: settingsController.setNotifications,
                    secondary: const Icon(Icons.notifications_outlined),
                  ),
                  SwitchListTile(
                    title: const Text('Sincronización Automática'),
                    subtitle: const Text('Sincronizar datos con Firebase'),
                    value: settingsController.autoSyncEnabled,
                    onChanged: settingsController.setAutoSync,
                    secondary: const Icon(Icons.sync_outlined),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppDimensions.marginL),

            // Sección de Datos del Ganado
            _buildSectionCard(
              title: 'Gestión de Datos',
              icon: Icons.analytics,
              child: Column(
                children: [
                  ListTile(
                    title: const Text('Estadísticas Generales'),
                    subtitle: const Text('Ver resumen del ganado'),
                    leading: const Icon(Icons.bar_chart_outlined),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.pushNamed(context, '/statistics');
                    },
                  ),
                  const Divider(),
                  ListTile(
                    title: const Text('Exportar Reportes'),
                    subtitle: const Text('Generar PDF con datos'),
                    leading: const Icon(Icons.picture_as_pdf_outlined),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.pushNamed(context, '/reports');
                    },
                  ),
                  const Divider(),
                  ListTile(
                    title: const Text('Respaldo de Datos'),
                    subtitle: const Text('Sincronizar con la nube'),
                    leading: const Icon(Icons.cloud_sync_outlined),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      _showBackupDialog(context);
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppDimensions.marginL),

            // Sección de Ayuda
            _buildSectionCard(
              title: 'Ayuda y Soporte',
              icon: Icons.help_outline,
              child: Column(
                children: [
                  ListTile(
                    title: const Text('Guía de Usuario'),
                    subtitle: const Text('Aprende a usar BoviData'),
                    leading: const Icon(Icons.help_outline),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      _showUserGuide(context);
                    },
                  ),
                  const Divider(),
                  ListTile(
                    title: const Text('Acerca de BoviData'),
                    subtitle: Text('Versión ${AppConstants.appVersion}'),
                    leading: const Icon(Icons.info_outline),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      _showAboutDialog(context);
                    },
                  ),
                  const Divider(),
                  ListTile(
                    title: const Text('Reportar Problema'),
                    subtitle: const Text('Ayúdanos a mejorar'),
                    leading: const Icon(Icons.bug_report_outlined),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      _showReportDialog(context);
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppDimensions.marginXL),

            // Botón de Cerrar Sesión
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final confirm = await _showLogoutConfirmation(context);
                  if (confirm == true) {
                    await authController.signOut();
                    if (mounted) {
                      Navigator.of(context).pushReplacementNamed('/login');
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade600,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: AppDimensions.marginM),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.logout),
                    SizedBox(width: AppDimensions.marginS),
                    Text('Cerrar Sesión'),
                  ],
                ),
              ),
            ),

            const SizedBox(height: AppDimensions.marginL),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.marginM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppColors.primary),
                const SizedBox(width: AppDimensions.marginS),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.marginM),
            child,
          ],
        ),
      ),
    );
  }

  Future<void> _showChangePasswordDialog(BuildContext context) async {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    bool obscureCurrentPassword = true;
    bool obscureNewPassword = true;
    bool obscureConfirmPassword = true;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Cambiar Contraseña'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: currentPasswordController,
                decoration: InputDecoration(
                  labelText: 'Contraseña Actual',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(obscureCurrentPassword ? Icons.visibility : Icons.visibility_off),
                    onPressed: () => setState(() => obscureCurrentPassword = !obscureCurrentPassword),
                  ),
                ),
                obscureText: obscureCurrentPassword,
              ),
              const SizedBox(height: AppDimensions.marginM),
              TextFormField(
                controller: newPasswordController,
                decoration: InputDecoration(
                  labelText: 'Nueva Contraseña',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(obscureNewPassword ? Icons.visibility : Icons.visibility_off),
                    onPressed: () => setState(() => obscureNewPassword = !obscureNewPassword),
                  ),
                ),
                obscureText: obscureNewPassword,
              ),
              const SizedBox(height: AppDimensions.marginM),
              TextFormField(
                controller: confirmPasswordController,
                decoration: InputDecoration(
                  labelText: 'Confirmar Nueva Contraseña',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(obscureConfirmPassword ? Icons.visibility : Icons.visibility_off),
                    onPressed: () => setState(() => obscureConfirmPassword = !obscureConfirmPassword),
                  ),
                ),
                obscureText: obscureConfirmPassword,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                // TODO: Implementar cambio de contraseña
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Función de cambio de contraseña pendiente')),
                );
              },
              child: const Text('Cambiar'),
            ),
          ],
        ),
      ),
    );
  }

  void _showThemeDialog(BuildContext context, SettingsController settingsController) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Seleccionar Tema'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<ThemeMode>(
              title: const Text('Claro'),
              subtitle: const Text('Siempre usar tema claro'),
              value: ThemeMode.light,
              groupValue: settingsController.themeMode,
              onChanged: (value) {
                if (value != null) {
                  settingsController.setThemeMode(value);
                  Navigator.pop(context);
                }
              },
            ),
            RadioListTile<ThemeMode>(
              title: const Text('Oscuro'),
              subtitle: const Text('Siempre usar tema oscuro'),
              value: ThemeMode.dark,
              groupValue: settingsController.themeMode,
              onChanged: (value) {
                if (value != null) {
                  settingsController.setThemeMode(value);
                  Navigator.pop(context);
                }
              },
            ),
            RadioListTile<ThemeMode>(
              title: const Text('Sistema'),
              subtitle: const Text('Usar configuración del sistema'),
              value: ThemeMode.system,
              groupValue: settingsController.themeMode,
              onChanged: (value) {
                if (value != null) {
                  settingsController.setThemeMode(value);
                  Navigator.pop(context);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showBackupDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Respaldo de Datos'),
        content: const Text('¿Desea sincronizar todos los datos con Firebase Cloud?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              
              // Mostrar indicador de carga
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => const AlertDialog(
                  content: Row(
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(width: 16),
                      Text('Sincronizando datos...'),
                    ],
                  ),
                ),
              );
              
              // Simular sincronización
              await Future.delayed(const Duration(seconds: 2));
              
              if (mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Datos sincronizados correctamente'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            child: const Text('Sincronizar'),
          ),
        ],
      ),
    );
  }

  void _showUserGuide(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Guía de Usuario'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Funciones Principales:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('• Gestión de Ganado: Registra y controla tus animales'),
              Text('• Tratamientos: Lleva el historial médico'),
              Text('• Inventario: Controla alimentos y suministros'),
              Text('• Reportes: Genera PDFs con información'),
              SizedBox(height: 16),
              Text(
                'Navegación:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('• Usa el menú inferior para cambiar secciones'),
              Text('• Toca los botones "+" para agregar elementos'),
              Text('• Desliza para actualizar las listas'),
              Text('• Toca cualquier elemento para ver detalles'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }

  void _showReportDialog(BuildContext context) {
    final TextEditingController messageController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reportar Problema'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Describe el problema que encontraste:'),
            const SizedBox(height: 16),
            TextField(
              controller: messageController,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Describe aquí el problema...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Reporte enviado. ¡Gracias por tu ayuda!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Enviar'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: AppConstants.appName,
      applicationVersion: AppConstants.appVersion,
      applicationIcon: const Icon(Icons.pets, size: 48),
      children: [
        const Text('Sistema de gestión ganadera desarrollado para el control y seguimiento de bovinos.'),
        const SizedBox(height: 16),
        const Text('Características:'),
        const Text('• Registro y seguimiento de animales'),
        const Text('• Control de inventario'),
        const Text('• Registro de salud'),
        const Text('• Reportes y estadísticas'),
        const Text('• Integración con Firebase'),
      ],
    );
  }



  Future<bool?> _showLogoutConfirmation(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar Sesión'),
        content: const Text('¿Está seguro que desea cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
            ),
            child: const Text('Cerrar Sesión'),
          ),
        ],
      ),
    );
  }
}
