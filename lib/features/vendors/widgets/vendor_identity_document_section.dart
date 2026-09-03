import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/date_format_utils.dart';
import '../../../core/utils/storage_url.dart';
import '../../../shared/widgets/media/app_network_image.dart';
import '../models/vendor_model.dart';

class VendorIdentityDocumentSection extends StatelessWidget {
  const VendorIdentityDocumentSection({super.key, required this.vendor});

  final VendorModel vendor;

  @override
  Widget build(BuildContext context) {
    if (!vendor.hasIdentityDocument) return const SizedBox.shrink();

    final hasImage = StorageUrl.isUsable(vendor.identityDocumentUrl);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: const Icon(
                        Icons.badge_outlined,
                        color: AppColors.primary,
                        size: AppIconSize.md,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('وثيقة التاجر', style: AppTextStyles.body1),
                          const SizedBox(height: 2),
                          Text(
                            vendor.identityDocumentTypeLabel,
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  vendor.identityDocumentUpdatedAt == null
                      ? 'تاريخ الرفع: —'
                      : 'تاريخ الرفع: ${DateFormatUtils.format(vendor.identityDocumentUpdatedAt)}',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                if (hasImage) ...[
                  const SizedBox(height: AppSpacing.sm),
                  TextButton.icon(
                    onPressed: () => _openDocumentViewer(context),
                    icon: const Icon(Icons.zoom_in, size: AppIconSize.sm),
                    label: const Text('عرض الوثيقة'),
                  ),
                ],
              ],
            ),
          ),
          if (hasImage) ...[
            const SizedBox(width: AppSpacing.md),
            _DocumentPreview(
              url: vendor.identityDocumentUrl,
              onTap: () => _openDocumentViewer(context),
            ),
          ],
        ],
      ),
    );
  }

  void _openDocumentViewer(BuildContext context) {
    if (!StorageUrl.isUsable(vendor.identityDocumentUrl)) return;

    showDialog<void>(
      context: context,
      barrierColor: AppColors.textPrimary.withValues(alpha: 0.72),
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    vendor.identityDocumentTypeLabel,
                    style: AppTextStyles.h6.copyWith(color: AppColors.surface),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close, color: AppColors.surface),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.lg),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.sizeOf(context).width * 0.9,
                  maxHeight: MediaQuery.sizeOf(context).height * 0.75,
                ),
                child: InteractiveViewer(
                  minScale: 0.5,
                  maxScale: 4,
                  child: AppNetworkImage(
                    url: vendor.identityDocumentUrl,
                    fit: BoxFit.contain,
                    memCacheWidth: 1200,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DocumentPreview extends StatelessWidget {
  const _DocumentPreview({
    required this.url,
    required this.onTap,
  });

  final String url;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppRadius.md),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          width: 168,
          height: 106,
          child: Stack(
            alignment: Alignment.center,
            children: [
              AppNetworkImage(
                url: url,
                fit: BoxFit.cover,
                width: 168,
                height: 106,
                memCacheWidth: 336,
              ),
              Positioned(
                right: AppSpacing.sm,
                bottom: AppSpacing.sm,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.textPrimary.withValues(alpha: 0.55),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: const Icon(
                    Icons.zoom_in,
                    size: AppIconSize.sm,
                    color: AppColors.surface,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
