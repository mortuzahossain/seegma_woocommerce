import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:seegma_woocommerce/api/api_service.dart';
import 'package:seegma_woocommerce/utils/loading_dialog.dart';
import 'package:seegma_woocommerce/utils/login_helper.dart';
import 'package:seegma_woocommerce/utils/snackbar.dart';
import 'package:seegma_woocommerce/utils/themes.dart';
import 'package:share_plus/share_plus.dart';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:seegma_woocommerce/provider/product_details_provider.dart';
import 'package:seegma_woocommerce/provider/tryon_provider.dart';
import 'package:image_picker/image_picker.dart';

class ProductDetailsPage extends StatefulWidget {
  final Map<String, dynamic> product;

  const ProductDetailsPage({super.key, required this.product});

  @override
  State<ProductDetailsPage> createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> with TickerProviderStateMixin {
  late TabController _tabController;
  int _quantity = 1;
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProductDetailsProvider>(context, listen: false).setProductId(widget.product['id'].toString());
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _addToCart(BuildContext context) async {
    // print(Provider.of<ProductDetailsProvider>(context, listen: false).product);

    var product = Provider.of<ProductDetailsProvider>(context, listen: false).product;
    if (product == null) return;
    bool haveVariation = false;
    Map<String, dynamic>? variation;
    if (Provider.of<ProductDetailsProvider>(context, listen: false).variations.isNotEmpty) {
      variation = await _showVariationSelector(context, product);
      haveVariation = true;
    }
    print({
      "id": widget.product['id'],
      "quantity": _quantity,
      if (variation != null && variation.isNotEmpty) "variation": variation['attributes'],
    });

    LoadingDialog.show(context);
    try {
      final response = await ApiService.post(
        '/cocart/v2/cart/add-item',
        body: {
          "id": widget.product['id'].toString(),
          "quantity": _quantity.toString(),
          if (variation != null && variation.isNotEmpty) "variation": variation['attributes'],
        },
      );

      if (!mounted) return;
      LoadingDialog.hide(context);
      showAwesomeSnackbar(context: context, type: ContentType.success, title: 'Successful!', message: "Added to cart");
    } catch (e) {
      final message = e is Exception ? e.toString().replaceFirst('Exception:', '') : 'Something went wrong';
      final RegExp exp = RegExp(r"<[^>]*>", multiLine: true, caseSensitive: true);
      String plainText = message.replaceAll(exp, '').trim();
      if (plainText.startsWith('Error:')) {
        plainText = plainText.replaceFirst('Error:', '').trim();
      }
      if (!mounted) return;
      LoadingDialog.hide(context);
      showAwesomeSnackbar(context: context, type: ContentType.failure, title: 'Failed!', message: plainText);
    }
  }

  Future<Map<String, dynamic>?> _showVariationSelector(BuildContext rootContext, Map<String, dynamic> product) {
    final details = Map<String, dynamic>.from(product['additional_details'] ?? {});
    final selections = <String, String>{}; // stores user choices

    return showModalBottomSheet(
      context: rootContext,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (context) {
        return SafeArea(
          child: StatefulBuilder(
            builder: (context, setState) {
              return SizedBox(
                width: double.infinity,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Select Options", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      ...details.entries.map((entry) {
                        final attrName = entry.key;
                        final values = List<Map<String, dynamic>>.from(entry.value);

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(attrName, style: const TextStyle(fontWeight: FontWeight.bold)),
                            Wrap(
                              spacing: 8,
                              children: values.map((v) {
                                final name = v['name'];
                                final slug = v['slug'];
                                final isSelected = selections[attrName] == slug;

                                return ChoiceChip(
                                  label: Text(name),
                                  selected: isSelected,
                                  onSelected: (_) {
                                    setState(() {
                                      selections[attrName] = slug;
                                    });
                                  },
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 12),
                          ],
                        );
                      }),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            if (selections.length < details.length) {
                              showDialog(
                                context: context,
                                useRootNavigator: true,
                                builder: (context) {
                                  return AlertDialog(
                                    title: const Text("Incomplete Selection"),
                                    content: const Text("Please select all options before adding to cart."),
                                    actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text("OK"))],
                                  );
                                },
                              );
                              return;
                            }
                            final provider = Provider.of<ProductDetailsProvider>(context, listen: false);
                            final variationId = provider.findVariationId(selections);

                            if (variationId != null) {
                              final data = {
                                "variation_id": variationId,
                                "attributes": selections.map((k, v) => MapEntry("attribute_pa_${k.toLowerCase()}", v)),
                              };

                              Navigator.pop(context, data);
                            } else {
                              ScaffoldMessenger.of(
                                context,
                              ).showSnackBar(const SnackBar(content: Text("Please select valid options")));
                            }
                          },
                          icon: const Icon(Icons.add_shopping_cart),
                          label: const Text("Add to Cart"),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product["name"] ?? ''),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const FaIcon(FontAwesomeIcons.shareFromSquare),
            onPressed: () {
              final name = widget.product["name"] ?? "Product";
              final url = widget.product["url"] ?? "";
              SharePlus.instance.share(ShareParams(text: "$name\n$url", title: "Share - ($name)"));
            },
          ),

          // Favorite toggle
          // IconButton(
          //   icon: FaIcon(
          //     widget.product['is_favorite'] ? FontAwesomeIcons.solidHeart : FontAwesomeIcons.heart,
          //     color: widget.product['is_favorite'] ? Colors.red : null,
          //   ),
          //   onPressed: () {
          //     setState(() {
          //       // isFav = !isFav;
          //     });
          //   },
          // ),
          IconButton(
            icon: const FaIcon(FontAwesomeIcons.cartShopping),
            onPressed: () async {
              var isLoggedIn = await ensureLoggedIn(context);
              if (isLoggedIn) {
                // call go to cart
              }
            },
          ),
        ],
      ),
      body: Consumer<ProductDetailsProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) return const Center(child: CircularProgressIndicator());
          if (provider.hasError) return const Center(child: Text('Failed to load product'));

          final product = provider.product;
          if (product == null) return const Center(child: Text('No product found'));
          // final additionalDetails = (product['additional_details'] is Map)
          //     ? Map<String, dynamic>.from(product['additional_details'])
          //     : <String, dynamic>{};
          // final purchasable = product['purchasable'] ?? false;
          // final inStock = (product['stock_status'] ?? '') == 'instock';
          // final virtualTryon = product['virtual_tryon'] ?? false;

          return NestedScrollView(
            headerSliverBuilder: (_, __) => [
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildImageSlider(product),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(product['name'] ?? '', style: Theme.of(context).textTheme.titleLarge),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Row(
                        children: [
                          if (product["on_sale"] == true && (product["sale_price"]?.toString().isNotEmpty ?? false))
                            Text(
                              "${AppText.currency}${product["sale_price"]}",
                              style: Theme.of(
                                context,
                              ).textTheme.titleLarge?.copyWith(color: product["on_sale"] == true ? Colors.green : Colors.black),
                            ),

                          if (product["on_sale"] == true && (product["sale_price"]?.toString().isNotEmpty ?? false))
                            const SizedBox(width: 5),
                          Text(
                            "${AppText.currency}${(product["regular_price"]?.toString().isNotEmpty ?? false) ? product["regular_price"] : product["price"] ?? ''}",
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: (product["on_sale"] == true) ? Colors.grey : Colors.black,
                              decoration:
                                  (product["on_sale"] == true && (product["regular_price"]?.toString().isNotEmpty ?? false))
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
                      child: Text(product['short_description'] ?? '', style: Theme.of(context).textTheme.bodyMedium),
                    ),
                    const SizedBox(height: 12),
                    // TabBar
                    TabBar(
                      controller: _tabController,
                      labelColor: Colors.blue,
                      unselectedLabelColor: Colors.grey,
                      indicatorColor: Colors.blue,
                      // isScrollable: true,
                      tabs: const [
                        Tab(text: 'Description'),
                        Tab(text: 'Additional Details'),
                        Tab(text: 'Reviews'),
                      ],
                    ),
                  ],
                ),
              ),
            ],
            body: TabBarView(
              controller: _tabController,
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.all(12),
                  child: Text(product['description'] ?? 'No description available'),
                ),
                buildAdditionalDetails(product),
                SingleChildScrollView(padding: const EdgeInsets.all(12), child: buildReviewsSection(product)),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Virtual Try-On row (if available)
            if ((Provider.of<ProductDetailsProvider>(context, listen: false).product?['virtual_tryon'] ?? false))
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      _showTryOnBottomSheet(context, widget.product['id']);
                    },
                    icon: const FaIcon(FontAwesomeIcons.eye, size: 16),
                    label: const Text('Virtual Try-On'),
                  ),
                ),
              ),

            // Add to Cart + Quantity row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
              child: Row(
                children: [
                  IconButton(
                    icon: const FaIcon(FontAwesomeIcons.minus),
                    onPressed: () {
                      if (_quantity > 1) setState(() => _quantity--);
                    },
                  ),
                  Text(_quantity.toString(), style: const TextStyle(fontSize: 18)),
                  IconButton(icon: const FaIcon(FontAwesomeIcons.plus), onPressed: () => setState(() => _quantity++)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed:
                          (Provider.of<ProductDetailsProvider>(context, listen: true).product?['purchasable'] ?? false) &&
                              (Provider.of<ProductDetailsProvider>(context, listen: true).product?['stock_status'] ?? '') ==
                                  'instock'
                          ? () {
                              _addToCart(context);
                            }
                          : null,
                      icon: const FaIcon(FontAwesomeIcons.cartPlus, size: 16),
                      label: const Text('Add to Cart'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            (Provider.of<ProductDetailsProvider>(context, listen: true).product?['purchasable'] ?? false) &&
                                (Provider.of<ProductDetailsProvider>(context, listen: true).product?['stock_status'] ?? '') ==
                                    'instock'
                            ? Colors.blue
                            : Colors.grey,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void _showTryOnBottomSheet(BuildContext context, int productId) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    builder: (ctx) {
      return SizedBox(
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Virtual Try-On Instructions",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              const Text(
                "• Make sure your face is clearly visible\n"
                "• Good lighting helps better results\n"
                "• Avoid hats, sunglasses, or filters",
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(ctx);

                    // pick image
                    final picker = ImagePicker();
                    final picked = await picker.pickImage(source: ImageSource.gallery);
                    if (picked == null) return;

                    // call API via provider
                    final provider = Provider.of<TryOnProvider>(context, listen: false);
                    await provider.processTryOn(context, productId, picked.path);

                    if (provider.processedImageUrl != null && context.mounted) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => _FullScreenImageGallery(images: [provider.processedImageUrl!], initialIndex: 0),
                        ),
                      );
                    }
                  },
                  child: const Text("Continue"),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      );
    },
  );
}

