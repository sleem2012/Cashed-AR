import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import 'models/ar_platform.dart';
import 'models/ar_cache_options.dart';

/// Manages caching of AR model files with intelligent download and cleanup
class ARCacheManager {
  static final ValueNotifier<double> _progressNotifier = ValueNotifier<double>(
    0.0,
  );

  /// Progress notifier for download operations
  static ValueNotifier<double> get progressNotifier => _progressNotifier;

  /// Generates a filename for the cached AR model
  static String _generateFileName(String productId, ARPlatform platform) {
    return '${platform.prefix}$productId.${platform.fileExtension}';
  }

  /// Gets a cached AR model file or downloads it if not available
  ///
  /// Returns the local file path if successful, null if failed
  static Future<String?> getCachedFile(
    BuildContext context,
    String fileUrl,
    String productId,
    ARPlatform platform, {
    ARCacheOptions options = const ARCacheOptions(),
  }) async {
    if (fileUrl.isEmpty) {
      _showSnackBar(context, 'No AR content available for this product');
      return null;
    }

    try {
      final dir = await getApplicationDocumentsDirectory();
      final fileName = _generateFileName(productId, platform);
      final savePath = '${dir.path}/$fileName';
      final metadataFile = File('$savePath.metadata');

      bool fileExists = false;
      if (await metadataFile.exists()) {
        final savedUrl = await metadataFile.readAsString();
        fileExists = await File(savePath).exists() && savedUrl == fileUrl;
      }

      if (!fileExists) {
        return await _downloadFile(
          context,
          fileUrl,
          savePath,
          metadataFile,
          options,
        );
      }

      return savePath;
    } catch (e) {
      _showSnackBar(context, 'Error loading AR content: ${e.toString()}');
      return null;
    }
  }

  /// Downloads an AR model file with progress tracking and retry logic
  static Future<String?> _downloadFile(
    BuildContext context,
    String fileUrl,
    String savePath,
    File metadataFile,
    ARCacheOptions options,
  ) async {
    // Delete old files if they exist
    if (await File(savePath).exists()) {
      await File(savePath).delete();
    }
    if (await metadataFile.exists()) {
      await metadataFile.delete();
    }

    final dio = Dio(
      BaseOptions(
        connectTimeout: options.connectTimeout,
        receiveTimeout: options.receiveTimeout,
        sendTimeout: options.sendTimeout,
        headers: options.headers,
      ),
    );

    // Add retry interceptor
    dio.interceptors.add(
      InterceptorsWrapper(
        onError: (error, handler) async {
          if (_shouldRetry(error)) {
            final retryCount = error.requestOptions.extra['retryCount'] ?? 0;
            if (retryCount < options.maxRetryAttempts) {
              error.requestOptions.extra['retryCount'] = retryCount + 1;

              // Exponential backoff
              final delay = Duration(seconds: pow(2, retryCount + 1).toInt());
              await Future.delayed(delay);

              return handler.resolve(await dio.fetch(error.requestOptions));
            }
          }
          return handler.next(error);
        },
      ),
    );

    try {
      // Get file size first
      final response = await dio.head(fileUrl);
      final totalSize = int.parse(
        response.headers.value('content-length') ?? '0',
      );

      if (totalSize > options.maxFileSize) {
        if (context.mounted) {
          _showSnackBar(
            context,
            'AR file is too large (${_formatFileSize(totalSize)})',
          );
        }
        return null;
      }

      // Show loading dialog if requested
      if (options.showLoadingDialog && context.mounted) {
        unawaited(_showLoadingDialog(context, options));
      }

      _progressNotifier.value = 0.0;

      // Download with chunked transfer and resume capability
      final tempFile = File('$savePath.temp');
      var downloadedBytes = 0;

      if (await tempFile.exists()) {
        downloadedBytes = await tempFile.length();
      }

      while (downloadedBytes < totalSize) {
        final endByte = min(downloadedBytes + options.chunkSize, totalSize - 1);

        final response = await dio.get(
          fileUrl,
          options: Options(
            responseType: ResponseType.bytes,
            headers: {'Range': 'bytes=$downloadedBytes-$endByte'},
            validateStatus: (status) => status! < 500,
          ),
        );

        final chunk = response.data as List<int>;
        await tempFile.writeAsBytes(chunk, mode: FileMode.append);
        downloadedBytes += chunk.length;

        final progress = (downloadedBytes / totalSize * 100);
        _progressNotifier.value = progress;
      }

      // Verify download and rename temp file
      if (await tempFile.length() == totalSize) {
        await tempFile.rename(savePath);
        await metadataFile.writeAsString(fileUrl);
        return savePath;
      } else {
        await tempFile.delete();
        throw Exception('Downloaded file size mismatch');
      }
    } catch (e) {
      if (context.mounted) {
        _showSnackBar(
          context,
          'Failed to download AR content: ${e.toString()}',
        );
      }
      return null;
    } finally {
      if (options.showLoadingDialog && context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }
    }
  }

  /// Cleans up unused AR files based on active product IDs
  static Future<void> cleanupUnusedARFiles(
    List<String> activeProductIds,
    Map<String, String> productArUrls,
    ARPlatform platform,
  ) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final files = dir.listSync();
      int deletedCount = 0;

