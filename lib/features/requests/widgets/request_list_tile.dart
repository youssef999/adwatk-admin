import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/date_format_utils.dart';
import '../../../core/utils/storage_url.dart';
import '../../../shared/widgets/media/app_network_image.dart';
import '../models/request_model.dart';
import 'status_badge.dart';

class RequestListTile extends StatelessWidget {
  const RequestListTile({
    super.key,
    required this.request,
    required this.selected,
    required this.onTap,
  });

  final RequestModel request;
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
                  child: !StorageUrl.isUsable(request.imageUrl)
                      ? Container(
                          color: AppColors.background,
                          child: const Icon(
                            Icons.image_not_supported_outlined,
                            color: AppColors.textDisabled,
                            size: AppIconSize.lg,
                          ),
                        )
                      : AppNetworkImage(
                          url: request.imageUrl,
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
                            request.partName.isEmpty ? 'بدون اسم' : request.partName,
                            style: AppTextStyles.h5,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        StatusBadge(status: request.status),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      '${request.carBrandLabel} · ${request.carType}',
                      style: AppTextStyles.body2,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
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
                            DateFormatUtils.format(request.createdAt),
                            style: AppTextStyles.body2,
                          ),
                        ),
                        if (request.hasShipmentOffer)
                          const Icon(
                            Icons.local_shipping_outlined,
                            size: AppIconSize.md,
                            color: AppColors.info,
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
