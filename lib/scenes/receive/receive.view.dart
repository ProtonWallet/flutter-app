import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:wallet/constants/assets.gen.dart';
import 'package:wallet/constants/constants.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/constants/sizedbox.dart';
import 'package:wallet/constants/text.style.dart';
import 'package:wallet/helper/common_helper.dart';
import 'package:wallet/l10n/generated/locale.dart';
import 'package:wallet/scenes/components/button.v5.dart';
import 'package:wallet/scenes/components/custom.header.dart';
import 'package:wallet/scenes/components/custom.tooltip.dart';
import 'package:wallet/scenes/components/wallet.account.dropdown.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/scenes/receive/receive.viewmodel.dart';

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
              color: ProtonColors.backgroundNorm,
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
                            style: ProtonStyles.body2Regular(
                                color: ProtonColors.textWeak),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
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
                                    if (viewModel.initialized)
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
                                      child: viewModel.initialized &&
                                              !viewModel.loadingAddress
                                          ? QrImageView(
                                              size: min(
                                                  MediaQuery.of(context)
                                                      .size
                                                      .width,
                                                  200),
                                              data: viewModel.currentAddress
                                                      ?.address ??
                                                  "",
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
                                            style: ProtonStyles.body2Medium(
                                                color: ProtonColors.textNorm),
                                          ),
                                          const SizedBox(width: 4),
                                          Assets.images.icon.icInfoCircleDark
                                              .svg(
                                                  fit: BoxFit.fill,
                                                  width: 20,
                                                  height: 20),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 6,
                                    ),
                                    if (viewModel.initialized &&
                                        !viewModel.loadingAddress)
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
                                                  viewModel.currentAddress
                                                          ?.address ??
                                                      "",
                                                  style:
                                                      ProtonStyles.body2Regular(
                                                          color: ProtonColors
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
                                                                  .currentAddress
                                                                  ?.address ??
                                                              ""));
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
                                    if (viewModel.warnUnusedAddress)
                                      Text(
                                        S
                                            .of(context)
                                            .warn_you_create_too_many_unused_address,
                                        style: ProtonStyles.body2Regular(
                                            color: ProtonColors.signalError),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        textAlign: TextAlign.center,
                                      ),
                                    if (viewModel.tooManyUnusedAddress)
                                      Text(
                                        S
                                            .of(context)
                                            .you_can_not_create_too_many_unused_address,
                                        style: ProtonStyles.body2Regular(
                                            color: ProtonColors.signalError),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        textAlign: TextAlign.center,
                                      ),
                                    // const SizedBox(height: 10),
                                    // Text(
                                    //   "(Debug) AddressIndex: ${viewModel.currentAddress?.index ?? -1}",
                                    //   style: ProtonStyles.body2Regular(color:
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
                                Share.share(
                                    viewModel.currentAddress?.address ?? "",
                                    subject: S.of(context).receive_address);
                              },
                              text: S.of(context).share_address_button,
                              width: MediaQuery.of(context).size.width,
                              backgroundColor: ProtonColors.protonBlue,
                              textStyle: ProtonStyles.body1Medium(
                                  color: ProtonColors.textInverted),
                              height: 48),
                          SizedBoxes.box12,
                          ButtonV5(
                            onPressed: () async {
                              viewModel.generateNewAddress();
                            },
                            text: S.of(context).generate_new_address,
                            width: MediaQuery.of(context).size.width,
                            textStyle: ProtonStyles.body1Medium(
                                color: ProtonColors.textNorm),
                            backgroundColor: ProtonColors.interActionWeak,
                            borderColor: ProtonColors.interActionWeak,
                            height: 48,
                            enable: !viewModel.loadingAddress,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ]),
            )));
  }
}
