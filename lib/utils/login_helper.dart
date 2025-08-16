import 'package:flutter/material.dart';
import 'package:seegma_woocommerce/ui/auth/login.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<bool> ensureLoggedIn(BuildContext context) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');

  if (token == null || token.isEmpty) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const Login()));
    return false;
  }

  return true;
}
