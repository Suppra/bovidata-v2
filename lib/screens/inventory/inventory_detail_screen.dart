import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../controllers/inventory_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../models/inventory_model.dart';
import '../../constants/app_styles.dart';
import '../../constants/app_constants.dart';
import 'inventory_form_screen.dart';

class InventoryDetailScreen extends StatelessWidget {
  final InventoryModel item;

  const InventoryDetailScreen({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(item.nombre),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        actions: [
          Consumer<AuthController>(
            builder: (context, authController, child) {
              final userRole = authController.currentUser?.rol;
              
              if (userRole == 'Ganadero' || userRole == 'Veterinario') {
                return PopupMenuButton<String>(
                  onSelected: (value) => _handleAction(context, value),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit),
                          SizedBox(width: 8),
                          Text('Editar'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'stock',
                      child: Row(
                        children: [
                          Icon(Icons.inventory),
                          SizedBox(width: 8),
                          Text('Ajustar Stock'),
                        ],
                      ),
                    ),
                    if (userRole == 'Ganadero') ...[
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: AppColors.error),
                            SizedBox(width: 8),
                            Text('Eliminar', style: AppTextStyles.errorText),
                          ],
                        ),
                      ),
                    ],
                  ],
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Estado del Stock
            _buildStockStatusCard(),
            
            // Información Básica
            _buildBasicInfoCard(),
            
            // Información Comercial
            _buildCommercialInfoCard(),
            
            // Información de Vencimiento
            if (item.fechaVencimiento != null) _buildExpirationCard(),
            
            // Botones de Acción Rápida
            _buildQuickActionsCard(context),
          ],
        ),
      ),
    );
  }

  Widget _buildStockStatusCard() {
    final stockStatus = _getStockStatus();
    
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(AppDimensions.paddingL),
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      decoration: BoxDecoration(
        color: stockStatus.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        border: Border.all(color: stockStatus.color, width: 2),
      ),
      child: Column(
        children: [
          Icon(
            stockStatus.icon,
            size: 48,
            color: stockStatus.color,
          ),
          const SizedBox(height: AppDimensions.marginM),
          Text(
            'Stock: ${item.cantidadActual} ${item.unidad}',
            style: AppTextStyles.h5.copyWith(
              color: stockStatus.color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppDimensions.marginS),
          Text(
            stockStatus.message,
            style: AppTextStyles.body2.copyWith(color: stockStatus.color),
            textAlign: TextAlign.center,
          ),
          if (item.cantidadActual > 0) ...[
            const SizedBox(height: AppDimensions.marginM),
            LinearProgressIndicator(
              value: (item.cantidadActual / (item.cantidadMinima * 3)).clamp(0.0, 1.0),
              backgroundColor: stockStatus.color.withValues(alpha: 0.3),
              valueColor: AlwaysStoppedAnimation<Color>(stockStatus.color),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBasicInfoCard() {
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingL,
        vertical: AppDimensions.marginM,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Información Básica',
              style: AppTextStyles.h6.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppDimensions.marginM),

            _buildInfoRow(
              icon: Icons.inventory_2,
              label: 'Nombre',
              value: item.nombre,
            ),

            _buildInfoRow(
              icon: Icons.category,
              label: 'Categoría',
              value: item.categoria,
            ),

            _buildInfoRow(
              icon: Icons.type_specimen,
              label: 'Tipo',
              value: item.tipo,
            ),

            if (item.descripcion != null && item.descripcion!.isNotEmpty) ...[
              _buildInfoRow(
                icon: Icons.description,
                label: 'Descripción',
                value: item.descripcion!,
                isMultiline: true,
              ),
            ],

            _buildInfoRow(
              icon: Icons.straighten,
              label: 'Unidad de Medida',
              value: item.unidad,
            ),

            _buildInfoRow(
              icon: Icons.calendar_today,
              label: 'Fecha de Registro',
              value: DateFormat(AppConstants.dateTimeFormat).format(item.fechaCreacion),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommercialInfoCard() {
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingL,
        vertical: AppDimensions.marginM,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Información Comercial',
              style: AppTextStyles.h6.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppDimensions.marginM),

            Row(
              children: [
                Expanded(
                  child: _buildStockCard(
                    'Stock Actual',
                    '${item.cantidadActual}',
                    item.unidad,
                    Icons.inventory,
                    AppColors.primary,
                  ),
                ),
                const SizedBox(width: AppDimensions.marginM),
                Expanded(
                  child: _buildStockCard(
                    'Stock Mínimo',
                    '${item.cantidadMinima}',
                    item.unidad,
                    Icons.warning,
                    AppColors.warning,
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppDimensions.marginL),

            if (item.precioUnitario != null) ...[
              _buildInfoRow(
                icon: Icons.attach_money,
                label: 'Precio Unitario',
                value: '\$${item.precioUnitario!.toStringAsFixed(2)}',
              ),
              
              _buildInfoRow(
                icon: Icons.calculate,
                label: 'Valor Total en Stock',
                value: '\$${(item.precioUnitario! * item.cantidadActual).toStringAsFixed(2)}',
              ),
            ],

            if (item.lote != null && item.lote!.isNotEmpty) ...[
              _buildInfoRow(
                icon: Icons.qr_code,
                label: 'Lote',
                value: item.lote!,
              ),
            ],

            if (item.proveedor != null && item.proveedor!.isNotEmpty) ...[
              _buildInfoRow(
                icon: Icons.business,
                label: 'Proveedor',
                value: item.proveedor!,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildExpirationCard() {
    final expirationInfo = _getExpirationInfo();
    
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingL,
        vertical: AppDimensions.marginM,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Información de Vencimiento',
              style: AppTextStyles.h6.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppDimensions.marginM),

            Container(
              padding: const EdgeInsets.all(AppDimensions.paddingM),
              decoration: BoxDecoration(
                color: expirationInfo.color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                border: Border.all(color: expirationInfo.color),
              ),
              child: Row(
                children: [
                  Icon(
                    expirationInfo.icon,
                    color: expirationInfo.color,
                    size: 32,
                  ),
                  const SizedBox(width: AppDimensions.marginM),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Vence: ${DateFormat(AppConstants.dateFormat).format(item.fechaVencimiento!)}',
                          style: AppTextStyles.body1.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: AppDimensions.marginS),
                        Text(
                          expirationInfo.message,
                          style: AppTextStyles.body2.copyWith(
                            color: expirationInfo.color,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionsCard(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(AppDimensions.paddingL),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Acciones Rápidas',
              style: AppTextStyles.h6.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppDimensions.marginM),

            Consumer<AuthController>(
              builder: (context, authController, child) {
                final userRole = authController.currentUser?.rol;
                
                return Column(
                  children: [
                    // Ajustar Stock
                    if (userRole == 'Ganadero' || userRole == 'Veterinario') ...[
                      ElevatedButton.icon(
                        onPressed: () => _showStockAdjustmentDialog(context),
                        icon: const Icon(Icons.inventory),
                        label: const Text('Ajustar Stock'),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 48),
                        ),
                      ),
                      
                      const SizedBox(height: AppDimensions.marginM),
                    ],

                    // Editar Información
                    if (userRole == 'Ganadero' || userRole == 'Veterinario') ...[
                      OutlinedButton.icon(
                        onPressed: () => _navigateToEdit(context),
                        icon: const Icon(Icons.edit),
                        label: const Text('Editar Información'),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 48),
                        ),
                      ),
                    ],
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    bool isMultiline = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppDimensions.marginS),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppColors.textSecondary),
          const SizedBox(width: AppDimensions.marginM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: AppTextStyles.body1,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStockCard(
    String title,
    String value,
    String unit,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: AppDimensions.marginS),
          Text(
            title,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            '$value $unit',
            style: AppTextStyles.body1.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  StockStatus _getStockStatus() {
    if (item.cantidadActual == 0) {
      return StockStatus(
        icon: Icons.error,
        color: AppColors.error,
        message: 'Sin stock disponible',
      );
    } else if (item.cantidadActual <= item.cantidadMinima) {
      return StockStatus(
        icon: Icons.warning,
        color: AppColors.warning,
        message: 'Stock bajo - Requiere reposición',
      );
    } else if (item.cantidadActual <= item.cantidadMinima * 2) {
      return StockStatus(
        icon: Icons.info,
        color: AppColors.info,
        message: 'Stock moderado',
      );
    } else {
      return StockStatus(
        icon: Icons.check_circle,
        color: AppColors.success,
        message: 'Stock suficiente',
      );
    }
  }

  ExpirationInfo _getExpirationInfo() {
    final daysUntilExpiry = item.fechaVencimiento!.difference(DateTime.now()).inDays;
    
    if (daysUntilExpiry < 0) {
      return ExpirationInfo(
        icon: Icons.dangerous,
        color: AppColors.error,
        message: 'Producto vencido hace ${(-daysUntilExpiry)} días',
      );
    } else if (daysUntilExpiry == 0) {
      return ExpirationInfo(
        icon: Icons.error,
        color: AppColors.error,
        message: 'Producto vence hoy',
      );
    } else if (daysUntilExpiry <= 30) {
      return ExpirationInfo(
        icon: Icons.warning,
        color: AppColors.warning,
        message: 'Vence en $daysUntilExpiry días - Revisar pronto',
      );
    } else {
      return ExpirationInfo(
        icon: Icons.check_circle,
        color: AppColors.success,
        message: 'Vence en $daysUntilExpiry días',
      );
    }
  }

  void _handleAction(BuildContext context, String action) {
    switch (action) {
      case 'edit':
        _navigateToEdit(context);
        break;
      case 'stock':
        _showStockAdjustmentDialog(context);
        break;
      case 'delete':
        _showDeleteConfirmation(context);
        break;
    }
  }

  void _navigateToEdit(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => InventoryFormScreen(item: item),
      ),
    );
  }

  void _showStockAdjustmentDialog(BuildContext context) {
    final TextEditingController quantityController = TextEditingController();
    final TextEditingController reasonController = TextEditingController();
    String adjustmentType = 'add';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Ajustar Stock'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Stock actual: ${item.cantidadActual} ${item.unidad}'),
              const SizedBox(height: AppDimensions.marginL),
              
              DropdownButtonFormField<String>(
                value: adjustmentType,
                decoration: const InputDecoration(
                  labelText: 'Tipo de Ajuste',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'add', child: Text('Agregar stock')),
                  DropdownMenuItem(value: 'remove', child: Text('Quitar stock')),
                  DropdownMenuItem(value: 'set', child: Text('Establecer cantidad')),
                ],
                onChanged: (value) {
                  setState(() {
                    adjustmentType = value!;
                  });
                },
              ),
              
              const SizedBox(height: AppDimensions.marginM),
              
              TextFormField(
                controller: quantityController,
                decoration: InputDecoration(
                  labelText: adjustmentType == 'set' ? 'Nueva cantidad' : 'Cantidad a ${adjustmentType == 'add' ? 'agregar' : 'quitar'}',
                  border: const OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              
              const SizedBox(height: AppDimensions.marginM),
              
              TextFormField(
                controller: reasonController,
                decoration: const InputDecoration(
                  labelText: 'Motivo del ajuste',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            Consumer<InventoryController>(
              builder: (context, inventoryController, child) => ElevatedButton(
                onPressed: inventoryController.isLoading
                    ? null
                    : () => _adjustStock(
                        context,
                        inventoryController,
                        quantityController.text,
                        adjustmentType,
                        reasonController.text,
                      ),
                child: inventoryController.isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Ajustar'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _adjustStock(
    BuildContext context,
    InventoryController inventoryController,
    String quantityText,
    String adjustmentType,
    String reason,
  ) async {
    if (quantityText.isEmpty) return;
    
    final quantity = int.tryParse(quantityText);
    if (quantity == null || quantity < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor ingresa una cantidad válida'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    int newQuantity;
    switch (adjustmentType) {
      case 'add':
        newQuantity = item.cantidadActual + quantity;
        break;
      case 'remove':
        newQuantity = (item.cantidadActual - quantity).clamp(0, double.infinity).toInt();
        break;
      case 'set':
        newQuantity = quantity;
        break;
      default:
        return;
    }

    final updatedItem = InventoryModel(
      id: item.id,
      nombre: item.nombre,
      tipo: item.tipo,
      categoria: item.categoria,
      cantidadActual: newQuantity,
      cantidadMinima: item.cantidadMinima,
      unidad: item.unidad,
      precioUnitario: item.precioUnitario,
      fechaVencimiento: item.fechaVencimiento,
      lote: item.lote,
      proveedor: item.proveedor,
      descripcion: item.descripcion,
      fechaCreacion: item.fechaCreacion,
      activo: item.activo,
    );

    final success = await inventoryController.updateInventoryItem(updatedItem);

    if (context.mounted) {
      Navigator.of(context).pop();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success
              ? 'Stock ajustado exitosamente'
              : 'Error al ajustar el stock'),
          backgroundColor: success ? AppColors.success : AppColors.error,
        ),
      );
    }
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Item'),
        content: Text('¿Estás seguro de que deseas eliminar "${item.nombre}"?\n\nEsta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          Consumer<InventoryController>(
            builder: (context, inventoryController, child) => ElevatedButton(
              onPressed: inventoryController.isLoading
                  ? null
                  : () => _deleteItem(context, inventoryController),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: AppColors.white,
              ),
              child: inventoryController.isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Eliminar'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteItem(
    BuildContext context,
    InventoryController inventoryController,
  ) async {
    final success = await inventoryController.deleteInventoryItem(item.id);

    if (context.mounted) {
      Navigator.of(context).pop(); // Close dialog
      
      if (success) {
        Navigator.of(context).pop(); // Go back to list
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Item eliminado exitosamente'),
            backgroundColor: AppColors.success,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(inventoryController.errorMessage ?? 'Error al eliminar el item'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}

class StockStatus {
  final IconData icon;
  final Color color;
  final String message;

  StockStatus({
    required this.icon,
    required this.color,
    required this.message,
  });
}

class ExpirationInfo {
  final IconData icon;
  final Color color;
  final String message;

  ExpirationInfo({
    required this.icon,
    required this.color,
    required this.message,
  });
}