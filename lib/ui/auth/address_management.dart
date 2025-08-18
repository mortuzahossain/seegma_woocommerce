import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:seegma_woocommerce/api/api_service.dart';
import 'package:seegma_woocommerce/utils/loading_dialog.dart';
import 'package:seegma_woocommerce/utils/snackbar.dart';

class AddressPage extends StatefulWidget {
  const AddressPage({super.key});

  @override
  State<AddressPage> createState() => _AddressPageState();
}

class _AddressPageState extends State<AddressPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final billing = <String, TextEditingController>{};
  final shipping = <String, TextEditingController>{};

  final fields = ["first_name", "last_name", "address_1", "address_2", "city", "state", "postcode", "country", "phone", "email"];

  final fieldIcons = {
    "first_name": FontAwesomeIcons.user,
    "last_name": FontAwesomeIcons.user,
    "address_1": FontAwesomeIcons.locationDot,
    "address_2": FontAwesomeIcons.locationDot,
    "city": FontAwesomeIcons.city,
    "state": FontAwesomeIcons.flag,
    "postcode": FontAwesomeIcons.hashtag,
    "country": FontAwesomeIcons.globe,
    "phone": FontAwesomeIcons.phone,
    "email": FontAwesomeIcons.envelope,
  };

  bool loading = true;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 2, vsync: this);

    // Fake data for demo
    for (var f in fields) {
      billing[f] = TextEditingController(text: "");
      shipping[f] = TextEditingController(text: "");
    }

    // Fetch addresses
    _fetchAddresses();
  }

  Future<void> _fetchAddresses() async {
    final data = await ApiService.get('/hh/v1/address');

    final billingData = Map<String, dynamic>.from(data["addresses"]["billing"]);
    final shippingData = Map<String, dynamic>.from(data["addresses"]["shipping"]);

    for (var f in fields) {
      billing[f] = TextEditingController(text: billingData[f] ?? "");
      shipping[f] = TextEditingController(text: shippingData[f] ?? "");
    }

    setState(() => loading = false);
  }

  Future<void> _updateAddress(String type) async {
    LoadingDialog.show(context);

    try {
      final body = <String, String>{"addr_type": type};
      final map = type == "billing" ? billing : shipping;
      body.addAll(map.map((k, v) => MapEntry(k, v.text)));

      final response = await ApiService.post('/hh/v1/update-address', body: body);

      LoadingDialog.hide(context);
      showAwesomeSnackbar(
        context: context,
        type: ContentType.success,
        title: 'Success!',
        message: response['message'] ?? 'Successful ... ',
      );
    } catch (e) {
      LoadingDialog.hide(context);

      final message = e is Exception ? e.toString().replaceFirst('Exception: ', '') : 'Something went wrong.';
      showAwesomeSnackbar(context: context, type: ContentType.failure, title: 'Failed!', message: message);
    }
  }

  Widget _buildAddressForm(String title, Map<String, TextEditingController> ctrls, String type) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          ...fields.map((f) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: TextFormField(
                controller: ctrls[f],
                maxLines: (f == "address_1" || f == "address_2") ? 3 : 1,
                decoration: InputDecoration(
                  prefixIcon: Icon(fieldIcons[f], size: 18),
                  labelText: f.replaceAll("_", " ").toUpperCase(),
                  border: const OutlineInputBorder(),
                ),
              ),
            );
          }),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(onPressed: () => _updateAddress(type), child: Text("Save $title")),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My Addresses")),
      body: loading
          ? animatedLoader()
          : SafeArea(
              child: Column(
                children: [
                  TabBar(
                    controller: _tabController,
                    labelColor: Theme.of(context).primaryColor,
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: Theme.of(context).primaryColor,
                    tabs: const [
                      Tab(text: "Billing"),
                      Tab(text: "Shipping"),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildAddressForm("Billing Address", billing, "billing"),
                        _buildAddressForm("Shipping Address", shipping, "shipping"),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

extension StringX on String {
  String capitalize() => isEmpty ? this : "${this[0].toUpperCase()}${substring(1)}";
}
