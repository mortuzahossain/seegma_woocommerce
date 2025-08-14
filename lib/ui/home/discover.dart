import 'package:flutter/material.dart';
import 'package:provider/provider.dart' show Provider, Consumer;
import 'package:seegma_woocommerce/provider/category_provider.dart';
import 'package:seegma_woocommerce/ui/home/products.dart';
import 'package:seegma_woocommerce/utils/themes.dart';

class DiscoverPage extends StatefulWidget {
  const DiscoverPage({super.key});

  @override
  State<DiscoverPage> createState() => _DiscoverPageState();
}

class _DiscoverPageState extends State<DiscoverPage> {
  List<dynamic> filteredCategories = [];
  List<dynamic> allCategories = [];

  @override
  void initState() {
    super.initState();

    final categoryProvider = Provider.of<CategoriesProvider>(context, listen: false);
    if (categoryProvider.categories.isEmpty) {
      Future.microtask(() => categoryProvider.loadCategories());
    }

    searchController.addListener(() {
      onSearch();
    });
  }

  final TextEditingController searchController = TextEditingController();

  void onSearch() {
    final query = searchController.text.trim().toLowerCase();
    // final categories = Provider.of<CategoriesProvider>(context, listen: false).categories;
    if (query.isEmpty) {
      filteredCategories = List.from(allCategories);
    } else {
      filteredCategories = allCategories.where((cat) {
        final name = (cat['name'] ?? '').toLowerCase();
        return name.contains(query);
      }).toList();
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Discover')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            // Search bar (same as before)
            Row(
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
                    onSubmitted: (_) => onSearch(),
                  ),
                ),
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: onSearch,
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

            const SizedBox(height: 12),

            Expanded(
              child: Consumer<CategoriesProvider>(
                builder: (context, provider, _) {
                  if (provider.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  // Initialize lists if first load
                  if (allCategories.isEmpty && provider.categories.isNotEmpty) {
                    allCategories = provider.categories;
                    filteredCategories = List.from(allCategories);
                  }

                  if (filteredCategories.isEmpty) {
                    return const Center(child: Text("No categories found"));
                  }

                  return GridView.builder(
                    itemCount: filteredCategories.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                      childAspectRatio: 1,
                    ),
                    itemBuilder: (context, index) {
                      final category = filteredCategories[index];
                      final gradient = AppColors.borderGradients[index % AppColors.borderGradients.length];

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => ProductsPage(category: category)));
                        },
                        child: CategoryCard(category: category, gradient: gradient),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CategoryCard extends StatelessWidget {
  final Map<String, dynamic> category;
  final Gradient gradient;
  final VoidCallback? onTap;

  const CategoryCard({super.key, required this.category, required this.gradient, this.onTap});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: onTap,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 60,
                      child: category['image'] != null && category['image'] != ''
                          ? Image.network(
                              category['image'],
                              fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) => const Icon(Icons.image_not_supported, size: 40, color: Colors.grey),
                            )
                          : const Icon(Icons.category, size: 40, color: Colors.grey),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      category['name'] ?? '',
                      style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            Container(
              height: 6,
              decoration: BoxDecoration(
                gradient: gradient,
                borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(12), bottomRight: Radius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
