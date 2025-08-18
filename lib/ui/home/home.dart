import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:seegma_woocommerce/provider/home_provider.dart';
import 'package:seegma_woocommerce/provider/slider_provider.dart';
import 'package:provider/provider.dart';
import 'package:seegma_woocommerce/ui/common/product.dart';
import 'package:seegma_woocommerce/ui/home/products.dart';
import 'package:seegma_woocommerce/ui/home/search.dart';
import 'package:seegma_woocommerce/ui/others/notifications.dart';
import 'package:seegma_woocommerce/utils/loading_dialog.dart';

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

    final homepageProvider = Provider.of<HomepageProvider>(context, listen: false);
    if (homepageProvider.homepagedata.isEmpty) {
      Future.microtask(() => homepageProvider.loadHomepageData());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Image.asset('assets/logo.png', height: 40, color: Colors.white, colorBlendMode: BlendMode.srcIn),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(FontAwesomeIcons.magnifyingGlass),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => SearchPage()));
            },
          ),
          IconButton(
            icon: const Icon(FontAwesomeIcons.solidBell),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => NotificationScreen()));
            },
          ),
        ],
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
                  return SizedBox(height: 180, child: Center(child: animatedLoader()));
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
                          child: Image.network(item['image_url'], fit: BoxFit.fill, width: double.infinity),
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
            SizedBox(height: 10),

            /// Categories title
            SizedBox(
              height: 100,
              child: Consumer<HomepageProvider>(
                builder: (context, provider, _) {
                  if (provider.isLoading) {
                    return animatedLoader();
                  }

                  if (provider.categories.isEmpty) {
                    return const Center(child: Text("No categories found"));
                  }

                  return ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: provider.categories.length,
                    itemBuilder: (context, index) {
                      final cat = provider.categories[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => ProductsPage(category: cat)));
                          },
                          child: Column(
                            children: [
                              Material(
                                elevation: 1,
                                shape: const CircleBorder(),
                                clipBehavior: Clip.antiAlias,
                                child: CircleAvatar(
                                  radius: 30,
                                  backgroundImage: cat['image'] != null && cat['image'] != "" ? NetworkImage(cat['image']) : null,
                                  child: cat['image'] == null || cat['image'] == "" ? Text(cat['name'][0]) : null,
                                ),
                              ),

                              const SizedBox(height: 6),
                              Text(cat['name'] ?? '', style: Theme.of(context).textTheme.bodyMedium),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),

            Consumer<HomepageProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading) {
                  return animatedLoader();
                }

                if (provider.homepagedata.isEmpty) {
                  return const Center(child: Text("No products found"));
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: provider.homepagedata.map<Widget>((section) {
                    final products = section['products'] ?? [];
                    final scrollDir = section['scrooldir'] ?? 'vertical';
                    final isHorizontal = scrollDir == 'horizontal';

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Section title
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          child: Text(section['title'] ?? '', style: Theme.of(context).textTheme.titleLarge),
                        ),

                        // Products list
                        if (isHorizontal)
                          SizedBox(
                            height: 250,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              itemCount: products.length,
                              separatorBuilder: (_, __) => const SizedBox(width: 8),
                              itemBuilder: (_, index) {
                                return ProductCard(product: products[index], isHorizontal: true);
                              },
                            ),
                          )
                        else
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
                            itemBuilder: (_, index) {
                              return ProductCard(product: products[index], isHorizontal: false);
                            },
                          ),
                      ],
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
