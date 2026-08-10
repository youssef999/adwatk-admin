import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/date_format_utils.dart';
import '../../../shared/widgets/buttons/app_button.dart';
import '../../requests/widgets/status_badge.dart';
import '../models/shipment_request_money_model.dart';

class ShipmentRequestMoneyCard extends StatelessWidget {
  const ShipmentRequestMoneyCard({
    super.key,
    required this.request,
    this.selected = false,
    this.onTap,
    this.onApprove,
    this.onReject,
    this.isActing = false,
  });

  final ShipmentRequestMoneyModel request;
  final bool selected;
  final VoidCallback? onTap;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;
  final bool isActing;

  @override
  Widget build(BuildContext context) {
    final showActions = request.isPending &&
        (onApprove != null || onReject != null);

    final card = Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: selected
            ? AppColors.warning.withValues(alpha: 0.08)
            : AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: selected ? AppColors.warning : AppColors.border,
          width: selected ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: const Icon(
                  Icons.request_page_outlined,
                  color: AppColors.warning,
                  size: AppIconSize.md,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      request.userEmail.isEmpty
                          ? 'طلب سحب شحن'
                          : request.userEmail,
                      style: AppTextStyles.h6,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      DateFormatUtils.format(request.createdAt),
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
              ),
              StatusBadge(status: request.status),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              _MiniStat(
                label: 'المبلغ',
                value: '${request.amount}',
                emphasize: true,
              ),
              const SizedBox(width: AppSpacing.sm),
              _MiniStat(
                label: 'طريقة الدفع',
                value: request.paymentMethod.isEmpty
                    ? '—'
                    : request.paymentMethod,
              ),
              const SizedBox(width: AppSpacing.sm),
              _MiniStat(
                label: 'معاملات',
                value: '${request.transIds.length}',
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'هاتف: ${request.phone.isEmpty ? '—' : request.phone}',
            style: AppTextStyles.caption,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (request.howToGetMoney.trim().isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              request.howToGetMoney,
              style: AppTextStyles.caption,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          if (showActions && onTap == null) ...[
            const SizedBox(height: AppSpacing.md),
            _ActionRow(
              isActing: isActing,
              onApprove: onApprove,
              onReject: onReject,
            ),
          ],
        ],
      ),
    );

    final tappable = onTap == null
        ? card
        : Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              child: card,
            ),
          );

    if (!showActions || onTap == null) return tappable;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        tappable,
        const SizedBox(height: AppSpacing.sm),
        _ActionRow(
          isActing: isActing,
          onApprove: onApprove,
          onReject: onReject,
        ),
      ],
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.isActing,
    this.onApprove,
    this.onReject,
  });

  final bool isActing;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (onReject != null)
          Expanded(
            child: AppButton(
              label: 'رفض',
              variant: AppButtonVariant.danger,
              icon: Icons.close,
              isLoading: isActing,
              isExpanded: true,
              onPressed: isActing ? null : onReject,
            ),
          ),
        if (onReject != null && onApprove != null)
          const SizedBox(width: AppSpacing.sm),
        if (onApprove != null)
          Expanded(
            child: AppButton(
              label: 'إرسال',
              icon: Icons.send_outlined,
              isLoading: isActing,
              isExpanded: true,
              onPressed: isActing ? null : onApprove,
            ),
          ),
      ],
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({
    required this.label,
    required this.value,
    this.emphasize = false,
  });

  final String label;
  final String value;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: AppTextStyles.caption),
            const SizedBox(height: AppSpacing.xs),
            Text(
              value,
              style: AppTextStyles.caption.copyWith(
                color: emphasize ? AppColors.warning : AppColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
