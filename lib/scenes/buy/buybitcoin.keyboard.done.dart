import 'package:flutter/cupertino.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/l10n/generated/locale.dart';

class InputDoneView extends StatelessWidget {
  final VoidCallback? onTap;

  const InputDoneView({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: ProtonColors.inputDoneOverlay,
      child: Align(
        alignment: Alignment.topRight,
        child: Padding(
          padding: const EdgeInsets.only(top: 4.0, bottom: 4.0),
          child: CupertinoButton(
            padding: const EdgeInsets.only(right: 24.0, top: 8.0, bottom: 8.0),
            onPressed: () {
              onTap?.call();
              FocusScope.of(context).requestFocus(FocusNode());
            },
            child: Text(S.of(context).done,
                style: TextStyle(
                    color: ProtonColors.avatarBlue1Text,
                    fontWeight: FontWeight.bold)),
          ),
        ),
      ),
    );
  }
}
