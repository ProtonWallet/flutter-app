import 'dart:math';

import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:wallet/components/button.v5.dart';
import 'package:wallet/components/dropdown.button.v1.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:flutter/services.dart';
import 'package:wallet/scenes/receive/receive.viewmodel.dart';
import 'package:share_plus/share_plus.dart';
import 'package:wallet/theme/theme.font.dart';

import '../../constants/sizedbox.dart';

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
            statusBarIconBrightness: Brightness.dark, // For Android (dark icons)
            statusBarBrightness: Brightness.light, // For iOS (dark icons)
          ),
          backgroundColor: Theme.of(context).colorScheme.background,
          title: Text("Receive Bitcoin",
              style: FontManager.titleHeadline(
                  Theme.of(context).colorScheme.primary)),
          scrolledUnderElevation:
              0.0, // don't change background color when scroll down
        ),
        body: ListView(scrollDirection: Axis.vertical, children: [
          Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                Container(
                  width: MediaQuery.of(context).size.width - 52,
                  child: Text(
                    "Receive to Wallet",
                    style: FontManager.captionMedian(
                        Theme.of(context).colorScheme.primary),
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
                Container(
                  width: MediaQuery.of(context).size.width - 52,
                  child: Text(
                    "Account",
                    style: FontManager.captionMedian(
                        Theme.of(context).colorScheme.primary),
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
                Container(
                  width: MediaQuery.of(context).size.width - 52,
                  child: Text(
                    "Add amount",
                    style:
                        FontManager.captionMedian(ProtonColors.interactionNorm),
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                    width: MediaQuery.of(context).size.width - 52,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      // border: Border.all(color: Colors.black, width: 1.0),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Column(children: [
                      const SizedBox(height: 20),
                      Text("Your Personal Wallet Address",
                          style: FontManager.body1Median(
                              Theme.of(context).colorScheme.primary)),
                      const SizedBox(height: 20),
                      Container(
                        color: Theme.of(context).colorScheme.background,
                        padding: const EdgeInsets.all(10),
                        child: QrImageView(
                          size: min(MediaQuery.of(context).size.width, 260),
                          data: viewModel.address,
                          version: QrVersions.auto,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(viewModel.address,
                          style: FontManager.body2Regular(
                              Theme.of(context).colorScheme.secondary)),
                      const SizedBox(height: 20),
                      ButtonV5(
                          onPressed: () {
                            Clipboard.setData(
                                ClipboardData(text: viewModel.address));
                            const snackBar = SnackBar(
                              content: Text('Copied to Clipboard!'),
                            );
                            ScaffoldMessenger.of(context)
                                .showSnackBar(snackBar);
                          },
                          text: "Copy",
                          width: MediaQuery.of(context).size.width - 100,
                          textStyle:
                              FontManager.body1Median(ProtonColors.white),
                          height: 48),
                      SizedBoxes.box12,
                      ButtonV5(
                          onPressed: () {
                            Share.share(viewModel.address,
                                subject: "Receive Address");
                          },
                          text: "Share",
                          width: MediaQuery.of(context).size.width - 100,
                          backgroundColor: ProtonColors.white,
                          borderColor: ProtonColors.interactionNorm,
                          textStyle: FontManager.body1Median(
                              ProtonColors.interactionNorm),
                          height: 48),
                      const SizedBox(height: 20),
                    ])),
                const SizedBox(height: 20),
              ],
            ),
          )
        ]));
  }
}
