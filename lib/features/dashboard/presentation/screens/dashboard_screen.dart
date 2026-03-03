import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import '../../../../core/config/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/dashboard_provider.dart';
import '../widgets/dashboard_header.dart';
import '../widgets/khata_summary_card.dart';
import '../widgets/quick_stats_widget.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    final auth = context.read<AuthProvider>();
    if (auth.user != null) {
      context.read<DashboardProvider>().loadAccounts(auth.user!.accountIds);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await context.read<AuthProvider>().refreshUser();
            _loadData();
          },
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: DashboardHeader(
                    userName: context.watch<AuthProvider>().user?.name ?? '',
                    photoUrl: context.watch<AuthProvider>().user?.photoUrl,
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Consumer<DashboardProvider>(
                  builder: (context, dash, _) {
                    return QuickStatsWidget(
                      totalBudget: Formatters.currency(dash.totalBudget),
                      accountCount: dash.accounts.length.toString(),
                    );
                  },
                ),
              ),
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20, 24, 20, 12),
                  child: Text(
                    'Your Khatas',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              Consumer<DashboardProvider>(
                builder: (context, dash, _) {
                  if (dash.isLoading) {
                    return const SliverFillRemaining(
                      child: LoadingWidget(),
                    );
                  }

                  if (dash.accounts.isEmpty) {
                    return SliverFillRemaining(
                      child: EmptyStateWidget(
                        icon: Iconsax.wallet_3,
                        title: 'No khatas yet',
                        subtitle: 'Create your first khata to start tracking',
                        actionLabel: 'Create Khata',
                        onAction: () => context.push(AppRoutes.createKhata),
                      ),
                    );
                  }

                  return SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final account = dash.accounts[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: KhataSummaryCard(
                              account: account,
                              onTap: () => context.push(
                                AppRoutes.khataDetail
                                    .replaceFirst(':accountId', account.id),
                              ),
                            ),
                          );
                        },
                        childCount: dash.accounts.length,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.createKhata),
        icon: const Icon(Icons.add),
        label: const Text('New Khata'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
      ),
    );
  }
}
