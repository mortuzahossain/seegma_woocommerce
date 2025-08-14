import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:seegma_woocommerce/provider/slider_provider.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  @override
  void initState() {
    super.initState();
    final sliderProvider = Provider.of<SliderProvider>(context, listen: false);
    if (sliderProvider.sliderData.isEmpty) {
      Future.microtask(() => sliderProvider.loadSliderData());
    }
  }

  final List<Map<String, dynamic>> products = [
    {"name": "Product 1", "image": "https://placehold.co/600x400", "price": 200, "salePrice": 150, "onSale": true},
    {"name": "Product 2", "image": "https://placehold.co/600x400", "price": 100, "salePrice": null, "onSale": false},
    {"name": "Product 3", "image": "https://placehold.co/600x400", "price": 300, "salePrice": 250, "onSale": true},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Image.asset('assets/logo.png', height: 40, color: Colors.white, colorBlendMode: BlendMode.srcIn),
        centerTitle: false,
        actions: [IconButton(icon: const Icon(FontAwesomeIcons.solidBell), onPressed: () {})],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 10),

            /// Image Slider
            Consumer<SliderProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading) {
                  return const SizedBox(height: 180, child: Center(child: CircularProgressIndicator()));
                }

                if (provider.sliderData.isEmpty) {
                  return const SizedBox(height: 180, child: Center(child: Text("No slider data found")));
                }

                return Column(
                  children: [
                    CarouselSlider(
                      options: CarouselOptions(
                        height: 180,
                        autoPlay: true,
                        enlargeCenterPage: true,
                        onPageChanged: (index, reason) {
                          setState(() => _currentIndex = index);
                        },
                      ),
                      items: provider.sliderData.map((item) {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            item['image_url'], // <-- use correct key
                            fit: BoxFit.cover,
                            width: double.infinity,
                          ),
                        );
                      }).toList(),
                    ),

                    /// Indicator
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: provider.sliderData.asMap().entries.map((entry) {
                        return Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.symmetric(horizontal: 3, vertical: 8),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _currentIndex == entry.key ? Colors.blue : Colors.grey,
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                );
              },
            ),

            /// Categories title
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text("Best Selling", style: Theme.of(context).textTheme.titleLarge),
            ),
            SizedBox(
              height: 250, // enough to fit the card height
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                itemCount: products.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final product = products[index];
                  return SizedBox(
                    width: 180, // fixed card width for horizontal layout
                    child: Card(
                      clipBehavior: Clip.hardEdge,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      child: Stack(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Stack(
                                children: [
                                  AspectRatio(
                                    aspectRatio: 1,
                                    child: Image.network(
                                      product["image"],
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => const Icon(Icons.image_not_supported),
                                    ),
                                  ),
                                  if (product["onSale"])
                                    Positioned(
                                      top: 8,
                                      left: 0,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: const BoxDecoration(
                                          color: Colors.red,
                                          borderRadius: BorderRadius.only(
                                            topRight: Radius.circular(8),
                                            bottomRight: Radius.circular(8),
                                          ),
                                        ),
                                        child: const Text(
                                          "SALE",
                                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  product["name"],
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Row(
                                  children: [
                                    if (product["salePrice"] != null)
                                      Flexible(
                                        child: Text(
                                          "\$${product["salePrice"]}",
                                          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    if (product["salePrice"] != null) const SizedBox(width: 5),
                                    Flexible(
                                      child: Text(
                                        "\$${product["price"]}",
                                        style: TextStyle(
                                          color: Colors.grey,
                                          decoration: product["onSale"] ? TextDecoration.lineThrough : TextDecoration.none,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.blueAccent,
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(8),
                                  bottomRight: Radius.circular(8),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.blueAccent.withOpacity(0.4),
                                    spreadRadius: 1,
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: IconButton(
                                padding: EdgeInsets.zero,
                                icon: const Icon(Icons.arrow_forward_ios),
                                color: Colors.white,
                                tooltip: 'Add to Cart',
                                onPressed: () {},
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            /// Categories title
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text("Categories", style: Theme.of(context).textTheme.titleLarge),
            ),
            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 10,
                itemBuilder: (_, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Column(
                      children: [
                        CircleAvatar(radius: 30, backgroundColor: Colors.blue.shade100),
                        const SizedBox(height: 4),
                        Text("Cat $index", style: Theme.of(context).textTheme.bodySmall),
                      ],
                    ),
                  );
                },
              ),
            ),

            /// Products title
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text("Products", style: Theme.of(context).textTheme.titleLarge),
            ),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.74,
                crossAxisSpacing: 4,
                mainAxisSpacing: 4,
              ),
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                return Card(
                  clipBehavior: Clip.hardEdge,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  child: Stack(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Stack(
                            children: [
                              AspectRatio(
                                aspectRatio: 1,
                                child: Image.network(
                                  product["image"],
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => const Icon(Icons.image_not_supported),
                                ),
                              ),
                              if (product["onSale"])
                                Positioned(
                                  top: 8,
                                  left: 0,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: const BoxDecoration(
                                      color: Colors.red,
                                      borderRadius: BorderRadius.only(
                                        topRight: Radius.circular(8),
                                        bottomRight: Radius.circular(8),
                                      ),
                                    ),
                                    child: const Text(
                                      "SALE",
                                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              product["name"],
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Row(
                              children: [
                                if (product["salePrice"] != null)
                                  Flexible(
                                    child: Text(
                                      "\$${product["salePrice"]}",
                                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                if (product["salePrice"] != null) const SizedBox(width: 5),
                                Flexible(
                                  child: Text(
                                    "\$${product["price"]}",
                                    style: TextStyle(
                                      color: Colors.grey,
                                      decoration: product["onSale"] ? TextDecoration.lineThrough : TextDecoration.none,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.blueAccent,
                            borderRadius: const BorderRadius.only(topLeft: Radius.circular(8), bottomRight: Radius.circular(8)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blueAccent.withOpacity(0.4),
                                spreadRadius: 1,
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            icon: const Icon(Icons.add_shopping_cart),
                            color: Colors.white,
                            tooltip: 'Add to Cart',
                            onPressed: () {},
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
