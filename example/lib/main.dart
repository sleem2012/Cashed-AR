import 'package:flutter/material.dart';
import 'package:cashed_ar/cashed_ar.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cashed AR Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const ExampleHomePage(),
    );
  }
}

class ExampleHomePage extends StatefulWidget {
  const ExampleHomePage({Key? key}) : super(key: key);

  @override
  State<ExampleHomePage> createState() => _ExampleHomePageState();
}

class _ExampleHomePageState extends State<ExampleHomePage> {
  final List<ARProduct> _products = [
    ARProduct(
      id: 'chair_1',
      name: 'Modern Office Chair',
      description: 'Ergonomic office chair with lumbar support',
      androidModelUrl:
          'https://modelviewer.dev/shared-assets/models/Astronaut.glb',
      iosModelUrl:
          'https://developer.apple.com/augmented-reality/quick-look/models/teapot/teapot.usdz',
      thumbnailUrl:
          'https://via.placeholder.com/200x200/4CAF50/FFFFFF?text=Chair',
    ),
    ARProduct(
      id: 'table_1',
      name: 'Wooden Dining Table',
      description: 'Solid oak dining table for 6 people',
      androidModelUrl:
          'https://modelviewer.dev/shared-assets/models/MaterialsVariantsShoe.glb',
      iosModelUrl:
          'https://developer.apple.com/augmented-reality/quick-look/models/drummertoy/toy_drummer.usdz',
      thumbnailUrl:
          'https://via.placeholder.com/200x200/FF9800/FFFFFF?text=Table',
    ),
    ARProduct(
      id: 'lamp_1',
      name: 'Designer Desk Lamp',
      description: 'Modern LED desk lamp with adjustable brightness',
      androidModelUrl:
          'https://modelviewer.dev/shared-assets/models/reflective-spheres.glb',
      iosModelUrl:
          'https://developer.apple.com/augmented-reality/quick-look/models/retrotv/tv_retro.usdz',
      thumbnailUrl:
          'https://via.placeholder.com/200x200/2196F3/FFFFFF?text=Lamp',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cashed AR Example'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            _buildQuickActionsSection(),
            const SizedBox(height: 24),
            _buildProductsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Welcome to Cashed AR',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Experience AR models with intelligent caching across iOS and Android platforms.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.phone_android, color: Colors.green),
                const SizedBox(width: 8),
                const Text('Android: GLB + model_viewer_plus'),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.phone_iphone, color: Colors.blue),
                const SizedBox(width: 8),
                const Text('iOS: USDZ + QuickLook AR'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Quick Actions',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _showFullScreenARExample,
                    icon: const Icon(Icons.view_in_ar),
                    label: const Text('Full Screen AR'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _cleanupCache,
                    icon: const Icon(Icons.cleaning_services),
                    label: const Text('Clean Cache'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _showCacheStatus,
                icon: const Icon(Icons.info),
                label: const Text('Cache Status'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[600],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'AR Product Gallery',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.8,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: _products.length,
          itemBuilder: (context, index) {
            final product = _products[index];
            return _buildProductCard(product);
          },
        ),
      ],
    );
  }

  Widget _buildProductCard(ARProduct product) {
    // Define color scheme based on product
    Color primaryColor = Colors.blue;
    Color accentColor = Colors.blueAccent;

    if (product.id == 'table_1') {
      primaryColor = Colors.orange;
      accentColor = Colors.deepOrange;
    } else if (product.id == 'lamp_1') {
      primaryColor = Colors.purple;
      accentColor = Colors.deepPurple;
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            primaryColor.withOpacity(0.05),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.15),
            spreadRadius: 0,
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image Section
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      primaryColor.withOpacity(0.1),
                      primaryColor.withOpacity(0.3),
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    // Fallback gradient background
                    Container(
                      width: double.infinity,
                      height: double.infinity,
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          center: Alignment.center,
                          radius: 1.0,
                          colors: [
                            Colors.white.withOpacity(0.8),
                            primaryColor.withOpacity(0.2),
                          ],
                        ),
                      ),
                    ),
                    // Product icon in center
                    Center(
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(40),
                          boxShadow: [
                            BoxShadow(
                              color: primaryColor.withOpacity(0.2),
                              spreadRadius: 2,
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Icon(
                          product.id == 'chair_1'
                              ? Icons.chair_alt
                              : product.id == 'table_1'
                                  ? Icons.table_restaurant
                                  : Icons.light,
                          size: 40,
                          color: primaryColor,
                        ),
                      ),
                    ),
                    // AR Badge
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: accentColor,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: accentColor.withOpacity(0.3),
                              spreadRadius: 1,
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.view_in_ar,
                              color: Colors.white,
                              size: 12,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'AR',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Product Info Section
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Expanded(
                      child: Text(
                        product.description,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Enhanced AR Button
                    Container(
                      width: double.infinity,
                      height: 36,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [primaryColor, accentColor],
                        ),
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: primaryColor.withOpacity(0.3),
                            spreadRadius: 0,
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(18),
                          onTap: () => _showProductAR(product),
                          child: const Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.view_in_ar,
                                  color: Colors.white,
                                  size: 18,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'View in AR',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showProductAR(ARProduct product) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ProductARScreen(product: product),
      ),
    );
  }

