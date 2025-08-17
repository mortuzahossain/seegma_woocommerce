import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:seegma_woocommerce/provider/category_product_provider.dart';
import 'package:seegma_woocommerce/ui/common/product.dart';
import 'package:seegma_woocommerce/utils/loading_dialog.dart';

class ProductsPage extends StatefulWidget {
  final Map<String, dynamic> category;
  const ProductsPage({super.key, required this.category});

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  late final ScrollController _scrollController;

  // @override
  // void initState() {
  //   super.initState();
  //   _scrollController = ScrollController();
  //   final provider = Provider.of<CategoryProductsProvider>(context, listen: false);
  //   provider.setCategorySlug(widget.category['slug']);
  //   _scrollController.addListener(() {
  //     if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200 && provider.canLoadMore) {
  //       provider.loadProducts();
  //     }
  //   });
  // }

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<CategoryProductsProvider>(context, listen: false);
      provider.setCategorySlug(widget.category['slug']);
    });

    _scrollController.addListener(() {
      final provider = Provider.of<CategoryProductsProvider>(context, listen: false);
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200 && provider.canLoadMore) {
        provider.loadProducts();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.category['name'])),
      body: SafeArea(
        child: Consumer<CategoryProductsProvider>(
          builder: (context, provider, _) {
            if (provider.isLoading && provider.products.isEmpty) {
              return animatedLoader();
            }

            if (provider.hasError && provider.products.isEmpty) {
              return Center(child: Text('Failed to load products'));
            }

            if (provider.products.isEmpty) {
              return const Center(child: Text('No products found'));
            }

            return GridView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(8),
              itemCount: provider.products.length + (provider.canLoadMore ? 1 : 0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 0.74,
              ),
              itemBuilder: (context, index) {
                if (index == provider.products.length) {
                  // show loader at bottom for next page
                  return animatedLoader();
                }

                final product = provider.products[index];
                return ProductCard(product: product); // Reusable widget
              },
            );
          },
        ),
      ),
    );
  }
}
