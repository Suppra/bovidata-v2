import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../controllers/bovine_controller.dart';
import '../../controllers/treatment_controller.dart';
import '../../controllers/inventory_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/notification_controller.dart';

import '../../models/bovine_model.dart';
import '../../models/treatment_model.dart';
import '../../models/inventory_model.dart';
import '../../models/notification_model.dart';
import '../../constants/app_styles.dart';
import '../../constants/app_constants.dart';
import '../treatments/treatment_detail_screen.dart';
import '../inventory/inventory_detail_screen.dart';


class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  String _selectedFilter = 'all';
  bool _showOnlyUnread = false;

  final List<String> _filterOptions = [
    'all',
    'treatments',
    'inventory',
    'bovines',
    'urgent',
  ];

  final Map<String, String> _filterNames = {
    'all': 'Todas',
    'treatments': 'Tratamientos',
    'inventory': 'Inventario',
    'bovines': 'Bovinos',
    'urgent': 'Urgentes',
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadData();
  }

  void _loadData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BovineController>().loadBovines();
      context.read<TreatmentController>().loadTreatments();
      context.read<InventoryController>().loadInventoryItems();
      
      // Cargar notificaciones del usuario actual
      final authController = context.read<AuthController>();
      final currentUser = authController.currentUser;
      if (currentUser != null) {
        context.read<NotificationController>().loadNotifications(currentUser.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notificaciones'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.white,
          unselectedLabelColor: AppColors.white.withOpacity(0.7),
          indicatorColor: AppColors.white,
          tabs: const [
            Tab(icon: Icon(Icons.notifications), text: 'Alertas'),
            Tab(icon: Icon(Icons.warning), text: 'Urgentes'),
            Tab(icon: Icon(Icons.message), text: 'Mensajes'),
            Tab(icon: Icon(Icons.settings), text: 'Configuración'),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            tooltip: 'Filtrar',
            onSelected: (value) => _handleFilterAction(value),
            itemBuilder: (context) => [
              ..._filterOptions.map((filter) => PopupMenuItem(
                value: filter,
                child: Row(
                  children: [
                    Icon(_selectedFilter == filter ? Icons.check : Icons.radio_button_unchecked),
                    const SizedBox(width: 8),
                    Text(_filterNames[filter]!),
                  ],
                ),
              )),
              const PopupMenuDivider(),
              PopupMenuItem(
                value: 'toggle_unread',
                child: Row(
                  children: [
                    Icon(_showOnlyUnread ? Icons.check_box : Icons.check_box_outline_blank),
                    const SizedBox(width: 8),
                    const Text('Solo no leídas'),
                  ],
                ),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.mark_email_read),
            onPressed: _markAllAsRead,
            tooltip: 'Marcar todas como leídas',
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAllNotificationsTab(),
          _buildUrgentNotificationsTab(),
          _buildMessagesTab(),
          _buildSettingsTab(),
        ],
      ),
    );
  }

  Widget _buildAllNotificationsTab() {
    return Consumer3<BovineController, TreatmentController, InventoryController>(
      builder: (context, bovineController, treatmentController, inventoryController, child) {
        final notifications = _generateNotifications(
          bovineController.bovines,
          treatmentController.treatments,
          inventoryController.inventoryItems,
        );

        final filteredNotifications = _filterNotifications(notifications);

        if (filteredNotifications.isEmpty) {
          return _buildEmptyState();
        }

        return RefreshIndicator(
          onRefresh: _refreshData,
          child: ListView.builder(
            padding: const EdgeInsets.all(AppDimensions.paddingM),
            itemCount: filteredNotifications.length,
            itemBuilder: (context, index) {
              final notification = filteredNotifications[index];
              return _buildNotificationCard(notification);
            },
          ),
        );
      },
    );
  }

  Widget _buildUrgentNotificationsTab() {
    return Consumer3<BovineController, TreatmentController, InventoryController>(
      builder: (context, bovineController, treatmentController, inventoryController, child) {
        final notifications = _generateNotifications(
          bovineController.bovines,
          treatmentController.treatments,
          inventoryController.inventoryItems,
        );

        final urgentNotifications = notifications.where((n) => n.priority == NotificationPriority.urgent).toList();

        if (urgentNotifications.isEmpty) {
          return _buildEmptyUrgentState();
        }

        return ListView.builder(
          padding: const EdgeInsets.all(AppDimensions.paddingM),
          itemCount: urgentNotifications.length,
          itemBuilder: (context, index) {
            final notification = urgentNotifications[index];
            return _buildNotificationCard(notification);
          },
        );
      },
    );
  }

  Widget _buildMessagesTab() {
    return Consumer2<AuthController, NotificationController>(
      builder: (context, authController, notificationController, child) {
        final currentUser = authController.currentUser;
        
        if (currentUser == null) {
          return const Center(
            child: Text('Usuario no autenticado'),
          );
        }

        return StreamBuilder<List<NotificationModel>>(
          stream: notificationController.getNotificationsStream(currentUser.id),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: AppColors.error,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error al cargar mensajes',
                      style: AppTextStyles.h6,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${snapshot.error}',
                      style: AppTextStyles.caption,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }

            final notifications = snapshot.data ?? [];

            if (notifications.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.message_outlined,
                      size: 64,
                      color: AppColors.grey400,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No hay mensajes',
                      style: AppTextStyles.h6.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Aquí aparecerán las notificaciones del sistema',
                      style: AppTextStyles.caption,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () => notificationController.refresh(currentUser.id),
              child: ListView.builder(
                padding: const EdgeInsets.all(AppDimensions.paddingM),
                itemCount: notifications.length,
                itemBuilder: (context, index) {
                  final notification = notifications[index];
                  return _buildSystemNotificationCard(notification);
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSettingsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Configuración de Notificaciones',
            style: AppTextStyles.h5.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: AppDimensions.marginL),

          // Treatment Notifications
          _buildSettingsSection(
            'Notificaciones de Tratamientos',
            [
              _buildSettingsSwitch(
                'Tratamientos vencidos',
                'Notificar cuando un tratamiento está vencido',
                true,
                (value) {},
              ),
              _buildSettingsSwitch(
                'Próximas aplicaciones',
                'Recordar tratamientos próximos a aplicar',
                true,
                (value) {},
              ),
              _buildSettingsSwitch(
                'Tratamientos completados',
                'Notificar cuando se completa un tratamiento',
                false,
                (value) {},
              ),
            ],
          ),

          const SizedBox(height: AppDimensions.marginL),

          // Inventory Notifications
          _buildSettingsSection(
            'Notificaciones de Inventario',
            [
              _buildSettingsSwitch(
                'Stock bajo',
                'Alertar cuando el stock esté por debajo del mínimo',
                true,
                (value) {},
              ),
              _buildSettingsSwitch(
                'Productos vencidos',
                'Notificar productos vencidos',
                true,
                (value) {},
              ),
              _buildSettingsSwitch(
                'Próximos a vencer',
                'Alertar productos próximos a vencer (30 días)',
                true,
                (value) {},
              ),
              _buildSettingsSwitch(
                'Stock agotado',
                'Notificar cuando un producto se agote',
                true,
                (value) {},
              ),
            ],
          ),

          const SizedBox(height: AppDimensions.marginL),

          // Bovine Notifications
          _buildSettingsSection(
            'Notificaciones de Bovinos',
            [
              _buildSettingsSwitch(
                'Bovinos enfermos',
                'Alertar cuando un bovino cambie a estado enfermo',
                true,
                (value) {},
              ),
              _buildSettingsSwitch(
                'Registros nuevos',
                'Notificar cuando se registre un nuevo bovino',
                false,
                (value) {},
              ),
            ],
          ),

          const SizedBox(height: AppDimensions.marginL),

          // General Settings
          _buildSettingsSection(
            'Configuración General',
            [
              _buildSettingsSwitch(
                'Sonido',
                'Reproducir sonido para notificaciones',
                true,
                (value) {},
              ),
              _buildSettingsSwitch(
                'Vibración',
                'Vibrar para notificaciones importantes',
                true,
                (value) {},
              ),
              _buildSettingsSwitch(
                'Notificaciones push',
                'Recibir notificaciones cuando la app esté cerrada',
                true,
                (value) {},
              ),
            ],
          ),

          const SizedBox(height: AppDimensions.marginXL),

          // Reset Settings
          Center(
            child: OutlinedButton.icon(
              onPressed: _resetNotificationSettings,
              icon: const Icon(Icons.restore),
              label: const Text('Restaurar Configuración Predeterminada'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.warning,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(String title, List<Widget> children) {
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
            const SizedBox(height: AppDimensions.marginM),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsSwitch(
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return SwitchListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      value: value,
      onChanged: onChanged,
      activeColor: AppColors.primary,
    );
  }

  Widget _buildNotificationCard(AppNotification notification) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppDimensions.marginM),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getPriorityColor(notification.priority),
          child: Icon(
            _getNotificationIcon(notification.type),
            color: AppColors.white,
            size: 20,
          ),
        ),
        title: Text(
          notification.title,
          style: AppTextStyles.body1.copyWith(
            fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(notification.message),
            const SizedBox(height: 4),
            Text(
              _formatNotificationTime(notification.timestamp),
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!notification.isRead)
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
            const SizedBox(width: 8),
            PopupMenuButton<String>(
              onSelected: (value) => _handleNotificationAction(value, notification),
              itemBuilder: (context) => [
                if (!notification.isRead)
                  const PopupMenuItem(
                    value: 'mark_read',
                    child: Row(
                      children: [
                        Icon(Icons.mark_email_read),
                        SizedBox(width: 8),
                        Text('Marcar como leída'),
                      ],
                    ),
                  ),
                if (notification.actionable)
                  const PopupMenuItem(
                    value: 'view_details',
                    child: Row(
                      children: [
                        Icon(Icons.visibility),
                        SizedBox(width: 8),
                        Text('Ver detalles'),
                      ],
                    ),
                  ),
                const PopupMenuItem(
                  value: 'dismiss',
                  child: Row(
                    children: [
                      Icon(Icons.close),
                      SizedBox(width: 8),
                      Text('Descartar'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        onTap: () => _handleNotificationTap(notification),
      ),
    );
  }

  Widget _buildSystemNotificationCard(NotificationModel notification) {
    Color priorityColor;
    IconData iconData;
    
    // Determinar color según prioridad
    switch (notification.prioridad.toLowerCase()) {
      case 'urgente':
        priorityColor = AppColors.error;
        break;
      case 'alta':
        priorityColor = AppColors.warning;
        break;
      case 'normal':
        priorityColor = AppColors.info;
        break;
      default:
        priorityColor = AppColors.textSecondary;
    }

    // Determinar icono según tipo
    switch (notification.tipo.toLowerCase()) {
      case 'tratamiento':
        iconData = Icons.medical_services;
        break;
      case 'inventario':
        iconData = Icons.inventory;
        break;
      case 'bovino':
        iconData = Icons.pets;
        break;
      default:
        iconData = Icons.notifications;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: AppDimensions.marginM),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: priorityColor,
          child: Icon(
            iconData,
            color: AppColors.white,
            size: 20,
          ),
        ),
        title: Text(
          notification.titulo,
          style: AppTextStyles.body1.copyWith(
            fontWeight: notification.leida ? FontWeight.normal : FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(notification.mensaje),
            const SizedBox(height: 4),
            Text(
              notification.tiempoTranscurrido,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!notification.leida)
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
            const SizedBox(width: 8),
            PopupMenuButton<String>(
              onSelected: (value) => _handleSystemNotificationAction(value, notification),
              itemBuilder: (context) => [
                if (!notification.leida)
                  const PopupMenuItem(
                    value: 'mark_read',
                    child: Row(
                      children: [
                        Icon(Icons.mark_email_read),
                        SizedBox(width: 8),
                        Text('Marcar como leída'),
                      ],
                    ),
                  ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete),
                      SizedBox(width: 8),
                      Text('Eliminar'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        onTap: () => _handleSystemNotificationTap(notification),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none,
            size: 64,
            color: AppColors.textSecondary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: AppDimensions.marginL),
          Text(
            'No hay notificaciones',
            style: AppTextStyles.h6.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppDimensions.marginM),
          Text(
            'Cuando tengas alertas importantes aparecerán aquí',
            style: AppTextStyles.body2.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyUrgentState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 64,
            color: AppColors.success.withValues(alpha: 0.7),
          ),
          const SizedBox(height: AppDimensions.marginL),
          Text(
            'No hay notificaciones urgentes',
            style: AppTextStyles.h6.copyWith(
              color: AppColors.success,
            ),
          ),
          const SizedBox(height: AppDimensions.marginM),
          Text(
            'Todo está bajo control. Las alertas urgentes aparecerán aquí cuando sea necesario.',
            style: AppTextStyles.body2.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  List<AppNotification> _generateNotifications(
    List<BovineModel> bovines,
    List<TreatmentModel> treatments,
    List<InventoryModel> inventory,
  ) {
    final notifications = <AppNotification>[];
    final now = DateTime.now();

    // Treatment notifications
    for (final treatment in treatments) {
      if (!treatment.completado) {
        if (treatment.proximaAplicacion != null) {
          final daysUntilNext = treatment.proximaAplicacion!.difference(now).inDays;
          
          if (daysUntilNext < 0) {
            // Overdue treatment
            notifications.add(AppNotification(
              id: 'treatment_overdue_${treatment.id}',
              type: NotificationType.treatment,
              priority: NotificationPriority.urgent,
              title: 'Tratamiento Vencido',
              message: 'El tratamiento "${treatment.tipo}" está vencido hace ${(-daysUntilNext)} días',
              timestamp: now,
              isRead: false,
              actionable: true,
              relatedId: treatment.id,
            ));
          } else if (daysUntilNext <= 1) {
            // Due soon
            notifications.add(AppNotification(
              id: 'treatment_due_${treatment.id}',
              type: NotificationType.treatment,
              priority: NotificationPriority.high,
              title: 'Tratamiento Próximo',
              message: daysUntilNext == 0 
                  ? 'El tratamiento "${treatment.tipo}" vence hoy'
                  : 'El tratamiento "${treatment.tipo}" vence mañana',
              timestamp: now,
              isRead: false,
              actionable: true,
              relatedId: treatment.id,
            ));
          } else if (daysUntilNext <= 3) {
            // Due in a few days
            notifications.add(AppNotification(
              id: 'treatment_reminder_${treatment.id}',
              type: NotificationType.treatment,
              priority: NotificationPriority.normal,
              title: 'Recordatorio de Tratamiento',
              message: 'El tratamiento "${treatment.tipo}" vence en $daysUntilNext días',
              timestamp: now,
              isRead: false,
              actionable: true,
              relatedId: treatment.id,
            ));
          }
        }
      }
    }

    // Inventory notifications
    for (final item in inventory) {
      // Low stock alerts
      if (item.cantidadActual <= item.cantidadMinima) {
        NotificationPriority priority = item.cantidadActual == 0 
            ? NotificationPriority.urgent 
            : NotificationPriority.high;
        
        notifications.add(AppNotification(
          id: 'inventory_low_${item.id}',
          type: NotificationType.inventory,
          priority: priority,
          title: item.cantidadActual == 0 ? 'Producto Agotado' : 'Stock Bajo',
          message: item.cantidadActual == 0 
              ? '${item.nombre} está agotado'
              : '${item.nombre} tiene stock bajo (${item.cantidadActual} ${item.unidad})',
          timestamp: now,
          isRead: false,
          actionable: true,
          relatedId: item.id,
        ));
      }

      // Expiration alerts
      if (item.fechaVencimiento != null) {
        final daysUntilExpiry = item.fechaVencimiento!.difference(now).inDays;
        
        if (daysUntilExpiry < 0) {
          // Expired
          notifications.add(AppNotification(
            id: 'inventory_expired_${item.id}',
            type: NotificationType.inventory,
            priority: NotificationPriority.urgent,
            title: 'Producto Vencido',
            message: '${item.nombre} está vencido hace ${(-daysUntilExpiry)} días',
            timestamp: now,
            isRead: false,
            actionable: true,
            relatedId: item.id,
          ));
        } else if (daysUntilExpiry <= 7) {
          // Expiring soon
          notifications.add(AppNotification(
            id: 'inventory_expiring_${item.id}',
            type: NotificationType.inventory,
            priority: daysUntilExpiry <= 1 ? NotificationPriority.high : NotificationPriority.normal,
            title: 'Producto Por Vencer',
            message: daysUntilExpiry == 0
                ? '${item.nombre} vence hoy'
                : '${item.nombre} vence en $daysUntilExpiry días',
            timestamp: now,
            isRead: false,
            actionable: true,
            relatedId: item.id,
          ));
        }
      }
    }

    // Bovine notifications
    for (final bovine in bovines) {
      if (bovine.estado == 'Enfermo') {
        notifications.add(AppNotification(
          id: 'bovine_sick_${bovine.id}',
          type: NotificationType.bovine,
          priority: NotificationPriority.high,
          title: 'Bovino Enfermo',
          message: '${bovine.nombre} está registrado como enfermo',
          timestamp: now,
          isRead: false,
          actionable: true,
          relatedId: bovine.id,
        ));
      }
    }

    // Sort by priority and timestamp
    notifications.sort((a, b) {
      int priorityComparison = _getPriorityOrder(b.priority).compareTo(_getPriorityOrder(a.priority));
      if (priorityComparison != 0) return priorityComparison;
      return b.timestamp.compareTo(a.timestamp);
    });

    return notifications;
  }

  List<AppNotification> _filterNotifications(List<AppNotification> notifications) {
    var filtered = notifications;

    // Filter by type
    if (_selectedFilter != 'all') {
      switch (_selectedFilter) {
        case 'treatments':
          filtered = filtered.where((n) => n.type == NotificationType.treatment).toList();
          break;
        case 'inventory':
          filtered = filtered.where((n) => n.type == NotificationType.inventory).toList();
          break;
        case 'bovines':
          filtered = filtered.where((n) => n.type == NotificationType.bovine).toList();
          break;
        case 'urgent':
          filtered = filtered.where((n) => n.priority == NotificationPriority.urgent).toList();
          break;
      }
    }

    // Filter by read status
    if (_showOnlyUnread) {
      filtered = filtered.where((n) => !n.isRead).toList();
    }

    return filtered;
  }

  Color _getPriorityColor(NotificationPriority priority) {
    switch (priority) {
      case NotificationPriority.urgent:
        return AppColors.error;
      case NotificationPriority.high:
        return AppColors.warning;
      case NotificationPriority.normal:
        return AppColors.info;
      case NotificationPriority.low:
        return AppColors.textSecondary;
    }
  }

  IconData _getNotificationIcon(NotificationType type) {
    switch (type) {
      case NotificationType.treatment:
        return Icons.medical_services;
      case NotificationType.inventory:
        return Icons.inventory;
      case NotificationType.bovine:
        return Icons.pets;
      case NotificationType.general:
        return Icons.info;
    }
  }

  int _getPriorityOrder(NotificationPriority priority) {
    switch (priority) {
      case NotificationPriority.urgent:
        return 4;
      case NotificationPriority.high:
        return 3;
      case NotificationPriority.normal:
        return 2;
      case NotificationPriority.low:
        return 1;
    }
  }

  String _formatNotificationTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Ahora mismo';
    } else if (difference.inHours < 1) {
      return 'Hace ${difference.inMinutes} minutos';
    } else if (difference.inDays < 1) {
      return 'Hace ${difference.inHours} horas';
    } else if (difference.inDays < 7) {
      return 'Hace ${difference.inDays} días';
    } else {
      return DateFormat(AppConstants.dateFormat).format(timestamp);
    }
  }

  void _handleFilterAction(String action) {
    if (action == 'toggle_unread') {
      setState(() {
        _showOnlyUnread = !_showOnlyUnread;
      });
    } else if (_filterOptions.contains(action)) {
      setState(() {
        _selectedFilter = action;
      });
    }
  }

  void _handleNotificationAction(String action, AppNotification notification) {
    switch (action) {
      case 'mark_read':
        _markNotificationAsRead(notification);
        break;
      case 'view_details':
        _viewNotificationDetails(notification);
        break;
      case 'dismiss':
        _dismissNotification(notification);
        break;
    }
  }

  void _handleNotificationTap(AppNotification notification) {
    if (!notification.isRead) {
      _markNotificationAsRead(notification);
    }
    
    if (notification.actionable) {
      _viewNotificationDetails(notification);
    }
  }

  void _markNotificationAsRead(AppNotification notification) {
    // TODO: Implement marking notification as read in database
    setState(() {
      notification.isRead = true;
    });
  }

  void _markAllAsRead() {
    final authController = context.read<AuthController>();
    final notificationController = context.read<NotificationController>();
    final currentUser = authController.currentUser;
    
    if (currentUser != null) {
      notificationController.markAllAsRead(currentUser.id).then((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Todas las notificaciones marcadas como leídas'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      }).catchError((error) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $error'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      });
    }
  }

  void _dismissNotification(AppNotification notification) {
    // TODO: Implement dismissing notification
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Notificación descartada'),
      ),
    );
  }

  // Métodos para manejar notificaciones del sistema
  void _handleSystemNotificationAction(String action, NotificationModel notification) {
    final notificationController = context.read<NotificationController>();
    
    switch (action) {
      case 'mark_read':
        notificationController.markAsRead(notification.id);
        break;
      case 'delete':
        _showDeleteConfirmation(notification);
        break;
    }
  }

  void _handleSystemNotificationTap(NotificationModel notification) {
    final notificationController = context.read<NotificationController>();
    
    // Marcar como leída si no está leída
    if (!notification.leida) {
      notificationController.markAsRead(notification.id);
    }

    // Si tiene datos adicionales, mostrar detalles
    if (notification.datos != null) {
      _showNotificationDetails(notification);
    }
  }

  void _showDeleteConfirmation(NotificationModel notification) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Notificación'),
        content: const Text('¿Está seguro de que desea eliminar esta notificación?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<NotificationController>().deleteNotification(notification.id);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Notificación eliminada'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.white,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  void _showNotificationDetails(NotificationModel notification) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(notification.titulo),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(notification.mensaje),
            const SizedBox(height: 16),
            if (notification.datos != null) ...[
              const Text(
                'Detalles:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...notification.datos!.entries.map((entry) => 
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Text('${entry.key}: ${entry.value}'),
                ),
              ),
            ],
            const SizedBox(height: 8),
            Text(
              'Recibido: ${notification.tiempoTranscurrido}',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
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

  void _viewNotificationDetails(AppNotification notification) {
    if (!notification.actionable || notification.relatedId == null) return;

    switch (notification.type) {
      case NotificationType.treatment:
        // Navigate to treatment detail
        _navigateToTreatmentDetail(notification.relatedId!);
        break;
      case NotificationType.inventory:
        // Navigate to inventory detail
        _navigateToInventoryDetail(notification.relatedId!);
        break;
      case NotificationType.bovine:
        // Navigate to bovine detail
        _navigateToBovineDetail(notification.relatedId!);
        break;
      case NotificationType.general:
        // Handle general notifications
        break;
    }
  }

  void _navigateToTreatmentDetail(String treatmentId) {
    final treatmentController = context.read<TreatmentController>();
    final treatment = treatmentController.treatments.firstWhere(
      (t) => t.id == treatmentId,
      orElse: () => throw Exception('Treatment not found'),
    );

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => TreatmentDetailScreen(treatment: treatment),
      ),
    );
  }

  void _navigateToInventoryDetail(String itemId) {
    final inventoryController = context.read<InventoryController>();
    final item = inventoryController.inventoryItems.firstWhere(
      (i) => i.id == itemId,
      orElse: () => throw Exception('Inventory item not found'),
    );

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => InventoryDetailScreen(item: item),
      ),
    );
  }

  void _navigateToBovineDetail(String bovineId) {
    final bovineController = context.read<BovineController>();
    final bovine = bovineController.bovines.firstWhere(
      (b) => b.id == bovineId,
      orElse: () => throw Exception('Bovine not found'),
    );

    // TODO: Navigate to bovine detail screen when implemented
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Ver detalles de ${bovine.nombre}'),
        backgroundColor: AppColors.info,
      ),
    );
  }

  void _resetNotificationSettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Restaurar Configuración'),
        content: const Text('¿Estás seguro de que deseas restaurar la configuración de notificaciones a los valores predeterminados?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Configuración restaurada'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            child: const Text('Restaurar'),
          ),
        ],
      ),
    );
  }

  Future<void> _refreshData() async {
    _loadData();
    await Future.delayed(const Duration(seconds: 1));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}

// Notification Models
class AppNotification {
  final String id;
  final NotificationType type;
  final NotificationPriority priority;
  final String title;
  final String message;
  final DateTime timestamp;
  bool isRead;
  final bool actionable;
  final String? relatedId;

  AppNotification({
    required this.id,
    required this.type,
    required this.priority,
    required this.title,
    required this.message,
    required this.timestamp,
    this.isRead = false,
    this.actionable = false,
    this.relatedId,
  });
}

enum NotificationType {
  treatment,
  inventory,
  bovine,
  general,
}

enum NotificationPriority {
  urgent,
  high,
  normal,
  low,
}