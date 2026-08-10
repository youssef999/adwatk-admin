import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:jose/jose.dart';

import 'fcm_config.dart';

/// Sends push notifications via FCM HTTP v1 using a service account.
class FcmNotificationSender {
  static const String _tokenUri = 'https://oauth2.googleapis.com/token';
  static const String _fcmScope =
      'https://www.googleapis.com/auth/firebase.messaging';

  String? _cachedAccessToken;
  DateTime? _tokenExpiry;
  String? lastError;

  Future<String> _getAccessToken() async {
    if (_cachedAccessToken != null &&
        _tokenExpiry != null &&
        DateTime.now().isBefore(
          _tokenExpiry!.subtract(const Duration(minutes: 5)),
        )) {
      return _cachedAccessToken!;
    }

    final now = DateTime.now();
    final expiry = now.add(const Duration(hours: 1));

    final claims = JsonWebTokenClaims.fromJson({
      'iss': FcmConfig.clientEmail,
      'sub': FcmConfig.clientEmail,
      'aud': _tokenUri,
      'iat': (now.millisecondsSinceEpoch / 1000).floor(),
      'exp': (expiry.millisecondsSinceEpoch / 1000).floor(),
      'scope': _fcmScope,
    });

    final builder = JsonWebSignatureBuilder()
      ..jsonContent = claims.toJson()
      ..addRecipient(
        JsonWebKey.fromPem(FcmConfig.privateKey, keyId: 'firebase-adminsdk'),
        algorithm: 'RS256',
      );

    final jwt = builder.build().toCompactSerialization();

    final response = await http.post(
      Uri.parse(_tokenUri),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {
        'grant_type': 'urn:ietf:params:oauth:grant-type:jwt-bearer',
        'assertion': jwt,
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to get access token: ${response.body}');
    }

    final data = json.decode(response.body) as Map<String, dynamic>;
    _cachedAccessToken = data['access_token'] as String?;
    _tokenExpiry = expiry;
    if (_cachedAccessToken == null || _cachedAccessToken!.isEmpty) {
      throw Exception('Access token missing in OAuth response');
    }
    return _cachedAccessToken!;
  }

  Future<bool> sendToToken({
    required String token,
    required String title,
    required String body,
    Map<String, String>? data,
  }) async {
    lastError = null;
    final trimmed = token.trim();
    if (trimmed.isEmpty) {
      lastError = 'لا يوجد FCM token للمستلم';
      return false;
    }

    try {
      final accessToken = await _getAccessToken();
      final url =
          'https://fcm.googleapis.com/v1/projects/${FcmConfig.projectId}/messages:send';

      final message = {
        'message': {
          'token': trimmed,
          'notification': {
            'title': title,
            'body': body,
          },
          if (data != null) 'data': data,
          'android': {
            'priority': 'high',
            'notification': {
              'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            },
          },
          'apns': {
            'payload': {
              'aps': {
                'sound': 'default',
                'badge': 1,
              },
            },
          },
        },
      };

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: json.encode(message),
      );

      if (response.statusCode == 200) return true;

      lastError = 'FCM ${response.statusCode}: ${response.body}';
      return false;
    } catch (e) {
      lastError = '$e';
      return false;
    }
  }
}
