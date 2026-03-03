import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/config/app_routes.dart';
import '../../../../core/constants/category_data.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../khata/presentation/providers/khata_provider.dart';
import '../../data/models/expense_model.dart';
import '../providers/expense_provider.dart';

class ExpenseDetailScreen extends StatelessWidget {
  final String accountId;
  final String expenseId;

  const ExpenseDetailScreen({
    super.key,
    required this.accountId,
    required this.expenseId,
  });

  @override
  Widget build(BuildContext context) {
    final expenses = context.watch<KhataProvider>().expenses;
    final expense = expenses.cast<ExpenseModel?>().firstWhere(
          (e) => e!.id == expenseId,
          orElse: () => null,
        );

    if (expense == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Expense not found')),
      );
    }

    final category = CategoryData.getCategoryByName(expense.category);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => context.push(
              AppRoutes.editExpense
                  .replaceFirst(':accountId', accountId)
                  .replaceFirst(':expenseId', expenseId),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppColors.error),
            onPressed: () => _confirmDelete(context),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Center(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: category.color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(category.icon, color: category.color, size: 40),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              Formatters.currency(expense.amount),
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.error,
                  ),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              expense.category,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
          ),
          const SizedBox(height: 32),
          _buildDetailRow(context, 'Description',
              expense.description.isNotEmpty ? expense.description : '-'),
          _buildDetailRow(context, 'Date', Formatters.date(expense.date)),
          _buildDetailRow(
              context, 'Added', Formatters.dateTime(expense.createdAt)),
          if (expense.receiptUrl != null) ...[
            const SizedBox(height: 24),
            Text('Receipt',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CachedNetworkImage(
                imageUrl: expense.receiptUrl!,
                fit: BoxFit.cover,
                placeholder: (context, url) => const SizedBox(
                  height: 200,
                  child: Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (context, url, error) =>
                    const Icon(Icons.broken_image),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
          Text(value, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Expense?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final deleted = await context
                  .read<ExpenseProvider>()
                  .deleteExpense(accountId, expenseId);
              if (deleted && context.mounted) {
                context.read<KhataProvider>().loadExpenses(accountId);
                Navigator.of(context).pop();
              }
            },
            child: const Text('Delete',
                style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}
