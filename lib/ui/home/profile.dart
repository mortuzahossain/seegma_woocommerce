import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:seegma_woocommerce/ui/auth/account_update.dart';
import 'package:seegma_woocommerce/ui/auth/address_management.dart';
import 'package:seegma_woocommerce/ui/auth/change_password.dart';
import 'package:seegma_woocommerce/ui/auth/login.dart';
import 'package:seegma_woocommerce/ui/home/orders.dart';
import 'package:seegma_woocommerce/ui/home/support.dart';
import 'package:seegma_woocommerce/ui/more/static_content.dart';
import 'package:seegma_woocommerce/ui/others/contact_us.dart';
import 'package:seegma_woocommerce/utils/loading_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String? fullName;
  String profileUrl = "";
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
    profileUrl = prefs.getString('profile_image') ?? "";

    setState(() {
      isLoggedIn = token != null && token.isNotEmpty;

      if (isLoggedIn) {
        final hasName = (firstName?.isNotEmpty ?? false) || (lastName?.isNotEmpty ?? false);
        fullName = hasName ? '${firstName ?? ''} ${lastName ?? ''}'.trim() : 'Please update your profile';
      } else {
        fullName = null;
      }
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
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.grey.shade300,
                    child: (profileUrl.isNotEmpty)
                        ? ClipOval(
                            child: CachedNetworkImage(
                              imageUrl: profileUrl,
                              width: 56,
                              height: 56,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => SizedBox(width: 24, height: 24, child: animatedLoader()),
                              errorWidget: (context, url, error) =>
                                  const FaIcon(FontAwesomeIcons.user, size: 32, color: Colors.white),
                            ),
                          )
                        : const FaIcon(FontAwesomeIcons.user, size: 32, color: Colors.white),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Welcome', style: const TextStyle(fontSize: 14, color: Colors.grey)),
                      const SizedBox(height: 4),
                      isLoggedIn
                          ? Text(
                              fullName ?? '',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            )
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
                if (isLoggedIn)
                  _buildOption(
                    icon: FontAwesomeIcons.user,
                    title: "Account details",
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => AccountUpdatePage())).then((onValue) {
                        _checkLoginStatus();
                      });
                    },
                  ),
                if (isLoggedIn) _divider(),
                if (isLoggedIn)
                  _buildOption(
                    icon: FontAwesomeIcons.lock,
                    title: "Change Password",
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => ChangePassword()));
                    },
                  ),
                if (isLoggedIn) _divider(),
                if (isLoggedIn)
                  _buildOption(
                    icon: FontAwesomeIcons.boxOpen,
                    title: "Orders",
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => OrdersPage()));
                    },
                  ),
                // StaticContentPage
                // if (isLoggedIn) _divider(),
                // if (isLoggedIn) _buildOption(icon: FontAwesomeIcons.solidHeart, title: "Favorites", onTap: () {}),
                // if (isLoggedIn) _divider(),
                // if (isLoggedIn) _buildOption(icon: FontAwesomeIcons.download, title: "Downloads", onTap: () {}),
                if (isLoggedIn) _divider(),
                if (isLoggedIn)
                  _buildOption(
                    icon: FontAwesomeIcons.locationDot,
                    title: "Addresses",
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => AddressPage()));
                    },
                  ),
                if (isLoggedIn) _divider(),
                _buildOption(
                  icon: FontAwesomeIcons.headset,
                  title: "Support",
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => SupportPage()));
                  },
                ),
                _divider(),
                _buildOption(
                  icon: FontAwesomeIcons.fileContract,
                  title: "Terms & Condition",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => StaticContentPage(title: "Privacy Policy", pageId: 11)),
                    );
                  },
                ),
                _divider(),
                _buildOption(
                  icon: FontAwesomeIcons.shieldHalved,
                  title: "Privacy Policy",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => StaticContentPage(title: "Privacy Policy", pageId: 3)),
                    );
                  },
                ),
                _divider(),
                _buildOption(
                  icon: FontAwesomeIcons.envelope,
                  title: "Contact Us",
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => ContactUs()));
                  },
                ),
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
      FontAwesomeIcons.envelope: Colors.blue, // Dashboard (if you meant lock here)
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
