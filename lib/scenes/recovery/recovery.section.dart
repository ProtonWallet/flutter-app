import 'package:flutter/cupertino.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/scenes/components/custom.loading.dart';

class RecoverySection extends StatelessWidget {
  final String title;
  final String description;
  final Widget? logo;
  final Widget? warning;
  final ValueChanged<bool>? onChanged;
  final bool isLoading;
  final bool? isSwitched;

  const RecoverySection({
    required this.title,
    required this.description,
    required this.isLoading,
    super.key,
    this.logo,
    this.warning,
    this.onChanged,
    this.isSwitched,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ProtonColors.backgroundSecondary,
        borderRadius: BorderRadius.all(
          Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// header
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: ProtonColors.textNorm,
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
                  Container(
                      height: 39,
                      width: 40,
                      padding: const EdgeInsets.only(
                          top: 9, bottom: 10, right: 15, left: 5),
                      child: const CustomLoading(size: 20))
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
            children: [
              Expanded(
                child: Text(
                  description,
                  style: TextStyle(
                    color: ProtonColors.textHint,
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