  void _showFullScreenARExample() async {
    final product = _products.first;
    await CashedARViewer.showARModal(
      context,
      androidModelUrl: product.androidModelUrl,
      iosModelUrl: product.iosModelUrl,
      productId: product.id,
      productName: product.name,
      onModelLoading: () {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Loading AR model...')));
      },
      onModelLoaded: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('AR model loaded successfully!')),
        );
      },
      onError: (error) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('AR Error: $error')));
      },
    );
  }

  void _cleanupCache() async {
    try {
      // Clear all cached AR files
      await ARCacheManager.clearAllCache();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cache cleared successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Cache cleanup failed: $e')));
      }
    }
  }

  void _showCacheStatus() async {
    final cachedFiles = <String>[];

    for (final product in _products) {
      // Check both platforms
      final androidCachedPath = await ARCacheManager.getCachedFilePath(
        product.androidModelUrl,
        product.id,
        ARPlatform.android,
      );

      final iosCachedPath = await ARCacheManager.getCachedFilePath(
        product.iosModelUrl,
        product.id,
        ARPlatform.ios,
      );

      // Add to list if cached on either platform
      if (androidCachedPath != null || iosCachedPath != null) {
        String platformInfo = '';
        if (androidCachedPath != null && iosCachedPath != null) {
          platformInfo = ' (Android + iOS)';
        } else if (androidCachedPath != null) {
          platformInfo = ' (Android)';
        } else {
          platformInfo = ' (iOS)';
        }
        cachedFiles.add('${product.name}$platformInfo');
      }

      // Debug logging
      debugPrint('Cache check for ${product.name}:');
      debugPrint('  Android: $androidCachedPath');
      debugPrint('  iOS: $iosCachedPath');
    }

    if (mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Cache Status'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Cached Products: ${cachedFiles.length}/${_products.length}',
              ),
              const SizedBox(height: 16),
              if (cachedFiles.isNotEmpty) ...[
                const Text('Cached:'),
                ...cachedFiles.map((name) => Text('• $name')),
              ] else
                const Text('No cached files found'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }
}

class ProductARScreen extends StatelessWidget {
  final ARProduct product;

  const ProductARScreen({Key? key, required this.product}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(product.name),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            child: Text(
              product.description,
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: CashedARViewer(
              androidModelUrl: product.androidModelUrl,
              iosModelUrl: product.iosModelUrl,
              productId: product.id,
              productName: product.name,
              cacheOptions: const ARCacheOptions(
                showLoadingDialog: true,
                showProgress: true,
              ),
              onModelLoading: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Loading ${product.name}...')),
                );
              },
              onModelLoaded: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${product.name} loaded!')),
                );
              },
              onError: (error) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('Error: $error')));
              },
            ),
          ),
        ],
      ),
    );
  }
}

class ARProduct {
  final String id;
  final String name;
  final String description;
  final String androidModelUrl;
  final String iosModelUrl;
  final String thumbnailUrl;

  ARProduct({
    required this.id,
    required this.name,
    required this.description,
    required this.androidModelUrl,
    required this.iosModelUrl,
    required this.thumbnailUrl,
  });
}
