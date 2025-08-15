import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:seegma_woocommerce/api/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CategoriesProvider with ChangeNotifier {
  List<dynamic> categories = [];
  bool isLoading = true;

  static const cacheKey = "categories_cache";
  static const cacheTimeKey = "categories_cache_time";
  static const cacheDuration = Duration(minutes: 10);

  Future<void> loadCategories() async {
    final prefs = await SharedPreferences.getInstance();

    final cachedJson = prefs.getString(cacheKey);
    final cachedTime = prefs.getInt(cacheTimeKey);

    // Use cache if not expired
    // if (cachedJson != null && cachedTime != null) {
    //   final cacheAge = DateTime.now().difference(DateTime.fromMillisecondsSinceEpoch(cachedTime));
    //   if (cacheAge < cacheDuration) {
    //     categories = jsonDecode(cachedJson);
    //     isLoading = false;
    //     notifyListeners();
    //     return;
    //   }
    // }

    // Fetch from API
    try {
      final data = await ApiService.get("/hh/v1/categories");
      categories = data ?? [];

      // Save to cache
      await prefs.setString(cacheKey, jsonEncode(categories));
      await prefs.setInt(cacheTimeKey, DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      debugPrint("Error fetching categories: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
