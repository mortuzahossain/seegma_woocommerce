import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:seegma_woocommerce/provider/search_provider.dart';
import 'package:seegma_woocommerce/ui/common/product.dart';
import 'package:seegma_woocommerce/utils/loading_dialog.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
        context.read<SearchProvider>().loadMore();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SearchProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text("Search Products")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText: 'Search Category',
                      filled: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      border: OutlineInputBorder(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(12),
                          bottomLeft: Radius.circular(12),
                          topRight: Radius.circular(0),
                          bottomRight: Radius.circular(0),
                        ),
                        borderSide: BorderSide.none,
                      ),
                      // suffixIcon: IconButton(
                      //   icon: const Icon(Icons.clear),
                      //   onPressed: () => searchController.clear(),
                      //   splashRadius: 20,
                      // ),
                    ),
                    onSubmitted: (query) => {
                      if (query.isNotEmpty) {provider.search(query, reset: true)},
                    },
                  ),
                ),
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      final query = searchController.text.trim();
                      if (query.isNotEmpty) {
                        provider.search(query, reset: true);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(12),
                          bottomRight: Radius.circular(12),
                          topLeft: Radius.circular(0),
                          bottomLeft: Radius.circular(0),
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Icon(Icons.search, size: 24),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          Expanded(
            child: provider.products.isEmpty && !provider.isLoading
                ? const Center(child: Text("No products found"))
                : GridView.builder(
                    controller: _scrollController,
                    itemCount: provider.products.length + (provider.hasMore ? 1 : 0),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                      childAspectRatio: 0.74,
                    ),
                    itemBuilder: (context, index) {
                      if (index < provider.products.length) {
                        final product = provider.products[index];
                        return ProductCard(product: product);
                      } else {
                        return Padding(padding: EdgeInsets.all(12), child: animatedLoader());
                      }
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
