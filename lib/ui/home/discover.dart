import 'package:flutter/material.dart';

class DiscoverPage extends StatelessWidget {
  const DiscoverPage({super.key});

  final List<Map<String, dynamic>> categories = const [
    {'title': 'Electronics', 'icon': 'https://cdn-icons-png.flaticon.com/512/263/263142.png'},
    {'title': 'Clothing', 'icon': 'https://cdn-icons-png.flaticon.com/512/892/892458.png'},
    {'title': 'Home & Garden', 'icon': 'https://cdn-icons-png.flaticon.com/512/1046/1046857.png'},
    {'title': 'Sports', 'icon': 'https://cdn-icons-png.flaticon.com/512/2733/2733515.png'},
    {'title': 'Toys', 'icon': 'https://cdn-icons-png.flaticon.com/512/616/616408.png'},
    {'title': 'Beauty', 'icon': 'https://cdn-icons-png.flaticon.com/512/3425/3425740.png'},
  ];

  final List<Gradient> borderGradients = const [
    LinearGradient(colors: [Colors.red, Colors.orange]),
    LinearGradient(colors: [Colors.blue, Colors.lightBlueAccent]),
    LinearGradient(colors: [Colors.green, Colors.lightGreenAccent]),
    LinearGradient(colors: [Colors.purple, Colors.deepPurpleAccent]),
    LinearGradient(colors: [Colors.teal, Colors.cyanAccent]),
    LinearGradient(colors: [Colors.pink, Colors.deepOrangeAccent]),
  ];

  @override
  Widget build(BuildContext context) {
    final TextEditingController searchController = TextEditingController();
    final textTheme = Theme.of(context).textTheme;

    void onSearch() {
      final query = searchController.text.trim();
      // TODO: Implement search
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Searching for "$query"...')));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Discover')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Search bar (same as before)
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText: 'Search Product',
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
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => searchController.clear(),
                        splashRadius: 20,
                      ),
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

            // Grid with 6 items visible and smaller icon/text + less spacing
            Expanded(
              child: GridView.builder(
                itemCount: categories.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 3 / 3, // less tall, more compact
                ),
                itemBuilder: (context, index) {
                  final category = categories[index];
                  final gradient = borderGradients[index % borderGradients.length];
                  return GestureDetector(
                    onTap: () {},
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
                                    child: Image.network(
                                      category['icon'],
                                      fit: BoxFit.contain,
                                      errorBuilder: (context, error, stackTrace) =>
                                          const Icon(Icons.image_not_supported, size: 40, color: Colors.grey),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    category['title'],
                                    style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // Gradient bottom bar
                          Container(
                            height: 6,
                            decoration: BoxDecoration(
                              gradient: gradient,
                              borderRadius: const BorderRadius.only(
                                bottomLeft: Radius.circular(12),
                                bottomRight: Radius.circular(12),
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
          ],
        ),
      ),
    );
  }
}
