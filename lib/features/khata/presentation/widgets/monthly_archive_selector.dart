import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/month_key_helper.dart';

class MonthlyArchiveSelector extends StatelessWidget {
  final String selectedMonthKey;
  final void Function(String monthKey) onMonthChanged;

  const MonthlyArchiveSelector({
    super.key,
    required this.selectedMonthKey,
    required this.onMonthChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          onPressed: () =>
              onMonthChanged(MonthKeyHelper.previous(selectedMonthKey)),
          icon: const Icon(Icons.chevron_left),
        ),
        GestureDetector(
          onTap: () => _showMonthPicker(context),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              MonthKeyHelper.displayName(selectedMonthKey),
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        IconButton(
          onPressed: selectedMonthKey != MonthKeyHelper.current()
              ? () =>
                  onMonthChanged(MonthKeyHelper.next(selectedMonthKey))
              : null,
          icon: const Icon(Icons.chevron_right),
        ),
      ],
    );
  }

  void _showMonthPicker(BuildContext context) {
    final months = MonthKeyHelper.generateKeys(count: 24);
    showModalBottomSheet(
      context: context,
      builder: (context) => ListView.builder(
        itemCount: months.length,
        itemBuilder: (context, index) {
          final key = months[index];
          final isSelected = key == selectedMonthKey;
          return ListTile(
            title: Text(MonthKeyHelper.displayName(key)),
            selected: isSelected,
            selectedTileColor: AppColors.primary.withValues(alpha: 0.1),
            trailing: isSelected
                ? const Icon(Icons.check, color: AppColors.primary)
                : null,
            onTap: () {
              onMonthChanged(key);
              Navigator.pop(context);
            },
          );
        },
      ),
    );
  }
}
