import 'package:lottie/lottie.dart';
import 'package:flutter/material.dart';

var assetsanimationjson = 'assets/Loader.json';

class LoadingDialog {
  static void show(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Center(
            child: SizedBox(height: 120, width: 120, child: Lottie.asset(assetsanimationjson, repeat: true, fit: BoxFit.contain)),
          ),
        );
      },
    );
  }

  static void hide(BuildContext context) {
    Navigator.of(context, rootNavigator: true).pop();
  }
}

Widget animatedLoader() {
  return Center(
    child: SizedBox(height: 120, width: 120, child: Lottie.asset(assetsanimationjson, repeat: true, fit: BoxFit.contain)),
  );
}
