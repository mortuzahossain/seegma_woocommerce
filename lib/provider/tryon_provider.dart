import 'dart:io';

import 'package:flutter/material.dart';
import 'package:seegma_woocommerce/api/api_service.dart';
import 'package:seegma_woocommerce/utils/loading_dialog.dart';

class TryOnProvider extends ChangeNotifier {
  String? processedImageUrl;

  Future<void> processTryOn(BuildContext context, int productId, String image) async {
    try {
      LoadingDialog.show(context);
      final response = await ApiService.post(
        '/tryon/v1/process',
        body: {'product_id': productId.toString(), 'avatar_image': image},
        // file: File(imagePath),
        // fileField: 'avatar_image',
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
