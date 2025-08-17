import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/material.dart';

IconData orderStatusIcon(String status) {
  switch (status.toLowerCase()) {
    case 'processing':
      return FontAwesomeIcons.clockRotateLeft;
    case 'completed':
      return FontAwesomeIcons.circleCheck;
    case 'cancelled':
      return FontAwesomeIcons.circleXmark;
    case 'on-hold':
      return FontAwesomeIcons.circlePause;
    case 'refunded':
      return FontAwesomeIcons.rotateLeft;
    default:
      return FontAwesomeIcons.circleQuestion;
  }
}

Color getStatusColor(String? status) {
  switch (status?.toLowerCase()) {
    case 'processing':
      return Colors.orange;
    case 'completed':
      return Colors.green;
    case 'cancelled':
      return Colors.red;
    case 'on-hold':
      return Colors.blueGrey;
    case 'refunded':
      return Colors.purple;
    default:
      return Colors.grey;
  }
}
