import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../invite/presentation/providers/invite_provider.dart';
import '../../../invite/presentation/widgets/pending_invite_card.dart';
import '../providers/notification_provider.dart';
import '../widgets/notification_tile.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthProvider>();
    if (auth.user != null) {
      context.read<NotificationProvider>().loadNotifications(auth.user!.id);
      context
          .read<InviteProvider>()
          .loadPendingInvitesForUser(auth.user!.email);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          Consumer<NotificationProvider>(
            builder: (context, provider, _) {
              if (provider.unreadCount > 0) {
                return TextButton(
                  onPressed: () =>
                      provider.markAllAsRead(auth.user!.id),
                  child: const Text('Mark all read'),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          if (auth.user != null) {
            final notifProvider = context.read<NotificationProvider>();
            final inviteProvider = context.read<InviteProvider>();
            await notifProvider.loadNotifications(auth.user!.id);
            await inviteProvider.loadPendingInvitesForUser(auth.user!.email);
          }
        },
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Pending invites
            Consumer<InviteProvider>(
              builder: (context, inviteProvider, _) {
                if (inviteProvider.pendingForUser.isEmpty) {
                  return const SizedBox.shrink();
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Pending Invites',
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 12),
                    ...inviteProvider.pendingForUser.map(
                      (invite) => PendingInviteCard(
                        invite: invite,
                        onAccept: () =>
                            inviteProvider.acceptInvite(
                          invite,
                          userId: auth.user!.id,
                          userName: auth.user!.name,
                          userEmail: auth.user!.email,
                        ),
                        onDecline: () =>
                            inviteProvider.declineInvite(invite),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                );
              },
            ),
            // Notifications
            Consumer<NotificationProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading) {
                  return const LoadingWidget();
                }

                if (provider.notifications.isEmpty) {
                  return const EmptyStateWidget(
                    icon: Icons.notifications_none,
                    title: 'No notifications',
                    subtitle: 'You\'re all caught up!',
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Recent',
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 12),
                    ...provider.notifications.map(
                      (notification) => NotificationTile(
                        notification: notification,
                        onTap: () {
                          if (!notification.isRead) {
                            provider.markAsRead(
                                auth.user!.id, notification.id);
                          }
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
