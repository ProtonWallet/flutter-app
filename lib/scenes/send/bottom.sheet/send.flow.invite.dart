import 'package:flutter/material.dart';
import 'package:wallet/constants/assets.gen.dart';
import 'package:wallet/constants/constants.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/constants/text.style.dart';
import 'package:wallet/helper/extension/asset.gen.image.extension.dart';
import 'package:wallet/l10n/generated/locale.dart';
import 'package:wallet/rust/proton_api/proton_address.dart';
import 'package:wallet/scenes/components/bottom.sheets/base.dart';
import 'package:wallet/scenes/components/button.v6.dart';
import 'package:wallet/scenes/components/close.button.v1.dart';
import 'package:wallet/scenes/components/dropdown.button.v2.dart';
import 'package:wallet/scenes/send/bottom.sheet/send.flow.invite.success.dart';

typedef SendFlowInviteCallback = Future<bool> Function(String email);

class SendFlowInviteSheet {
  static void show(
    BuildContext context,
    List<ProtonAddress> userAddresses,
    String email,
    SendFlowInviteCallback sendInvite,
  ) {
    final ValueNotifier userAddressValueNotifier =
        ValueNotifier(userAddresses.firstOrNull);
    HomeModalBottomSheet.show(context,
        backgroundColor: ProtonColors.backgroundSecondary, child:
            StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
      return Column(mainAxisSize: MainAxisSize.min, children: [
        Align(
            alignment: Alignment.centerLeft,
            child: CloseButtonV1(
                backgroundColor: ProtonColors.backgroundNorm,
                onPressed: () {
                  Navigator.of(context).pop();
                })),
        Transform.translate(
            offset: const Offset(0, -20),
            child: Column(children: [
              Assets.images.icon.user.applyThemeIfNeeded(context).image(
                    fit: BoxFit.fill,
                    width: 240,
                    height: 167,
                  ),
              Text(
                S.of(context).send_invite_to(email),
                style: ProtonStyles.headline(color: ProtonColors.textNorm),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                S.of(context).no_wallet_found_desc,
                style: ProtonStyles.body2Regular(color: ProtonColors.textWeak),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              DropdownButtonV2(
                width: MediaQuery.of(context).size.width,
                labelText: S.of(context).send_from_email,
                title: S.of(context).choose_your_email,
                items: userAddresses,
                itemsText: userAddresses.map((e) => e.email).toList(),
                valueNotifier: userAddressValueNotifier,
                border: Border.all(color: ProtonColors.interActionWeakDisable),
                padding: const EdgeInsets.only(
                    left: defaultPadding, right: 8, top: 12, bottom: 12),
              ),
              const SizedBox(height: 20),
              ButtonV6(
                  onPressed: () async {
                    final bool success = await sendInvite.call(
                      email,
                    );
                    if (context.mounted && success) {
                      Navigator.of(context).pop();
                      SendFlowInviteSuccessSheet.show(
                        context,
                        email,
                      );
                    }
                  },
                  text: S.of(context).send_invite_email,
                  width: MediaQuery.of(context).size.width,
                  textStyle: ProtonStyles.body1Medium(
                      color: ProtonColors.textInverted),
                  backgroundColor: ProtonColors.protonBlue,
                  borderColor: ProtonColors.protonBlue,
                  height: 55),
            ]))
      ]);
    }));
  }
}
