import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wallet/constants/constants.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/constants/script_type.dart';
import 'package:wallet/constants/sizedbox.dart';
import 'package:wallet/constants/text.style.dart';
import 'package:wallet/helper/common_helper.dart';
import 'package:wallet/helper/external.url.dart';
import 'package:wallet/l10n/generated/locale.dart';
import 'package:wallet/scenes/components/button.v5.dart';
import 'package:wallet/scenes/components/button.v6.dart';
import 'package:wallet/scenes/components/custom.header.dart';
import 'package:wallet/scenes/components/dropdown.button.v2.dart';
import 'package:wallet/scenes/components/page.layout.v1.dart';
import 'package:wallet/scenes/components/textfield.text.v2.dart';
import 'package:wallet/scenes/components/underline.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/scenes/home.v3/sub.views/add.wallet.account/add.wallet.account.viewmodel.dart';

class AddWalletAccountView extends ViewBase<AddWalletAccountViewModel> {
  const AddWalletAccountView(AddWalletAccountViewModel viewModel)
      : super(viewModel, const Key("AddWalletAccountView"));

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
      return PageLayoutV1(
        headerWidget: CustomHeader(
          title: S.of(context).add_wallet_account,
          buttonDirection: AxisDirection.right,
          padding: const EdgeInsets.all(0.0),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Column(mainAxisSize: MainAxisSize.min, children: [
            Padding(
                padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
                child: Text(
                  S.of(context).add_wallet_account_desc,
                  style:
                      ProtonStyles.body2Regular(color: ProtonColors.textWeak),
                  textAlign: TextAlign.center,
                )),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
              child: TextFieldTextV2(
                labelText: S.of(context).name,
                maxLength: maxWalletNameSize,
                textController: viewModel.newAccountNameController,
                myFocusNode: viewModel.newAccountNameFocusNode,
                validation: (String newAccountName) {
                  return "";
                },
              ),
            ),
            ExpansionTile(
                shape: const Border(),
                title: Text(S.of(context).advanced_settings,
                    style:
                        ProtonStyles.body2Medium(color: ProtonColors.textWeak)),
                iconColor: ProtonColors.textHint,
                collapsedIconColor: ProtonColors.textHint,
                children: [
                  Text(S.of(context).script_type,
                      style: ProtonStyles.body1Medium(
                          color: ProtonColors.textNorm)),
                  const SizedBox(height: 5),
                  Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: defaultPadding),
                      child: Text(
                        S.of(context).wallet_account_script_type_desc,
                        style: ProtonStyles.body2Regular(
                            color: ProtonColors.textWeak),
                        textAlign: TextAlign.center,
                      )),
                  const SizedBox(height: 20),
                  Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: defaultPadding,
                    ),
                    child: DropdownButtonV2(
                      labelText: S.of(context).script_type,
                      width: MediaQuery.of(context).size.width -
                          defaultPadding * 4,
                      items: ScriptTypeInfo.scripts,
                      itemsText:
                          ScriptTypeInfo.scripts.map((v) => v.name).toList(),
                      itemsMoreDetail: ScriptTypeInfo.scripts.map((v) {
                        switch (v.bipVersion) {
                          case 44:
                            return S
                                .of(context)
                                .wallet_account_script_type_desc_bip44;
                          case 49:
                            return S
                                .of(context)
                                .wallet_account_script_type_desc_bip49;
                          case 84:
                            return S
                                .of(context)
                                .wallet_account_script_type_desc_bip84;
                          case 86:
                            return S
                                .of(context)
                                .wallet_account_script_type_desc_bip86;
                          default:
                            return "TODO";
                        }
                      }).toList(),
                      valueNotifier:
                          viewModel.newAccountScriptTypeValueNotifier,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Underline(
                      onTap: () {
                        ExternalUrl.shared.launchBlogAddressType();
                      },
                      color: ProtonColors.protonBlue,
                      child: Text(S.of(context).learn_more,
                          style: ProtonStyles.body2Medium(
                              color: ProtonColors.protonBlue))),
                  const SizedBox(height: 20),
                  Text(S.of(context).wallet_account_index,
                      style: ProtonStyles.body1Medium(
                          color: ProtonColors.textNorm)),
                  const SizedBox(height: 5),
                  Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: defaultPadding),
                      child: Text(
                        S.of(context).wallet_account_index_desc,
                        style: ProtonStyles.body2Regular(
                            color: ProtonColors.textWeak),
                        textAlign: TextAlign.center,
                      )),
                  const SizedBox(height: 20),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: defaultPadding),
                    child: TextFieldTextV2(
                      labelText: S.of(context).wallet_account_index,
                      maxLength: maxWalletNameSize,
                      textController: viewModel.newAccountIndexController,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^[0-9]\d*')),
                      ],
                      myFocusNode: viewModel.newAccountIndexFocusNode,
                      validation: (String newAccountName) {
                        return "";
                      },
                    ),
                  ),
                  Underline(
                      onTap: () {
                        ExternalUrl.shared.launchBlogAccountIndex();
                      },
                      color: ProtonColors.protonBlue,
                      child: Text(S.of(context).learn_more,
                          style: ProtonStyles.body2Medium(
                              color: ProtonColors.protonBlue))),
                ]),
            const SizedBox(height: 12),
            Container(
                padding: const EdgeInsets.only(top: 20),
                margin: const EdgeInsets.symmetric(
                    horizontal: defaultButtonPadding),
                child: Column(children: [
                  ButtonV6(
                      onPressed: () async {
                        if (!viewModel.isAdding) {
                          viewModel.isAdding = true;
                          int newAccountIndex = 0;
                          try {
                            newAccountIndex = int.parse(
                                viewModel.newAccountIndexController.text);
                          } catch (e) {
                            // parse newAccountIndex failed, use default one
                          }
                          const accountNameExists = false;
                          if (context.mounted) {
                            if (!accountNameExists) {
                              final isSuccess =
                                  await viewModel.addWalletAccount(
                                viewModel
                                    .newAccountScriptTypeValueNotifier.value,
                                viewModel.newAccountNameController.text
                                        .isNotEmpty
                                    ? viewModel.newAccountNameController.text
                                    : S.of(context).default_account,
                                newAccountIndex,
                              );
                              if (context.mounted) {
                                if (isSuccess) {
                                  Navigator.of(context).pop();
                                  CommonHelper.showSnackbar(
                                      context, S.of(context).account_created);
                                }
                              }
                            }
                          }
                          viewModel.isAdding = false;
                        }
                      },
                      backgroundColor: ProtonColors.protonBlue,
                      text: S.of(context).create_wallet_account,
                      width: MediaQuery.of(context).size.width,
                      textStyle: ProtonStyles.body1Medium(
                          color: ProtonColors.textInverted),
                      height: 48),
                  SizedBoxes.box8,
                  ButtonV5(
                      onPressed: () async {
                        Navigator.of(context).pop();
                      },
                      text: S.of(context).cancel,
                      width: MediaQuery.of(context).size.width,
                      textStyle: ProtonStyles.body1Medium(
                          color: ProtonColors.textNorm),
                      backgroundColor: ProtonColors.interActionWeak,
                      borderColor: ProtonColors.interActionWeak,
                      height: 48),
                  SizedBoxes.box8,
                ])),
          ]),
        ]),
      );
    });
  }
}
