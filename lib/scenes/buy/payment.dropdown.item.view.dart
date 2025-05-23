import 'package:flutter/material.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/constants/text.style.dart';

import 'payment.dropdown.item.dart';

class PaymentDropdownItem extends StatelessWidget {
  final DropdownItem item;
  final Widget? icon;
  final bool selected;
  final VoidCallback? onTap;

  const PaymentDropdownItem({
    required this.item,
    required this.icon,
    super.key,
    this.selected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.only(left: 8, top: 8, right: 8, bottom: 8),
        decoration: ShapeDecoration(
          color: selected ? ProtonColors.interActionWeakDisable : null,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            /// payment icon
            Container(
              width: 40,
              height: 40,
              decoration: ShapeDecoration(
                color: const Color.fromARGB(255, 255, 255, 255),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(200),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 16,
                    height: 16,
                    clipBehavior: Clip.antiAlias,
                    decoration: const BoxDecoration(),
                    child: icon,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Text(
              // 'Credit Card',
              item.title,
              style: ProtonStyles.body2Medium(color: ProtonColors.textNorm),
            ),
            Expanded(
              child: Text(
                item.subtitle,
                textAlign: TextAlign.right,
                style: ProtonStyles.body2Medium(color: ProtonColors.textNorm),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
