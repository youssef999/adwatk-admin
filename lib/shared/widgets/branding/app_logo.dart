import 'package:flutter/material.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';

enum AppLogoVariant { full, compact, mark }

class AppLogo extends StatelessWidget {
  const AppLogo({
    super.key,
    this.variant = AppLogoVariant.full,
    this.height,
    this.showTagline = false,
  });

  final AppLogoVariant variant;
  final double? height;
  final bool showTagline;

  @override
  Widget build(BuildContext context) {
    return switch (variant) {
      AppLogoVariant.full => _FullLogo(height: height ?? 72, showTagline: showTagline),
      AppLogoVariant.compact => _CompactLogo(height: height ?? 40),
      AppLogoVariant.mark => _MarkLogo(size: height ?? 36),
    };
  }
}

class _FullLogo extends StatelessWidget {
  const _FullLogo({required this.height, required this.showTagline});

  final double height;
  final bool showTagline;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          child: Image.asset(
            AppAssets.logo,
            height: height,
            fit: BoxFit.contain,
            filterQuality: FilterQuality.high,
            errorBuilder: (context, error, stackTrace) => const _LogoFallback(),
          ),
        ),
        if (showTagline) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(
            'لوحة التحكم',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.4,
            ),
          ),
        ],
      ],
    );
  }
}

class _CompactLogo extends StatelessWidget {
  const _CompactLogo({required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.md),
          child: Image.asset(
            AppAssets.logo,
            height: height,
            width: height,
            fit: BoxFit.cover,
            filterQuality: FilterQuality.high,
            errorBuilder: (context, error, stackTrace) => SizedBox(
              height: height,
              width: height,
              child: const _LogoFallback(compact: true),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'ادواتك',
                style: AppTextStyles.h6.copyWith(
                  color: AppColors.secondary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                'لوحة التحكم',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MarkLogo extends StatelessWidget {
  const _MarkLogo({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Image.asset(
        AppAssets.logo,
        height: size,
        width: size,
        fit: BoxFit.cover,
        filterQuality: FilterQuality.high,
        errorBuilder: (context, error, stackTrace) => SizedBox(
          height: size,
          width: size,
          child: const _LogoFallback(compact: true),
        ),
      ),
    );
  }
}

class _LogoFallback extends StatelessWidget {
  const _LogoFallback({this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(compact ? AppSpacing.sm : AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Text(
        'ادواتك',
        style: (compact ? AppTextStyles.caption : AppTextStyles.h5).copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
