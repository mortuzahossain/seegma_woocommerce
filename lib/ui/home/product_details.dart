import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:seegma_woocommerce/provider/product_details_provider.dart';

class ProductDetailsPage extends StatefulWidget {
  final Map<String, dynamic> product;

  const ProductDetailsPage({super.key, required this.product});

  @override
  State<ProductDetailsPage> createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProductDetailsProvider>(context, listen: false).setProductId(widget.product['id'].toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.product["name"] ?? '')),
      body: Consumer<ProductDetailsProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.hasError) {
            return const Center(child: Text('Failed to load product'));
          }

          final product = provider.product;
          if (product == null) {
            return const Center(child: Text('No product found'));
          }

          final purchasable = product['purchasable'] ?? false;
          final inStock = (product['stock_status'] ?? '') == 'instock';
          final virtualTryon = product['virtual_tryon'] ?? false;
          final price = product['price'] ?? '';
          final salePrice = product['sale_price'] ?? '';
          final imageUrl = product['image'] ?? '';
          final name = product['name'] ?? '';
          final shortDescription = product['short_description'] ?? '';
          final additionalDetails = (product['additional_details'] is Map)
              ? Map<String, dynamic>.from(product['additional_details'])
              : <String, dynamic>{};

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildImageSlider(product),

                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(name, style: Theme.of(context).textTheme.titleLarge),
                ),

                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    children: [
                      if (salePrice != null && salePrice.isNotEmpty)
                        Text(
                          '\$$salePrice',
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red, fontSize: 18),
                        ),
                      if (salePrice != null && salePrice.isNotEmpty) const SizedBox(width: 8),
                      Text(
                        '\$$price',
                        style: TextStyle(
                          fontSize: 16,
                          color: salePrice != null && salePrice.isNotEmpty ? Colors.grey : Colors.black,
                          decoration: salePrice != null && salePrice.isNotEmpty
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(shortDescription, style: Theme.of(context).textTheme.bodyMedium),
                ),

                const SizedBox(height: 12),
                if (additionalDetails.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: additionalDetails.entries.map((e) {
                        final valueList = (e.value as List).join(', ');
                        return Text('${e.key}: $valueList', style: Theme.of(context).textTheme.bodyMedium);
                      }).toList(),
                    ),
                  ),

                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    children: [
                      if (virtualTryon)
                        ElevatedButton.icon(
                          onPressed: () {
                            // handle virtual try-on
                          },
                          icon: const FaIcon(FontAwesomeIcons.eye, size: 16),
                          label: const Text('Virtual Try-On'),
                        ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: purchasable && inStock
                              ? () {
                                  // handle add to cart
                                }
                              : null,
                          icon: const FaIcon(FontAwesomeIcons.cartPlus, size: 16),
                          style: ElevatedButton.styleFrom(backgroundColor: purchasable && inStock ? Colors.blue : Colors.grey),
                          label: const Text('Add to Cart'),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),
                // Optional: Reviews or Related Products can go here
              ],
            ),
          );
        },
      ),
    );
  }
}

Widget buildImageSlider(Map<String, dynamic> product, {double height = 250}) {
  final List<dynamic> imagesData = product['images'] ?? [];
  final List<String> imageUrls = imagesData.map<String>((img) => img['src'] ?? '').where((url) => url.isNotEmpty).toList();

  if (imageUrls.isEmpty) {
    return Container(height: height, color: Colors.grey.shade200, child: const Icon(Icons.image_not_supported, size: 80));
  }

  return _ImageSlider(imageUrls: imageUrls, height: height);
}

class _ImageSlider extends StatefulWidget {
  final List<String> imageUrls;
  final double height;

  const _ImageSlider({required this.imageUrls, required this.height});

  @override
  State<_ImageSlider> createState() => _ImageSliderState();
}

class _ImageSliderState extends State<_ImageSlider> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  void _openFullScreen(int initialIndex) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _FullScreenImageGallery(images: widget.imageUrls, initialIndex: initialIndex),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: widget.height,
          child: PageView.builder(
            controller: _pageController,
            itemCount: widget.imageUrls.length,
            onPageChanged: (index) {
              setState(() => _currentIndex = index);
            },
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () => _openFullScreen(index),
                child: CachedNetworkImage(
                  imageUrl: widget.imageUrls[index],
                  fit: BoxFit.cover,
                  width: double.infinity,
                  placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                  errorWidget: (context, url, error) => const Icon(Icons.error, size: 40),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            widget.imageUrls.length,
            (index) => Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: _currentIndex == index ? 10 : 8,
              height: _currentIndex == index ? 10 : 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _currentIndex == index ? Colors.blue : Colors.grey.shade400,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _FullScreenImageGallery extends StatelessWidget {
  final List<String> images;
  final int initialIndex;

  const _FullScreenImageGallery({required this.images, required this.initialIndex});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PhotoViewGallery.builder(
            itemCount: images.length,
            pageController: PageController(initialPage: initialIndex),
            builder: (context, index) {
              return PhotoViewGalleryPageOptions(
                imageProvider: CachedNetworkImageProvider(images[index]),
                minScale: PhotoViewComputedScale.contained,
                maxScale: PhotoViewComputedScale.covered * 2,
              );
            },
            backgroundDecoration: const BoxDecoration(color: Colors.black),
          ),
          Positioned(
            top: 40,
            left: 20,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 30),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }
}
