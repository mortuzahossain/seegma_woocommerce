import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:seegma_woocommerce/api/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomepageProvider with ChangeNotifier {
  List<dynamic> categories = [];
  List<dynamic> homepagedata = [];
  bool isLoading = true;

  static const cacheKey = "homepage_cache";
  static const cacheTimeKey = "homepage_cache_time";
  static const cacheDuration = Duration(minutes: 10);

  Future<void> loadHomepageData() async {
    final prefs = await SharedPreferences.getInstance();

    final cachedJson = prefs.getString(cacheKey);
    final cachedTime = prefs.getInt(cacheTimeKey);

    // Use cache if available and not expired
    // if (cachedJson != null && cachedTime != null) {
    //   final cacheAge = DateTime.now().difference(DateTime.fromMillisecondsSinceEpoch(cachedTime));

    //   if (cacheAge < cacheDuration) {
    //     final data = jsonDecode(cachedJson);
    //     categories = data['categories'] ?? [];
    //     homepagedata = data['homepagedata'] ?? [];
    //     isLoading = false;
    //     notifyListeners();
    //     return;
    //   }
    // }

    // Fetch from API
    try {
      final data = await ApiService.get("/hh/v1/homepage-data"); // endpoint
      categories = data['categories'] ?? [];
      homepagedata = data['homepagedata'] ?? [];

      // Save to cache
      await prefs.setString(cacheKey, jsonEncode(data));
      await prefs.setInt(cacheTimeKey, DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      debugPrint("Error fetching homepage data: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
