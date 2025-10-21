import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/auth_controller.dart';
import '../../constants/app_styles.dart';
import '../../constants/app_constants.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificaciones = true;
  bool _actualizacionesAutomaticas = true;
  bool _modoOscuro = false;
  bool _sincronizacionAuto = true;

  @override
  Widget build(BuildContext context) {
    final authController = Provider.of<AuthController>(context);

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
              title: 'Aplicación',
              icon: Icons.settings,
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text('Notificaciones'),
                    subtitle: const Text('Recibir alertas y recordatorios'),
                    value: _notificaciones,
                    onChanged: (value) {
                      setState(() {
                        _notificaciones = value;
                      });
                    },
                    secondary: const Icon(Icons.notifications_outlined),
                  ),
                  SwitchListTile(
                    title: const Text('Modo Oscuro'),
                    subtitle: const Text('Tema oscuro para la aplicación'),
                    value: _modoOscuro,
                    onChanged: (value) {
                      setState(() {
                        _modoOscuro = value;
                      });
                      // TODO: Implementar cambio de tema
                    },
                    secondary: const Icon(Icons.dark_mode_outlined),
                  ),
                  SwitchListTile(
                    title: const Text('Actualizaciones Automáticas'),
                    subtitle: const Text('Actualizar datos automáticamente'),
                    value: _actualizacionesAutomaticas,
                    onChanged: (value) {
                      setState(() {
                        _actualizacionesAutomaticas = value;
                      });
                    },
                    secondary: const Icon(Icons.update_outlined),
                  ),
                  SwitchListTile(
                    title: const Text('Sincronización Automática'),
                    subtitle: const Text('Sincronizar con Firebase'),
                    value: _sincronizacionAuto,
                    onChanged: (value) {
                      setState(() {
                        _sincronizacionAuto = value;
                      });
                    },
                    secondary: const Icon(Icons.sync_outlined),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppDimensions.marginL),

            // Sección de Datos
            _buildSectionCard(
              title: 'Datos',
              icon: Icons.storage,
              child: Column(
                children: [
                  ListTile(
                    title: const Text('Exportar Datos'),
                    subtitle: const Text('Descargar copia de seguridad'),
                    leading: const Icon(Icons.download_outlined),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      _showExportDialog(context);
                    },
                  ),
                  const Divider(),
                  ListTile(
                    title: const Text('Importar Datos'),
                    subtitle: const Text('Cargar datos desde archivo'),
                    leading: const Icon(Icons.upload_outlined),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      _showImportDialog(context);
                    },
                  ),
                  const Divider(),
                  ListTile(
                    title: const Text('Limpiar Caché'),
                    subtitle: const Text('Liberar espacio de almacenamiento'),
                    leading: const Icon(Icons.cleaning_services_outlined),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      _showClearCacheDialog(context);
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppDimensions.marginL),

            // Sección de Información
            _buildSectionCard(
              title: 'Información',
              icon: Icons.info,
              child: Column(
                children: [
                  ListTile(
                    title: const Text('Acerca de'),
                    subtitle: Text('Versión ${AppConstants.appVersion}'),
                    leading: const Icon(Icons.info_outline),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      _showAboutDialog(context);
                    },
                  ),
                  const Divider(),
                  ListTile(
                    title: const Text('Términos y Condiciones'),
                    subtitle: const Text('Política de uso y privacidad'),
                    leading: const Icon(Icons.description_outlined),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      // TODO: Mostrar términos y condiciones
                    },
                  ),
                  const Divider(),
                  ListTile(
                    title: const Text('Soporte'),
                    subtitle: const Text('Contactar desarrollador'),
                    leading: const Icon(Icons.support_agent_outlined),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      _showSupportDialog(context);
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

  void _showExportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exportar Datos'),
        content: const Text('Se descargará un archivo con todos los datos de la aplicación.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implementar exportación de datos
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Función de exportación pendiente')),
              );
            },
            child: const Text('Exportar'),
          ),
        ],
      ),
    );
  }

  void _showImportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Importar Datos'),
        content: const Text('Seleccione el archivo de datos para importar.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implementar importación de datos
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Función de importación pendiente')),
              );
            },
            child: const Text('Importar'),
          ),
        ],
      ),
    );
  }

  void _showClearCacheDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Limpiar Caché'),
        content: const Text('Esto liberará espacio de almacenamiento. ¿Está seguro?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implementar limpieza de caché
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Caché limpiado correctamente')),
              );
            },
            child: const Text('Limpiar'),
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

  void _showSupportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Soporte'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Para soporte técnico contactar:'),
            SizedBox(height: 8),
            Text('Email: soporte@bovidata.com'),
            Text('Teléfono: +1 234 567 8900'),
            SizedBox(height: 16),
            Text('Horario de atención:'),
            Text('Lunes a Viernes: 8:00 AM - 6:00 PM'),
            Text('Sábados: 9:00 AM - 2:00 PM'),
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
