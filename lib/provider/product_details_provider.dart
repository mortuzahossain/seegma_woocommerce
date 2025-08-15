import 'package:flutter/material.dart';
import 'package:seegma_woocommerce/api/api_service.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ProductDetailsProvider extends ChangeNotifier {
  String? _productId;
  Map<String, dynamic>? product;

  bool isLoading = false;
  bool hasError = false;

  /// Set the product ID dynamically and load details
  void setProductId(String id) {
    if (_productId != id) {
      _productId = id;
      _loadProduct();
    }
  }

  /// Load product details from API or cache
  Future<void> _loadProduct({bool refresh = false}) async {
    if (_productId == null) return;

    if (refresh) {
      product = null;
      isLoading = false;
      hasError = false;
      notifyListeners();
    }

    // Try load from cache first
    if (!refresh && await _loadCache()) return;

    isLoading = true;
    notifyListeners();

    try {
      final response = await ApiService.get('/hh/v1/product/$_productId');
      product = response;
      hasError = false;
      await _saveCache();
    } catch (e) {
      hasError = true;
      debugPrint('ProductDetailsProvider error: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Save to cache
  Future<void> _saveCache() async {
    final prefs = await SharedPreferences.getInstance();
    final cacheKey = 'product_$_productId';
    final cacheData = jsonEncode({'timestamp': DateTime.now().millisecondsSinceEpoch, 'product': product});
    await prefs.setString(cacheKey, cacheData);
  }

  /// Load from cache if less than 10 minutes old
  Future<bool> _loadCache() async {
    final prefs = await SharedPreferences.getInstance();
    final cacheKey = 'product_$_productId';
    if (!prefs.containsKey(cacheKey)) return false;

    final cached = prefs.getString(cacheKey);
    if (cached == null) return false;

    final data = jsonDecode(cached);
    final timestamp = data['timestamp'] as int;
    final now = DateTime.now().millisecondsSinceEpoch;

    const cacheDuration = 10 * 60 * 1000; // 10 min
    if (now - timestamp > cacheDuration) return false;

    product = data['product'] as Map<String, dynamic>?;
    notifyListeners();
    return true;
  }
}
