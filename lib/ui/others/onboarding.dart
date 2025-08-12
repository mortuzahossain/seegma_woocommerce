import 'package:flutter/material.dart';
import 'package:seegma_woocommerce/ui/home/dashboard.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _current = 0;

  final List<Map<String, String>> _pages = [
    {
      'image': 'assets/onboarding/1.png',
      'title': 'Discover Products',
      'description': 'Browse thousands of products from top brands.',
    },
    {
      'image': 'assets/onboarding/2.png',
      'title': 'Secure Checkout',
      'description': 'Fast & secure checkout with multiple payment options.',
    },
    {
      'image': 'assets/onboarding/3.png',
      'title': 'Fast Delivery',
      'description': 'Get your orders delivered to your door quickly.',
    },
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _goNext() {
    if (_current < _pages.length - 1) {
      _controller.animateToPage(_current + 1, duration: Duration(milliseconds: 300), curve: Curves.ease);
    } else {
      _finish();
    }
  }

  void _skip() {
    _controller.animateToPage(_pages.length - 1, duration: Duration(milliseconds: 300), curve: Curves.ease);
  }

  void _finish() {
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => DashboardScreen()));
  }

  Widget _buildIndicator() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(_pages.length, (i) {
        final bool active = i == _current;
        return AnimatedContainer(
          duration: Duration(milliseconds: 250),
          margin: EdgeInsets.symmetric(horizontal: 6),
          width: active ? 20 : 10,
          height: 10,
          decoration: BoxDecoration(color: active ? Colors.blue : Colors.grey.shade300, borderRadius: BorderRadius.circular(20)),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _pages.length,
                onPageChanged: (index) => setState(() => _current = index),
                itemBuilder: (context, index) {
                  final item = _pages[index];
                  return Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      children: [
                        SizedBox(height: 24),
                        Expanded(child: Image.asset(item['image']!, fit: BoxFit.contain)),
                        SizedBox(height: 24),
                        Text(
                          item['title']!,
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 12),
                        Text(
                          item['description']!,
                          style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 40),
                      ],
                    ),
                  );
                },
              ),
            ),

            // bottom controls
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(onPressed: _current == _pages.length - 1 ? null : _skip, child: Text('Skip')),
                  _buildIndicator(),
                  IconButton(
                    onPressed: _goNext,
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.all(12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: Icon(_current == _pages.length - 1 ? Icons.check : Icons.arrow_forward, size: 24),
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
