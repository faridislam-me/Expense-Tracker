import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/buttons/primary_button.dart';
import '../../../../core/widgets/inputs/custom_text_field.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../khata/presentation/providers/khata_provider.dart';
import '../../data/models/expense_model.dart';
import '../providers/expense_provider.dart';
import '../widgets/category_selector.dart';

class EditExpenseScreen extends StatefulWidget {
  final String accountId;
  final String expenseId;

  const EditExpenseScreen({
    super.key,
    required this.accountId,
    required this.expenseId,
  });

  @override
  State<EditExpenseScreen> createState() => _EditExpenseScreenState();
}

class _EditExpenseScreenState extends State<EditExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedCategory = 'Food';
  DateTime _selectedDate = DateTime.now();
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final expenses = context.read<KhataProvider>().expenses;
      final expense = expenses.cast<ExpenseModel?>().firstWhere(
            (e) => e!.id == widget.expenseId,
            orElse: () => null,
          );
      if (expense != null) {
        _amountController.text = expense.amount.toStringAsFixed(2);
        _descriptionController.text = expense.description;
        _selectedCategory = expense.category;
        _selectedDate = expense.date;
      }
      _initialized = true;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (date != null) setState(() => _selectedDate = date);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await context.read<ExpenseProvider>().updateExpense(
          accountId: widget.accountId,
          expenseId: widget.expenseId,
          amount: double.parse(_amountController.text.trim()),
          category: _selectedCategory,
          description: _descriptionController.text.trim(),
          date: _selectedDate,
        );

    if (success && mounted) {
      context.read<KhataProvider>().loadExpenses(widget.accountId);
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Expense updated')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Expense')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomTextField(
                controller: _amountController,
                labelText: 'Amount',
                prefixIcon: Icons.attach_money,
                keyboardType: TextInputType.number,
                validator: Validators.amount,
              ),
              const SizedBox(height: 16),
              Text('Category',
                  style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              CategorySelector(
                selected: _selectedCategory,
                onSelected: (cat) =>
                    setState(() => _selectedCategory = cat),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _descriptionController,
                labelText: 'Description',
                prefixIcon: Icons.notes,
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: _pickDate,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).inputDecorationTheme.fillColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 20),
                      const SizedBox(width: 12),
                      Text(Formatters.date(_selectedDate)),
                      const Spacer(),
                      const Icon(Icons.chevron_right,
                          color: AppColors.textHint),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Consumer<ExpenseProvider>(
                builder: (context, provider, _) {
                  return PrimaryButton(
                    text: 'Save Changes',
                    isLoading: provider.isLoading,
                    onPressed: _save,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
