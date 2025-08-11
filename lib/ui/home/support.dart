import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SupportPage extends StatefulWidget {
  const SupportPage({super.key});

  @override
  State<SupportPage> createState() => _SupportPageState();
}

class _SupportPageState extends State<SupportPage> {
  final TextEditingController _searchController = TextEditingController();
  final List<Gradient> borderGradients = [
    LinearGradient(colors: [Colors.red, Colors.orange]),
    LinearGradient(colors: [Colors.blue, Colors.lightBlueAccent]),
    LinearGradient(colors: [Colors.green, Colors.lightGreenAccent]),
    LinearGradient(colors: [Colors.purple, Colors.deepPurpleAccent]),
    LinearGradient(colors: [Colors.teal, Colors.cyanAccent]),
    LinearGradient(colors: [Colors.pink, Colors.deepOrangeAccent]),
  ];

  // Example categories & FAQs data
  final List<Map<String, dynamic>> categories = [
    {'name': 'Account', 'icon': FontAwesomeIcons.user},
    {'name': 'Orders', 'icon': FontAwesomeIcons.boxOpen},
    {'name': 'Payments', 'icon': FontAwesomeIcons.creditCard},
    {'name': 'Technical', 'icon': FontAwesomeIcons.cogs},
  ];

  final Map<String, List<String>> faqs = {
    'Account': ['How do I reset my password?', 'How to change my email?', 'How to delete my account?'],
    'Orders': ['How to track my order?', 'Can I cancel my order?'],
    'Payments': ['What payment methods are accepted?', 'Is my payment information secure?'],
    'Technical': ['App is crashing, what to do?', 'How to report a bug?'],
  };

  void _showFaqBottomSheet(List<String> faqList) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          builder: (_, controller) {
            return Container(
              padding: const EdgeInsets.all(16),
              child: ListView.builder(
                controller: controller,
                itemCount: faqList.length,
                itemBuilder: (context, index) {
                  final question = faqList[index];
                  return Theme(
                    data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                      // tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      // childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                      title: Text(question, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: const Text('Detailed answer for this question goes here.', style: TextStyle(fontSize: 13)),
                        ),
                      ],
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  void _onSearch() {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) return;

    // Search FAQs that contain the query
    List<String> matchedFaqs = [];
    faqs.forEach((category, questions) {
      for (var q in questions) {
        if (q.toLowerCase().contains(query)) {
          matchedFaqs.add(q);
        }
      }
    });

    if (matchedFaqs.isEmpty) {
      matchedFaqs.add('No FAQs found matching "$query".');
    }

    _showFaqBottomSheet(matchedFaqs);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Support')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Type your question here...',
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
                        onPressed: () => _searchController.clear(),
                        splashRadius: 20,
                      ),
                    ),
                    onSubmitted: (_) => _onSearch(),
                  ),
                ),
                SizedBox(
                  height: 50, // match TextField height approx
                  child: ElevatedButton(
                    onPressed: _onSearch,
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

          const SizedBox(height: 8),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GridView.builder(
                itemCount: categories.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 3,
                ),
                itemBuilder: (_, index) {
                  final category = categories[index];
                  final gradient = borderGradients[index % borderGradients.length];
                  return Card(
                    margin: EdgeInsets.zero,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                        bottomLeft: Radius.circular(0),
                        bottomRight: Radius.circular(0),
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Expanded(
                          child: TextButton(
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
                              ),
                            ),
                            onPressed: () {
                              final selectedFaqs = faqs[category['name']] ?? [];
                              _showFaqBottomSheet(selectedFaqs);
                            },
                            child: Row(
                              children: [
                                FaIcon(category['icon'], color: Colors.blueGrey, size: 20),
                                Expanded(
                                  child: Center(
                                    child: Text(category['name'], style: const TextStyle(fontWeight: FontWeight.w600)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Container(
                          height: 4,
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
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
