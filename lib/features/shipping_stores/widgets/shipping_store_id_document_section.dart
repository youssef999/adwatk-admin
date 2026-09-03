import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/date_format_utils.dart';
import '../../../core/utils/storage_url.dart';
import '../../../shared/widgets/media/app_network_image.dart';
import '../models/shippiment_store_model.dart';

class ShippingStoreIdDocumentSection extends StatelessWidget {
  const ShippingStoreIdDocumentSection({super.key, required this.store});

  final ShippimentStoreModel store;

  @override
  Widget build(BuildContext context) {
    if (!store.hasIdDocument) return const SizedBox.shrink();

    final hasImage = StorageUrl.isUsable(store.idDocumentUrl);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.18),
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 560;

          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _Header(typeLabel: store.idDocumentTypeLabel),
                const SizedBox(height: AppSpacing.sm),
                _MetaRow(updatedAt: store.idDocumentUpdatedAt),
                if (hasImage) ...[
                  const SizedBox(height: AppSpacing.md),
                  _DocumentPreview(
                    url: store.idDocumentUrl,
                    onTap: () => _openViewer(context),
                  ),
                ] else ...[
                  const SizedBox(height: AppSpacing.sm),
                  _NoImageNote(),
                ],
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Header(typeLabel: store.idDocumentTypeLabel),
                    const SizedBox(height: AppSpacing.sm),
                    _MetaRow(updatedAt: store.idDocumentUpdatedAt),
                    if (hasImage) ...[
                      const SizedBox(height: AppSpacing.sm),
                      TextButton.icon(
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        onPressed: () => _openViewer(context),
                        icon: const Icon(Icons.zoom_in, size: AppIconSize.sm),
                        label: const Text('عرض الوثيقة بالحجم الكامل'),
                      ),
                    ] else
                      _NoImageNote(),
                  ],
                ),
              ),
              if (hasImage) ...[
                const SizedBox(width: AppSpacing.md),
                SizedBox(
                  width: 180,
                  child: _DocumentPreview(
                    url: store.idDocumentUrl,
                    width: 180,
                    height: 114,
                    onTap: () => _openViewer(context),
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  void _openViewer(BuildContext context) {
    if (!StorageUrl.isUsable(store.idDocumentUrl)) return;

    showDialog<void>(
      context: context,
      barrierColor: AppColors.textPrimary.withValues(alpha: 0.72),
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      store.idDocumentTypeLabel,
                      style: AppTextStyles.h6.copyWith(color: AppColors.surface),
                    ),
                  ),
                  IconButton(
                    tooltip: 'إغلاق',
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
                      url: store.idDocumentUrl,
                      fit: BoxFit.contain,
                      memCacheWidth: 1200,
                    ),
                  ),
                ),
              ),
              if (store.idDocumentUpdatedAt != null) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'آخر تحديث: ${DateFormatUtils.format(store.idDocumentUpdatedAt)}',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.surface.withValues(alpha: 0.85),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.typeLabel});

  final String typeLabel;

  @override
  Widget build(BuildContext context) {
    return Row(
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
              Text('وثيقة الهوية', style: AppTextStyles.body1),
              const SizedBox(height: 2),
              Text(
                typeLabel,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: AppColors.success.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppRadius.sm),
            border: Border.all(
              color: AppColors.success.withValues(alpha: 0.3),
            ),
          ),
          child: Text(
            'موثّقة',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.success,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({required this.updatedAt});

  final DateTime? updatedAt;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(
          Icons.schedule,
          size: AppIconSize.sm,
          color: AppColors.textDisabled,
        ),
        const SizedBox(width: AppSpacing.xs),
        Text(
          updatedAt == null
              ? 'تاريخ الرفع: —'
              : 'تاريخ الرفع: ${DateFormatUtils.format(updatedAt)}',
          style: AppTextStyles.caption.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

/// يظهر عندما يوجد نوع هوية لكن لا توجد صورة مرفوعة.
class _NoImageNote extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(
          Icons.image_not_supported_outlined,
          size: AppIconSize.sm,
          color: AppColors.textDisabled,
        ),
        const SizedBox(width: AppSpacing.xs),
        Text(
          'لم يتم رفع صورة الوثيقة بعد',
          style: AppTextStyles.caption.copyWith(
            color: AppColors.textDisabled,
          ),
        ),
      ],
    );
  }
}

class _DocumentPreview extends StatelessWidget {
  const _DocumentPreview({
    required this.url,
    required this.onTap,
    this.width,
    this.height,
  });

  final String url;
  final VoidCallback onTap;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppRadius.md),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Stack(
          alignment: Alignment.center,
          children: [
            AspectRatio(
              aspectRatio: 1.58,
              child: AppNetworkImage(
                url: url,
                fit: BoxFit.cover,
                width: width,
                height: height,
                memCacheWidth: 336,
              ),
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
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.zoom_in,
                      size: AppIconSize.sm,
                      color: AppColors.surface,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      'تكبير',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.surface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
