# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.1] - 2024-09-15

### Fixed
- Enhanced demo with complete AR functionality showcase
- Updated README with auto-playing GIF demonstration
- Improved visual presentation for pub.dev

## [1.0.0] - 2024-09-14

### Added
- Initial release of Cashed AR plugin
- Cross-platform AR model viewing support
- iOS native QuickLook AR viewer integration with USDZ files
- Android model_viewer_plus integration with GLB files
- Intelligent caching system with automatic cleanup
- Advanced download management with progress tracking
- Exponential backoff retry mechanism for failed downloads
- Chunked downloads for large files with resume capability
- URL-based cache validation and integrity verification
- Configurable cache options (size limits, timeouts, retry attempts)
- Beautiful loading dialogs with progress indicators
- Error handling with retry options
- CashedARViewer widget for seamless cross-platform AR
- CachedModelViewer widget for Android-specific 3D viewing
- ARCacheManager for file caching operations
- ARCacheOptions for cache configuration
- Platform-specific file format support (USDZ for iOS, GLB for Android)
- Enhanced product gallery UI with modern design
- Comprehensive documentation and examples
- Example application with beautiful UI

### Features
- **iOS Support**: Native QuickLook AR viewer with USDZ files
- **Android Support**: model_viewer_plus integration with GLB files  
- **Smart Caching**: Automatic file caching with cleanup and validation
- **Download Management**: Progress tracking, retry logic, chunked transfers
- **User Experience**: Loading dialogs, error handling, smooth transitions
- **Performance**: Lazy loading, efficient memory management, minimal overhead
- **Customization**: Configurable UI components and caching behavior

### Platform Support
- iOS 11.0+ (QuickLook AR)
- Android API 19+ (model_viewer_plus)

### Dependencies
- Flutter 3.3.0+
- Dart 3.0.0+
- model_viewer_plus: ^1.7.2
- dio: +5.3.2
- path_provider: ^2.1.1
