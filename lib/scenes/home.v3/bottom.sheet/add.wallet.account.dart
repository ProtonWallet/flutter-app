import 'package:flutter/material.dart';
import 'package:wallet/components/button.v5.dart';
import 'package:wallet/components/dropdown.button.v2.dart';
import 'package:wallet/components/textfield.text.v2.dart';
import 'package:wallet/constants/constants.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/constants/script_type.dart';
import 'package:wallet/l10n/generated/locale.dart';
import 'package:wallet/models/wallet.model.dart';
import 'package:wallet/components/bottom.sheets/base.dart';
import 'package:wallet/scenes/home.v3/home.viewmodel.dart';
import 'package:wallet/theme/theme.font.dart';

class AddWalletAccountSheet {
  static void show(
      BuildContext context, HomeViewModel viewModel, WalletModel walletModel) {
    HomeModalBottomSheet.show(context,
        child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 10),
              DropdownButtonV2(
                  labelText: S.of(context).script_type,
                  width: MediaQuery.of(context).size.width - defaultPadding * 2,
                  items: ScriptType.scripts,
                  itemsText: ScriptType.scripts.map((v) => v.name).toList(),
                  valueNotifier: viewModel.newAccountScriptTypeValueNotifier),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
                child: TextFieldTextV2(
                  labelText: S.of(context).account_label,
                  textController: viewModel.newAccountNameController,
                  myFocusNode: viewModel.newAccountNameFocusNode,
                  validation: (String value) {
                    if (value.isEmpty) {
                      return "Required";
                    }
                    return "";
                  },
                ),
              ),
              const SizedBox(height: 12),
              Container(
                  padding: const EdgeInsets.only(top: 20),
                  margin: const EdgeInsets.symmetric(
                      horizontal: defaultButtonPadding),
                  child: ButtonV5(
                      onPressed: () async {
                        await viewModel.addWalletAccount(
                            walletModel.id!,
                            viewModel.newAccountScriptTypeValueNotifier.value,
                            viewModel.newAccountNameController.text.isNotEmpty
                                ? viewModel.newAccountNameController.text
                                : S.of(context).default_account);
                        if (context.mounted) {
                          Navigator.of(context).pop();
                        }
                      },
                      backgroundColor: ProtonColors.protonBlue,
                      text: S.of(context).add_account,
                      width: MediaQuery.of(context).size.width,
                      textStyle: FontManager.body1Median(
                          ProtonColors.backgroundSecondary),
                      height: 48)),
            ]));
  }
}
