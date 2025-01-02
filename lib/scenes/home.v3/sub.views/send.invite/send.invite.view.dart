import 'package:card_loading/card_loading.dart';
import 'package:flutter/material.dart';
import 'package:wallet/constants/assets.gen.dart';
import 'package:wallet/constants/constants.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/constants/text.style.dart';
import 'package:wallet/l10n/generated/locale.dart';
import 'package:wallet/scenes/components/bottom.sheets/email.autocomplete.dart';
import 'package:wallet/scenes/components/button.v5.dart';
import 'package:wallet/scenes/components/button.v6.dart';
import 'package:wallet/scenes/components/close.button.v1.dart';
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
        buttonDirection: AxisDirection.left,
        padding: const EdgeInsets.all(0.0),
        button: CloseButtonV1(
            backgroundColor: ProtonColors.backgroundProton,
            onPressed: () {
              Navigator.of(context).pop();
            }),
      ),
      backgroundColor: ProtonColors.white,
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
              Assets.images.icon.paperPlane.image(
                fit: BoxFit.fill,
                width: 240,
                height: 167,
              ),
              const SizedBox(height: 20),
              Text(
                S
                    .of(context)
                    .invitation_sent_to(viewModel.emailController.text),
                style: ProtonStyles.subheadline(color: ProtonColors.textNorm),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                S.of(context).invitation_success_content,
                style: ProtonStyles.body2Regular(color: ProtonColors.textWeak),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 60),
              ButtonV5(
                  onPressed: () async {
                    viewModel.updateState(SendInviteState.sendInvite);
                  },
                  text: S.of(context).invite_another_friend,
                  width: MediaQuery.of(context).size.width,
                  textStyle:
                      ProtonStyles.body1Medium(color: ProtonColors.white),
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
                  textStyle:
                      ProtonStyles.body1Medium(color: ProtonColors.textNorm),
                  backgroundColor: ProtonColors.protonShades20,
                  borderColor: ProtonColors.protonShades20,
                  height: 48),
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
              Assets.images.icon.user.image(
                fit: BoxFit.fill,
                width: 240,
                height: 167,
              ),
              Text(
                S.of(context).exclusive_invites,
                style: ProtonStyles.subheadline(color: ProtonColors.textNorm),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                S.of(context).exclusive_invites_content,
                style: ProtonStyles.body2Regular(color: ProtonColors.textWeak),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              !viewModel.initialized
                  ? const Padding(
                      padding: EdgeInsets.symmetric(vertical: 5),
                      child: CardLoading(height: 74),
                    )
                  : DropdownButtonV2(
                      width: MediaQuery.of(context).size.width,
                      labelText: S.of(context).send_from_email,
                      title: S.of(context).choose_your_email,
                      items: viewModel.userAddresses,
                      itemsText:
                          viewModel.userAddresses.map((e) => e.email).toList(),
                      valueNotifier: viewModel.userAddressValueNotifier,
                      border: Border.all(color: ProtonColors.protonShades20),
                      padding: const EdgeInsets.only(
                          left: defaultPadding, right: 8, top: 12, bottom: 12),
                    ),
              !viewModel.initialized
                  ? const Padding(
                      padding: EdgeInsets.symmetric(vertical: 5),
                      child: CardLoading(height: 74),
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
                            color: ProtonColors.white,
                            borderRadius:
                                const BorderRadius.all(Radius.circular(18.0)),
                            border: Border.all(
                              color: ProtonColors.protonShades20,
                            )),
                        child: TextFormField(
                          enabled: false,
                          focusNode: FocusNode(),
                          controller: viewModel.emailController,
                          style: ProtonStyles.body1Medium(
                              color: ProtonColors.textNorm),
                          decoration: InputDecoration(
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                            labelText: S.of(context).your_friend_email,
                            labelStyle: ProtonStyles.body2Regular(
                                color: ProtonColors.textWeak, fontSize: 15.0),
                            hintText: S.of(context).you_can_invite_any,
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
                  ? const CardLoading(height: 50)
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
                      text: S.of(context).send_invite_email,
                      width: MediaQuery.of(context).size.width,
                      textStyle: ProtonStyles.body1Medium(
                          color: viewModel.emailController.text.isEmpty
                              ? ProtonColors.textNorm
                              : ProtonColors.white),
                      backgroundColor: viewModel.emailController.text.isEmpty
                          ? ProtonColors.protonShades20
                          : ProtonColors.protonBlue,
                      borderColor: viewModel.emailController.text.isEmpty
                          ? ProtonColors.protonShades20
                          : ProtonColors.protonBlue,
                      enable: viewModel.emailController.text.isNotEmpty,
                      height: 48),
            ]))
      ]);
    });
  }
}
