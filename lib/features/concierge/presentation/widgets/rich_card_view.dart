import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/screen.dart';
import '../../domain/concierge_models.dart';
import 'cab_comparison_card.dart';
import 'budget_summary_card.dart';

/// Renders a [RichCard] payload into the appropriate Flutter widget.
class RichCardView extends StatelessWidget {
  final RichCard card;
  const RichCardView({super.key, required this.card});

  @override
  Widget build(BuildContext context) {
    switch (card.type) {
      case 'cab_comparison':
        return CabComparisonCard(data: card.data);
      case 'budget_summary':
        return BudgetSummaryCard(data: card.data);
      default:
        return _UnknownCard(type: card.type);
    }
  }
}

class _UnknownCard extends StatelessWidget {
  final String type;
  const _UnknownCard({required this.type});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: kSoftShadow,
      ),
      child: Text('Card: $type'),
    );
  }
}
