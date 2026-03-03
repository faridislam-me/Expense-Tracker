import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class MemberRoleChip extends StatelessWidget {
  final String role;

  const MemberRoleChip({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    final color = AppColors.roleColor(role);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        role[0].toUpperCase() + role.substring(1),
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
