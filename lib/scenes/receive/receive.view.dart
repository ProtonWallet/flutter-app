import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:wallet/components/alert.custom.dart';
import 'package:wallet/components/bottom.sheets/placeholder.dart';
import 'package:wallet/components/button.v5.dart';
import 'package:wallet/components/close.button.v1.dart';
import 'package:wallet/components/underline.dart';
import 'package:wallet/components/wallet.account.dropdown.dart';
import 'package:wallet/constants/constants.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/constants/sizedbox.dart';
import 'package:wallet/helper/common_helper.dart';
import 'package:wallet/provider/proton.wallet.provider.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:flutter/services.dart';
import 'package:wallet/scenes/receive/receive.viewmodel.dart';
import 'package:share_plus/share_plus.dart';
import 'package:wallet/theme/theme.font.dart';
import 'package:wallet/l10n/generated/locale.dart';

class ReceiveView extends ViewBase<ReceiveViewModel> {
  const ReceiveView(ReceiveViewModel viewModel)
      : super(viewModel, const Key("ReceiveView"));

  @override
  Widget buildWithViewModel(
      BuildContext context, ReceiveViewModel viewModel, ViewSize viewSize) {
    return Scaffold(
        backgroundColor: Colors.transparent,
        body: Container(
            height: double.infinity,
            decoration: BoxDecoration(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(24.0)),
              color: ProtonColors.backgroundProton,
            ),
            child: Padding(
                padding: const EdgeInsets.all(defaultPadding),
                child: Column(children: [
                  Expanded(
                      child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Align(
                            alignment: Alignment.centerLeft,
                            child: CloseButtonV1(onPressed: () {
                              Navigator.of(context).pop();
                            })),
                        Text(
                          S.of(context).receive_bitcoin,
                          style: FontManager.body1Median(ProtonColors.textNorm),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          S.of(context).receive_desc,
                          style:
                              FontManager.body2Regular(ProtonColors.textWeak),
                          textAlign: TextAlign.center,
                        ),
                        if (viewModel.hasEmailIntegration == true)
                          Column(children: [
                            const SizedBox(height: 10),
                            AlertCustom(
                              content: S
                                  .of(context)
                                  .receive_email_integration_alert_content,
                              learnMore: Underline(
                                  onTap: () {
                                    CustomPlaceholder.show(context);
                                  },
                                  color: ProtonColors.purple1Text,
                                  child: Text(S.of(context).learn_more,
                                      style: FontManager.body2Median(
                                          ProtonColors.purple1Text))),
                              leadingWidget: SvgPicture.asset(
                                  "assets/images/icon/send_2.svg",
                                  fit: BoxFit.fill,
                                  width: 30,
                                  height: 30),
                              border: Border.all(
                                color: Colors.transparent,
                                width: 0,
                              ),
                              backgroundColor: ProtonColors.purple1Background,
                              color: ProtonColors.purple1Text,
                            ),
                            const SizedBox(height: 10),
                          ]),
                        const SizedBox(height: 14),
                        Container(
                            width: MediaQuery.of(context).size.width,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: ProtonColors.white,
                              // border: Border.all(color: Colors.black, width: 1.0),
                              borderRadius: BorderRadius.circular(24.0),
                            ),
                            child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const SizedBox(height: 10),
                                  if (Provider.of<ProtonWalletProvider>(context)
                                          .protonWallet
                                          .currentAccount ==
                                      null)
                                    Column(children: [
                                      WalletAccountDropdown(
                                          labelText: S
                                              .of(context)
                                              .receive_to,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width -
                                              defaultPadding * 2,
                                          accounts:
                                              Provider.of<ProtonWalletProvider>(
                                                      context)
                                                  .protonWallet
                                                  .currentAccounts,
                                          valueNotifier: viewModel.initialized
                                              ? viewModel.accountValueNotifier
                                              : ValueNotifier(Provider.of<
                                                          ProtonWalletProvider>(
                                                      context)
                                                  .protonWallet
                                                  .currentAccounts
                                                  .first)),
                                      const Divider(
                                        thickness: 0.2,
                                        height: 1,
                                      ),
                                    ]),
                                  Container(
                                    color: ProtonColors.white,
                                    padding: const EdgeInsets.all(10),
                                    child: QrImageView(
                                      size: min(
                                          MediaQuery.of(context).size.width,
                                          200),
                                      data: viewModel.address,
                                      version: QrVersions.auto,
                                    ),
                                  ),
                                  Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                            width: min(
                                                MediaQuery.of(context)
                                                        .size
                                                        .width -
                                                    defaultPadding * 2 -
                                                    50,
                                                200),
                                            child: Text(
                                              viewModel.address,
                                              style: FontManager.body2Regular(
                                                  ProtonColors.textWeak),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              textAlign: TextAlign.center,
                                            )),
                                        GestureDetector(
                                            onTap: () {
                                              Clipboard.setData(ClipboardData(
                                                  text: viewModel.address));
                                              CommonHelper.showSnackbar(context,
                                                  S.of(context).copied_address);
                                            },
                                            child: Icon(
                                              Icons.copy_rounded,
                                              size: 20,
                                              color: ProtonColors.textWeak,
                                            ))
                                      ]),
                                  const SizedBox(height: 10),
                                  // TODO:: remove this debug output
                                  Text(
                                    "(Debug) AddressIndex: ${viewModel.addressIndex}",
                                    style: FontManager.body2Regular(
                                        ProtonColors.textWeak),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 20),
                                ])),
                      ],
                    ),
                  )),
                  Column(
                    children: [
                      ButtonV5(
                          onPressed: () {
                            Share.share(viewModel.address,
                                subject: S.of(context).receive_address);
                          },
                          text: S.of(context).share_address_button,
                          width: MediaQuery.of(context).size.width,
                          backgroundColor: ProtonColors.protonBlue,
                          textStyle:
                              FontManager.body1Median(ProtonColors.white),
                          height: 48),
                      SizedBoxes.box12,
                      GestureDetector(
                        onTap: () {
                          viewModel.getAddress();
                        },
                        child: Container(
                            margin: const EdgeInsets.only(top: 5),
                            width: MediaQuery.of(context).size.width,
                            height: 48,
                            child: Text(
                              S.of(context).generate_new_address,
                              style: FontManager.body1Median(
                                  ProtonColors.textWeak),
                              textAlign: TextAlign.center,
                            )),
                      ),
                    ],
                  )
                ]))));
  }
}
