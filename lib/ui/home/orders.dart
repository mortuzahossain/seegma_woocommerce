import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:seegma_woocommerce/provider/order_provider.dart';
import 'package:seegma_woocommerce/ui/home/order_details.dart';
import 'package:seegma_woocommerce/utils/order_status_icon.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  final ScrollController _scrollController = ScrollController();
  final DateFormat _dateFormat = DateFormat('dd MMM yyyy, hh:mm a');

  @override
  void initState() {
    super.initState();
    final provider = context.read<OrderProvider>();
    provider.fetchOrders();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
        provider.loadMore();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OrderProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text("My Orders")),
      body: provider.orders.isEmpty && provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              controller: _scrollController,
              itemCount: provider.orders.length + (provider.hasMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index < provider.orders.length) {
                  final order = provider.orders[index];
                  final date = DateTime.tryParse(order['date_created'] ?? '') ?? DateTime.now();

                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => OrderDetailsPage(orderId: order['id'] ?? 0)));
                      },
                      child: Stack(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ListTile(
                              leading: CircleAvatar(
                                radius: 20, // circular icon
                                backgroundColor: getStatusColor(order['status']),
                                child: Icon(orderStatusIcon(order['status'] ?? ''), color: Colors.white, size: 16),
                              ),
                              title: Text("Order #${order['id']}"),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [Text("Total: ৳${order['total'] ?? ''}"), Text("Date: ${_dateFormat.format(date)}")],
                              ),
                            ),
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: getStatusColor(order['status']),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                order['status']?.toString().toUpperCase() ?? '',
                                style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                } else {
                  return const Padding(
                    padding: EdgeInsets.all(12),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
              },
            ),
    );
  }
}
