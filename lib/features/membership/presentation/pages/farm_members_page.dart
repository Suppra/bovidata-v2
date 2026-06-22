// Capa de PRESENTACIÓN — gestión de miembros del hato e invitaciones.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bovidata_new/features/authentication/presentation/controllers/auth_controller.dart';
import '../../../../constants/app_styles.dart';
import '../../domain/entities/membership.dart';
import '../controllers/membership_controller.dart';

class FarmMembersPage extends StatelessWidget {
  const FarmMembersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final user = auth.currentUser;
    final isGanadero = auth.isGanadero;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Miembros del hato'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
      ),
      body: user == null
          ? const Center(child: Text('Sesión no disponible'))
          : ListView(
              padding: const EdgeInsets.all(AppDimensions.paddingM),
              children: [
                // Invitaciones recibidas (cualquier rol puede tenerlas).
                _SectionTitle('Invitaciones recibidas'),
                _InvitationsList(memberId: user.id),
                const SizedBox(height: AppDimensions.paddingL),

                if (isGanadero) ...[
                  _SectionTitle('Invitar a mi hato'),
                  _InviteForm(ganaderoId: user.id, ganaderoNombre: user.nombreCompleto),
                  const SizedBox(height: AppDimensions.paddingL),
                  _SectionTitle('Miembros de mi hato'),
                  _MembersList(ganaderoId: user.id),
                ],
              ],
            ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: AppDimensions.paddingS),
        child: Text(text,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      );
}

class _InviteForm extends StatefulWidget {
  final String ganaderoId;
  final String ganaderoNombre;
  const _InviteForm({required this.ganaderoId, required this.ganaderoNombre});

  @override
  State<_InviteForm> createState() => _InviteFormState();
}

class _InviteFormState extends State<_InviteForm> {
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _invite() async {
    final controller = context.read<MembershipController>();
    final ok = await controller.invite(
      ganaderoId: widget.ganaderoId,
      ganaderoNombre: widget.ganaderoNombre,
      memberEmail: _emailController.text,
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok
            ? 'Invitación enviada'
            : (controller.errorMessage ?? 'No se pudo invitar')),
        backgroundColor: ok ? AppColors.success : AppColors.error,
      ),
    );
    if (ok) _emailController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<MembershipController>();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Correo del veterinario o empleado',
                prefixIcon: Icon(Icons.email_outlined),
              ),
            ),
            const SizedBox(height: AppDimensions.paddingM),
            ElevatedButton.icon(
              onPressed: controller.isLoading ? null : _invite,
              icon: const Icon(Icons.person_add),
              label: Text(controller.isLoading ? 'Enviando...' : 'Enviar invitación'),
            ),
          ],
        ),
      ),
    );
  }
}

class _InvitationsList extends StatelessWidget {
  final String memberId;
  const _InvitationsList({required this.memberId});

  @override
  Widget build(BuildContext context) {
    final controller = context.read<MembershipController>();
    return StreamBuilder<List<Membership>>(
      stream: controller.watchMyInvitations(memberId),
      builder: (context, snapshot) {
        final all = snapshot.data ?? const <Membership>[];
        final relevant = all
            .where((m) => m.estado != MembershipStatus.revocada)
            .toList();
        if (relevant.isEmpty) {
          return const Card(
            child: ListTile(
              leading: Icon(Icons.inbox_outlined),
              title: Text('No tienes invitaciones'),
            ),
          );
        }
        return Column(
          children: relevant.map((m) => _InvitationTile(m)).toList(),
        );
      },
    );
  }
}

class _InvitationTile extends StatelessWidget {
  final Membership membership;
  const _InvitationTile(this.membership);

  @override
  Widget build(BuildContext context) {
    final controller = context.read<MembershipController>();
    final m = membership;
    return Card(
      child: ListTile(
        leading: const Icon(Icons.agriculture, color: AppColors.primary),
        title: Text('Hato de ${m.ganaderoNombre}'),
        subtitle: Text('Rol: ${m.memberRol} · Estado: ${m.estado.value}'),
        trailing: m.isPending
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.check_circle, color: AppColors.success),
                    tooltip: 'Aceptar',
                    onPressed: () =>
                        controller.respond(membershipId: m.id, accept: true),
                  ),
                  IconButton(
                    icon: const Icon(Icons.cancel, color: AppColors.error),
                    tooltip: 'Rechazar',
                    onPressed: () =>
                        controller.respond(membershipId: m.id, accept: false),
                  ),
                ],
              )
            : null,
      ),
    );
  }
}

class _MembersList extends StatelessWidget {
  final String ganaderoId;
  const _MembersList({required this.ganaderoId});

  @override
  Widget build(BuildContext context) {
    final controller = context.read<MembershipController>();
    return StreamBuilder<List<Membership>>(
      stream: controller.watchFarmMembers(ganaderoId),
      builder: (context, snapshot) {
        final members = snapshot.data ?? const <Membership>[];
        if (members.isEmpty) {
          return const Card(
            child: ListTile(
              leading: Icon(Icons.group_outlined),
              title: Text('Aún no has invitado a nadie'),
            ),
          );
        }
        return Column(
          children: members.map((m) {
            return Card(
              child: ListTile(
                leading: Icon(
                  m.memberRol == 'Veterinario'
                      ? Icons.medical_services
                      : Icons.badge,
                  color: AppColors.primary,
                ),
                title: Text(m.memberNombre),
                subtitle: Text('${m.memberRol} · ${m.memberEmail}\nEstado: ${m.estado.value}'),
                isThreeLine: true,
                trailing: m.estado != MembershipStatus.revocada
                    ? IconButton(
                        icon: const Icon(Icons.person_remove, color: AppColors.error),
                        tooltip: 'Revocar acceso',
                        onPressed: () => controller.revoke(m.id),
                      )
                    : null,
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
