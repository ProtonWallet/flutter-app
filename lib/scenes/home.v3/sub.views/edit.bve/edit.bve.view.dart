import 'package:flutter/material.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/constants/text.style.dart';
import 'package:wallet/helper/local_toast.dart';
import 'package:wallet/l10n/generated/locale.dart';
import 'package:wallet/scenes/components/button.v6.dart';
import 'package:wallet/scenes/components/close.button.v1.dart';
import 'package:wallet/scenes/components/custom.header.dart';
import 'package:wallet/scenes/components/page.layout.v1.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/scenes/home.v3/sub.views/edit.bve/edit.bve.viewmodel.dart';

class EditBvEView extends ViewBase<EditBvEViewModel> {
  const EditBvEView(EditBvEViewModel viewModel)
      : super(viewModel, const Key("EditBvEView"));

  @override
  Widget build(BuildContext context) {
    return PageLayoutV1(
      headerWidget: CustomHeader(
        buttonDirection: AxisDirection.right,
        padding: const EdgeInsets.all(0.0),
        button: CloseButtonV1(
            backgroundColor: ProtonColors.backgroundProton,
            onPressed: () {
              Navigator.of(context).pop();
            }),
      ),
      expanded: viewModel.userAddresses.length > 5,
      initialized: viewModel.initialized,
      backgroundColor: ProtonColors.white,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              S.of(context).email_integration,
              style: ProtonStyles.subheadline(color: ProtonColors.textNorm),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            S.of(context).email_integration_setting_desc,
            style: ProtonStyles.body2Regular(color: ProtonColors.textWeak),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          for (final protonAddress in viewModel.userAddresses)
            Container(
                height: 60,
                alignment: Alignment.center,
                child: Stack(children: [
                  ListTile(
                    leading: Transform.translate(
                      offset: const Offset(0, 2),
                      child: Radio<String>(
                        value: viewModel.usedEmailIDs.contains(protonAddress.id)
                            ? "used"
                            : protonAddress.id,
                        groupValue:
                            viewModel.usedEmailIDs.contains(protonAddress.id)
                                ? "used"
                                : viewModel.selectedEmailID,
                        toggleable: true,
                        onChanged: viewModel.updateSelectedEmailID,
                      ),
                    ),
                    title: Transform.translate(
                      offset: const Offset(-12, 0),
                      child: Text(protonAddress.email,
                          style: ProtonStyles.body2Regular(
                              color: ProtonColors.textNorm)),
                    ),
                    onTap: () async {
                      final clickable =
                          !viewModel.usedEmailIDs.contains(protonAddress.id);
                      final itemValue =
                          viewModel.usedEmailIDs.contains(protonAddress.id)
                              ? "used"
                              : protonAddress.id;
                      if (clickable) {
                        if (itemValue == viewModel.selectedEmailID) {
                          viewModel.updateSelectedEmailID(null);
                        } else {
                          viewModel.updateSelectedEmailID(itemValue);
                        }
                      }
                    },
                  ),
                  if (viewModel.usedEmailIDs.contains(protonAddress
                      .id)) // add an overlay, so user cannot select this
                    Container(
                      width: MediaQuery.of(context).size.width,
                      height: 50,
                      color: Colors.white.withOpacity(0.5),
                    ),
                ])),
          const SizedBox(height: 20),
          Container(
              height: 60,
              alignment: Alignment.center,
              child: Column(children: [
                ButtonV6(
                    onPressed: () async {
                      if (viewModel.usedEmailIDs
                          .contains(viewModel.selectedEmailID)) {
                        LocalToast.showErrorToast(context,
                            S.of(context).email_already_linked_to_wallet);
                      } else {
                        final success =
                            await viewModel.addEmailAddressToWalletAccount();
                        if (success) {
                          viewModel.callback?.call();
                          if (context.mounted) {
                            Navigator.of(context).pop();
                          }
                        }
                      }
                    },
                    enable: viewModel.selectedEmailID != null,
                    backgroundColor: ProtonColors.protonBlue,
                    text: S.of(context).select_this_address,
                    width: MediaQuery.of(context).size.width,
                    textStyle:
                        ProtonStyles.body1Medium(color: ProtonColors.white),
                    height: 48),
              ])),
        ],
      ),
    );
  }
}
