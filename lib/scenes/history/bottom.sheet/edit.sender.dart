import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:wallet/constants/assets.gen.dart';
import 'package:wallet/constants/constants.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/helper/common_helper.dart';
import 'package:wallet/helper/exceptions.dart';
import 'package:wallet/helper/logger.dart';
import 'package:wallet/l10n/generated/locale.dart';
import 'package:wallet/models/contacts.model.dart';
import 'package:wallet/rust/api/errors.dart';
import 'package:wallet/scenes/components/bottom.sheets/base.dart';
import 'package:wallet/scenes/components/button.v6.dart';
import 'package:wallet/scenes/components/close.button.v1.dart';
import 'package:wallet/scenes/components/protonmail.autocomplete.dart';
import 'package:wallet/scenes/components/textfield.text.v2.dart';
import 'package:wallet/scenes/history/details.viewmodel.dart';
import 'package:wallet/theme/theme.font.dart';

// TODO(fix): refactor this to a sperate view and viewmodel. dont need to share the viewmodel with the home viewmodel
class EditSenderSheet {
  static void show(BuildContext context, HistoryDetailViewModel viewModel) {
    String email = "";
    String name = "";
    try {
      final jsonMap = jsonDecode(viewModel.fromEmail) as Map<String, dynamic>;
      email = jsonMap["email"] ?? "";
      name = jsonMap["name"] ?? "";
    } catch (e) {
      // e.toString();
    }
    final TextEditingController nameController =
        TextEditingController(text: name);
    final FocusNode nameFocusNode = FocusNode();
    final TextEditingController emailController =
        TextEditingController(text: email);
    final FocusNode emailFocusNode = FocusNode();
    HomeModalBottomSheet.show(context,
        useIntrinsicHeight: false,
        maxHeight: MediaQuery.of(context).size.height - 120,
        // need to set false otherwise it will raise error since auto complete conflict with IntrinsicHeight
        child: Column(children: [
          Align(
              alignment: Alignment.centerRight,
              child: CloseButtonV1(onPressed: () {
                Navigator.of(context).pop();
              })),
          Column(children: [
            Assets.images.icon.noWalletFound
                .svg(fit: BoxFit.fill, width: 86, height: 87),
            const SizedBox(height: 10),
            Padding(
                padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
                child: Text(S.of(context).unknown_sender,
                    style: FontManager.titleHeadline(ProtonColors.textNorm))),
            const SizedBox(height: 10),
            Padding(
                padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
                child: Text(S.of(context).unknown_sender_desc,
                    style: FontManager.body2Regular(ProtonColors.textWeak))),
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
              child: Column(children: [
                ProtonMailAutoComplete(
                    labelText: S.of(context).sender_name,
                    hintText: S.of(context).sender_name_hint,
                    emails: viewModel.contactsEmails,
                    color: ProtonColors.white,
                    focusNode: nameFocusNode,
                    textEditingController: nameController,
                    showBorder: false,
                    showQRcodeScanner: false,
                    maxHeight:
                        max(MediaQuery.of(context).size.height - 460, 190),
                    callback: () {
                      final String email = nameController.text;
                      for (ContactsModel contactsModel
                          in viewModel.contactsEmails) {
                        if (email == contactsModel.email) {
                          if (contactsModel.name.isNotEmpty) {
                            nameController.text = contactsModel.name;
                          }
                          emailController.text = contactsModel.email;
                          break;
                        }
                      }
                    }),
              ]),
              //
              //
              // TextFieldTextV2(
              //   labelText: S.of(context).sender_name,
              //   hintText: S.of(context).sender_name_hint,
              //   alwaysShowHint: true,
              //   maxLength: maxWalletNameSize,
              //   textController: nameController,
              //   myFocusNode: nameFocusNode,
              //   validation: (String newAccountName) {
              //     // bool accountNameExists = false;
              //
              // TODO(fix): check if accountName already used
              //     // if (accountNameExists) {
              //     //   return S.of(context).account_name_already_used;
              //     // }
              //     return "";
              //   },
              // ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
              child: TextFieldTextV2(
                labelText: S.of(context).sender_email_optional,
                hintText: S.of(context).sender_email_optional_hint,
                alwaysShowHint: true,
                maxLength: maxWalletNameSize,
                textController: emailController,
                myFocusNode: emailFocusNode,
                validation: (String newAccountName) {
                  // bool accountNameExists = false;

                  // TODO(fix): check if accountName already used
                  // if (accountNameExists) {
                  //   return S.of(context).account_name_already_used;
                  // }
                  return "";
                },
              ),
            ),
            Container(
                padding: const EdgeInsets.only(top: 20),
                margin: const EdgeInsets.symmetric(
                    horizontal: defaultButtonPadding),
                child: ButtonV6(
                    onPressed: () async {
                      try {
                        if (nameController.text.isNotEmpty) {
                          await viewModel.updateSender(
                            nameController.text,
                            emailController.text,
                          );
                        }
                      } on BridgeError catch (e, stacktrace) {
                        final msg = parseSampleDisplayError(e);
                        logger.e("error: $e, stacktrace: $stacktrace");
                        CommonHelper.showErrorDialog(msg);
                      } catch (e) {
                        CommonHelper.showErrorDialog(e.toString());
                      }
                      if (context.mounted) {
                        Navigator.of(context).pop();
                      }
                    },
                    backgroundColor: ProtonColors.protonBlue,
                    text: S.of(context).update_details,
                    width: MediaQuery.of(context).size.width,
                    textStyle: FontManager.body1Median(
                        ProtonColors.backgroundSecondary),
                    height: 48)),
            SizedBox(
              height: MediaQuery.of(context).viewInsets.bottom,
            ),
          ])
        ]));
  }
}
