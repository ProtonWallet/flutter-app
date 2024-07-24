import 'package:flutter/material.dart';
import 'package:wallet/constants/assets.gen.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/l10n/generated/locale.dart';
import 'package:wallet/models/contacts.model.dart';
import 'package:wallet/scenes/components/bottom.sheets/base.dart';
import 'package:wallet/scenes/components/button.v5.dart';
import 'package:wallet/scenes/components/close.button.v1.dart';
import 'package:wallet/scenes/home.v3/bottom.sheet/send.invite.dart';
import 'package:wallet/theme/theme.font.dart';

class SendInviteSuccessSheet {
  static void show(
    BuildContext context,
    List<ContactsModel> contactsEmails,
    String email,
    SendInviteCallback sendInvite,
  ) {
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
              Assets.images.icon.paperPlane.image(
                fit: BoxFit.fill,
                width: 240,
                height: 167,
              ),
              const SizedBox(height: 20),
              Text(
                S.of(context).invitation_sent_to(email),
                style: FontManager.titleHeadline(ProtonColors.textNorm),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                S.of(context).invitation_success_content,
                style: FontManager.body2Regular(ProtonColors.textWeak),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 60),
              ButtonV5(
                  onPressed: () async {
                    Navigator.of(context).pop();
                    SendInviteSheet.show(context, contactsEmails, sendInvite);
                  },
                  text: S.of(context).invite_another_friend,
                  width: MediaQuery.of(context).size.width,
                  textStyle: FontManager.body1Median(ProtonColors.white),
                  backgroundColor: ProtonColors.protonBlue,
                  borderColor: ProtonColors.protonBlue,
                  height: 48),
              const SizedBox(height: 8),
              ButtonV5(
                  onPressed: () async {
                    Navigator.of(context).pop();
                  },
                  text: S.of(context).close,
                  width: MediaQuery.of(context).size.width,
                  textStyle: FontManager.body1Median(ProtonColors.textNorm),
                  backgroundColor: ProtonColors.protonShades20,
                  borderColor: ProtonColors.protonShades20,
                  height: 48),
            ]))
      ]);
    }));
  }
}
