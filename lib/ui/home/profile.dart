import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:seegma_woocommerce/ui/auth/login.dart';
import 'package:seegma_woocommerce/ui/home/orders.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String? fullName;
  bool isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final firstName = prefs.getString('first_name');
    final lastName = prefs.getString('last_name');

    setState(() {
      isLoggedIn = token != null && token.isNotEmpty;
      fullName = isLoggedIn ? '$firstName $lastName' : null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My Account")),
      body: ListView(
        children: [
          Card(
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(radius: 28, child: const Icon(Icons.person, size: 32, color: Colors.white)),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Welcome', style: const TextStyle(fontSize: 14, color: Colors.grey)),
                      const SizedBox(height: 4),
                      isLoggedIn
                          ? Text(fullName ?? '', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold))
                          : GestureDetector(
                              onTap: () {
                                Navigator.push(context, MaterialPageRoute(builder: (_) => const Login()));
                              },
                              child: const Text(
                                'Guest - Login / Register',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Card(
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            elevation: 0,
            child: Column(
              children: [
                if (isLoggedIn) _buildOption(icon: FontAwesomeIcons.user, title: "Account details", onTap: () {}),
                if (isLoggedIn) _divider(),
                if (isLoggedIn) _buildOption(icon: FontAwesomeIcons.lock, title: "Change Password", onTap: () {}),
                if (isLoggedIn) _divider(),
                if (isLoggedIn)
                  _buildOption(
                    icon: FontAwesomeIcons.boxOpen,
                    title: "Orders",
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => OrdersPage()));
                    },
                  ),
                // if (isLoggedIn) _divider(),
                // if (isLoggedIn) _buildOption(icon: FontAwesomeIcons.solidHeart, title: "Favorites", onTap: () {}),
                // if (isLoggedIn) _divider(),
                // if (isLoggedIn) _buildOption(icon: FontAwesomeIcons.download, title: "Downloads", onTap: () {}),
                if (isLoggedIn) _divider(),
                if (isLoggedIn) _buildOption(icon: FontAwesomeIcons.locationDot, title: "Addresses", onTap: () {}),
                if (isLoggedIn) _divider(),
                _buildOption(icon: FontAwesomeIcons.headset, title: "Support", onTap: () {}),
                _divider(),
                _buildOption(icon: FontAwesomeIcons.fileContract, title: "Terms & Condition", onTap: () {}),
                _divider(),
                _buildOption(icon: FontAwesomeIcons.shieldHalved, title: "Privacy Policy", onTap: () {}),
                if (isLoggedIn) _divider(),
                if (isLoggedIn)
                  _buildOption(
                    icon: FontAwesomeIcons.rightFromBracket,
                    title: "Log out",
                    onTap: () async {
                      final shouldLogout = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text("Log out"),
                          content: const Text("Are you sure you want to log out?"),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
                            TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Yes")),
                          ],
                        ),
                      );

                      if (shouldLogout ?? false) {
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.clear();
                        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const Login()), (route) => false);
                      }
                    },
                    color: Colors.red,
                  ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: const [
                Text("Contact Us", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                SizedBox(height: 4),
                Text("support@example.com"),
                SizedBox(height: 2),
                Text("+880 1234 567 890"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() {
    return Divider(height: 1, indent: 56);
  }

  Widget _buildOption({required IconData icon, required String title, required VoidCallback onTap, Color? color}) {
    final Map<IconData, Color> iconColors = {
      FontAwesomeIcons.lock: Colors.blue, // Dashboard (if you meant lock here)
      FontAwesomeIcons.boxOpen: Colors.orange, // Orders
      FontAwesomeIcons.download: Colors.green, // Downloads
      FontAwesomeIcons.locationDot: Colors.purple, // Addresses
      FontAwesomeIcons.headset: Colors.orange, // Addresses
      FontAwesomeIcons.user: Colors.teal, // Account details
      FontAwesomeIcons.rightFromBracket: Colors.red, // Logout
      FontAwesomeIcons.solidHeart: Colors.red, // Logout
      FontAwesomeIcons.fileContract: Colors.blueGrey, // Terms & Condition
      FontAwesomeIcons.shieldHalved: Colors.lightGreen, // Privacy Policy
    };

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: FaIcon(icon, color: color ?? iconColors[icon] ?? Colors.black, size: 20),
      title: Text(title, style: TextStyle(fontSize: 16)),
      trailing: const Icon(Icons.chevron_right, size: 18),
      onTap: onTap,
    );
  }
}
