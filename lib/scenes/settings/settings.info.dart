import 'package:flutter/widgets.dart';

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
            style: const TextStyle(
              color: Color(0xFF0E0E0E),
              fontSize: 17,
              fontFamily: 'SF Pro Text',
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            displayEmail,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF848993),
              fontSize: 14,
              fontFamily: 'SF Pro Text',
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
