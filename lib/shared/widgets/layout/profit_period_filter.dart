import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/profit_period.dart';

class ProfitPeriodFilter extends StatelessWidget {
  const ProfitPeriodFilter({
    super.key,
    required this.selected,
    required this.onSelected,
    this.activeColor = AppColors.primary,
  });

  final ProfitPeriod selected;
  final ValueChanged<ProfitPeriod> onSelected;
  final Color activeColor;

  @override
  Widget build(BuildContext context) {
    final periods = ProfitPeriod.values;
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _PeriodChip(
                period: periods[0],
                selected: selected == periods[0],
                activeColor: activeColor,
                onTap: () => onSelected(periods[0]),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: _PeriodChip(
                period: periods[1],
                selected: selected == periods[1],
                activeColor: activeColor,
                onTap: () => onSelected(periods[1]),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Expanded(
              child: _PeriodChip(
                period: periods[2],
                selected: selected == periods[2],
                activeColor: activeColor,
                onTap: () => onSelected(periods[2]),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: _PeriodChip(
                period: periods[3],
                selected: selected == periods[3],
                activeColor: activeColor,
                onTap: () => onSelected(periods[3]),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _PeriodChip extends StatelessWidget {
  const _PeriodChip({
    required this.period,
    required this.selected,
    required this.activeColor,
    required this.onTap,
  });

  final ProfitPeriod period;
  final bool selected;
  final Color activeColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? activeColor : AppColors.surface,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(
              color: selected ? activeColor : AppColors.border,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            period.labelAr,
            style: AppTextStyles.caption.copyWith(
              color: selected ? AppColors.surface : AppColors.textSecondary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}
