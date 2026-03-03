import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/summary_card.dart';

class QuickStatsWidget extends StatelessWidget {
  final String totalBudget;
  final String accountCount;

  const QuickStatsWidget({
    super.key,
    required this.totalBudget,
    required this.accountCount,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: SummaryCard(
              title: 'Total Budget',
              value: totalBudget,
              icon: Iconsax.wallet_3,
              iconColor: AppColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: SummaryCard(
              title: 'Khatas',
              value: accountCount,
              icon: Iconsax.book,
              iconColor: AppColors.secondary,
            ),
          ),
        ],
      ),
    );
  }
}
