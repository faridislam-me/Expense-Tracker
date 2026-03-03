import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import '../../../../core/config/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../providers/khata_provider.dart';
import '../widgets/category_pie_chart.dart';
import '../widgets/expense_list_tile.dart';
import '../widgets/khata_budget_header.dart';
import '../widgets/monthly_archive_selector.dart';

class KhataDetailScreen extends StatefulWidget {
  final String accountId;

  const KhataDetailScreen({super.key, required this.accountId});

  @override
  State<KhataDetailScreen> createState() => _KhataDetailScreenState();
}

class _KhataDetailScreenState extends State<KhataDetailScreen> {
  @override
  void initState() {
    super.initState();
    context.read<KhataProvider>().loadKhata(widget.accountId);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<KhataProvider>(
      builder: (context, khata, _) {
        if (khata.isLoading && khata.account == null) {
          return const Scaffold(body: LoadingWidget());
        }

        final account = khata.account;
        if (account == null) {
          return const Scaffold(body: Center(child: Text('Khata not found')));
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(account.name),
            actions: [
              IconButton(
                icon: const Icon(Iconsax.message),
                onPressed: () => context.push(
                  AppRoutes.khataChat
                      .replaceFirst(':accountId', widget.accountId),
                ),
              ),
              IconButton(
                icon: const Icon(Iconsax.people),
                onPressed: () => context.push(
                  AppRoutes.manageMembers
                      .replaceFirst(':accountId', widget.accountId),
                ),
              ),
              IconButton(
                icon: const Icon(Iconsax.setting_2),
                onPressed: () => context.push(
                  AppRoutes.khataSettings
                      .replaceFirst(':accountId', widget.accountId),
                ),
              ),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: () => khata.loadKhata(widget.accountId),
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                KhataBudgetHeader(
                  totalBudget: account.totalBudget,
                  totalExpenses: khata.totalExpenses,
                  remaining: khata.remainingBudget,
                  progress: khata.budgetProgress,
                ),
                if (account.trackingType == 'monthly') ...[
                  const SizedBox(height: 16),
                  MonthlyArchiveSelector(
                    selectedMonthKey: khata.selectedMonthKey,
                    onMonthChanged: (key) =>
                        khata.loadExpenses(widget.accountId, monthKey: key),
                  ),
                ],
                if (khata.expenses.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  CategoryPieChart(categoryTotals: khata.categoryTotals),
                ],
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Expenses',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      '${khata.expenses.length} items',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (khata.expenses.isEmpty)
                  const EmptyStateWidget(
                    icon: Iconsax.receipt_item,
                    title: 'No expenses yet',
                    subtitle: 'Tap + to add your first expense',
                  )
                else
                  ...khata.expenses.map(
                    (expense) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: ExpenseListTile(
                        expense: expense,
                        onTap: () => context.push(
                          AppRoutes.expenseDetail
                              .replaceFirst(':accountId', widget.accountId)
                              .replaceFirst(':expenseId', expense.id),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => context.push(
              AppRoutes.addExpense
                  .replaceFirst(':accountId', widget.accountId),
            ),
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.onPrimary,
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }
}
