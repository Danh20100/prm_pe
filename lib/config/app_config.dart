/// Google keys for this app.
///
/// Paste the real values before the demo:
/// - [serverClientId] is the OAuth *Web* client ID.
/// - [mapsApiKey] must be the same string as `com.google.android.geo.API_KEY`
///   in android/app/src/main/AndroidManifest.xml. The map reads the manifest.
///
/// The Android OAuth client in Google Cloud must use package `com.example.app`
/// and the debug keystore SHA-1. No separate Android client id is pasted here.
class AppConfig {
  const AppConfig._();

  static const String mapsApiKey = 'AIzaSyC-ZbkHYPcXZ7BwkaxDn8wqYX8TPDS0Afo';
  static const String serverClientId = '716385075533-a30ild0r1cju1bn8g3t3jmp7727o40of.apps.googleusercontent.com';

  static bool _isPlaceholder(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty || trimmed.startsWith('YOUR_');
  }

  static bool get hasMapsKey => !_isPlaceholder(mapsApiKey);

  /// Null until a real Web client ID is pasted, so a placeholder is not sent
  /// to Google Sign-In.
  static String? get serverClientIdOrNull =>
      _isPlaceholder(serverClientId) ? null : serverClientId;
}
