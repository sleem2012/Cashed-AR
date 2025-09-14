# Cashed AR

[![pub package](https://img.shields.io/pub/v/cashed_ar.svg)](https://pub.dev/packages/cashed_ar)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![likes](https://img.shields.io/pub/likes/cashed_ar)](https://pub.dev/packages/cashed_ar/score)

A comprehensive Flutter plugin for displaying AR models with intelligent caching on both Android and iOS platforms. Perfect for e-commerce apps, product catalogs, and any application that needs to display 3D models with AR functionality.

## Demo

<p align="center">
  <img src="https://raw.githubusercontent.com/sleem2012/cashed_ar/main/screenshots/demo.gif" alt="Plugin Demo" width="300"/>
  <br/>
  <em>Plugin in Action</em>
</p>

## Features

- **Cross-Platform AR Support**:
  - **iOS**: Native QuickLook AR viewer with USDZ files
  - **Android**: model_viewer_plus integration with GLB files
  - Unified API for seamless cross-platform development

- **Intelligent Caching System**:
  - Smart file caching with automatic cleanup
  - Resume interrupted downloads
  - Chunked downloads for large files
  - URL-based cache validation
  - Configurable cache size limits

- **Advanced Download Management**:
  - Progress tracking with visual indicators
  - Exponential backoff retry mechanism
  - Network timeout handling
  - File integrity verification
  - Chunked transfer for reliable downloads

- **User Experience**:
  - Beautiful loading dialogs with progress
  - Error handling with retry options
  - Smooth platform transitions
  - Customizable UI components

- **Performance Optimized**:
  - Lazy loading of 3D models
  - Efficient memory management
  - Background processing
  - Minimal app size impact

## Platform Support

| Platform | File Format | AR Technology | Status |
|----------|-------------|---------------|---------|
| iOS      | USDZ        | QuickLook AR  | Full Support |
| Android  | GLB         | model_viewer_plus | Full Support |

## Installation

```yaml
dependencies:
  cashed_ar: ^1.0.0
```

## Quick Start

Get up and running with Cashed AR in minutes:

### 1. Add Dependency
```yaml
dependencies:
  cashed_ar: ^1.0.0
```

### 2. Import Package
```dart
import 'package:cashed_ar/cashed_ar.dart';
```

### 3. Basic Usage

#### Simple AR Viewer
```dart
CashedARViewer(
  androidModelUrl: 'https://example.com/model.glb',
  iosModelUrl: 'https://example.com/model.usdz',
  productId: 'product_123',
  productName: 'Sample Product',
)
```

#### Full-Screen AR Modal
```dart
await CashedARViewer.showARModal(
  context,
  androidModelUrl: 'https://example.com/model.glb',
  iosModelUrl: 'https://example.com/model.usdz',
  productId: 'product_123',
  productName: 'Sample Product',
);
```

#### Android-Only 3D Viewer
```dart
CachedModelViewer(
  modelUrl: 'https://example.com/model.glb',
  productId: 'product_123',
  productName: 'Sample Product',
  autoRotate: true,
  ar: true,
)
```

## Configuration Options

### Cache Options
```dart
const cacheOptions = ARCacheOptions(
  maxFileSize: 50 * 1024 * 1024, // 50MB
  maxRetryAttempts: 3,
  chunkSize: 2 * 1024 * 1024, // 2MB chunks
  showLoadingDialog: true,
  showProgress: true,
  connectTimeout: Duration(minutes: 2),
);
```

### Customization
```dart
CashedARViewer(
  androidModelUrl: 'https://example.com/model.glb',
  iosModelUrl: 'https://example.com/model.usdz',
  productId: 'product_123',
  productName: 'Sample Product',
  
  // Android-specific options
  autoRotate: true,
  disableZoom: false,
  disablePan: false,
  cameraControls: 'auto',
  backgroundColor: Colors.black,
  
  // Cache configuration
  cacheOptions: cacheOptions,
  
  // Callbacks
  onModelLoading: () => print('Model loading...'),
  onModelLoaded: () => print('Model loaded!'),
  onError: (error) => print('Error: $error'),
  onIOSARPresented: () => print('iOS AR presented'),
  onIOSARDismissed: () => print('iOS AR dismissed'),
);
```

## Platform-Specific Setup

### iOS Configuration

No additional configuration required! The plugin automatically handles:
- QuickLook framework integration
- USDZ file support
- Native AR presentation
- File management

### Android Configuration

Add internet permission to `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.INTERNET" />
```

For AR features, add camera permission (optional):
```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-feature android:name="android.hardware.camera.ar" android:required="false" />
```

## Advanced Usage

### Cache Management
```dart
// Clean up unused cached files
await ARCacheManager.cleanup(
  activeProductIds: ['product_1', 'product_2'],
);

// Check if file is cached
final cachedPath = await ARCacheManager.getCachedFilePath(
  modelUrl: 'https://example.com/model.glb',
  productId: 'product_123',
  platform: ARPlatform.android,
);
```

### Custom Loading and Error Widgets
```dart
CachedModelViewer(
  modelUrl: 'https://example.com/model.glb',
  productId: 'product_123',
  productName: 'Sample Product',
  loadingWidget: CustomLoadingWidget(),
  errorWidget: CustomErrorWidget(),
)
```

### Progress Monitoring
```dart
// Listen to download progress
ValueListenableBuilder<double>(
  valueListenable: ARCacheManager.progressNotifier,
  builder: (context, progress, child) {
    return LinearProgressIndicator(value: progress / 100);
  },
);
```

## API Reference

### CashedARViewer

The main widget that handles both iOS and Android AR viewing.

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `androidModelUrl` | `String` | Required | URL for Android GLB model |
| `iosModelUrl` | `String` | Required | URL for iOS USDZ model |
| `productId` | `String` | Required | Unique product identifier |
| `productName` | `String` | Required | Display name for the product |
| `autoRotate` | `bool` | `true` | Enable auto-rotation (Android) |
| `ar` | `bool` | `true` | Enable AR mode |
| `backgroundColor` | `Color?` | `null` | Background color |
| `cacheOptions` | `ARCacheOptions` | `default` | Cache configuration |

### CachedModelViewer

Android-specific 3D model viewer with caching.

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `modelUrl` | `String` | Required | URL of the 3D model |
| `productId` | `String` | Required | Unique product identifier |
| `productName` | `String` | Required | Product display name |
| `autoRotate` | `bool` | `true` | Enable auto-rotation |
| `disableZoom` | `bool` | `false` | Disable zoom functionality |
| `disablePan` | `bool` | `false` | Disable pan functionality |

### ARCacheOptions

Configuration for caching behavior.

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `maxFileSize` | `int` | `100MB` | Maximum file size for caching |
| `maxRetryAttempts` | `int` | `3` | Maximum retry attempts |
| `chunkSize` | `int` | `5MB` | Download chunk size |
| `showLoadingDialog` | `bool` | `true` | Show loading dialog |
| `connectTimeout` | `Duration` | `3min` | Connection timeout |

## Performance Considerations

### File Size Optimization
- iOS USDZ files: Recommended < 25MB
- Android GLB files: Recommended < 50MB
- Use compression tools for smaller file sizes

### Memory Management
```dart
// The plugin automatically manages memory by:
// - Lazy loading models
// - Cleaning up unused files
// - Using efficient caching strategies
```

### Network Optimization
```dart
const cacheOptions = ARCacheOptions(
  chunkSize: 1 * 1024 * 1024, // 1MB for slower networks
  maxRetryAttempts: 5, // More retries for unstable connections
  connectTimeout: Duration(minutes: 5), // Longer timeout
);
```

## Troubleshooting

### Common Issues

#### iOS AR not working
- Ensure device supports ARKit (iOS 11+)
- Check USDZ file format validity
- Verify file is accessible via HTTPS

#### Android 3D model not loading
- Verify GLB file format
- Check internet connectivity
- Ensure file size is within limits

#### Caching issues
```dart
// Clear all cached files
await ARCacheManager.cleanup(
  activeProductIds: [],
);
```

#### Performance issues
- Reduce model complexity
- Use smaller file sizes
- Enable chunked downloads

### Debug Mode
```dart
// Enable debug logging
debugPrint('Cache path: ${await getCachedFilePath(...)}');
```

## Examples

### E-commerce Product Viewer
```dart
class ProductARViewer extends StatelessWidget {
  final Product product;
  
  const ProductARViewer({Key? key, required this.product}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(product.name)),
      body: CashedARViewer(
        androidModelUrl: product.androidModelUrl,
        iosModelUrl: product.iosModelUrl,
        productId: product.id,
        productName: product.name,
        onError: (error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('AR Error: $error')),
          );
        },
      ),
    );
  }
}
```

### Gallery with AR Preview
```dart
class ARGallery extends StatelessWidget {
  final List<Product> products;
  
  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      itemCount: products.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
      itemBuilder: (context, index) {
        final product = products[index];
        return Card(
          child: Column(
            children: [
              Expanded(
                child: CashedARViewer(
                  androidModelUrl: product.androidModelUrl,
                  iosModelUrl: product.iosModelUrl,
                  productId: product.id,
                  productName: product.name,
                ),
              ),
              Text(product.name),
            ],
          ),
        );
      },
    );
  }
}
```

## Contributing

Contributions are welcome! Please read our [contributing guidelines](CONTRIBUTING.md) before submitting PRs.

### Development Setup
1. Clone the repository
2. Run `flutter pub get`
3. Run the example app: `cd example && flutter run`

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support

If you have any questions or need help, you can:
- Open an [issue](https://github.com/sleem2012/Cashed-AR/issues)
- Check our [example](https://github.com/sleem2012/Cashed-AR/tree/main/example) for more usage examples
- Read our [API documentation](https://pub.dev/documentation/cashed_ar/latest/)
- Contact Ahmed directly: [ahmedslem779@gmail.com](mailto:ahmedslem779@gmail.com)

## Author

**Ahmed Sleem**  
📧 Email: [ahmedslem779@gmail.com](mailto:ahmedslem779@gmail.com)  
🔗 LinkedIn: [linkedin.com/in/sleem98](https://www.linkedin.com/in/sleem98/)  
⭐ GitHub: [github.com/sleem2012](https://github.com/sleem2012)  
📦 pub.dev: [pub.dev/publishers/sleem2012](https://pub.dev/publishers/sleem2012)

---

<p align="center">
  <a href="https://pub.dev/packages/cashed_ar">pub.dev</a> •
  <a href="https://github.com/sleem2012/Cashed-AR">GitHub Repository</a> •
  <a href="https://github.com/sleem2012/Cashed-AR/issues">Report Issues</a> •
  <a href="mailto:ahmedslem779@gmail.com">Contact</a>
</p>