// Helper

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
                  fit: BoxFit.scaleDown,
                  width: double.infinity,
                  placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                  errorWidget: (context, url, error) => const Icon(Icons.error, size: 40),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        if (widget.imageUrls.length > 1)
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
            top: 60,
            left: 30,
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

Widget buildAdditionalDetails(Map<String, dynamic> product) {
  final additionalDetails = (product['additional_details'] is Map)
      ? Map<String, dynamic>.from(product['additional_details'])
      : <String, dynamic>{};

  if (additionalDetails.isEmpty) {
    return const Padding(padding: EdgeInsets.all(12), child: Text('No additional details'));
  }

  return Padding(
    padding: const EdgeInsets.all(12),
    child: Table(
      columnWidths: const {0: IntrinsicColumnWidth(), 1: FlexColumnWidth()},
      border: TableBorder.all(color: Colors.grey, width: 1),
      children: additionalDetails.entries.map((entry) {
        final key = entry.key;
        final value = entry.value;

        String displayValue = '';
        if (value is List) {
          // Extract "name" field if available
          displayValue = value
              .map((item) => (item is Map<String, dynamic>) ? (item['name'] ?? '') : item.toString())
              .where((name) => name.isNotEmpty)
              .join(', ');
        } else {
          displayValue = value.toString();
        }

        return TableRow(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(key, style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
            Padding(padding: const EdgeInsets.all(8.0), child: Text(displayValue)),
          ],
        );
      }).toList(),
    ),
  );
}

