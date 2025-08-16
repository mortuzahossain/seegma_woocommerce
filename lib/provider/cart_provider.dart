import 'package:flutter/material.dart';
import 'package:seegma_woocommerce/api/api_service.dart';

class CartProvider extends ChangeNotifier {
  bool isLoading = false;
  bool hasError = false;
  Map<String, dynamic>? cart;

  CartProvider();

  Future<void> fetchCart() async {
    isLoading = true;
    hasError = false;
    notifyListeners();
    try {
      cart = await ApiService.get('/cocart/v2/cart');
    } catch (e) {
      hasError = true;
      cart = null;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  int get itemCount => cart?['item_count'] ?? 0;
  List<dynamic> get items => cart?['items'] ?? [];

  // --------------------
  Future<void> updateQuantity(String itemKey, int quantity) async {
    try {
      await ApiService.post('/cocart/v2/cart/item/$itemKey', body: {'quantity': quantity.toString()});
      final index = items.indexWhere((item) => item['item_key'] == itemKey);
      if (index != -1) {
        items[index]['quantity']['value'] = quantity;
        fetchCart();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error updating quantity: $e');
    }
  }

  // ---------------------
  Future<void> removeItem(String itemKey) async {
    try {
      await ApiService.delete('/cocart/v2/cart/item/$itemKey');
      items.removeWhere((item) => item['item_key'] == itemKey);
      notifyListeners();
    } catch (e) {
      debugPrint('Error removing item: $e');
    }
  }

  // ---------------------
  // --------------------
  Future<void> changeShippingMethod(String rateId) async {
    try {
      await ApiService.post('/hh/v1/update-shipping', body: {"rate_id": rateId});
      fetchCart();
      notifyListeners();
    } catch (e) {
      debugPrint('Error updating quantity: $e');
    }
  }
}
