import 'package:flutter/widgets.dart';
import 'package:wallet/rust/proton_api/payment_gateway.dart';

class DropdownItem {
  final Widget icon;
  final String title;
  final String subtitle;
  final PaymentMethod method;

  DropdownItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.method = PaymentMethod.card,
  });
}
