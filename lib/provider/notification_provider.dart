import 'package:flutter/material.dart';
import 'package:seegma_woocommerce/api/api_service.dart';

class NotificationProvider extends ChangeNotifier {
  List<dynamic> _notifications = [];
  bool _loading = false;

  NotificationProvider() {
    fetchNotifications();
  }

  List<dynamic> get notifications => _notifications;
  bool get loading => _loading;
  Future<void> fetchNotifications() async {
    _loading = true;
    notifyListeners();

    try {
      final response = await ApiService.get('/hh/v1/notifications');
      _notifications = response;
    } catch (e) {
      debugPrint('Error fetching notifications: $e');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> refreshNotifications() async {
    await fetchNotifications();
  }
}
