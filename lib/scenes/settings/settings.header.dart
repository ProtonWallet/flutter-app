import 'package:flutter/widgets.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/constants/text.style.dart';

class SectionHeader extends StatelessWidget {
  final String title;

  const SectionHeader({
    required this.title,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 12, right: 16),
      child: Row(children: [
        Expanded(
          child: Text(
            title,
            style: ProtonStyles.body2Semibold(
              color: ProtonColors.textWeak,
            ),
          ),
        ),
      ]),
    );
  }
}
