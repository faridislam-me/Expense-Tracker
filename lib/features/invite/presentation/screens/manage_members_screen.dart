import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/config/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../khata/presentation/providers/khata_provider.dart';
import '../providers/invite_provider.dart';
import '../widgets/invite_list_tile.dart';
import '../widgets/member_role_chip.dart';

class ManageMembersScreen extends StatefulWidget {
  final String accountId;

  const ManageMembersScreen({super.key, required this.accountId});

  @override
  State<ManageMembersScreen> createState() => _ManageMembersScreenState();
}

class _ManageMembersScreenState extends State<ManageMembersScreen> {
  @override
  void initState() {
    super.initState();
    context.read<InviteProvider>().loadInvites(widget.accountId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Members'),
        actions: [
          TextButton.icon(
            onPressed: () => context.push(
              AppRoutes.inviteMember
                  .replaceFirst(':accountId', widget.accountId),
            ),
            icon: const Icon(Icons.person_add),
            label: const Text('Invite'),
          ),
        ],
      ),
      body: Consumer<KhataProvider>(
        builder: (context, khata, _) {
          if (khata.members.isEmpty) {
            return const EmptyStateWidget(
              icon: Icons.people_outline,
              title: 'No members yet',
              subtitle: 'Invite people to collaborate',
            );
          }

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text('Members (${khata.members.length})',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              ...khata.members.map((member) => ListTile(
                    leading: CircleAvatar(
                      backgroundColor:
                          AppColors.roleColor(member.role).withValues(alpha: 0.1),
                      child: Text(
                        member.name.isNotEmpty
                            ? member.name[0].toUpperCase()
                            : '?',
                        style: TextStyle(
                          color: AppColors.roleColor(member.role),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(member.name),
                    subtitle: Text(member.email),
                    trailing: MemberRoleChip(role: member.role),
                  )),
              const SizedBox(height: 24),
              Consumer<InviteProvider>(
                builder: (context, inviteProvider, _) {
                  final pendingInvites = inviteProvider.invites
                      .where((i) => i.isPending)
                      .toList();

                  if (pendingInvites.isEmpty) {
                    return const SizedBox.shrink();
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Pending Invites (${pendingInvites.length})',
                          style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 12),
                      ...pendingInvites.map(
                        (invite) => InviteListTile(invite: invite),
                      ),
                    ],
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
