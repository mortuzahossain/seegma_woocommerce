import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:seegma_woocommerce/provider/category_product_provider.dart';
import 'package:seegma_woocommerce/provider/category_provider.dart';
import 'package:seegma_woocommerce/provider/home_provider.dart';
import 'package:seegma_woocommerce/provider/slider_provider.dart';
import 'package:seegma_woocommerce/ui/home/dashboard.dart';
import 'package:seegma_woocommerce/utils/themes.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SliderProvider()),
        ChangeNotifierProvider(create: (_) => HomepageProvider()),
        ChangeNotifierProvider(create: (_) => CategoriesProvider()),
        ChangeNotifierProvider(create: (_) => CategoryProductsProvider()),
      ],
      child: const MainApp(),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      home: DashboardScreen(),
    );
  }
}
