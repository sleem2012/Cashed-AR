import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'cashed_ar_viewer.dart';

/// The interface that implementations of cashed_ar must implement.
///
/// Platform implementations should extend this class rather than implement it as `cashed_ar`
/// does not consider newly added methods to be breaking changes. Extending this class
/// (using `extends`) ensures that the subclass will get the default implementation, while
/// platform implementations that `implements` this interface will be broken by newly added
/// [CashedArPlatform] methods.
abstract class CashedArPlatform extends PlatformInterface {
  /// Constructs a CashedArPlatform.
  CashedArPlatform() : super(token: _token);

  static final Object _token = Object();

  static CashedArPlatform _instance = CashedArViewer();

  /// The default instance of [CashedArPlatform] to use.
  ///
  /// Defaults to [CashedArViewer].
  static CashedArPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [CashedArPlatform] when
  /// they register themselves.
  static set instance(CashedArPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  /// Shows an AR model viewer with the specified parameters.
  ///
  /// [modelUrl] - The URL of the 3D model to display
  /// [productId] - Unique identifier for caching purposes
  /// [productName] - Display name for the product
  /// [iosModelUrl] - iOS-specific model URL (USDZ format)
  /// [androidModelUrl] - Android-specific model URL (GLB format)
  Future<bool> showARViewer({
    required String modelUrl,
    required String productId,
    required String productName,
    String? iosModelUrl,
    String? androidModelUrl,
  }) {
    throw UnimplementedError('showARViewer() has not been implemented.');
  }

  /// Clears cached AR models for unused products.
  ///
  /// [activeProductIds] - List of product IDs that should be kept
  /// [productArUrls] - Map of product IDs to their current AR URLs
  Future<void> cleanupUnusedARFiles({
    required List<String> activeProductIds,
    required Map<String, String> productArUrls,
  }) {
    throw UnimplementedError(
      'cleanupUnusedARFiles() has not been implemented.',
    );
  }

  /// Gets the cached file path for a model if it exists.
  ///
  /// Returns null if the file is not cached or needs to be re-downloaded.
  Future<String?> getCachedFilePath({
    required String modelUrl,
    required String productId,
  }) {
    throw UnimplementedError('getCachedFilePath() has not been implemented.');
  }
}
