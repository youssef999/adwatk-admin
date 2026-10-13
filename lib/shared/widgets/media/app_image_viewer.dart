import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/storage_url.dart';
import 'app_network_image.dart';

/// عارض صورة بملء الشاشة مع تكبير/تصغير (pinch / scroll).
Future<void> showAppImageViewer(
  BuildContext context, {
  required String url,
  required String title,
  String? footer,
}) async {
  if (!StorageUrl.isUsable(url)) return;

  await showDialog<void>(
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
                    title,
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
                    url: url,
                    fit: BoxFit.contain,
                    memCacheWidth: 1200,
                  ),
                ),
              ),
            ),
            if (footer != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                footer,
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
