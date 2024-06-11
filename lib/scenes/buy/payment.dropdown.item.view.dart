import 'package:flutter/material.dart';
import 'package:wallet/scenes/buy/payment.dropdown.item.dart';

class PaymentDropdownItem extends StatelessWidget {
  final DropdownItem item;
  final VoidCallback? onTap;
  const PaymentDropdownItem({
    super.key,
    required this.item,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        /// payment icon
        Container(
          width: 40,
          height: 40,
          decoration: ShapeDecoration(
            color: const Color(0xFFF3F5F6),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(200),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 16,
                height: 16,
                clipBehavior: Clip.antiAlias,
                decoration: const BoxDecoration(),
                child: const FlutterLogo(),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            // 'Credit Card',
            item.title,
            style: const TextStyle(
              color: Color(0xFF0C0C14),
              fontSize: 14,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Text(
          item.subtitle,
          // 'Take minutes',
          textAlign: TextAlign.right,
          style: const TextStyle(
            color: Color(0xFF191C32),
            fontSize: 14,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 16),
      ],
    );
  }
}
