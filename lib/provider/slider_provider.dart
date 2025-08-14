import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:seegma_woocommerce/api/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SliderProvider with ChangeNotifier {
  List<dynamic> sliderData = [];
  bool isLoading = true;

  static const cacheKey = "slider_cache";
  static const cacheTimeKey = "slider_cache_time";
  static const cacheDuration = Duration(minutes: 10);

  Future<void> loadSliderData() async {
    final prefs = await SharedPreferences.getInstance();

    final cachedJson = prefs.getString(cacheKey);
    final cachedTime = prefs.getInt(cacheTimeKey);

    if (cachedJson != null && cachedTime != null) {
      final cacheAge = DateTime.now().difference(DateTime.fromMillisecondsSinceEpoch(cachedTime));

      if (cacheAge < cacheDuration) {
        sliderData = jsonDecode(cachedJson);
        isLoading = false;
        notifyListeners();
        return;
      }
    }

    try {
      final data = await ApiService.get("/hh/v1/slider");
      await prefs.setString(cacheKey, jsonEncode(data));
      await prefs.setInt(cacheTimeKey, DateTime.now().millisecondsSinceEpoch);

      sliderData = data;
    } catch (e) {
      debugPrint("Error fetching slider data: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
