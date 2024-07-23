import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wallet/constants/constants.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/constants/proton.links.dart';
import 'package:wallet/constants/sizedbox.dart';
import 'package:wallet/helper/common_helper.dart';
import 'package:wallet/l10n/generated/locale.dart';
import 'package:wallet/scenes/components/alert.custom.dart';
import 'package:wallet/scenes/components/button.v5.dart';
import 'package:wallet/scenes/components/custom.header.dart';
import 'package:wallet/scenes/components/custom.tooltip.dart';
import 'package:wallet/scenes/components/wallet.account.dropdown.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/scenes/receive/receive.viewmodel.dart';
import 'package:wallet/theme/theme.font.dart';

class ReceiveView extends ViewBase<ReceiveViewModel> {
  const ReceiveView(ReceiveViewModel viewModel)
      : super(viewModel, const Key("ReceiveView"));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.transparent,
        body: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(24.0)),
              color: ProtonColors.backgroundProton,
            ),
            child: SafeArea(
              child: Column(children: [
                CustomHeader(
                  title: S.of(context).receive_bitcoin,
                  buttonDirection: AxisDirection.left,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(
                      left: defaultPadding,
                      right: defaultPadding,
                      bottom: 20,
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          Text(
                            S.of(context).receive_desc,
                            style:
                                FontManager.body2Regular(ProtonColors.textWeak),
                            textAlign: TextAlign.center,
                          ),
                          Column(children: [
                            const SizedBox(height: 10),
                            if (viewModel.initialized)
                              viewModel.hasEmailIntegration
                                  ? AlertCustom(
                                      content: S
                                          .of(context)
                                          .receive_email_integration_alert_content(
                                              viewModel.bitcoinViaEmailAddress),
                                      learnMore: GestureDetector(
                                          onTap: () {
                                            launchUrl(
                                                Uri.parse(bveAcitvedLink));
                                          },
                                          child: Text(S.of(context).learn_more,
                                              style: FontManager.body2Regular(
                                                  ProtonColors.protonBlue))),
                                      leadingWidget: SvgPicture.asset(
                                          "assets/images/icon/bve_enable.svg",
                                          fit: BoxFit.fill,
                                          width: 30,
                                          height: 30),
                                      border: Border.all(
                                        color: Colors.transparent,
                                        width: 0,
                                      ),
                                      backgroundColor: ProtonColors.white,
                                      color: ProtonColors.textNorm,
                                    )
                                  : AlertCustom(
                                      content: S
                                          .of(context)
                                          .bitcoin_via_email_not_active_desc,
                                      learnMore: GestureDetector(
                                          onTap: () {
                                            launchUrl(
                                                Uri.parse(bveInAcitvedLink));
                                          },
                                          child: Text(S.of(context).learn_more,
                                              style: FontManager.body2Regular(
                                                  ProtonColors.protonBlue))),
                                      leadingWidget: SvgPicture.asset(
                                          "assets/images/icon/bve_disable.svg",
                                          fit: BoxFit.fill,
                                          width: 30,
                                          height: 30),
                                      border: Border.all(
                                        color: Colors.transparent,
                                        width: 0,
                                      ),
                                      backgroundColor: ProtonColors.white,
                                      color: ProtonColors.textNorm,
                                    ),
                            const SizedBox(height: 10),
                          ]),
                          const SizedBox(height: 14),
                          Container(
                              width: MediaQuery.of(context).size.width,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                color: ProtonColors.white,
                                // border: Border.all(color: Colors.black, width: 1.0),
                                borderRadius: BorderRadius.circular(24.0),
                              ),
                              child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const SizedBox(height: 10),
                                    if (viewModel.isWalletView &&
                                        viewModel.initialized &&
                                        viewModel.accountsCount > 1)
                                      Column(children: [
                                        WalletAccountDropdown(
                                            labelText: S.of(context).receive_to,
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width -
                                                defaultPadding * 2,
                                            accounts: viewModel
                                                    .walletData?.accounts ??
                                                [],
                                            valueNotifier:
                                                viewModel.accountValueNotifier),
                                        const Divider(
                                          thickness: 0.2,
                                          height: 1,
                                        ),
                                      ]),
                                    Container(
                                      color: ProtonColors.white,
                                      padding: const EdgeInsets.all(10),
                                      child: viewModel.initialized
                                          ? QrImageView(
                                              size: min(
                                                  MediaQuery.of(context)
                                                      .size
                                                      .width,
                                                  200),
                                              data: viewModel.address,
                                            )
                                          : CircularProgressIndicator(
                                              color: ProtonColors.protonBlue,
                                            ),
                                    ),
                                    CustomTooltip(
                                      preferredDirection: AxisDirection.down,
                                      message:
                                          S.of(context).bitcoin_address_desc,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            S.of(context).bitcoin_address,
                                            style: FontManager.body2Median(
                                                ProtonColors.textNorm),
                                          ),
                                          const SizedBox(width: 4),
                                          SvgPicture.asset(
                                            "assets/images/icon/ic-info-circle-dark.svg",
                                            fit: BoxFit.fill,
                                            width: 20,
                                            height: 20,
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 6,
                                    ),
                                    if (viewModel.initialized)
                                      Row(
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
                                                  style:
                                                      FontManager.body2Regular(
                                                          ProtonColors
                                                              .textWeak),
                                                  maxLines: 5,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  textAlign: TextAlign.center,
                                                )),
                                            GestureDetector(
                                                onTap: () {
                                                  Clipboard.setData(
                                                      ClipboardData(
                                                          text: viewModel
                                                              .address));
                                                  CommonHelper.showSnackbar(
                                                      context,
                                                      S
                                                          .of(context)
                                                          .copied_address);
                                                },
                                                child: Icon(
                                                  Icons.copy_rounded,
                                                  size: 20,
                                                  color: ProtonColors.textWeak,
                                                ))
                                          ]),
                                    const SizedBox(height: 10),
                                    if (viewModel.tooManyUnusedAddress)
                                      Text(
                                        S
                                            .of(context)
                                            .you_can_not_create_too_many_unused_address,
                                        style: FontManager.body2Regular(
                                            ProtonColors.signalError),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        textAlign: TextAlign.center,
                                      ),
                                    // const SizedBox(height: 10),
                                    // Text(
                                    //   "(Debug) AddressIndex: ${viewModel.addressIndex}",
                                    //   style: FontManager.body2Regular(
                                    //       ProtonColors.textWeak),
                                    //   maxLines: 2,
                                    //   overflow: TextOverflow.ellipsis,
                                    //   textAlign: TextAlign.center,
                                    // ),
                                    const SizedBox(height: 20),
                                  ])),
                          SizedBoxes.box24,
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
                          ButtonV5(
                              onPressed: () async {
                                viewModel.generateNewAddress();
                              },
                              text: S.of(context).generate_new_address,
                              width: MediaQuery.of(context).size.width,
                              textStyle: FontManager.body1Median(
                                  ProtonColors.textNorm),
                              backgroundColor: ProtonColors.textWeakPressed,
                              borderColor: ProtonColors.textWeakPressed,
                              height: 48),
                        ],
                      ),
                    ),
                  ),
                ),
              ]),
            )));
  }
}