      for (var file in files) {
        if (file is File) {
          String fileName = file.path.split('/').last;
          
          // Check if this file matches our platform pattern
          if (fileName.startsWith(platform.prefix) && 
              fileName.endsWith('.${platform.fileExtension}')) {
            
            // Extract product ID from filename
            String productId = fileName
                .replaceFirst(platform.prefix, '')
                .replaceFirst('.${platform.fileExtension}', '');

            // Check if product is still active
            if (!activeProductIds.contains(productId)) {
              await file.delete();
              final metadataFile = File('${file.path}.metadata');
              if (await metadataFile.exists()) {
                await metadataFile.delete();
              }
              deletedCount++;
              debugPrint(
                'Deleted unused ${platform.displayName} AR file: $fileName (productId: $productId)',
              );
            } else {
              // Check if URL has changed
              final metadataFile = File('${file.path}.metadata');
              if (await metadataFile.exists()) {
                final savedUrl = await metadataFile.readAsString();
                final currentUrl = productArUrls[productId] ?? '';
                if (savedUrl != currentUrl && currentUrl.isNotEmpty) {
                  await file.delete();
                  await metadataFile.delete();
                  deletedCount++;
                  debugPrint(
                    'Deleted outdated ${platform.displayName} AR file: $fileName (URL changed)',
                  );
                }
              }
            }
          }
        }
      }
      
      debugPrint('Cache cleanup completed for ${platform.displayName}: $deletedCount files deleted');
    } catch (e) {
      debugPrint('Error cleaning up ${platform.displayName} AR files: $e');
      rethrow;
    }
  }

  /// Simple cleanup method that deletes all cached AR files
  static Future<void> clearAllCache() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final files = dir.listSync();
      int deletedCount = 0;

      for (var file in files) {
        if (file is File) {
          String fileName = file.path.split('/').last;
          
          // Delete all AR cache files and their metadata
          if (fileName.startsWith('ar_content_') && 
              (fileName.endsWith('.glb') || fileName.endsWith('.usdz') || fileName.endsWith('.metadata'))) {
            await file.delete();
            deletedCount++;
            debugPrint('Deleted AR cache file: $fileName');
          }
        }
      }
      
      debugPrint('All cache cleared: $deletedCount files deleted');
    } catch (e) {
      debugPrint('Error clearing all cache: $e');
      rethrow;
    }
  }

  /// Gets the cached file path if it exists and is valid
  static Future<String?> getCachedFilePath(
    String fileUrl,
    String productId,
    ARPlatform platform,
  ) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final fileName = _generateFileName(productId, platform);
      final savePath = '${dir.path}/$fileName';
      final metadataFile = File('$savePath.metadata');

      debugPrint('Checking cache for productId: $productId, platform: ${platform.displayName}');
      debugPrint('  Expected file: $fileName');
      debugPrint('  Full path: $savePath');
      debugPrint('  Metadata exists: ${await metadataFile.exists()}');
      debugPrint('  Model file exists: ${await File(savePath).exists()}');

      if (await metadataFile.exists() && await File(savePath).exists()) {
        final savedUrl = await metadataFile.readAsString();
        debugPrint('  Saved URL: $savedUrl');
        debugPrint('  Expected URL: $fileUrl');
        debugPrint('  URLs match: ${savedUrl == fileUrl}');
        
        if (savedUrl == fileUrl) {
          return savePath;
        }
      }
    } catch (e) {
      debugPrint('Error checking cached file: $e');
    }
    return null;
  }

  /// Lists all cached AR files for debugging
  static Future<List<String>> listAllCachedFiles() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final files = dir.listSync();
      final arFiles = <String>[];

      for (var file in files) {
        if (file is File) {
          String fileName = file.path.split('/').last;
          if (fileName.startsWith('ar_content_') && 
              (fileName.endsWith('.glb') || fileName.endsWith('.usdz'))) {
            arFiles.add(fileName);
          }
        }
      }
      
      debugPrint('All cached AR files: $arFiles');
      return arFiles;
    } catch (e) {
      debugPrint('Error listing cached files: $e');
      return [];
    }
  }

  /// Checks if an error should trigger a retry
  static bool _shouldRetry(DioException error) {
    return error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        (error.response?.statusCode != null &&
            error.response!.statusCode! >= 500);
  }

  /// Shows a loading dialog with progress indicator
  static Future<void> _showLoadingDialog(
    BuildContext context,
    ARCacheOptions options,
  ) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  width: 60,
                  height: 60,
                  child: CircularProgressIndicator(),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Downloading AR Content',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                if (options.showProgress) ...[
                  const SizedBox(height: 16),
                  ValueListenableBuilder<double>(
                    valueListenable: _progressNotifier,
                    builder: (context, value, child) {
                      return Column(
                        children: [
                          SizedBox(
                            width: 200,
                            child: LinearProgressIndicator(
                              value: value / 100,
                              backgroundColor: Colors.grey[200],
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                Colors.blue,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${value.toStringAsFixed(0)}%',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  /// Shows a snackbar message
  static void _showSnackBar(BuildContext context, String message) {
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  /// Formats file size in human-readable format
  static String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
