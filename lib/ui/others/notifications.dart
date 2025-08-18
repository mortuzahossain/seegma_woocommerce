import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:seegma_woocommerce/provider/notification_provider.dart';
import 'package:seegma_woocommerce/utils/loading_dialog.dart';
import 'package:seegma_woocommerce/utils/random_color.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  String _formatDateTime(String dtString) {
    final dt = DateTime.tryParse(dtString);
    if (dt == null) return 'Invalid date';
    return '${dt.day}/${dt.month}/${dt.year} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final notificationProvider = Provider.of<NotificationProvider>(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Notifications'), centerTitle: true),
      body: SafeArea(
        child: notificationProvider.loading
            ? animatedLoader()
            : RefreshIndicator.adaptive(
                onRefresh: notificationProvider.refreshNotifications,
                child: notificationProvider.notifications.isEmpty
                    ? SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: SizedBox(
                          height: MediaQuery.of(context).size.height * 0.8,
                          child: const Center(
                            child: Text('No notifications available.', style: TextStyle(fontSize: 16, color: Colors.grey)),
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: notificationProvider.notifications.length,
                        itemBuilder: (context, index) {
                          final notification = notificationProvider.notifications[index];
                          return IntrinsicHeight(
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              decoration: BoxDecoration(
                                color: theme.cardColor,
                                borderRadius: BorderRadius.circular(10),
                                // boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 3))],
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  // Full height colored left border
                                  Container(
                                    width: 6,
                                    decoration: BoxDecoration(
                                      color: getRowColor(index),
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(10),
                                        bottomLeft: Radius.circular(10),
                                      ),
                                    ),
                                  ),
                                  // Notification content
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            notification['title'],
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w700,
                                              // color: Colors.black87,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Text(notification['message'], style: const TextStyle(fontSize: 14)),
                                          const SizedBox(height: 8),
                                          Text(
                                            _formatDateTime(notification['visibility_start']),
                                            style: const TextStyle(fontSize: 12, color: Colors.grey, fontStyle: FontStyle.italic),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
      ),
    );
  }
}
