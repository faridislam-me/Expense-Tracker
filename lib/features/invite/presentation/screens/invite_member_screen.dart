import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/buttons/primary_button.dart';
import '../../../../core/widgets/inputs/custom_text_field.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../khata/presentation/providers/khata_provider.dart';
import '../providers/invite_provider.dart';

class InviteMemberScreen extends StatefulWidget {
  final String accountId;

  const InviteMemberScreen({super.key, required this.accountId});

  @override
  State<InviteMemberScreen> createState() => _InviteMemberScreenState();
}

class _InviteMemberScreenState extends State<InviteMemberScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  String _selectedRole = AppConstants.roleEditor;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    final khata = context.read<KhataProvider>();

    final success = await context.read<InviteProvider>().sendInvite(
          accountId: widget.accountId,
          email: _emailController.text.trim(),
          role: _selectedRole,
          invitedBy: auth.user!.id,
          accountName: khata.account?.name ?? '',
        );

    if (success && mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invite sent')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Invite Member')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomTextField(
                controller: _emailController,
                labelText: 'Email',
                hintText: 'Enter member email',
                prefixIcon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                validator: Validators.email,
              ),
              const SizedBox(height: 24),
              Text('Role', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              _buildRoleOption('Editor', AppConstants.roleEditor,
                  'Can add and edit expenses'),
              const SizedBox(height: 8),
              _buildRoleOption('Viewer', AppConstants.roleViewer,
                  'Can only view expenses'),
              const SizedBox(height: 32),
              Consumer<InviteProvider>(
                builder: (context, provider, _) {
                  return PrimaryButton(
                    text: 'Send Invite',
                    isLoading: provider.isLoading,
                    onPressed: _send,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleOption(String title, String value, String description) {
    final selected = _selectedRole == value;
    return InkWell(
      onTap: () => setState(() => _selectedRole = value),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.divider,
            width: selected ? 2 : 1,
          ),
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
                  Text(title,
                      style: Theme.of(context).textTheme.titleSmall),
                  Text(
                    description,
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
