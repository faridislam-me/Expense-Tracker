import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/config/app_routes.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/buttons/primary_button.dart';
import '../../../../core/widgets/inputs/custom_text_field.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/khata_provider.dart';

class CreateKhataScreen extends StatefulWidget {
  const CreateKhataScreen({super.key});

  @override
  State<CreateKhataScreen> createState() => _CreateKhataScreenState();
}

class _CreateKhataScreenState extends State<CreateKhataScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _budgetController = TextEditingController();
  String _trackingType = AppConstants.trackingMonthly;

  @override
  void dispose() {
    _nameController.dispose();
    _budgetController.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    final khataProvider = context.read<KhataProvider>();
    final user = auth.user!;

    try {
      final accountId = await khataProvider.createKhata(
            name: _nameController.text.trim(),
            trackingType: _trackingType,
            totalBudget: double.parse(_budgetController.text.trim()),
            userId: user.id,
            userName: user.name,
            userEmail: user.email,
          );

      if (!mounted) return;
      await auth.refreshUser();
      if (!mounted) return;
      context.go(
        AppRoutes.khataDetail.replaceFirst(':accountId', accountId),
      );
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Khata')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomTextField(
                controller: _nameController,
                labelText: 'Khata Name',
                hintText: 'e.g., Personal, Office, Family',
                prefixIcon: Icons.book,
                validator: (v) => Validators.required(v, 'Name'),
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _budgetController,
                labelText: 'Budget',
                hintText: 'Enter total budget',
                prefixIcon: Icons.attach_money,
                keyboardType: TextInputType.number,
                validator: Validators.amount,
                textInputAction: TextInputAction.done,
              ),
              const SizedBox(height: 24),
              Text(
                'Tracking Type',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              _buildTrackingOption(
                'Monthly',
                'Track expenses per month, resets each month',
                AppConstants.trackingMonthly,
              ),
              const SizedBox(height: 8),
              _buildTrackingOption(
                'Total',
                'Track all expenses without monthly reset',
                AppConstants.trackingTotal,
              ),
              const SizedBox(height: 32),
              Consumer<KhataProvider>(
                builder: (context, khata, _) {
                  return PrimaryButton(
                    text: 'Create Khata',
                    isLoading: khata.isLoading,
                    onPressed: _create,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTrackingOption(String title, String subtitle, String value) {
    final selected = _trackingType == value;
    return InkWell(
      onTap: () => setState(() => _trackingType = value),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.divider,
            width: selected ? 2 : 1,
          ),
          color: selected
              ? AppColors.primary.withValues(alpha: 0.05)
              : null,
        ),
        child: Row(
          children: [
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: selected ? AppColors.primary : AppColors.textHint,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
