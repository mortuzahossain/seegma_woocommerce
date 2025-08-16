import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:seegma_woocommerce/provider/cart_provider.dart';
import 'package:seegma_woocommerce/provider/category_product_provider.dart';
import 'package:seegma_woocommerce/provider/category_provider.dart';
import 'package:seegma_woocommerce/provider/home_provider.dart';
import 'package:seegma_woocommerce/provider/product_details_provider.dart';
import 'package:seegma_woocommerce/provider/slider_provider.dart';
import 'package:seegma_woocommerce/provider/tryon_provider.dart';
import 'package:seegma_woocommerce/ui/home/dashboard.dart';
import 'package:seegma_woocommerce/ui/others/onboarding.dart';
import 'package:seegma_woocommerce/utils/themes.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SliderProvider()),
        ChangeNotifierProvider(create: (_) => HomepageProvider()),
        ChangeNotifierProvider(create: (_) => CategoriesProvider()),
        ChangeNotifierProvider(create: (_) => CategoryProductsProvider()),
        ChangeNotifierProvider(create: (_) => ProductDetailsProvider()),
        ChangeNotifierProvider(create: (_) => TryOnProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
      ],
      child: const MainApp(),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  Future<bool> _checkOnboardingShown() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('onboarding_shown') ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      home: FutureBuilder<bool>(
        future: _checkOnboardingShown(),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            // Splash / loading screen
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }

          final shown = snapshot.data ?? false;
          return shown ? const DashboardScreen() : const OnboardingScreen();
        },
      ),
    );
  }
}
