import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_svg/svg.dart';
import 'package:wallet/scenes/components/button.v5.dart';
import 'package:wallet/scenes/components/close.button.v1.dart';
import 'package:wallet/scenes/components/textfield.text.v2.dart';
import 'package:wallet/constants/constants.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/helper/common_helper.dart';
import 'package:wallet/l10n/generated/locale.dart';
import 'package:wallet/scenes/components/bottom.sheets/base.dart';
import 'package:wallet/scenes/history/details.viewmodel.dart';
import 'package:wallet/theme/theme.font.dart';

//TODO:: refactor this to a sperate view and viewmodel. dont need to share the viewmodel with the home viewmodel
class EditSenderSheet {
  static void show(BuildContext context, HistoryDetailViewModel viewModel) {
    String email = "";
    String name = "";
    try {
      var jsonMap = jsonDecode(viewModel.fromEmail) as Map<String, dynamic>;
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
        child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Align(
                  alignment: Alignment.centerRight,
                  child: CloseButtonV1(onPressed: () {
                    Navigator.of(context).pop();
                  })),
              Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SvgPicture.asset("assets/images/icon/no_wallet_found.svg",
                        fit: BoxFit.fill, width: 86, height: 87),
                    const SizedBox(height: 10),
                    Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: defaultPadding),
                        child: Text(S.of(context).unknown_sender,
                            style: FontManager.titleHeadline(
                                ProtonColors.textNorm))),
                    const SizedBox(height: 10),
                    Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: defaultPadding),
                        child: Text(S.of(context).unknown_sender_desc,
                            style: FontManager.body2Regular(
                                ProtonColors.textWeak))),
                    const SizedBox(height: 30),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: defaultPadding),
                      child: TextFieldTextV2(
                        labelText: S.of(context).sender_name,
                        hintText: S.of(context).sender_name_hint,
                        maxLength: maxWalletNameSize,
                        textController: nameController,
                        myFocusNode: nameFocusNode,
                        validation: (String newAccountName) {
                          // bool accountNameExists = false;

                          /// TODO:: check if accountName already used
                          // if (accountNameExists) {
                          //   return S.of(context).account_name_already_used;
                          // }
                          return "";
                        },
                      ),
                    ),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: defaultPadding),
                      child: TextFieldTextV2(
                        labelText: S.of(context).sender_email_optional,
                        hintText: S.of(context).sender_email_optional_hint,
                        maxLength: maxWalletNameSize,
                        textController: emailController,
                        myFocusNode: emailFocusNode,
                        validation: (String newAccountName) {
                          // bool accountNameExists = false;

                          /// TODO:: check if accountName already used
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
                        child: ButtonV5(
                            onPressed: () async {
                              Navigator.of(context).pop();
                              EasyLoading.show(
                                  status: "updating..",
                                  maskType: EasyLoadingMaskType.black);
                              try {
                                if (nameController.text.isNotEmpty) {
                                  await viewModel.updateSender(
                                    nameController.text,
                                    emailController.text,
                                  );
                                }
                              } catch (e) {
                                CommonHelper.showErrorDialog(e.toString());
                              }
                              EasyLoading.dismiss();
                            },
                            backgroundColor: ProtonColors.protonBlue,
                            text: S.of(context).update_details,
                            width: MediaQuery.of(context).size.width,
                            textStyle: FontManager.body1Median(
                                ProtonColors.backgroundSecondary),
                            height: 48)),
                  ])
            ]));
  }
}
