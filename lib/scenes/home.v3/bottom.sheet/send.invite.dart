import 'package:flutter/material.dart';
import 'package:wallet/constants/assets.gen.dart';
import 'package:wallet/constants/constants.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/l10n/generated/locale.dart';
import 'package:wallet/models/contacts.model.dart';
import 'package:wallet/rust/proton_api/proton_address.dart';
import 'package:wallet/scenes/components/bottom.sheets/base.dart';
import 'package:wallet/scenes/components/bottom.sheets/email.autocomplete.dart';
import 'package:wallet/scenes/components/button.v6.dart';
import 'package:wallet/scenes/components/close.button.v1.dart';
import 'package:wallet/scenes/components/dropdown.button.v2.dart';
import 'package:wallet/scenes/home.v3/bottom.sheet/send.invite.success.dart';
import 'package:wallet/theme/theme.font.dart';

typedef SendInviteCallback = Future<bool> Function(
    ProtonAddress protonAddress, String email);

class SendInviteSheet {
  static void show(
    BuildContext context,
    List<ProtonAddress> userAddresses,
    List<ContactsModel> contactsEmails,
    SendInviteCallback sendInvite,
  ) {
    final TextEditingController emailController =
        TextEditingController(text: "");
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
                S.of(context).exclusive_invites,
                style: FontManager.titleHeadline(ProtonColors.textNorm),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                S.of(context).exclusive_invites_content,
                style: FontManager.body2Regular(ProtonColors.textWeak),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              DropdownButtonV2(
                width: MediaQuery.of(context).size.width,
                labelText: S.of(context).send_from_email,
                items: userAddresses,
                itemsText: userAddresses.map((e) => e.email).toList(),
                valueNotifier: userAddressValueNotifier,
                border: Border.all(color: ProtonColors.protonShades20),
                padding: const EdgeInsets.only(
                    left: defaultPadding, right: 8, top: 12, bottom: 12),
              ),
              GestureDetector(
                onTap: () {
                  EmailAutoCompleteSheet.show(context, contactsEmails,
                      (selectedEmail) {
                    setState(() {
                      emailController.text = selectedEmail;
                    });
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 4,
                  ),
                  decoration: BoxDecoration(
                      color: ProtonColors.white,
                      borderRadius:
                          const BorderRadius.all(Radius.circular(18.0)),
                      border: Border.all(
                        color: ProtonColors.protonShades20,
                      )),
                  child: TextFormField(
                    enabled: false,
                    focusNode: FocusNode(),
                    controller: emailController,
                    style: FontManager.body1Median(ProtonColors.textNorm),
                    decoration: InputDecoration(
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      labelText: S.of(context).your_friend_email,
                      labelStyle: FontManager.textFieldLabelStyle(
                          ProtonColors.textWeak),
                      hintText: S.of(context).you_can_invite_any,
                      hintStyle: FontManager.textFieldLabelStyle(
                          ProtonColors.textHint),
                      contentPadding: const EdgeInsets.only(
                          left: 10, right: 10, top: 4, bottom: 16),
                      enabledBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      border: InputBorder.none,
                      errorStyle: const TextStyle(height: 0),
                      focusedErrorBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 60),
              ButtonV6(
                  onPressed: () async {
                    final email = emailController.text;
                    if (email.isNotEmpty) {
                      final bool success = await sendInvite.call(
                        userAddressValueNotifier.value,
                        email,
                      );
                      if (context.mounted && success) {
                        Navigator.of(context).pop();
                        SendInviteSuccessSheet.show(
                          context,
                          userAddresses,
                          contactsEmails,
                          emailController.text,
                          sendInvite,
                        );
                      }
                    }
                  },
                  text: S.of(context).send_invite_email,
                  width: MediaQuery.of(context).size.width,
                  textStyle: FontManager.body1Median(
                      emailController.text.isEmpty
                          ? ProtonColors.textNorm
                          : ProtonColors.white),
                  backgroundColor: emailController.text.isEmpty
                      ? ProtonColors.protonShades20
                      : ProtonColors.protonBlue,
                  borderColor: emailController.text.isEmpty
                      ? ProtonColors.protonShades20
                      : ProtonColors.protonBlue,
                  enable: emailController.text.isNotEmpty,
                  height: 48),
            ]))
      ]);
    }));
  }
}
