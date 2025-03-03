import 'package:flutter/material.dart';
import 'package:wallet/constants/assets.gen.dart';
import 'package:wallet/constants/constants.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/constants/text.style.dart';
import 'package:wallet/helper/extension/asset.gen.image.extension.dart';
import 'package:wallet/helper/extension/build.context.extension.dart';
import 'package:wallet/l10n/generated/locale.dart';
import 'package:wallet/scenes/components/bottom.sheets/email.autocomplete.dart';
import 'package:wallet/scenes/components/button.v5.dart';
import 'package:wallet/scenes/components/button.v6.dart';
import 'package:wallet/scenes/components/close.button.v1.dart';
import 'package:wallet/scenes/components/custom.card_loading.builder.dart';
import 'package:wallet/scenes/components/custom.header.dart';
import 'package:wallet/scenes/components/dropdown.button.v2.dart';
import 'package:wallet/scenes/components/page.layout.v1.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/scenes/home.v3/sub.views/send.invite/send.invite.viewmodel.dart';

class SendInviteView extends ViewBase<SendInviteViewModel> {
  const SendInviteView(SendInviteViewModel viewModel)
      : super(viewModel, const Key("SendInviteView"));

  @override
  Widget build(BuildContext context) {
    return PageLayoutV1(
      headerWidget: CustomHeader(
        buttonDirection: AxisDirection.right,
        padding: const EdgeInsets.all(0.0),
        button: CloseButtonV1(
            backgroundColor: ProtonColors.backgroundNorm,
            onPressed: () {
              Navigator.of(context).pop();
            }),
      ),
      backgroundColor: ProtonColors.backgroundSecondary,
      child: viewModel.state == SendInviteState.sendInvite
          ? buildSendInvite(context)
          : buildSendInviteSuccess(context),
    );
  }

  Widget buildSendInviteSuccess(BuildContext context) {
    return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
      return Column(mainAxisSize: MainAxisSize.min, children: [
        Transform.translate(
            offset: const Offset(0, -20),
            child: Column(children: [
              Assets.images.icon.paperPlane.applyThemeIfNeeded(context).image(
                    fit: BoxFit.fill,
                    width: 240,
                    height: 167,
                  ),
              const SizedBox(height: 20),
              Text(
                S
                    .of(context)
                    .invitation_sent_to(viewModel.emailController.text),
                style: ProtonStyles.headline(color: ProtonColors.textNorm),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                context.local.invitation_success_content,
                style: ProtonStyles.body2Regular(color: ProtonColors.textWeak),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 60),
              ButtonV5(
                  onPressed: () async {
                    viewModel.updateState(SendInviteState.sendInvite);
                  },
                  text: context.local.invite_another_friend,
                  width: MediaQuery.of(context).size.width,
                  textStyle:
                      ProtonStyles.body1Medium(color: ProtonColors.white),
                  backgroundColor: ProtonColors.protonBlue,
                  borderColor: ProtonColors.protonBlue,
                  height: 55),
              const SizedBox(height: 8),
              ButtonV5(
                  onPressed: () async {
                    Navigator.of(context).pop();
                  },
                  text: context.local.close,
                  width: MediaQuery.of(context).size.width,
                  textStyle:
                      ProtonStyles.body1Medium(color: ProtonColors.textNorm),
                  backgroundColor: ProtonColors.interActionWeakDisable,
                  borderColor: ProtonColors.interActionWeakDisable,
                  height: 55),
            ]))
      ]);
    });
  }

  Widget buildSendInvite(BuildContext context) {
    return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
      return Column(mainAxisSize: MainAxisSize.min, children: [
        Transform.translate(
            offset: const Offset(0, -20),
            child: Column(children: [
              Assets.images.icon.user.applyThemeIfNeeded(context).image(
                    fit: BoxFit.fill,
                    width: 240,
                    height: 167,
                  ),
              Text(
                viewModel.isWalletEarlyAccess()
                    ? context.local.exclusive_invites
                    : context.local.invites,
                style: ProtonStyles.headline(color: ProtonColors.textNorm),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                viewModel.isWalletEarlyAccess()
                    ? context.local.exclusive_invites_content
                    : context.local.invites_content,
                style: ProtonStyles.body2Regular(color: ProtonColors.textWeak),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              !viewModel.initialized
                  ? Padding(
                      padding: EdgeInsets.symmetric(vertical: 5),
                      child:
                          CustomCardLoadingBuilder(height: 74).build(context),
                    )
                  : DropdownButtonV2(
                      width: MediaQuery.of(context).size.width,
                      labelText: context.local.send_from_email,
                      title: context.local.choose_your_email,
                      items: viewModel.userAddresses,
                      itemsText:
                          viewModel.userAddresses.map((e) => e.email).toList(),
                      valueNotifier: viewModel.userAddressValueNotifier,
                      border: Border.all(
                        color: ProtonColors.interActionWeakDisable,
                      ),
                      padding: const EdgeInsets.only(
                          left: defaultPadding, right: 8, top: 12, bottom: 12),
                    ),
              !viewModel.initialized
                  ? Padding(
                      padding: EdgeInsets.symmetric(vertical: 5),
                      child:
                          CustomCardLoadingBuilder(height: 74).build(context),
                    )
                  : GestureDetector(
                      onTap: () {
                        EmailAutoCompleteSheet.show(
                            context, viewModel.contactsEmails, (selectedEmail) {
                          setState(() {
                            viewModel.emailController.text = selectedEmail;
                          });
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 4,
                        ),
                        decoration: BoxDecoration(
                            color: ProtonColors.backgroundSecondary,
                            borderRadius:
                                const BorderRadius.all(Radius.circular(18.0)),
                            border: Border.all(
                              color: ProtonColors.interActionWeakDisable,
                            )),
                        child: TextFormField(
                          enabled: false,
                          focusNode: FocusNode(),
                          controller: viewModel.emailController,
                          style: ProtonStyles.body1Medium(
                              color: ProtonColors.textNorm),
                          decoration: InputDecoration(
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                            labelText: context.local.your_friend_email,
                            labelStyle: ProtonStyles.body2Regular(
                                color: ProtonColors.textWeak, fontSize: 15.0),
                            hintText: context.local.you_can_invite_any,
                            hintStyle: ProtonStyles.body2Regular(
                                color: ProtonColors.textHint),
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
              const SizedBox(height: 20),
              !viewModel.initialized
                  ? const CustomCardLoadingBuilder(height: 50).build(context)
                  : ButtonV6(
                      onPressed: () async {
                        final email = viewModel.emailController.text;
                        if (email.isNotEmpty) {
                          final bool success =
                              await viewModel.sendExclusiveInvite(
                            viewModel.userAddressValueNotifier.value,
                            email,
                          );
                          if (context.mounted && success) {
                            viewModel
                                .updateState(SendInviteState.sendInviteSuccess);
                          }
                        }
                      },
                      text: context.local.send_invite_email,
                      width: MediaQuery.of(context).size.width,
                      textStyle: ProtonStyles.body1Medium(
                          color: viewModel.emailController.text.isEmpty
                              ? ProtonColors.textNorm
                              : ProtonColors.white),
                      backgroundColor: viewModel.emailController.text.isEmpty
                          ? ProtonColors.interActionWeakDisable
                          : ProtonColors.protonBlue,
                      borderColor: viewModel.emailController.text.isEmpty
                          ? ProtonColors.interActionWeakDisable
                          : ProtonColors.protonBlue,
                      enable: viewModel.emailController.text.isNotEmpty,
                      height: 55),
            ]))
      ]);
    });
  }
}
