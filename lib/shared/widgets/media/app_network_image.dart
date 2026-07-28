import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/utils/storage_url.dart';

/// Project-wide network image for Firebase Storage download URLs and CDNs.
///
/// On web, prefers an HTML `<img>` element so Firebase Storage URLs load
/// despite CanvasKit CORS restrictions on `firebasestorage.googleapis.com`.
class AppNetworkImage extends StatelessWidget {
  const AppNetworkImage({
    super.key,
    required this.url,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.memCacheWidth,
    this.placeholder,
    this.errorWidget,
  });

  final String? url;
  final BoxFit fit;
  final double? width;
  final double? height;
  final int? memCacheWidth;
  final Widget? placeholder;
  final Widget? errorWidget;

  @override
  Widget build(BuildContext context) {
    final resolved = StorageUrl.normalize(url);
    if (resolved == null) {
      return errorWidget ?? _DefaultBrokenImage(width: width, height: height);
    }

    if (kIsWeb) {
      return Image.network(
        resolved,
        fit: fit,
        width: width,
        height: height,
        cacheWidth: memCacheWidth,
        filterQuality: FilterQuality.medium,
        webHtmlElementStrategy: WebHtmlElementStrategy.prefer,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return placeholder ??
              _DefaultPlaceholder(width: width, height: height);
        },
        errorBuilder: (context, error, stackTrace) {
          return errorWidget ??
              _DefaultBrokenImage(width: width, height: height);
        },
      );
    }

    return CachedNetworkImage(
      imageUrl: resolved,
      fit: fit,
      width: width,
      height: height,
      memCacheWidth: memCacheWidth,
      placeholder: (context, _) =>
          placeholder ?? _DefaultPlaceholder(width: width, height: height),
      errorWidget: (context, url, error) =>
          errorWidget ?? _DefaultBrokenImage(width: width, height: height),
    );
  }
}

class _DefaultPlaceholder extends StatelessWidget {
  const _DefaultPlaceholder({this.width, this.height});

  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: const ColoredBox(
        color: AppColors.background,
        child: Center(
          child: SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      ),
    );
  }
}

class _DefaultBrokenImage extends StatelessWidget {
  const _DefaultBrokenImage({this.width, this.height});

  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: const ColoredBox(
        color: AppColors.background,
        child: Center(
          child: Icon(
            Icons.broken_image_outlined,
            color: AppColors.textDisabled,
            size: AppIconSize.lg,
          ),
        ),
      ),
    );
  }
}
