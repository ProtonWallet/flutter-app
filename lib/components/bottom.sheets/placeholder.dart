import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:wallet/components/button.v5.dart';
import 'package:wallet/constants/constants.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/l10n/generated/locale.dart';
import 'package:wallet/theme/theme.font.dart';

class CustomPlaceholder {
  static void show(BuildContext context) {
    showModalBottomSheet(
        context: context,
        backgroundColor: ProtonColors.white,
        constraints: BoxConstraints(
          minWidth: MediaQuery.of(context).size.width,
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(8.0)),
        ),
        builder: (BuildContext context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            return SafeArea(
              child: SingleChildScrollView(
                  child: Padding(
                      padding: const EdgeInsets.all(defaultPadding),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SvgPicture.asset(
                              "assets/images/icon/no_wallet_found.svg",
                              fit: BoxFit.fill,
                              width: 86,
                              height: 87),
                          const SizedBox(height: 10),
                          Text(S.of(context).placeholder,
                              style: FontManager.body1Median(
                                  ProtonColors.textNorm)),
                          const SizedBox(height: 5),
                          Text(S.of(context).placeholder,
                              style: FontManager.body2Regular(
                                  ProtonColors.textWeak)),
                          const SizedBox(height: 20),
                          ButtonV5(
                            text: S.of(context).ok,
                            width: MediaQuery.of(context).size.width,
                            backgroundColor: ProtonColors.protonBlue,
                            textStyle:
                                FontManager.body1Median(ProtonColors.white),
                            height: 48,
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                          const SizedBox(height: 10),
                        ],
                      ))),
            );
          });
        });
  }
}
