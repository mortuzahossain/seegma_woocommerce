import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:seegma_woocommerce/ui/home/discover.dart';
import 'package:seegma_woocommerce/ui/home/home.dart';
import 'package:seegma_woocommerce/ui/home/profile.dart';
import 'package:seegma_woocommerce/ui/home/support.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [HomePage(), DiscoverPage(), SupportPage(), ProfilePage()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        // selectedItemColor: Colors.blue,
        // unselectedItemColor: Colors.grey,
        onTap: (index) => setState(() => _currentIndex = index),
        items: [
          BottomNavigationBarItem(icon: FaIcon(FontAwesomeIcons.shop), label: 'Shop'),
          BottomNavigationBarItem(icon: FaIcon(FontAwesomeIcons.magnifyingGlass), label: 'Discover'),
          BottomNavigationBarItem(icon: FaIcon(FontAwesomeIcons.headset), label: 'Support'),
          BottomNavigationBarItem(icon: FaIcon(FontAwesomeIcons.user), label: 'My Account'),
        ],
      ),
    );
  }
}
