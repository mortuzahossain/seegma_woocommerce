import 'package:flutter/material.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final _shippingFormKey = GlobalKey<FormState>();
  final _billingFormKey = GlobalKey<FormState>();
  final TextEditingController _couponController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  bool _sameAsShipping = true;
  String _selectedShippingOption = 'Flat rate';
  double _shippingCost = 100.0;

  // shipping options (can be dynamic)
  final List<Map<String, dynamic>> _shippingOptions = [
    {'name': 'Flat rate', 'cost': 100.0},
    {'name': 'Express delivery', 'cost': 150.0},
    {'name': 'Free shipping', 'cost': 0.0},
  ];

  // coupon state
  bool _couponApplied = false;
  String _appliedCoupon = '';
  double _discountPercent = 0.0;

  // sample order items (replace with real cart)
  final List<Map<String, dynamic>> orderItems = [
    {
      'title': 'Beanie with Logo',
      'previousPrice': 20.0,
      'price': 18.0,
      'quantity': 1,
      'description': 'This is a simple product.',
    },
  ];

  double get subtotal => orderItems.fold(0.0, (s, i) => s + (i['price'] as double) * (i['quantity'] as int));

  double get discount => _couponApplied ? subtotal * _discountPercent / 100.0 : 0.0;

  double get total => subtotal - discount + _shippingCost;

  String _fmt(double v) => "${v.toStringAsFixed(2)}৳";

  void _applyCoupon() {
    final code = _couponController.text.trim().toLowerCase();
    if (code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Enter a coupon code")));
      return;
    }

    // Example: support only 'free10' coupon for 10% off
    if (code == 'free10') {
      setState(() {
        _couponApplied = true;
        _appliedCoupon = 'free10';
        _discountPercent = 10.0;
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Coupon applied: free10 (10% off)")));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Invalid coupon")));
    }
  }

  void _removeCoupon() {
    setState(() {
      _couponApplied = false;
      _appliedCoupon = '';
      _discountPercent = 0.0;
      _couponController.clear();
    });
  }

  @override
  void dispose() {
    _couponController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Checkout")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Apply coupon ---
            _buildCouponSection(),
            const SizedBox(height: 16),

            // --- Contact info ---
            const Text("Contact information", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            const Text("We'll use this email to send you details and updates about your order."),
            const SizedBox(height: 8),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: "Email address"),
            ),
            const SizedBox(height: 12),
            const Text("You are currently checking out as a guest.", style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 16),

            // --- Delivery (shipping method) ---
            const Text("Delivery", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Column(
              children: _shippingOptions.map((opt) {
                return RadioListTile<String>(
                  title: Text("${opt['name']} (${_fmt(opt['cost'] as double)})"),
                  value: opt['name'] as String,
                  groupValue: _selectedShippingOption,
                  onChanged: (val) {
                    setState(() {
                      _selectedShippingOption = val!;
                      _shippingCost = (opt['cost'] as double);
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // --- Shipping address form ---
            const Text("Shipping address", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Form(
              key: _shippingFormKey,
              child: Column(
                children: [
                  TextFormField(
                    decoration: const InputDecoration(labelText: "Country/Region"),
                    initialValue: "Bangladesh",
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(decoration: const InputDecoration(labelText: "First name")),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextFormField(decoration: const InputDecoration(labelText: "Last name")),
                      ),
                    ],
                  ),
                  TextFormField(decoration: const InputDecoration(labelText: "Address")),
                  TextFormField(decoration: const InputDecoration(labelText: "+ Add apartment, suite, etc.")),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(decoration: const InputDecoration(labelText: "City")),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextFormField(
                          decoration: const InputDecoration(labelText: "District"),
                          initialValue: "Dhaka",
                        ),
                      ),
                    ],
                  ),
                  TextFormField(decoration: const InputDecoration(labelText: "Postal code (optional)")),
                  TextFormField(decoration: const InputDecoration(labelText: "Phone (optional)")),
                ],
              ),
            ),

            const SizedBox(height: 12),
            CheckboxListTile(
              value: _sameAsShipping,
              onChanged: (v) => setState(() => _sameAsShipping = v ?? true),
              title: const Text("Use same address for billing"),
            ),

            if (!_sameAsShipping) ...[
              const SizedBox(height: 8),
              const Text("Billing address", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Form(
                key: _billingFormKey,
                child: Column(
                  children: [
                    TextFormField(decoration: const InputDecoration(labelText: "Country/Region")),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(decoration: const InputDecoration(labelText: "First name")),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextFormField(decoration: const InputDecoration(labelText: "Last name")),
                        ),
                      ],
                    ),
                    TextFormField(decoration: const InputDecoration(labelText: "Address")),
                    TextFormField(decoration: const InputDecoration(labelText: "+ Add apartment, suite, etc.")),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(decoration: const InputDecoration(labelText: "City")),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextFormField(decoration: const InputDecoration(labelText: "District")),
                        ),
                      ],
                    ),
                    TextFormField(decoration: const InputDecoration(labelText: "Postal code (optional)")),
                    TextFormField(decoration: const InputDecoration(labelText: "Phone (optional)")),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 16),
            const Text("Payment options", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const ListTile(
              leading: Icon(Icons.money),
              title: Text("Cash on delivery"),
              subtitle: Text("Pay with cash upon delivery."),
            ),
            const SizedBox(height: 12),

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
            ...orderItems.map((it) {
              final itemTotal = (it['price'] as double) * (it['quantity'] as int);
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  title: Text(it['title'] as String),
                  subtitle: Text(
                    "Previous price: ${_fmt(it['previousPrice'] as double)}  Discounted price: ${_fmt(it['price'] as double)}\n${it['description']}",
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_fmt(itemTotal), style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text("x${it['quantity']}", style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
              );
            }),

            // Coupon & summary rows
            const SizedBox(height: 8),
            _summaryRow("Subtotal", _fmt(subtotal)),
            if (_couponApplied) _summaryRow("Discount ($_appliedCoupon)", "-${_fmt(discount)}"),
            _summaryRow("Flat rate", _fmt(_shippingCost)),
            const Divider(),
            _summaryRow("Total", _fmt(total), bold: true),

            const SizedBox(height: 16),
            const Text(
              "By proceeding with your purchase you agree to our Terms and Conditions and Privacy Policy",
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text("Return to Cart")),
                const Spacer(),
                ElevatedButton(
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
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Order placed (demo)")));
                  },
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20)),
                  child: const Text("Place Order"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryRow(String label, String value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: bold ? const TextStyle(fontWeight: FontWeight.bold) : null),
          Text(value, style: bold ? const TextStyle(fontWeight: FontWeight.bold) : null),
        ],
      ),
    );
  }

  bool _showCoupons = false;
  final List<String> _appliedCoupons = [];

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
                  setState(() {
                    _appliedCoupons.add(_couponController.text.trim());
                    _couponController.clear();
                    _showCoupons = true; // auto expand on first add
                  });
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
