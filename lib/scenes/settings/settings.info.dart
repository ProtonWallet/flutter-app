import 'package:flutter/widgets.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/constants/text.style.dart';

class SectionUserInfo extends StatelessWidget {
  final String displayName;
  final String displayEmail;

  const SectionUserInfo({
    required this.displayName,
    required this.displayEmail,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Text(
            displayName,
            textAlign: TextAlign.center,
            style: ProtonStyles.body1Semibold(
              color: ProtonColors.textNorm,
            ),
          ),
          Text(
            displayEmail,
            textAlign: TextAlign.center,
            style: ProtonStyles.body2Medium(
              color: ProtonColors.textWeak,
            ),
          ),
        ],
      ),
    );
  }
}
