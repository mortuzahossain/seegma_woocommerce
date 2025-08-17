import 'package:flutter/material.dart';
import 'package:seegma_woocommerce/api/api_service.dart';

class SearchProvider with ChangeNotifier {
  List<Map<String, dynamic>> products = [];
  int _page = 1;
  int _totalPages = 1;
  bool _loading = false;
  String _lastQuery = "";

  bool get isLoading => _loading;
  bool get hasMore => _page <= _totalPages;

  Future<void> search(String query, {bool reset = false}) async {
    if (_loading) return;

    if (reset) {
      _page = 1;
      _totalPages = 1;
      products = [];
      _lastQuery = query;
      notifyListeners();
    }

    _loading = true;
    notifyListeners();

    try {
      final data = await ApiService.get("/hh/v1/search?search=$query&page=$_page&per_page=15");
      _totalPages = data["total_pages"] ?? 1;
      final newProducts = (data["products"] as List).map((e) => Map<String, dynamic>.from(e)).toList();
      products.addAll(newProducts);
      _page++;
    } catch (e) {
      debugPrint("Search error: $e");
    }

    _loading = false;
    notifyListeners();
  }

  Future<void> loadMore() async {
    if (hasMore) {
      await search(_lastQuery);
    }
  }
}
