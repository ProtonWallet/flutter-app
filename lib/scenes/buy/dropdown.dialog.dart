import 'package:flutter/material.dart';
import 'package:wallet/constants/assets.gen.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/constants/sizedbox.dart';

class AccountDropdown extends StatelessWidget {
  final String title;
  final List<Widget> widgets;

  const AccountDropdown({
    required this.widgets,
    required this.title,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: ShapeDecoration(
          color: ProtonColors.backgroundSecondary,
          shape: RoundedRectangleBorder(
            side: const BorderSide(color: Color(0xFFE6E8EC)),
            borderRadius: BorderRadius.circular(16),
          ),
          shadows: const [
            BoxShadow(
              color: Color(0x28000000),
              blurRadius: 24,
              offset: Offset(0, 8),
            )
          ],
        ),
        child: Container(
          padding: const EdgeInsets.only(
            top: 12,
            left: 8,
            right: 8,
            bottom: 8,
          ),
          decoration: const BoxDecoration(color: Color(0x00575D6B)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBoxes.box16,
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        color: Color(0xFF191C32),
                        fontSize: 14,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  /// close button
                  IconButton(
                    icon: Assets.images.icon.icCross.svg(
                      width: 20,
                      height: 20,
                      fit: BoxFit.fill,
                    ),
                    iconSize: 20.0, // Size of the image
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
              SizedBoxes.box12,
              for (final widget in widgets) ...<Widget>{
                widget,
                SizedBoxes.box12
              },
            ],
          ),
        ),
      ),
    );
  }
}
