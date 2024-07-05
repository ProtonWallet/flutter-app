import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wallet/constants/proton.color.dart';

class RecoverySection extends StatelessWidget {
  final String title;
  final String description;
  final Widget? logo;
  final Widget? warning;
  final ValueChanged<bool>? onChanged;
  final bool isLoading;
  final bool? isSwitched;

  const RecoverySection({
    super.key,
    required this.title,
    required this.description,
    this.logo,
    this.warning,
    required this.isLoading,
    this.onChanged,
    this.isSwitched,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(
          Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// header
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Color(0xFF0E0E0E),
                        fontSize: 17,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w500,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              if (warning != null)
                SizedBox(width: 20, height: 20, child: warning),
              const SizedBox(width: 16),
              if (logo != null) SizedBox(width: 20, height: 20, child: logo),
              if (onChanged != null)
                if (isLoading)
                  const SizedBox(
                      height: 39, child: CupertinoActivityIndicator())
                else
                  CupertinoSwitch(
                    value: isSwitched ?? false,
                    activeColor: ProtonColors.protonBlue,
                    onChanged: onChanged,
                  ),
            ],
          ),
          const SizedBox(height: 20),

          /// description
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  description,
                  style: const TextStyle(
                    color: Color(0xFF6F7B8F),
                    fontSize: 12,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w500,
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
