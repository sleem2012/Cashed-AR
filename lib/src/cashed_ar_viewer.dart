import 'dart:io';
import 'package:flutter/services.dart';

import 'cashed_ar_platform_interface.dart';
import 'cashed_ar_cache_manager.dart';
import 'models/ar_platform.dart';

/// Implementation of [CashedArPlatform] for handling AR model viewing with caching
class CashedArViewer extends CashedArPlatform {
  /// The method channel used to interact with native platforms.
  static const MethodChannel _channel = MethodChannel('cashed_ar_channel');

  @override
  Future<bool> showARViewer({
    required String modelUrl,
    required String productId,
    required String productName,
    String? iosModelUrl,
    String? androidModelUrl,
  }) async {
    try {
      // Determine the appropriate URL
      String targetUrl;

      if (Platform.isIOS) {
        targetUrl = iosModelUrl ?? modelUrl;
      } else {
        targetUrl = androidModelUrl ?? modelUrl;
      }

      if (targetUrl.isEmpty) {
        return false;
      }

      // For iOS, use native implementation
      if (Platform.isIOS) {
        return await _showIOSARViewer(targetUrl, productId);
      }

      // For Android, this will be handled by the widget layer
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Shows AR viewer on iOS using native implementation
  Future<bool> _showIOSARViewer(String modelUrl, String productId) async {
    try {
      // The native iOS code will handle the file checking and QuickLook presentation
      final result = await _channel.invokeMethod('showARViewer', {
        'modelUrl': modelUrl,
        'productId': productId,
      });
      return result == true;
    } on PlatformException catch (e) {
      throw Exception('Failed to show iOS AR viewer: ${e.message}');
    }
  }

  @override
  Future<void> cleanupUnusedARFiles({
    required List<String> activeProductIds,
    required Map<String, String> productArUrls,
  }) async {
    // Clean up both iOS and Android files
    await ARCacheManager.cleanupUnusedARFiles(
      activeProductIds,
      productArUrls,
      ARPlatform.ios,
    );

    await ARCacheManager.cleanupUnusedARFiles(
      activeProductIds,
      productArUrls,
      ARPlatform.android,
    );
  }

  @override
  Future<String?> getCachedFilePath({
    required String modelUrl,
    required String productId,
  }) async {
    final platform = Platform.isIOS ? ARPlatform.ios : ARPlatform.android;
    return await ARCacheManager.getCachedFilePath(
      modelUrl,
      productId,
      platform,
    );
  }
}
