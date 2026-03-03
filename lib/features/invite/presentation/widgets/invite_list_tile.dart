import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../data/models/invite_model.dart';

class InviteListTile extends StatelessWidget {
  final InviteModel invite;

  const InviteListTile({super.key, required this.invite});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: AppColors.warning.withValues(alpha: 0.1),
        child: const Icon(Icons.mail_outline, color: AppColors.warning),
      ),
      title: Text(invite.email),
      subtitle: Text(
        'Invited ${Formatters.relativeTime(invite.createdAt)} • ${invite.role}',
      ),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.warning.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Text(
          'Pending',
          style: TextStyle(
            color: AppColors.warning,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
