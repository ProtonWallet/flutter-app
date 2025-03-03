import 'package:flutter/material.dart';
import 'package:wallet/constants/assets.gen.dart';
import 'package:wallet/constants/constants.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/helper/avatar.color.helper.dart';
import 'package:wallet/helper/extension/bitcoin.unit.extension.dart';
import 'package:wallet/helper/extension/build.context.extension.dart';
import 'package:wallet/helper/extension/svg.gen.image.extension.dart';
import 'package:wallet/l10n/generated/locale.dart';
import 'package:wallet/scenes/components/custom.loading.dart';
import 'package:wallet/scenes/components/dropdown.button.v2.dart';
import 'package:wallet/scenes/components/textfield.text.v2.dart';

Widget getWalletLeadingIcon(BuildContext context, int index) {
  switch (index) {
    case 1:
      return Assets.images.icon.wallet1.applyThemeIfNeeded(context).svg(
            fit: BoxFit.fill,
            width: 16,
            height: 16,
          );
    case 2:
      return Assets.images.icon.wallet2.applyThemeIfNeeded(context).svg(
            fit: BoxFit.fill,
            width: 16,
            height: 16,
          );
    case 3:
      return Assets.images.icon.wallet3.applyThemeIfNeeded(context).svg(
            fit: BoxFit.fill,
            width: 16,
            height: 16,
          );
    default:
      return Assets.images.icon.wallet0.applyThemeIfNeeded(context).svg(
            fit: BoxFit.fill,
            width: 16,
            height: 16,
          );
  }
}

class WalletNameCard extends StatelessWidget {
  final bool initialized;
  final int maxWalletNameSize;
  final int waleltIndex;
  final Function? onFinish;
  final ValueNotifier? valueNotifier;
  final TextEditingController nameController;
  final FocusNode nameFocusNode;
  const WalletNameCard({
    required this.initialized,
    required this.maxWalletNameSize,
    required this.waleltIndex,
    required this.nameController,
    required this.nameFocusNode,
    this.onFinish,
    this.valueNotifier,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: ProtonColors.backgroundSecondary,
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: Column(
            children: [
              /// Wallet Name TextField
              TextFieldTextV2(
                prefixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(width: 20),
                    CircleAvatar(
                      backgroundColor: AvatarColorHelper.getBackgroundColor(
                        waleltIndex % 4,
                      ),
                      radius: 20,
                      child: getWalletLeadingIcon(
                        context,
                        waleltIndex % 4,
                      ),
                    ),
                    const SizedBox(width: 16),
                  ],
                ),
                labelText: S.of(context).name,
                hintText: S.of(context).wallet_name_hint,
                alwaysShowHint: true,
                textController: nameController,
                myFocusNode: nameFocusNode,
                maxLength: maxWalletNameSize,
                onFinish: onFinish,
                validation: (String value) {
                  if (value.isEmpty) {
                    return "Required";
                  }
                  return "";
                },
              ),

              // Divider
              const Divider(
                thickness: 0.2,
                height: 1,
              ),

              // Bitcoin Unit Dropdown
              !initialized
                  ? CustomLoading()
                  : DropdownButtonV2(
                      labelText: S.of(context).setting_bitcoin_unit_label,
                      width: context.width - defaultPadding * 2,
                      items: bitcoinUnits,
                      itemsText: bitcoinUnits.toUpperCaseList,
                      valueNotifier: valueNotifier,
                    ),
            ],
          ),
        ),
      ],
    );
  }
}
