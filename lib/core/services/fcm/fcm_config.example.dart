// Copy to fcm_config.dart and fill Firebase Admin SDK credentials.
// Firebase Console → Project Settings → Service Accounts → Generate New Private Key

class FcmConfig {
  static const String projectId = 'your-project-id';
  static const String clientEmail =
      'firebase-adminsdk-xxxxx@your-project-id.iam.gserviceaccount.com';
  static const String privateKey = '''-----BEGIN PRIVATE KEY-----
YOUR_PRIVATE_KEY_HERE
-----END PRIVATE KEY-----''';
}
