import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:seegma_woocommerce/api/api_service.dart';
import 'package:seegma_woocommerce/ui/home/dashboard.dart';
import 'package:seegma_woocommerce/utils/loading_dialog.dart';
import 'package:seegma_woocommerce/utils/snackbar.dart';

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
  Future<void> changeShippingMethod(String rateId) async {
    try {
      await ApiService.post('/hh/v1/update-shipping', body: {"rate_id": rateId});
      fetchCart();
      notifyListeners();
    } catch (e) {
      debugPrint('Error updating quantity: $e');
    }
  }

  // ---------------------
  Future<void> applyCoupon(String coupon) async {
    try {
      await ApiService.post('/hh/v1/apply-coupon', body: {"coupon": coupon});
      fetchCart();
      notifyListeners();
    } catch (e) {
      debugPrint('Error updating quantity: $e');
    }
  }

  Future<void> placeOrder(BuildContext context) async {
    try {
      LoadingDialog.show(context);
      await ApiService.post(
        '/hh/v1/checkout',
        body: {"payment_method": "cod", "payment_method_title": "Cash on delivery", "set_paid": false},
      );

      LoadingDialog.hide(context);
      showAwesomeSnackbar(context: context, type: ContentType.success, title: 'Success!', message: "Order Placed Successfully!");

      Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const DashboardScreen()), (route) => false);
    } catch (e) {
      final message = e is Exception ? e.toString().replaceFirst('Exception:', '') : 'Something went wrong';
      final RegExp exp = RegExp(r"<[^>]*>", multiLine: true, caseSensitive: true);
      String plainText = message.replaceAll(exp, '').trim();
      if (plainText.startsWith('Error:')) {
        plainText = plainText.replaceFirst('Error:', '').trim();
      }
      LoadingDialog.hide(context);
      showAwesomeSnackbar(context: context, type: ContentType.failure, title: 'Failed!', message: plainText);
    }
  }
}
