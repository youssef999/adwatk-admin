import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/date_format_utils.dart';
import '../../../core/utils/storage_url.dart';
import '../../../shared/widgets/media/app_network_image.dart';
import '../models/sale_part_model.dart';
import 'status_badge.dart';

class SalePartListTile extends StatelessWidget {
  const SalePartListTile({
    super.key,
    required this.part,
    required this.selected,
    required this.onTap,
  });

  final SalePartModel part;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected
          ? AppColors.primary.withValues(alpha: 0.08)
          : AppColors.surface,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.border,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.md),
                child: SizedBox(
                  width: 88,
                  height: 88,
                  child: !StorageUrl.isUsable(part.imageUrl)
                      ? Container(
                          color: AppColors.background,
                          child: const Icon(
                            Icons.image_not_supported_outlined,
                            color: AppColors.textDisabled,
                            size: AppIconSize.lg,
                          ),
                        )
                      : AppNetworkImage(
                          url: part.imageUrl,
                          fit: BoxFit.cover,
                          memCacheWidth: 176,
                        ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            part.partName.isEmpty ? 'بدون اسم' : part.partName,
                            style: AppTextStyles.h5,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        StatusBadge(status: part.status),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      '${part.carBrandLabel} · ${part.carType}',
                      style: AppTextStyles.body2,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      '${part.price} د.ع · ${part.condition}',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      children: [
                        const Icon(
                          Icons.schedule,
                          size: AppIconSize.md,
                          color: AppColors.textDisabled,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Expanded(
                          child: Text(
                            DateFormatUtils.format(part.createdAt),
                            style: AppTextStyles.body2,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
