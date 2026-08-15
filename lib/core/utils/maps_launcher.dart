import 'package:url_launcher/url_launcher.dart';

import '../../shared/widgets/feedback/app_snackbar.dart';

class MapsLauncher {
  MapsLauncher._();

  static Future<void> openLatLng({
    required double lat,
    required double lng,
  }) async {
    final uri = Uri.https(
      'www.google.com',
      '/maps/search/',
      {'api': '1', 'query': '$lat,$lng'},
    );

    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok) {
      AppSnackbar.error('تعذر فتح خرائط جوجل');
    }
  }
}
