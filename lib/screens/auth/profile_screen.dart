import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/auth_controller.dart';
import '../../models/user_model.dart';
import '../../constants/app_styles.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _emailController = TextEditingController();
  final _apellidoController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _direccionController = TextEditingController();
  final _cedulaController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _emailController.dispose();
    _apellidoController.dispose();
    _telefonoController.dispose();
    _direccionController.dispose();
    _cedulaController.dispose();
    super.dispose();
  }

  void _loadUserData() {
    final authController = context.read<AuthController>();
    final user = authController.currentUser;
    
    if (user != null) {
      _nombreController.text = user.nombre;
      _emailController.text = user.email;
      _apellidoController.text = user.apellido;
      _telefonoController.text = user.telefono;
      _direccionController.text = user.direccion ?? '';
      _cedulaController.text = user.cedula ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Perfil'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        actions: [
          TextButton(
            onPressed: _saveProfile,
            child: const Text(
              'Guardar',
              style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: Consumer<AuthController>(
        builder: (context, authController, child) {
          final user = authController.currentUser;
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppDimensions.paddingL),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // Avatar Section
                  Container(
                    padding: const EdgeInsets.all(AppDimensions.paddingXL),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: AppColors.primary,
                          child: Text(
                            user?.nombre.substring(0, 1).toUpperCase() ?? 'U',
                            style: const TextStyle(
                              fontSize: 40,
                              color: AppColors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: AppDimensions.marginM),
                        Text(
                          user?.nombre ?? 'Usuario',
                          style: AppTextStyles.h2,
                        ),
                        const SizedBox(height: AppDimensions.marginS),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppDimensions.paddingM,
                            vertical: AppDimensions.paddingS,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                          ),
                          child: Text(
                            user?.rol ?? 'Usuario',
                            style: AppTextStyles.body2.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppDimensions.marginL),

                  // Form Fields
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(AppDimensions.paddingL),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Información Personal',
                            style: AppTextStyles.h4.copyWith(color: AppColors.primary),
                          ),
                          const SizedBox(height: AppDimensions.marginL),

                          // Nombre
                          TextFormField(
                            controller: _nombreController,
                            decoration: const InputDecoration(
                              labelText: 'Nombre Completo',
                              prefixIcon: Icon(Icons.person_outline),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'El nombre es requerido';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: AppDimensions.marginM),

                          // Apellido
                          TextFormField(
                            controller: _apellidoController,
                            decoration: const InputDecoration(
                              labelText: 'Apellido',
                              prefixIcon: Icon(Icons.person_outline),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'El apellido es requerido';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: AppDimensions.marginM),

                          // Email (solo lectura)
                          TextFormField(
                            controller: _emailController,
                            decoration: const InputDecoration(
                              labelText: 'Correo Electrónico',
                              prefixIcon: Icon(Icons.email_outlined),
                            ),
                            readOnly: true,
                            enabled: false,
                          ),
                          const SizedBox(height: AppDimensions.marginM),

                          // Teléfono
                          TextFormField(
                            controller: _telefonoController,
                            decoration: const InputDecoration(
                              labelText: 'Teléfono',
                              prefixIcon: Icon(Icons.phone_outlined),
                            ),
                            keyboardType: TextInputType.phone,
                          ),
                          const SizedBox(height: AppDimensions.marginM),

                          // Cédula
                          TextFormField(
                            controller: _cedulaController,
                            decoration: const InputDecoration(
                              labelText: 'Cédula/ID',
                              prefixIcon: Icon(Icons.badge_outlined),
                            ),
                          ),
                          const SizedBox(height: AppDimensions.marginM),

                          // Dirección
                          TextFormField(
                            controller: _direccionController,
                            decoration: const InputDecoration(
                              labelText: 'Dirección',
                              prefixIcon: Icon(Icons.location_on_outlined),
                            ),
                            maxLines: 2,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: AppDimensions.marginL),

                  // Account Info Card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(AppDimensions.paddingL),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Información de la Cuenta',
                            style: AppTextStyles.h4.copyWith(color: AppColors.primary),
                          ),
                          const SizedBox(height: AppDimensions.marginM),
                          
                          ListTile(
                            leading: const Icon(Icons.calendar_today_outlined, color: AppColors.primary),
                            title: const Text('Fecha de registro'),
                            subtitle: Text(
                              user?.fechaCreacion.toLocal().toString().split(' ')[0] ?? 'No disponible',
                              style: AppTextStyles.caption,
                            ),
                          ),
                          
                          ListTile(
                            leading: const Icon(Icons.verified_user_outlined, color: AppColors.success),
                            title: const Text('Estado de la cuenta'),
                            subtitle: Text(
                              user?.activo == true ? 'Activa' : 'Inactiva',
                              style: AppTextStyles.caption.copyWith(
                                color: user?.activo == true ? AppColors.success : AppColors.error,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: AppDimensions.marginXL),

                  // Action Buttons
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _changePassword,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondary,
                      ),
                      child: const Text('Cambiar Contraseña'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      // TODO: Implementar actualización de perfil
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Perfil actualizado correctamente'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  void _changePassword() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cambiar Contraseña'),
        content: const Text('Funcionalidad en desarrollo. Pronto podrás cambiar tu contraseña desde aquí.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }
}