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
  final List<Widget?> _pages = [null, null, null, null];

  Future<bool> _onWillPop() async {
    if (_currentIndex != 0) {
      setState(() => _currentIndex = 0);
      return false; // Prevent exiting, just go to Home
    }
    return true; // Exit app if already on Home
  }

  @override
  Widget build(BuildContext context) {
    // Lazily initialize the page when selected
    if (_pages[_currentIndex] == null) {
      switch (_currentIndex) {
        case 0:
          _pages[_currentIndex] = HomePage();
          break;
        case 1:
          _pages[_currentIndex] = DiscoverPage();
          break;
        case 2:
          _pages[_currentIndex] = CartPage();
          break;
        case 3:
          _pages[_currentIndex] = ProfilePage();
          break;
      }
    }

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        body: _pages[_currentIndex]!,
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          type: BottomNavigationBarType.fixed,
          onTap: (index) => setState(() => _currentIndex = index),
          items: const [
            BottomNavigationBarItem(icon: FaIcon(FontAwesomeIcons.shop), label: 'Shop'),
            BottomNavigationBarItem(icon: FaIcon(FontAwesomeIcons.magnifyingGlass), label: 'Discover'),
            BottomNavigationBarItem(icon: FaIcon(FontAwesomeIcons.cartShopping), label: 'Cart'),
            BottomNavigationBarItem(icon: FaIcon(FontAwesomeIcons.user), label: 'My Account'),
          ],
        ),
      ),
    );
  }
}
