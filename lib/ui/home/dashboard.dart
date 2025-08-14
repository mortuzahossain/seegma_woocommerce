import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:seegma_woocommerce/ui/home/cart.dart';
import 'package:seegma_woocommerce/ui/home/discover.dart';
import 'package:seegma_woocommerce/ui/home/home.dart';
import 'package:seegma_woocommerce/ui/home/profile.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [HomePage(), DiscoverPage(), CartPage(), ProfilePage()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        onTap: (index) => setState(() => _currentIndex = index),
        items: [
          BottomNavigationBarItem(icon: FaIcon(FontAwesomeIcons.shop), label: 'Shop'),
          BottomNavigationBarItem(icon: FaIcon(FontAwesomeIcons.magnifyingGlass), label: 'Discover'),
          BottomNavigationBarItem(icon: FaIcon(FontAwesomeIcons.cartShopping), label: 'Cart'),
          BottomNavigationBarItem(icon: FaIcon(FontAwesomeIcons.user), label: 'My Account'),
        ],
      ),
    );
  }
}
