import 'package:flutter/material.dart';
import 'package:seegma_woocommerce/api/api_service.dart';

class OrderDetailsProvider extends ChangeNotifier {
  Map<String, dynamic>? order;
  bool loading = false;
  String? error;

  OrderDetailsProvider();

  Future<void> fetchOrder(int orderId) async {
    loading = true;
    error = null;
    notifyListeners();

    try {
      order = await ApiService.get("/hh/v1/orders/$orderId");
    } catch (e) {
      error = '$e';
    }

    loading = false;
    notifyListeners();
  }
}
