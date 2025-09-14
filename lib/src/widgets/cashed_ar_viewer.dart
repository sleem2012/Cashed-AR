import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../cashed_ar_cache_manager.dart';
import '../models/ar_platform.dart';
import '../models/ar_cache_options.dart';
import 'cached_model_viewer.dart';

/// A cross-platform AR viewer that automatically handles iOS and Android platforms
class CashedARViewer extends StatelessWidget {
  /// The URL of the Android 3D model (GLB format)
  final String androidModelUrl;

  /// The URL of the iOS 3D model (USDZ format)
  final String iosModelUrl;

  /// Unique identifier for the product (used for caching)
  final String productId;

  /// Display name for the product
  final String productName;

  /// Whether to enable auto-rotation of the model (Android only)
  final bool autoRotate;

  /// Whether to enable AR mode
  final bool ar;

  /// Whether to disable zoom functionality (Android only)
  final bool disableZoom;

  /// Whether to disable pan functionality (Android only)
  final bool disablePan;

  /// Camera controls settings (Android only)
  final String cameraControls;

  /// Background color for the viewer
  final Color? backgroundColor;

  /// Loading widget to show while preparing the model
  final Widget? loadingWidget;

  /// Error widget to show if model fails to load
  final Widget? errorWidget;

  /// Cache options for downloading and storing models
  final ARCacheOptions cacheOptions;

  /// Callback called when the model starts loading
  final VoidCallback? onModelLoading;

  /// Callback called when the model finishes loading
  final VoidCallback? onModelLoaded;

  /// Callback called when an error occurs
  final void Function(String error)? onError;

  /// Callback called when iOS AR viewer is presented
  final VoidCallback? onIOSARPresented;

  /// Callback called when iOS AR viewer is dismissed
  final VoidCallback? onIOSARDismissed;

  const CashedARViewer({
    Key? key,
    required this.androidModelUrl,
    required this.iosModelUrl,
    required this.productId,
    required this.productName,
    this.autoRotate = true,
    this.ar = true,
    this.disableZoom = false,
    this.disablePan = false,
    this.cameraControls = 'auto',
    this.backgroundColor,
    this.loadingWidget,
    this.errorWidget,
    this.cacheOptions = const ARCacheOptions(),
    this.onModelLoading,
    this.onModelLoaded,
    this.onError,
    this.onIOSARPresented,
    this.onIOSARDismissed,
  }) : super(key: key);

  /// Shows AR content in a full-screen modal
  static Future<void> showARModal(
    BuildContext context, {
    required String androidModelUrl,
    required String iosModelUrl,
    required String productId,
    required String productName,
    bool autoRotate = true,
    bool ar = true,
    bool disableZoom = false,
    bool disablePan = false,
    String cameraControls = 'auto',
    Color? backgroundColor,
    ARCacheOptions cacheOptions = const ARCacheOptions(),
    VoidCallback? onModelLoading,
    VoidCallback? onModelLoaded,
    void Function(String error)? onError,
    VoidCallback? onIOSARPresented,
    VoidCallback? onIOSARDismissed,
  }) async {
    if (Platform.isIOS) {
      // On iOS, directly show the native AR viewer
      await _showIOSARViewer(
        context,
        iosModelUrl,
        productId,
        productName,
        cacheOptions,
        onModelLoading,
        onModelLoaded,
        onError,
        onIOSARPresented,
        onIOSARDismissed,
      );
    } else {
      // On Android, show a full-screen modal with the 3D viewer
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => Scaffold(
            backgroundColor: backgroundColor ?? Colors.black,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
              title: Text(
                productName,
                style: const TextStyle(color: Colors.white),
              ),
            ),
            body: CashedARViewer(
              androidModelUrl: androidModelUrl,
              iosModelUrl: iosModelUrl,
              productId: productId,
              productName: productName,
              autoRotate: autoRotate,
              ar: ar,
              disableZoom: disableZoom,
              disablePan: disablePan,
              cameraControls: cameraControls,
              backgroundColor: backgroundColor,
              cacheOptions: cacheOptions,
              onModelLoading: onModelLoading,
              onModelLoaded: onModelLoaded,
              onError: onError,
            ),
          ),
        ),
      );
    }
  }

  static Future<void> _showIOSARViewer(
    BuildContext context,
    String modelUrl,
    String productId,
    String productName,
    ARCacheOptions cacheOptions,
    VoidCallback? onModelLoading,
    VoidCallback? onModelLoaded,
    void Function(String error)? onError,
    VoidCallback? onIOSARPresented,
    VoidCallback? onIOSARDismissed,
  ) async {
    if (modelUrl.isEmpty) {
      onError?.call('No AR content available for this product');
      return;
    }

    const MethodChannel channel = MethodChannel('cashed_ar_channel');

    try {
      onModelLoading?.call();

      // Get cached file path or download if needed
      final savePath = await ARCacheManager.getCachedFile(
        context,
        modelUrl,
        productId,
        ARPlatform.ios,
        options: cacheOptions,
      );

      if (savePath == null) {
        onError?.call('Failed to load AR content');
        return;
      }

      // Check if file exists and has content
      final file = File(savePath);
      if (!await file.exists() || await file.length() == 0) {
        onError?.call('AR file not found or empty');
        return;
      }

      onModelLoaded?.call();
      onIOSARPresented?.call();

      // Show AR viewer using the cached file
      final fileName = savePath.split('/').last;
      await channel.invokeMethod('showARViewer', {
        'fileName': fileName,
        'productName': productName,
      });

      onIOSARDismissed?.call();
    } on PlatformException catch (e) {
      onError?.call('Failed to open AR viewer: ${e.message}');
    } catch (e) {
      onError?.call('Error loading AR content: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (Platform.isIOS) {
      // On iOS, show a button to launch native AR viewer
      return _buildIOSARButton(context);
    } else {
      // On Android, show the 3D model viewer directly
      return CachedModelViewer(
        modelUrl: androidModelUrl,
        productId: productId,
        productName: productName,
        autoRotate: autoRotate,
        ar: ar,
        disableZoom: disableZoom,
        disablePan: disablePan,
        cameraControls: cameraControls,
        backgroundColor: backgroundColor,
        loadingWidget: loadingWidget,
        errorWidget: errorWidget,
        cacheOptions: cacheOptions,
        onModelLoading: onModelLoading,
        onModelLoaded: onModelLoaded,
        onError: onError,
      );
    }
  }

  Widget _buildIOSARButton(BuildContext context) {
    return Container(
      color: backgroundColor ?? Colors.transparent,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(60),
                border: Border.all(color: Colors.blue, width: 2),
              ),
              child: const Icon(Icons.view_in_ar, size: 60, color: Colors.blue),
            ),
            const SizedBox(height: 16),
            Text(
              'View in AR',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap to view ${productName} in Augmented Reality',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _showIOSARViewer(
                context,
                iosModelUrl,
                productId,
                productName,
                cacheOptions,
                onModelLoading,
                onModelLoaded,
                onError,
                onIOSARPresented,
                onIOSARDismissed,
              ),
              icon: const Icon(Icons.view_in_ar),
              label: const Text('Open AR Viewer'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
