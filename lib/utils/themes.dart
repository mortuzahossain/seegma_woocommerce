import 'package:flutter/material.dart';

class AppText {
  static const String currency = "৳";
}

class AppColors {
  static const Color primaryBlue = Color(0xFF1E88E5);
  static const Color primaryBlueDark = Color(0xFF1565C0);
  static const Color secondaryGreen = Color(0xFF43A047);
  static const Color secondaryGreenDark = Color(0xFF2E7D32);

  static const Color lightBackground = Color(0xFFF5F5F5);
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);

  static const List<Gradient> borderGradients = [
    LinearGradient(colors: [Colors.red, Colors.orange]),
    LinearGradient(colors: [Colors.blue, Colors.lightBlueAccent]),
    LinearGradient(colors: [Colors.green, Colors.lightGreenAccent]),
    LinearGradient(colors: [Colors.purple, Colors.deepPurpleAccent]),
    LinearGradient(colors: [Colors.teal, Colors.cyanAccent]),
    LinearGradient(colors: [Colors.pink, Colors.deepOrangeAccent]),
  ];
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      fontFamily: 'TrebuchetMS',
      pageTransitionsTheme: PageTransitionsTheme(
        builders: {TargetPlatform.android: CustomPageTransitionBuilder(), TargetPlatform.iOS: CustomPageTransitionBuilder()},
      ),
      primarySwatch: Colors.blue,
      brightness: Brightness.light,
      primaryColor: AppColors.primaryBlue,
      primaryColorDark: AppColors.primaryBlueDark,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primaryBlue,
        secondary: AppColors.secondaryGreen,
        surface: Colors.white,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: Colors.black,
        error: Colors.redAccent,
        onError: Colors.white,
      ),
      scaffoldBackgroundColor: AppColors.lightBackground,
      appBarTheme: const AppBarTheme(backgroundColor: AppColors.primaryBlue, foregroundColor: Colors.white, centerTitle: true),
      tabBarTheme: TabBarThemeData(
        labelColor: Colors.blue,
        unselectedLabelColor: Colors.grey,
        indicator: UnderlineTabIndicator(borderSide: BorderSide(color: Colors.blue, width: 2)),
        // indicatorSize: TabBarIndicatorSize.tab,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.secondaryGreen,
        foregroundColor: Colors.white,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryBlue,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      fontFamily: 'TrebuchetMS',
      pageTransitionsTheme: PageTransitionsTheme(
        builders: {TargetPlatform.android: CustomPageTransitionBuilder(), TargetPlatform.iOS: CustomPageTransitionBuilder()},
      ),
      primarySwatch: Colors.blue,
      brightness: Brightness.dark,
      primaryColor: AppColors.primaryBlue,
      primaryColorDark: AppColors.primaryBlueDark,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primaryBlue,
        secondary: AppColors.secondaryGreen,
        surface: AppColors.darkSurface,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: Colors.white,
        error: Colors.redAccent,
        onError: Colors.black,
      ),
      scaffoldBackgroundColor: AppColors.darkBackground,
      appBarTheme: const AppBarTheme(backgroundColor: AppColors.darkSurface, foregroundColor: Colors.white, centerTitle: true),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.secondaryGreen,
        foregroundColor: Colors.white,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryBlue,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}

class CustomPageTransitionBuilder extends PageTransitionsBuilder {
  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return FadeTransition(opacity: animation, child: child);
  }
}
