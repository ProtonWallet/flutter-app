import 'dart:math';

import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:wallet/components/button.v5.dart';
import 'package:wallet/components/dropdown.button.v1.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/constants/sizedbox.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:flutter/services.dart';
import 'package:wallet/scenes/receive/receive.viewmodel.dart';
import 'package:share_plus/share_plus.dart';
import 'package:wallet/theme/theme.font.dart';
import 'package:wallet/l10n/generated/locale.dart';

class ReceiveView extends ViewBase<ReceiveViewModel> {
  ReceiveView(ReceiveViewModel viewModel)
      : super(viewModel, const Key("ReceiveView"));

  @override
  Widget buildWithViewModel(
      BuildContext context, ReceiveViewModel viewModel, ViewSize viewSize) {
    return Scaffold(
        appBar: AppBar(
          systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness:
                Brightness.dark, // For Android (dark icons)
            statusBarBrightness: Brightness.light, // For iOS (dark icons)
          ),
          backgroundColor: ProtonColors.backgroundProton,
          title: Text(S.of(context).receive_bitcoin,
              style: FontManager.titleHeadline(
                  ProtonColors.textNorm)),
          scrolledUnderElevation:
              0.0, // don't change background color when scroll down
        ),
        body: Stack(children: [
          ListView(scrollDirection: Axis.vertical, children: [
            Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  SizedBox(
                    width: MediaQuery.of(context).size.width - 52,
                    child: Text(
                      S.of(context).receive_to_wallet,
                      style: FontManager.captionMedian(
                          ProtonColors.textNorm),
                    ),
                  ),
                  const SizedBox(height: 5),
                  if (viewModel.userWallets.isNotEmpty)
                    DropdownButtonV1(
                      width: MediaQuery.of(context).size.width - 52,
                      items: viewModel.userWallets,
                      valueNotifier: viewModel.valueNotifier,
                      itemsText:
                          viewModel.userWallets.map((v) => v.name).toList(),
                    ),
                  const SizedBox(height: 5),
                  SizedBox(
                    width: MediaQuery.of(context).size.width - 52,
                    child: Text(
                      S.of(context).account_label,
                      style: FontManager.captionMedian(
                          ProtonColors.textNorm),
                    ),
                  ),
                  const SizedBox(height: 5),
                  if (viewModel.userAccounts.isNotEmpty)
                    DropdownButtonV1(
                      width: MediaQuery.of(context).size.width - 52,
                      items: viewModel.userAccounts,
                      valueNotifier: viewModel.valueNotifierForAccount,
                      itemsText: viewModel.userAccounts
                          .map((v) => "${v.labelDecrypt} (${v.derivationPath})")
                          .toList(),
                    ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: MediaQuery.of(context).size.width - 52,
                    child: Text(
                      S.of(context).add_amount,
                      style: FontManager.captionMedian(
                          ProtonColors.interactionNorm),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                      width: MediaQuery.of(context).size.width - 52,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: ProtonColors.backgroundSecondary,
                        // border: Border.all(color: Colors.black, width: 1.0),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Column(children: [
                        const SizedBox(height: 14),
                        Text(S.of(context).your_personal_addr,
                            style: FontManager.body1Median(
                                ProtonColors.textNorm)),
                        const SizedBox(height: 14),
                        Container(
                          color: ProtonColors.white,
                          padding: const EdgeInsets.all(10),
                          child: QrImageView(
                            size: min(MediaQuery.of(context).size.width, 260),
                            data: viewModel.address,
                            version: QrVersions.auto,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(viewModel.address,
                            style: FontManager.body2Regular(
                                ProtonColors.textWeak)),
                        const SizedBox(height: 10),
                      ])),
                ],
              ),
            )
          ]),
          Container(
              padding: const EdgeInsets.only(bottom: 50),
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height -
                  56 -
                  MediaQuery.of(context).padding.top,
              // AppBar default height is 56
              margin: const EdgeInsets.only(left: 40, right: 40),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ButtonV5(
                        onPressed: () {
                          Clipboard.setData(
                              ClipboardData(text: viewModel.address));
                          var snackBar = SnackBar(
                            content: Text(S.of(context).copied),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(snackBar);
                        },
                        text: S.of(context).copy_button,
                        width: MediaQuery.of(context).size.width,
                        textStyle: FontManager.body1Median(ProtonColors.white),
                        height: 48),
                    SizedBoxes.box12,
                    ButtonV5(
                        onPressed: () {
                          Share.share(viewModel.address,
                              subject: S.of(context).receive_address);
                        },
                        text: S.of(context).share_button,
                        width: MediaQuery.of(context).size.width,
                        backgroundColor: ProtonColors.white,
                        borderColor: ProtonColors.interactionNorm,
                        textStyle: FontManager.body1Median(
                            ProtonColors.interactionNorm),
                        height: 48),
                  ]))
        ]));
  }
}
