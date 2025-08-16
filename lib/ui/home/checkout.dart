import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:seegma_woocommerce/provider/cart_provider.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final _shippingFormKey = GlobalKey<FormState>();
  final _billingFormKey = GlobalKey<FormState>();
  // Controllers for shipping
  late TextEditingController shippingFirstName;
  late TextEditingController shippingLastName;
  late TextEditingController shippingCountry;
  late TextEditingController shippingAddress1;
  late TextEditingController shippingAddress2;
  late TextEditingController shippingCity;
  late TextEditingController shippingState;
  late TextEditingController shippingPostcode;
  late TextEditingController shippingPhone;

  // Controllers for billing
  late TextEditingController billingFirstName;
  late TextEditingController billingLastName;
  late TextEditingController billingCountry;
  late TextEditingController billingAddress1;
  late TextEditingController billingAddress2;
  late TextEditingController billingCity;
  late TextEditingController billingState;
  late TextEditingController billingPostcode;
  late TextEditingController billingPhone;

  final TextEditingController _emailController = TextEditingController();

  Map<String, dynamic>? cart = {};

  @override
  void initState() {
    super.initState();

    // --- Initialize all controllers empty ---
    shippingFirstName = TextEditingController();
    shippingLastName = TextEditingController();
    shippingCountry = TextEditingController();
    shippingAddress1 = TextEditingController();
    shippingAddress2 = TextEditingController();
    shippingCity = TextEditingController();
    shippingState = TextEditingController();
    shippingPostcode = TextEditingController();
    shippingPhone = TextEditingController();

    billingFirstName = TextEditingController();
    billingLastName = TextEditingController();
    billingCountry = TextEditingController();
    billingAddress1 = TextEditingController();
    billingAddress2 = TextEditingController();
    billingCity = TextEditingController();
    billingState = TextEditingController();
    billingPostcode = TextEditingController();
    billingPhone = TextEditingController();
  }

  @override
  void dispose() {
    _couponController.dispose();
    _emailController.dispose();
    // Dispose all controllers to prevent memory leaks
    shippingFirstName.dispose();
    shippingLastName.dispose();
    shippingCountry.dispose();
    shippingAddress1.dispose();
    shippingAddress2.dispose();
    shippingCity.dispose();
    shippingState.dispose();
    shippingPostcode.dispose();
    shippingPhone.dispose();

    billingFirstName.dispose();
    billingLastName.dispose();
    billingCountry.dispose();
    billingAddress1.dispose();
    billingAddress2.dispose();
    billingCity.dispose();
    billingState.dispose();
    billingPostcode.dispose();
    billingPhone.dispose();

    super.dispose();
  }

  bool _sameAsShipping = true;
  bool _isPickup = false;
  String _selectedShippingOption = '';

  // coupon state
  bool _showCoupons = false;
  final List<String> _appliedCoupons = [];
  final TextEditingController _couponController = TextEditingController();

  String _fmt(double v) => "${v.toStringAsFixed(2)}৳";

  void _applyCoupon() {
    final code = _couponController.text.trim().toLowerCase();
    if (code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Enter a coupon code")));
      return;
    }

    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    cartProvider.applyCoupon(code);
  }

  void _removeCoupon() {
    setState(() {
      // _couponApplied = false;
      // _discountPercent = 0.0;
      _couponController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    cart = Provider.of<CartProvider>(context, listen: true).cart;
    final shippingRates = (cart?['shipping']['packages']['default']['rates'] as Map<String, dynamic>).values.toList();
    final chosenMethod = cart?['shipping']['packages']['default']['chosen_method'] ?? '';
    _selectedShippingOption = chosenMethod;

    final selectedRate = shippingRates.firstWhere((rate) => rate['key'] == _selectedShippingOption, orElse: () => {});
    if (selectedRate['method_id'] == 'pickup_location') {
      _sameAsShipping = false;
    }

    _isPickup = selectedRate['method_id'] == 'pickup_location';
    if (_isPickup) _sameAsShipping = false;

    final customer = cart?['customer'] ?? {};
    final shipping = customer['shipping_address'] ?? {};
    final billing = customer['billing_address'] ?? {};

    shippingFirstName.text = shipping['shipping_first_name'] ?? "";
    shippingLastName.text = shipping['shipping_last_name'] ?? "";
    shippingCountry.text = shipping['shipping_country'] ?? "";
    shippingAddress1.text = shipping['shipping_address_1'] ?? "";
    shippingAddress2.text = shipping['shipping_address_2'] ?? "";
    shippingCity.text = shipping['shipping_city'] ?? "";
    shippingState.text = shipping['shipping_state'] ?? "";
    shippingPostcode.text = shipping['shipping_postcode'] ?? "";
    shippingPhone.text = shipping['shipping_phone'] ?? "";

    billingFirstName.text = billing['billing_first_name'] ?? "";
    billingLastName.text = billing['billing_last_name'] ?? "";
    billingCountry.text = billing['billing_country'] ?? "";
    billingAddress1.text = billing['billing_address_1'] ?? "";
    billingAddress2.text = billing['billing_address_2'] ?? "";
    billingCity.text = billing['billing_city'] ?? "";
    billingState.text = billing['billing_state'] ?? "";
    billingPostcode.text = billing['billing_postcode'] ?? "";
    billingPhone.text = billing['billing_phone'] ?? "";

    final coupons = cart?["coupons"] as List<dynamic>? ?? [];
    _appliedCoupons.clear();
    for (var c in coupons) {
      final code = c['coupon']?.toString() ?? '';
      if (code.isNotEmpty) _appliedCoupons.add(code);
    }

    // Show the coupon section if there are any applied
    if (_appliedCoupons.isNotEmpty) _showCoupons = true;

    return Scaffold(
      appBar: AppBar(title: const Text("Checkout")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Apply coupon ---
              _buildCouponSection(),
              const SizedBox(height: 16),
              // --- Shipping options ---
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Delivery", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),

                  Column(
                    children: shippingRates.map<Widget>((opt) {
                      final label = opt['label'] ?? '';
                      final cost = (double.tryParse(opt['cost'].toString()) ?? 0) / 100;
                      final key = opt['key'] ?? '';

                      return RadioListTile<String>(
                        title: Text("$label (${_fmt(cost)})"),
                        subtitle: opt['meta_data']?['pickup_address'] != null ? Text(opt['meta_data']['pickup_address']) : null,
                        value: key,
                        groupValue: _selectedShippingOption,
                        onChanged: (val) {
                          setState(() {
                            _selectedShippingOption = val!;
                            final cartProvider = Provider.of<CartProvider>(context, listen: false);
                            cartProvider.changeShippingMethod(val);
                          });
                        },
                        contentPadding: EdgeInsets.zero,
                        visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
                        dense: false,
                      );
                    }).toList(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text("Payment options", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const ListTile(
                leading: Icon(Icons.money),
                title: Text("Cash on delivery"),
                subtitle: Text("Pay with cash upon delivery."),
              ),
              const SizedBox(height: 12),
              // --- Shipping address form ---
              if (!_isPickup) ...[
                const Text("Shipping address", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Form(
                  key: _shippingFormKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: shippingCountry,
                        decoration: const InputDecoration(labelText: "Country/Region"),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: shippingFirstName,
                              decoration: const InputDecoration(labelText: "First name"),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextFormField(
                              controller: shippingLastName,
                              decoration: const InputDecoration(labelText: "Last name"),
                            ),
                          ),
                        ],
                      ),
                      TextFormField(
                        controller: shippingAddress1,
                        decoration: const InputDecoration(labelText: "Address"),
                      ),
                      TextFormField(
                        controller: shippingAddress2,
                        decoration: const InputDecoration(labelText: "+ Add apartment, suite, etc."),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: shippingCity,
                              decoration: const InputDecoration(labelText: "City"),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextFormField(
                              controller: shippingState,
                              decoration: const InputDecoration(labelText: "District"),
                            ),
                          ),
                        ],
                      ),
                      TextFormField(
                        controller: shippingPostcode,
                        decoration: const InputDecoration(labelText: "Postal code (optional)"),
                      ),
                      TextFormField(
                        controller: shippingPhone,
                        decoration: const InputDecoration(labelText: "Phone (optional)"),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),
                CheckboxListTile(
                  value: _sameAsShipping,
                  onChanged: (v) => setState(() => _sameAsShipping = v ?? true),
                  title: const Text("Use same address for billing"),
                ),
              ],

              if (!_sameAsShipping) ...[
                const SizedBox(height: 8),
                const Text("Billing address", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Form(
                  key: _billingFormKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: billingCountry,
                        decoration: const InputDecoration(labelText: "Country/Region"),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: billingFirstName,
                              decoration: const InputDecoration(labelText: "First name"),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextFormField(
                              controller: billingLastName,
                              decoration: const InputDecoration(labelText: "Last name"),
                            ),
                          ),
                        ],
                      ),
                      TextFormField(
                        controller: billingAddress1,
                        decoration: const InputDecoration(labelText: "Address"),
                      ),
                      TextFormField(
                        controller: billingAddress2,
                        decoration: const InputDecoration(labelText: "+ Add apartment, suite, etc."),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: billingCity,
                              decoration: const InputDecoration(labelText: "City"),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextFormField(
                              controller: billingState,
                              decoration: const InputDecoration(labelText: "District"),
                            ),
                          ),
                        ],
                      ),
                      TextFormField(
                        controller: billingPostcode,
                        decoration: const InputDecoration(labelText: "Postal code (optional)"),
                      ),
                      TextFormField(
                        controller: billingPhone,
                        decoration: const InputDecoration(labelText: "Phone (optional)"),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 16),

              const Text("Add a note to your order", style: TextStyle(fontSize: 16)),
              const SizedBox(height: 6),
              TextFormField(
                maxLines: 3,
                decoration: const InputDecoration(border: OutlineInputBorder(), hintText: "Optional note..."),
              ),

              const SizedBox(height: 16),
              const Text("Order summary", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),

              // Order items
              ...cart?['items']?.map<Widget>((it) {
                    return ListTile(
                      leading: CachedNetworkImage(
                        imageUrl: it['featured_image'] != null && it['featured_image'].isNotEmpty ? it['featured_image'] : "",

                        placeholder: (context, url) => const SizedBox(
                          width: 40,
                          height: 40,
                          child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                        ),
                        errorWidget: (context, url, error) => const FaIcon(FontAwesomeIcons.image, size: 30, color: Colors.grey),
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      ),
                      title: Text(it['name'] ?? "", style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(left: 20),
                        child: Text(
                          "${it['quantity']['value']}p x ${int.parse(it['price']) / 100}৳ = ${int.parse(it['totals']['subtotal']) / 100}৳",
                        ),
                      ),
                    );
                  }).toList() ??
                  [],
              const Divider(),

              // Coupon & summary rows
              const SizedBox(),
              _summaryRow("Subtotal", _fmt((double.tryParse(cart?["totals"]['subtotal'] ?? '0') ?? 0) / 100)),
              if (coupons.isNotEmpty)
                _summaryRow(
                  "Discount (${_appliedCoupons.join(', ')})",
                  "-${_fmt((double.tryParse(cart?["totals"]['discount_total'] ?? '0') ?? 0) / 100)}",
                ),
              _summaryRow("Shipping", _fmt((double.tryParse(cart?["totals"]['shipping_total'] ?? '0') ?? 0) / 100)),
              const Divider(),
              _summaryRow("Total", _fmt((double.tryParse(cart?["totals"]['total'] ?? '0') ?? 0) / 100), bold: true),
              const SizedBox(height: 16),
              const Text(
                "By proceeding with your purchase you agree to our Terms and Conditions and Privacy Policy",
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // validate forms (basic)
                    final shippingValid = _shippingFormKey.currentState?.validate() ?? true;
                    final billingValid = _sameAsShipping ? true : (_billingFormKey.currentState?.validate() ?? true);
                    if (!shippingValid || !billingValid) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(const SnackBar(content: Text("Please complete address form(s)")));
                      return;
                    }

                    // Place order logic here

                    final cartProvider = Provider.of<CartProvider>(context, listen: false);
                    cartProvider.placeOrder(context);
                  },
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20)),
                  child: const Text("Place Order"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _summaryRow(String label, String value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: bold ? const TextStyle(fontWeight: FontWeight.bold) : null),
          Text(value, style: bold ? const TextStyle(fontWeight: FontWeight.bold) : null),
        ],
      ),
    );
  }

  Widget _buildCouponSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // --- Apply coupon form ---
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _couponController,
                decoration: const InputDecoration(labelText: "Apply coupon", hintText: "Enter coupon code"),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () {
                if (_couponController.text.isNotEmpty && !_appliedCoupons.contains(_couponController.text.trim())) {
                  _applyCoupon();
                }
              },
              child: const Text("Apply"),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // --- Collapsible coupons list toggle ---
        if (_appliedCoupons.isNotEmpty)
          GestureDetector(
            onTap: () => setState(() => _showCoupons = !_showCoupons),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Applied Coupons", style: TextStyle(fontWeight: FontWeight.bold)),
                Icon(_showCoupons ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down),
              ],
            ),
          ),

        // --- Coupons list ---
        AnimatedCrossFade(
          firstChild: const SizedBox.shrink(),
          secondChild: Wrap(
            spacing: 8,
            runSpacing: 4,
            children: _appliedCoupons
                .map(
                  (coupon) => Chip(
                    label: Text(coupon),
                    deleteIcon: const Icon(Icons.close),
                    onDeleted: () {
                      setState(() {
                        _appliedCoupons.remove(coupon);
                        if (_appliedCoupons.isEmpty) {
                          _showCoupons = false;
                        }
                      });
                    },
                  ),
                )
                .toList(),
          ),
          crossFadeState: _showCoupons ? CrossFadeState.showSecond : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 250),
        ),
      ],
    );
  }
}
