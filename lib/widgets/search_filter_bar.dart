import 'package:flutter/material.dart';
import '../constants/app_styles.dart';

class SearchFilterBar extends StatelessWidget {
  final TextEditingController searchController;
  final String selectedStatus;
  final String selectedRace;
  final List<String> availableRaces;
  final ValueChanged<String?> onStatusChanged;
  final ValueChanged<String?> onRaceChanged;

  const SearchFilterBar({
    super.key,
    required this.searchController,
    required this.selectedStatus,
    required this.selectedRace,
    required this.availableRaces,
    required this.onStatusChanged,
    required this.onRaceChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      color: AppColors.grey50,
      child: Column(
        children: [
          // Search Field
          TextField(
            controller: searchController,
            decoration: InputDecoration(
              hintText: 'Buscar por nombre, ID o raza...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () => searchController.clear(),
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: AppColors.white,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.paddingM,
                vertical: AppDimensions.paddingS,
              ),
            ),
          ),
          
          const SizedBox(height: AppDimensions.marginM),
          
          // Filter Row
          Row(
            children: [
              // Status Filter
              Expanded(
                child: _buildFilterDropdown(
                  label: 'Estado',
                  value: selectedStatus,
                  items: ['Todos', 'Sano', 'Enfermo', 'En recuperación', 'Muerto'],
                  onChanged: onStatusChanged,
                  icon: Icons.health_and_safety,
                ),
              ),
              
              const SizedBox(width: AppDimensions.marginM),
              
              // Race Filter
              Expanded(
                child: _buildFilterDropdown(
                  label: 'Raza',
                  value: selectedRace,
                  items: ['Todas', ...availableRaces],
                  onChanged: onRaceChanged,
                  icon: Icons.pets,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    required IconData icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        border: Border.all(color: AppColors.border),
      ),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, size: AppDimensions.iconS),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingM,
            vertical: AppDimensions.paddingS,
          ),
        ),
        items: items.map((item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(
              item,
              style: AppTextStyles.body2,
              overflow: TextOverflow.ellipsis,
            ),
          );
        }).toList(),
        onChanged: onChanged,
        isExpanded: true,
        icon: const Icon(Icons.keyboard_arrow_down),
      ),
    );
  }
}