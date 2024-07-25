import 'package:flutter/material.dart';
import 'package:wallet/constants/assets.gen.dart';
import 'package:wallet/constants/constants.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/l10n/generated/locale.dart';
import 'package:wallet/rust/proton_api/proton_address.dart';
import 'package:wallet/scenes/components/bottom.sheets/base.dart';
import 'package:wallet/scenes/components/button.v6.dart';
import 'package:wallet/scenes/components/close.button.v1.dart';
import 'package:wallet/scenes/components/dropdown.button.v2.dart';
import 'package:wallet/scenes/send/bottom.sheet/send.flow.invite.success.dart';
import 'package:wallet/theme/theme.font.dart';

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
    HomeModalBottomSheet.show(context, backgroundColor: ProtonColors.white,
        child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
      return Column(mainAxisSize: MainAxisSize.min, children: [
        Align(
            alignment: Alignment.centerLeft,
            child: CloseButtonV1(
                backgroundColor: ProtonColors.backgroundProton,
                onPressed: () {
                  Navigator.of(context).pop();
                })),
        Transform.translate(
            offset: const Offset(0, -20),
            child: Column(children: [
              Assets.images.icon.user.image(
                fit: BoxFit.fill,
                width: 240,
                height: 167,
              ),
              const SizedBox(height: 20),
              Text(
                S.of(context).send_invite_to(email),
                style: FontManager.titleHeadline(ProtonColors.textNorm),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                S.of(context).no_wallet_found_desc,
                style: FontManager.body2Regular(ProtonColors.textWeak),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              DropdownButtonV2(
                width: MediaQuery.of(context).size.width,
                labelText: S.of(context).send_from_email,
                title: S.of(context).choose_your_email,
                items: userAddresses,
                itemsText: userAddresses.map((e) => e.email).toList(),
                valueNotifier: userAddressValueNotifier,
                border: Border.all(color: ProtonColors.protonShades20),
                padding: const EdgeInsets.only(
                    left: defaultPadding, right: 8, top: 12, bottom: 12),
              ),
              const SizedBox(height: 60),
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
                  textStyle: FontManager.body1Median(ProtonColors.white),
                  backgroundColor: ProtonColors.protonBlue,
                  borderColor: ProtonColors.protonBlue,
                  height: 48),
            ]))
      ]);
    }));
  }
}
