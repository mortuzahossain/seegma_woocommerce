import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:seegma_woocommerce/provider/order_details_provider.dart';
import 'package:seegma_woocommerce/ui/home/product_details.dart';
import 'package:seegma_woocommerce/utils/loading_dialog.dart';

class OrderDetailsPage extends StatelessWidget {
  final int orderId;

  const OrderDetailsPage({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => OrderDetailsProvider()..fetchOrder(orderId),
      child: Scaffold(
        appBar: AppBar(title: Text('Order Details #$orderId')),
        body: Consumer<OrderDetailsProvider>(
          builder: (context, provider, _) {
            if (provider.loading) {
              return animatedLoader();
            }
            if (provider.error != null) {
              return Center(child: Text(provider.error!));
            }
            final order = provider.order;
            if (order == null) return const SizedBox.shrink();

            final date = DateTime.tryParse(order['date_created'] ?? '') ?? DateTime.now();
            final dateFormat = DateFormat('dd MMM yyyy, hh:mm a');

            final billing = order['billing'] ?? {};
            final shipping = order['shipping'] ?? {};
            final items = order['items'] ?? [];
            final shippingMethod = (order['shipping_method'] ?? []).isNotEmpty ? order['shipping_method'][0] : null;

            return SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- Order info ---
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text("Order #${order['id']}", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 12),
                            _buildOrderStatusRow(order['status'] ?? ''),
                            const SizedBox(height: 12),
                            Text("Order At: ${dateFormat.format(date)}"),
                            Text("Payment: ${order['payment_method_title'] ?? ''}"),

                            if (shippingMethod != null) ...[
                              Text("Shipping Method: ${shippingMethod['name'] ?? ''}(৳${shippingMethod['total'] ?? ''})"),
                            ],
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // --- Items ---
                    const Text("Items", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),

                    // ...items.map<Widget>((item) {
                    //   return Column(
                    //     children: [
                    //       ListTile(
                    //         leading: CachedNetworkImage(
                    //           imageUrl: item['image'] ?? '',
                    //           width: 50,
                    //           height: 50,
                    //           fit: BoxFit.cover,
                    //           placeholder: (context, url) => const Icon(Icons.image, color: Colors.grey),
                    //           errorWidget: (context, url, error) => const Icon(Icons.broken_image, color: Colors.grey),
                    //         ),
                    //         title: Text(item['name'] ?? ''),
                    //         subtitle: Padding(
                    //           padding: const EdgeInsets.only(left: 0),
                    //           child: Text("${item['quantity'] ?? 0}p * ৳${item['price'] ?? 0} = ৳${item['total'] ?? 0}"),
                    //         ),
                    //       ),
                    //       const Divider(height: 1, color: Colors.grey),
                    //     ],
                    //   );
                    // }).toList(),
                    Column(
                      children: List.generate(items.length, (index) {
                        final item = items[index];
                        return Column(
                          children: [
                            ListTile(
                              onTap: () {
                                Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailsPage(product: item)));
                              },
                              leading: CachedNetworkImage(
                                imageUrl: item['image'] ?? '',
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => const Icon(Icons.image, color: Colors.grey),
                                errorWidget: (context, url, error) => const Icon(Icons.broken_image, color: Colors.grey),
                              ),
                              title: Text(item['name'] ?? ''),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(left: 16),
                                child: Text("${item['quantity'] ?? 0}p * ৳${item['price'] ?? 0} = ৳${item['total'] ?? 0}"),
                              ),
                            ),
                            // Only show divider if not last item
                            if (index != items.length - 1) const Divider(height: 1, color: Colors.grey),
                          ],
                        );
                      }),
                    ),

                    const SizedBox(height: 16),
                    // --- Totals ---
                    const Text("Totals", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Table(
                      border: TableBorder.all(color: Colors.grey.shade300, width: 1),
                      columnWidths: const {0: FlexColumnWidth(2), 1: FlexColumnWidth(1)},
                      children: [
                        _buildRow("Subtotal", order['subtotal'] ?? '0'),
                        _buildRow("Shipping", order['shipping_total'] ?? '0'),
                        _buildRow("Total", order['total'] ?? '0', isBold: true),
                      ],
                    ),
                    // --- Shipping method ---
                    DefaultTabController(
                      length: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const TabBar(
                            tabs: [
                              Tab(text: "Shipping"),
                              Tab(text: "Billing"),
                            ],
                          ),
                          SizedBox(
                            height: 200, // adjust height as needed
                            child: TabBarView(
                              children: [
                                // --- Shipping Table ---
                                SingleChildScrollView(
                                  child: Table(
                                    border: TableBorder.all(color: Colors.grey.shade300, width: 1),
                                    columnWidths: const {0: IntrinsicColumnWidth(), 1: FlexColumnWidth()},
                                    children: [
                                      if ((shipping['first_name'] ?? '').isNotEmpty || (shipping['last_name'] ?? '').isNotEmpty)
                                        TableRow(
                                          children: [
                                            const Padding(
                                              padding: EdgeInsets.all(4),
                                              child: Text("Name:", style: TextStyle(fontWeight: FontWeight.bold)),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.all(4),
                                              child: Text("${shipping['first_name'] ?? ''} ${shipping['last_name'] ?? ''}"),
                                            ),
                                          ],
                                        ),
                                      if ((shipping['address_1'] ?? '').isNotEmpty || (shipping['address_2'] ?? '').isNotEmpty)
                                        TableRow(
                                          children: [
                                            const Padding(
                                              padding: EdgeInsets.all(4),
                                              child: Text("Address:", style: TextStyle(fontWeight: FontWeight.bold)),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.all(4),
                                              child: Text("${shipping['address_1'] ?? ''} ${shipping['address_2'] ?? ''}"),
                                            ),
                                          ],
                                        ),
                                      if ((shipping['city'] ?? '').isNotEmpty ||
                                          (shipping['state'] ?? '').isNotEmpty ||
                                          (shipping['postcode'] ?? '').isNotEmpty)
                                        TableRow(
                                          children: [
                                            const Padding(
                                              padding: EdgeInsets.all(4),
                                              child: Text("City/State/Postcode:", style: TextStyle(fontWeight: FontWeight.bold)),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.all(4),
                                              child: Text(
                                                "${shipping['city'] ?? ''}, ${shipping['state'] ?? ''} ${shipping['postcode'] ?? ''}",
                                              ),
                                            ),
                                          ],
                                        ),
                                      if ((shipping['country'] ?? '').isNotEmpty)
                                        TableRow(
                                          children: [
                                            const Padding(
                                              padding: EdgeInsets.all(4),
                                              child: Text("Country:", style: TextStyle(fontWeight: FontWeight.bold)),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.all(4),
                                              child: Text("${shipping['country'] ?? ''}"),
                                            ),
                                          ],
                                        ),
                                      if ((shipping['phone'] ?? '').isNotEmpty)
                                        TableRow(
                                          children: [
                                            const Padding(
                                              padding: EdgeInsets.all(4),
                                              child: Text("Phone:", style: TextStyle(fontWeight: FontWeight.bold)),
                                            ),
                                            Padding(padding: const EdgeInsets.all(4), child: Text("${shipping['phone'] ?? ''}")),
                                          ],
                                        ),
                                    ],
                                  ),
                                ),

                                // --- Billing Table ---
                                SingleChildScrollView(
                                  child: Table(
                                    border: TableBorder.all(color: Colors.grey.shade300, width: 1),
                                    columnWidths: const {0: IntrinsicColumnWidth(), 1: FlexColumnWidth()},
                                    children: [
                                      if ((billing['first_name'] ?? '').isNotEmpty || (billing['last_name'] ?? '').isNotEmpty)
                                        TableRow(
                                          children: [
                                            const Padding(
                                              padding: EdgeInsets.all(4),
                                              child: Text("Name:", style: TextStyle(fontWeight: FontWeight.bold)),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.all(4),
                                              child: Text("${billing['first_name'] ?? ''} ${billing['last_name'] ?? ''}"),
                                            ),
                                          ],
                                        ),
                                      if ((billing['address_1'] ?? '').isNotEmpty || (billing['address_2'] ?? '').isNotEmpty)
                                        TableRow(
                                          children: [
                                            const Padding(
                                              padding: EdgeInsets.all(4),
                                              child: Text("Address:", style: TextStyle(fontWeight: FontWeight.bold)),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.all(4),
                                              child: Text("${billing['address_1'] ?? ''} ${billing['address_2'] ?? ''}"),
                                            ),
                                          ],
                                        ),
                                      if ((billing['city'] ?? '').isNotEmpty ||
                                          (billing['state'] ?? '').isNotEmpty ||
                                          (billing['postcode'] ?? '').isNotEmpty)
                                        TableRow(
                                          children: [
                                            const Padding(
                                              padding: EdgeInsets.all(4),
                                              child: Text("City/State/Postcode:", style: TextStyle(fontWeight: FontWeight.bold)),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.all(4),
                                              child: Text(
                                                "${billing['city'] ?? ''}, ${billing['state'] ?? ''} ${billing['postcode'] ?? ''}",
                                              ),
                                            ),
                                          ],
                                        ),
                                      if ((billing['country'] ?? '').isNotEmpty)
                                        TableRow(
                                          children: [
                                            const Padding(
                                              padding: EdgeInsets.all(4),
                                              child: Text("Country:", style: TextStyle(fontWeight: FontWeight.bold)),
                                            ),
                                            Padding(padding: const EdgeInsets.all(4), child: Text("${billing['country'] ?? ''}")),
                                          ],
                                        ),
                                      if ((billing['email'] ?? '').isNotEmpty)
                                        TableRow(
                                          children: [
                                            const Padding(
                                              padding: EdgeInsets.all(4),
                                              child: Text("Email:", style: TextStyle(fontWeight: FontWeight.bold)),
                                            ),
                                            Padding(padding: const EdgeInsets.all(4), child: Text("${billing['email'] ?? ''}")),
                                          ],
                                        ),
                                      if ((billing['phone'] ?? '').isNotEmpty)
                                        TableRow(
                                          children: [
                                            const Padding(
                                              padding: EdgeInsets.all(4),
                                              child: Text("Phone:", style: TextStyle(fontWeight: FontWeight.bold)),
                                            ),
                                            Padding(padding: const EdgeInsets.all(4), child: Text("${billing['phone'] ?? ''}")),
                                          ],
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  TableRow _buildRow(String label, dynamic value, {bool isBold = false}) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          child: Text(label, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          child: Text(
            "৳$value",
            textAlign: TextAlign.right,
            style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal),
          ),
        ),
      ],
    );
  }

  Widget _buildOrderStatusRow(String status) {
    // Define stages
    final stages = [
      {"key": "pending", "icon": FontAwesomeIcons.clock, "label": "Pending"},
      {"key": "processing", "icon": FontAwesomeIcons.spinner, "label": "Processing"},
      {"key": "final", "icon": FontAwesomeIcons.check, "label": "Completed"}, // last stage placeholder
    ];

    // Determine final stage
    String finalStatusLabel = "Completed";
    IconData finalStatusIcon = FontAwesomeIcons.check;

    if (status == "completed") {
      finalStatusLabel = "Completed";
      finalStatusIcon = FontAwesomeIcons.check;
    } else if (status == "cancelled") {
      finalStatusLabel = "Cancelled";
      finalStatusIcon = FontAwesomeIcons.xmark;
    } else if (status == "refunded") {
      finalStatusLabel = "Refunded";
      finalStatusIcon = FontAwesomeIcons.repeat;
    } else if (status == "processing") {
      finalStatusLabel = "Completed"; // still pending
      finalStatusIcon = FontAwesomeIcons.check;
    }

    List<Widget> children = [];

    for (var i = 0; i < stages.length; i++) {
      final stage = stages[i];
      bool isCurrent = false;

      if (stage['key'] == "final") {
        isCurrent = ["completed", "cancelled", "refunded"].contains(status);
      } else {
        isCurrent = stage['key'] == status;
        if (status == "processing" && stage['key'] == "pending") isCurrent = false;
      }

      final icon = stage['key'] == "final" ? finalStatusIcon : stage['icon'] as IconData;
      final label = stage['key'] == "final" ? finalStatusLabel : stage['label'].toString();

      children.add(
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: isCurrent ? Colors.blue : Colors.grey[300],
              child: FaIcon(icon, color: isCurrent ? Colors.white : Colors.grey[600], size: 14),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: isCurrent ? Colors.blue : Colors.grey[600],
                fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      );

      // Add dash line except for last icon
      if (i != stages.length - 1) {
        children.add(
          Expanded(
            child: Container(
              height: 2,
              alignment: Alignment.center,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final dashWidth = 4.0;
                  final dashSpacing = 4.0;
                  final dashCount = (constraints.maxWidth / (dashWidth + dashSpacing)).floor();
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(dashCount, (_) {
                      return Container(
                        width: dashWidth,
                        height: 2,
                        color: Colors.grey,
                        margin: EdgeInsets.only(right: dashSpacing),
                      );
                    }),
                  );
                },
              ),
            ),
          ),
        );
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: children),
    );
  }
}
