/// Configuration options for AR model caching
class ARCacheOptions {
  /// Maximum file size allowed for caching (in bytes)
  /// Default: 100MB
  final int maxFileSize;

  /// Connection timeout for downloads
  /// Default: 3 minutes
  final Duration connectTimeout;

  /// Receive timeout for downloads
  /// Default: 3 minutes
  final Duration receiveTimeout;

  /// Send timeout for downloads
  /// Default: 3 minutes
  final Duration sendTimeout;

  /// Maximum number of retry attempts for failed downloads
  /// Default: 3
  final int maxRetryAttempts;

  /// Chunk size for download progress (in bytes)
  /// Default: 5MB
  final int chunkSize;

  /// Whether to show loading dialog during download
  /// Default: true
  final bool showLoadingDialog;

  /// Whether to show progress indicator
  /// Default: true
  final bool showProgress;

  /// Custom headers to include in download requests
  final Map<String, String> headers;

  const ARCacheOptions({
    this.maxFileSize = 100 * 1024 * 1024, // 100MB
    this.connectTimeout = const Duration(minutes: 3),
    this.receiveTimeout = const Duration(minutes: 3),
    this.sendTimeout = const Duration(minutes: 3),
    this.maxRetryAttempts = 3,
    this.chunkSize = 5 * 1024 * 1024, // 5MB
    this.showLoadingDialog = true,
    this.showProgress = true,
    this.headers = const {'Accept-Encoding': 'gzip, deflate'},
  });

  /// Create a copy of this options with some fields replaced
  ARCacheOptions copyWith({
    int? maxFileSize,
    Duration? connectTimeout,
    Duration? receiveTimeout,
    Duration? sendTimeout,
    int? maxRetryAttempts,
    int? chunkSize,
    bool? showLoadingDialog,
    bool? showProgress,
    Map<String, String>? headers,
  }) {
    return ARCacheOptions(
      maxFileSize: maxFileSize ?? this.maxFileSize,
      connectTimeout: connectTimeout ?? this.connectTimeout,
      receiveTimeout: receiveTimeout ?? this.receiveTimeout,
      sendTimeout: sendTimeout ?? this.sendTimeout,
      maxRetryAttempts: maxRetryAttempts ?? this.maxRetryAttempts,
      chunkSize: chunkSize ?? this.chunkSize,
      showLoadingDialog: showLoadingDialog ?? this.showLoadingDialog,
      showProgress: showProgress ?? this.showProgress,
      headers: headers ?? this.headers,
    );
  }
}
