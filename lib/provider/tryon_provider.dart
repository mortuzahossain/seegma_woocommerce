import 'dart:io';

import 'package:flutter/material.dart';
import 'package:seegma_woocommerce/api/api_service.dart';
import 'package:seegma_woocommerce/utils/loading_dialog.dart';

class TryOnProvider extends ChangeNotifier {
  String? processedImageUrl;

  Future<void> processTryOn(BuildContext context, int productId, String imagePath) async {
    try {
      LoadingDialog.show(context);
      final response = await ApiService.postMultipart(
        '/tryon/v1/process',
        fields: {'product_id': '75'},
        file: File('/Users/islamicwallet/Downloads/007.png'),
        fileField: 'avatar_image',
      );
      processedImageUrl = response['image_url'];
      notifyListeners();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      LoadingDialog.hide(context);
    }
  }
}