Widget buildReviewsSection(Map<String, dynamic> product) {
  bool reviewsAllowed = product['reviews_allowed'] ?? false;
  List<dynamic> lastReviews = product['last_reviews'] ?? [];

  if (!reviewsAllowed) return const SizedBox();

  final reviewController = TextEditingController();
  double selectedRating = 0;

  return StatefulBuilder(
    builder: (context, setState) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          // --- Existing Reviews ---
          if (lastReviews.isNotEmpty) ...[
            const Text("Customer Reviews", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...lastReviews.map((review) {
              return Card(
                elevation: 1,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // --- Author + Date Row ---
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(review['author'], style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                          Text(review['date'], style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                        ],
                      ),
                      const SizedBox(height: 6),

                      // --- Rating stars ---
                      Row(
                        children: List.generate(
                          5,
                          (index) =>
                              Icon(index < review['rating'] ? Icons.star : Icons.star_border, color: Colors.orange, size: 18),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // --- Review Content ---
                      Text(review['content'], style: const TextStyle(fontSize: 14, height: 1.4)),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 16),
          ],

          // --- Add Review Form ---
          const Text("Add a Review", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text("Your Rating *"),
          Row(
            children: List.generate(
              5,
              (index) => IconButton(
                icon: Icon(index < selectedRating ? Icons.star : Icons.star_border, color: Colors.orange),
                onPressed: () {
                  setState(() => selectedRating = index + 1.0);
                },
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Text("Your Review *"),
          TextField(
            controller: reviewController,
            maxLines: 3,
            decoration: const InputDecoration(border: OutlineInputBorder(), hintText: "Write your review here"),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () {
              if (selectedRating == 0 || reviewController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please add rating and review")));
                return;
              }
              // TODO: Call API to submit review
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Review submitted successfully!")));
              reviewController.clear();
              setState(() => selectedRating = 0);
            },
            child: const Text("Submit"),
          ),
        ],
      );
    },
  );
}
