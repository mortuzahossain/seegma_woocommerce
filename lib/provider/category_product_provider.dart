import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:seegma_woocommerce/api/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CategoryProductsProvider extends ChangeNotifier {
  String? categorySlug;

  List<dynamic> products = [];
  int page = 1;
  int perPage = 10;
  int totalPages = 1;
  bool isLoading = false;
  bool isLoadingMore = false;
  bool hasError = false;

  Future<bool> _loadCache() async {
    final prefs = await SharedPreferences.getInstance();
    final cacheKey = 'category_$categorySlug';
    if (!prefs.containsKey(cacheKey)) return false;

    final cached = prefs.getString(cacheKey);
    if (cached == null) return false;

    final data = jsonDecode(cached);
    final timestamp = data['timestamp'] as int;
    final now = DateTime.now().millisecondsSinceEpoch;

    const cacheDuration = 10 * 60 * 1000; // 10 minutes in milliseconds
    if (now - timestamp > cacheDuration) return false; // expired

    products = List<dynamic>.from(data['products'] ?? []);
    page = (data['page'] ?? 1) + 1;
    totalPages = data['totalPages'] ?? 1;

    notifyListeners();
    return true;
  }

  Future<void> _saveCache() async {
    final prefs = await SharedPreferences.getInstance();
    final cacheKey = 'category_$categorySlug';
    final cacheData = jsonEncode({
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'products': products,
      'page': page - 1,
      'totalPages': totalPages,
    });
    await prefs.setString(cacheKey, cacheData);
  }

  void setCategorySlug(String slug) {
    if (categorySlug != slug) {
      categorySlug = slug;
      reset();
      loadProducts();
    }
  }

  void reset() {
    products = [];
    page = 1;
    totalPages = 1;
    isLoading = false;
    isLoadingMore = false;
    hasError = false;
    notifyListeners();
  }

  Future<void> loadProducts({bool refresh = false}) async {
    if (refresh) {
      page = 1;
      products = [];
      totalPages = 1;
    }

    if (page == 1 && !refresh) {
      final cacheLoaded = await _loadCache();
      if (cacheLoaded) return; // use cached data
    }

    if (isLoading || isLoadingMore || page > totalPages) return;

    try {
      if (page == 1) {
        isLoading = true;
      } else {
        isLoadingMore = true;
      }
      notifyListeners();

      final response = await ApiService.get('/hh/v1/category-products?category_slug=$categorySlug&page=$page&per_page=$perPage');

      final fetchedProducts = response['products'] as List<dynamic>? ?? [];
      if (page == 1) {
        products = fetchedProducts;
      } else {
        products.addAll(fetchedProducts);
      }

      totalPages = response['total_pages'] ?? 1;
      page++;

      await _saveCache(); // cache updated products
      hasError = false;
    } catch (e) {
      hasError = true;
      debugPrint('CategoryProductsProvider Error: $e');
    } finally {
      isLoading = false;
      isLoadingMore = false;
      notifyListeners();
    }
  }

  bool get canLoadMore => page <= totalPages && !isLoadingMore;
}
