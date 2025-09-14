import 'dart:async';
import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';

import '../cashed_ar_cache_manager.dart';
import '../models/ar_platform.dart';
import '../models/ar_cache_options.dart';

/// A widget that displays 3D AR models with intelligent caching for Android
class CachedModelViewer extends StatefulWidget {
  /// The URL of the 3D model to display
  final String modelUrl;

  /// Unique identifier for the product (used for caching)
  final String productId;

  /// Display name for the product
  final String productName;

  /// Whether to enable auto-rotation of the model
  final bool autoRotate;

  /// Whether to enable AR mode
  final bool ar;

  /// Whether to disable zoom functionality
  final bool disableZoom;

  /// Whether to disable pan functionality
  final bool disablePan;

  /// Camera controls settings
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

  const CachedModelViewer({
    Key? key,
    required this.modelUrl,
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
  }) : super(key: key);

  @override
  State<CachedModelViewer> createState() => _CachedModelViewerState();
}

class _CachedModelViewerState extends State<CachedModelViewer> {
  bool _isLoading = true;
  bool _hasError = false;
  String? _localModelPath;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _prepareModel();
  }

  Future<void> _prepareModel() async {
    if (!mounted) return;

    try {
      widget.onModelLoading?.call();

      final savePath = await ARCacheManager.getCachedFile(
        context,
        widget.modelUrl,
        widget.productId,
        ARPlatform.android,
        options: widget.cacheOptions,
      );

      if (mounted) {
        setState(() {
          _localModelPath = savePath;
          _isLoading = false;
          _hasError = savePath == null;
          if (savePath == null) {
            _errorMessage = 'Failed to load 3D model';
            widget.onError?.call(_errorMessage!);
          } else {
            widget.onModelLoaded?.call();
          }
        });
      }
    } catch (e) {
      debugPrint('Error preparing model: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
          _errorMessage = e.toString();
        });
        widget.onError?.call(e.toString());
      }
    }
  }

  Widget _buildLoadingWidget() {
    if (widget.loadingWidget != null) {
      return widget.loadingWidget!;
    }

    return Container(
      color: widget.backgroundColor ?? Colors.transparent,
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              'Loading 3D Model...',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    if (widget.errorWidget != null) {
      return widget.errorWidget!;
    }

    return Container(
      color: widget.backgroundColor ?? Colors.transparent,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              _errorMessage ?? 'Failed to load 3D model',
              style: const TextStyle(fontSize: 16, color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _isLoading = true;
                  _hasError = false;
                  _errorMessage = null;
                });
                _prepareModel();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModelViewer() {
    return Stack(
      children: [
        ModelViewer(
          backgroundColor: widget.backgroundColor ?? Colors.transparent,
          src: 'file://$_localModelPath',
          alt: 'A 3D model of ${widget.productName}',
          ar: widget.ar,
          autoRotate: widget.autoRotate,
          disableZoom: widget.disableZoom,
          disablePan: widget.disablePan,
        ),
        // Show download progress overlay if still downloading
        ValueListenableBuilder<double>(
          valueListenable: ARCacheManager.progressNotifier,
          builder: (context, progress, child) {
            if (progress > 0 && progress < 100) {
              return Container(
                color: Colors.black54,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Downloading 3D Model...',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${progress.toStringAsFixed(0)}%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _buildLoadingWidget();
    }

    if (_hasError || _localModelPath == null) {
      return _buildErrorWidget();
    }

    return _buildModelViewer();
  }
}
