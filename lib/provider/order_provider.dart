import 'package:flutter/material.dart';
import 'package:seegma_woocommerce/api/api_service.dart';

class OrderProvider extends ChangeNotifier {
  final String baseUrl = "{{BASE_URL}}/hh/v1/orders";

  List<Map<String, dynamic>> orders = [];
  int _page = 1;
  int _totalPages = 1;
  bool _loading = false;

  bool get isLoading => _loading;
  bool get hasMore => _page <= _totalPages;

  Future<void> fetchOrders({bool reset = false}) async {
    if (_loading) return;

    if (reset) {
      _page = 1;
      _totalPages = 1;
      orders = [];
      notifyListeners();
    }

    _loading = true;
    notifyListeners();

    try {
      final data = await ApiService.get("/hh/v1/orders?page=$_page&per_page=10");
      _totalPages = data['total_pages'] ?? 1;
      final newOrders = (data['orders'] as List).map((e) => Map<String, dynamic>.from(e)).toList();
      orders.addAll(newOrders);
      _page++;
    } catch (e) {
      debugPrint("Exception fetching orders: $e");
    }

    _loading = false;
    notifyListeners();
  }

  Future<void> loadMore() async {
    if (hasMore) {
      await fetchOrders();
    }
  }
}
