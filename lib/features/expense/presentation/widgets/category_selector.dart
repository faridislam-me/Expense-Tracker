import 'package:flutter/material.dart';
import '../../../../core/constants/category_data.dart';
import '../../../../core/theme/app_colors.dart';

class CategorySelector extends StatelessWidget {
  final String selected;
  final void Function(String category) onSelected;

  const CategorySelector({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: CategoryData.defaultCategories.map((cat) {
        final isSelected = cat.name == selected;
        return FilterChip(
          label: Text(cat.name),
          avatar: Icon(cat.icon, size: 18, color: isSelected ? Colors.white : cat.color),
          selected: isSelected,
          onSelected: (_) => onSelected(cat.name),
          selectedColor: AppColors.primary,
          checkmarkColor: Colors.white,
          labelStyle: TextStyle(
            color: isSelected ? Colors.white : null,
            fontWeight: isSelected ? FontWeight.w600 : null,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        );
      }).toList(),
    );
  }
}
