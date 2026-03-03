import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/buttons/primary_button.dart';
import '../../../../core/widgets/inputs/custom_text_field.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../khata/presentation/providers/khata_provider.dart';
import '../providers/expense_provider.dart';
import '../providers/image_upload_provider.dart';
import '../widgets/category_selector.dart';
import '../widgets/receipt_image_picker.dart';

class AddExpenseScreen extends StatefulWidget {
  final String accountId;

  const AddExpenseScreen({super.key, required this.accountId});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedCategory = 'Food';
  DateTime _selectedDate = DateTime.now();

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

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    final imageProvider = context.read<ImageUploadProvider>();

    final expense = await context.read<ExpenseProvider>().addExpense(
          accountId: widget.accountId,
          amount: double.parse(_amountController.text.trim()),
          category: _selectedCategory,
          description: _descriptionController.text.trim(),
          date: _selectedDate,
          addedBy: auth.user!.id,
          receiptUrl: imageProvider.receiptUrl,
        );

    if (expense != null && mounted) {
      imageProvider.reset();
      context.read<KhataProvider>().loadExpenses(widget.accountId);
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Expense added')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Expense')),
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
                hintText: '0.00',
                prefixIcon: Icons.attach_money,
                keyboardType: TextInputType.number,
                validator: Validators.amount,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),
              Text(
                'Category',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              CategorySelector(
                selected: _selectedCategory,
                onSelected: (cat) =>
                    setState(() => _selectedCategory = cat),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _descriptionController,
                labelText: 'Description (optional)',
                hintText: 'What was this expense for?',
                prefixIcon: Icons.notes,
                maxLines: 2,
                textInputAction: TextInputAction.next,
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
              const SizedBox(height: 16),
              const ReceiptImagePicker(),
              const SizedBox(height: 32),
              Consumer<ExpenseProvider>(
                builder: (context, provider, _) {
                  return PrimaryButton(
                    text: 'Add Expense',
                    isLoading: provider.isLoading,
                    onPressed: _submit,
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
