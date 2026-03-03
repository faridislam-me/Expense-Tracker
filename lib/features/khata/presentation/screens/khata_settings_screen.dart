import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/buttons/primary_button.dart';
import '../../../../core/widgets/inputs/custom_text_field.dart';
import '../providers/khata_provider.dart';

class KhataSettingsScreen extends StatefulWidget {
  final String accountId;

  const KhataSettingsScreen({super.key, required this.accountId});

  @override
  State<KhataSettingsScreen> createState() => _KhataSettingsScreenState();
}

class _KhataSettingsScreenState extends State<KhataSettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _budgetController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final khata = context.read<KhataProvider>();
    if (khata.account != null) {
      _nameController.text = khata.account!.name;
      _budgetController.text = khata.account!.totalBudget.toStringAsFixed(0);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _budgetController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    await context.read<KhataProvider>().updateKhata(
          accountId: widget.accountId,
          name: _nameController.text.trim(),
          totalBudget: double.parse(_budgetController.text.trim()),
        );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Khata updated')),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Khata Settings')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              CustomTextField(
                controller: _nameController,
                labelText: 'Khata Name',
                prefixIcon: Icons.book,
                validator: (v) => Validators.required(v, 'Name'),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _budgetController,
                labelText: 'Budget',
                prefixIcon: Icons.attach_money,
                keyboardType: TextInputType.number,
                validator: Validators.amount,
              ),
              const SizedBox(height: 32),
              PrimaryButton(
                text: 'Save Changes',
                onPressed: _save,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
