/// Enumeration for AR platforms supported by the plugin
enum ARPlatform {
  /// iOS platform using USDZ files
  ios,

  /// Android platform using GLB files
  android;

  /// Get the file extension for this platform
  String get fileExtension => this == ARPlatform.ios ? 'usdz' : 'glb';

  /// Get the filename prefix for cached files
  String get prefix =>
      this == ARPlatform.ios ? 'ar_content_' : 'ar_content_android_';

  /// Get the display name for this platform
  String get displayName => this == ARPlatform.ios ? 'iOS' : 'Android';
}
