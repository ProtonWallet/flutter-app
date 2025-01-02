import 'dart:math';

import 'package:flutter/material.dart';
import 'package:wallet/constants/constants.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/constants/text.style.dart';
import 'package:wallet/l10n/generated/locale.dart';
import 'package:wallet/models/contacts.model.dart';
import 'package:wallet/scenes/components/bottom.sheets/base.dart';
import 'package:wallet/scenes/components/close.button.v1.dart';
import 'package:wallet/scenes/components/protonmail.autocomplete.dart';

typedef EmailSelectedCallback = void Function(String email);

// TODO(fix): refactor this to a sperate view and viewmodel. dont need to share the viewmodel with the home viewmodel
class EmailAutoCompleteSheet {
  static void show(BuildContext context, List<ContactsModel> contactsEmails,
      EmailSelectedCallback emailSelectedCallback) {
    final TextEditingController emailController =
        TextEditingController(text: "");
    final FocusNode emailFocusNode = FocusNode();
    Future.delayed(
        const Duration(milliseconds: 200), emailFocusNode.requestFocus);
    HomeModalBottomSheet.show(context,
        backgroundColor: ProtonColors.white,
        useIntrinsicHeight: false,
        maxHeight: MediaQuery.of(context).size.height - 60,
        // need to set false otherwise it will raise error since auto complete conflict with IntrinsicHeight
        child: Column(children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: CloseButtonV1(
                      backgroundColor: ProtonColors.backgroundProton,
                      onPressed: () {
                        Navigator.of(context).pop();
                      }),
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  S.of(context).send_invite_to(""),
                  style: ProtonStyles.body1Medium(color: ProtonColors.textNorm),
                  textAlign: TextAlign.center,
                ),
              ),
              const Spacer(),
            ],
          ),
          const SizedBox(
            height: defaultPadding,
          ),
          Column(children: [
            Column(children: [
              ProtonMailAutoComplete(
                  labelText: S.of(context).email_address,
                  hintText: S.of(context).you_can_invite_any,
                  emails: contactsEmails,
                  color: ProtonColors.white,
                  focusNode: emailFocusNode,
                  textEditingController: emailController,
                  showQRcodeScanner: false,
                  maxHeight: max(MediaQuery.of(context).size.height - 460, 190),
                  keyboardType: TextInputType.emailAddress,
                  callback: () {
                    final String email = emailController.text;
                    emailSelectedCallback.call(email);
                    Navigator.of(context).pop();
                  }),
            ]),
            SizedBox(
              height: MediaQuery.of(context).viewInsets.bottom,
            ),
          ])
        ]));
  }
}
