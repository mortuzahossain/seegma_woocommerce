import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My Account")),
      body: ListView(
        children: [
          Card(
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 0,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(radius: 28, child: const Icon(Icons.person, size: 32, color: Colors.white)),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text("Welcome", style: TextStyle(fontSize: 14, color: Colors.grey)),
                      SizedBox(height: 4),
                      Text("Mortuza", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
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
                // _buildOption(icon: FontAwesomeIcons.gauge, title: "Dashboard", onTap: () {}),
                // _divider(),
                _buildOption(icon: FontAwesomeIcons.user, title: "Account details", onTap: () {}),
                _divider(),
                _buildOption(icon: FontAwesomeIcons.lock, title: "Change Password", onTap: () {}),
                _divider(),
                _buildOption(icon: FontAwesomeIcons.boxOpen, title: "Orders", onTap: () {}),
                _divider(),
                _buildOption(icon: FontAwesomeIcons.download, title: "Downloads", onTap: () {}),
                _divider(),
                _buildOption(icon: FontAwesomeIcons.locationDot, title: "Addresses", onTap: () {}),
                _divider(),
                _buildOption(icon: FontAwesomeIcons.fileContract, title: "Terms & Condition", onTap: () {}),
                _divider(),
                _buildOption(icon: FontAwesomeIcons.shieldHalved, title: "Privacy Policy", onTap: () {}),
                _divider(),
                _buildOption(icon: FontAwesomeIcons.rightFromBracket, title: "Log out", onTap: () {}, color: Colors.red),
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
      FontAwesomeIcons.user: Colors.teal, // Account details
      FontAwesomeIcons.rightFromBracket: Colors.red, // Logout
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
