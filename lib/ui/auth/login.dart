import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:seegma_woocommerce/api/api_service.dart';
import 'package:seegma_woocommerce/ui/home/dashboard.dart';
import 'package:seegma_woocommerce/utils/loading_dialog.dart';
import 'package:seegma_woocommerce/utils/snackbar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();

  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    // _usernameController.text = '10000065';
    // _passwordController.text = '01683985640';
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(child: Image.asset('assets/background.jpg', fit: BoxFit.cover)),
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white, // dark at top
                    Colors.transparent, // transparent towards bottom
                  ],
                ),
              ),
            ),
          ),
          // Foreground (Form)
          Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: ListView(
                children: [
                  const SizedBox(height: 50.0),
                  Image.asset("assets/logo.png", width: 200, height: 200, fit: BoxFit.contain),
                  const SizedBox(height: 20.0),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(18.0),
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _usernameController,
                            decoration: const InputDecoration(
                              labelText: 'User ID',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(FontAwesomeIcons.solidUser, size: 20),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'User ID is required';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20.0),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              border: const OutlineInputBorder(),
                              prefixIcon: const Icon(FontAwesomeIcons.lock, size: 20),
                              suffixIcon: IconButton(
                                icon: FaIcon(_obscurePassword ? FontAwesomeIcons.eyeSlash : FontAwesomeIcons.eye),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Password is required';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20.0),
                          Align(
                            alignment: Alignment.centerRight,
                            child: GestureDetector(
                              onTap: () {
                                // Navigator.push(context, MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()));
                              },
                              child: const Text('Forgot Password?', style: TextStyle(color: Colors.red)),
                            ),
                          ),
                          const SizedBox(height: 20.0),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                _login(context);
                              },
                              child: const Text('Login'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20.0),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _login(BuildContext context) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    LoadingDialog.show(context);
    try {
      dynamic response = await ApiService.post(
        '/jwt-auth/v1/token',
        body: {"username": _usernameController.text, "password": _passwordController.text},
      );
      if (!mounted) return;
      LoadingDialog.hide(context);
      final prefs = await SharedPreferences.getInstance();
      final body = response;

      // Token
      await prefs.setString('token', body['token'] ?? '');
      await prefs.setString('user_email', body['user_email'] ?? '');
      await prefs.setString('user_nicename', body['user_nicename'] ?? '');
      await prefs.setString('user_display_name', body['user_display_name'] ?? '');
      await prefs.setInt('user_id', body['user']?['id'] ?? 0);
      await prefs.setString('username', body['user']?['username'] ?? '');
      await prefs.setString('first_name', body['user']?['first_name'] ?? '');
      await prefs.setString('last_name', body['user']?['last_name'] ?? '');
      await prefs.setString('nickname', body['user']?['nickname'] ?? '');
      await prefs.setString('gender', body['user']?['gender'] ?? '');
      await prefs.setString('mobile', body['user']?['mobile'] ?? '');
      await prefs.setString('profile_image', body['user']?['profile_image'] ?? '');
      await prefs.setString('billing_address_1', body['user']?['billing']?['address_1'] ?? '');
      await prefs.setString('billing_city', body['user']?['billing']?['city'] ?? '');
      await prefs.setString('billing_postcode', body['user']?['billing']?['postcode'] ?? '');
      await prefs.setString('billing_country', body['user']?['billing']?['country'] ?? '');
      await prefs.setString('shipping_address_1', body['user']?['shipping']?['address_1'] ?? '');
      await prefs.setString('shipping_city', body['user']?['shipping']?['city'] ?? '');
      await prefs.setString('shipping_postcode', body['user']?['shipping']?['postcode'] ?? '');
      await prefs.setString('shipping_country', body['user']?['shipping']?['country'] ?? '');

      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const DashboardScreen()), (route) => false);
    } catch (e) {
      final message = e is Exception ? e.toString().replaceFirst('Exception:', '') : 'Something went wrong';
      final RegExp exp = RegExp(r"<[^>]*>", multiLine: true, caseSensitive: true);
      String plainText = message.replaceAll(exp, '').trim();
      if (plainText.startsWith('Error:')) {
        plainText = plainText.replaceFirst('Error:', '').trim();
      }
      if (!mounted) return;
      LoadingDialog.hide(context);
      showAwesomeSnackbar(context: context, type: ContentType.failure, title: 'Failed!', message: plainText);
    }
  }
}
