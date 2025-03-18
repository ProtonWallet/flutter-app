import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:wallet/constants/constants.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/constants/sizedbox.dart';
import 'package:wallet/constants/text.style.dart';
import 'package:wallet/helper/extension/build.context.extension.dart';
import 'package:wallet/helper/local_toast.dart';
import 'package:wallet/l10n/generated/locale.dart';
import 'package:wallet/scenes/components/button.v5.dart';
import 'package:wallet/scenes/components/custom.expansion.tile.dart';
import 'package:wallet/scenes/components/page.layout.v2.dart';
import 'package:wallet/scenes/components/wallet.account.dropdown.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/scenes/core/view.navigatior.identifiers.dart';
import 'package:wallet/scenes/receive/receive.viewmodel.dart';

class ReceiveView extends ViewBase<ReceiveViewModel> {
  const ReceiveView(ReceiveViewModel viewModel)
      : super(viewModel, const Key("ReceiveView"));

  @override
  Widget build(BuildContext context) {
    final GlobalKey shareButtonKey = GlobalKey();
    final qrCodeSize = min(context.width, 180.0);
    final loadingBoxSize = qrCodeSize + 90.0;

    return PageLayoutV2(
      scrollController: viewModel.scrollController,
      child: Column(children: [
        Column(children: [
          Text(
            S.of(context).receive_bitcoin,
            style: ProtonStyles.headline(color: ProtonColors.textNorm),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Text(
            S.of(context).receive_desc,
            style: ProtonStyles.body2Regular(
              color: ProtonColors.textWeak,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 26),
          Container(
            width: context.width,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: ProtonColors.backgroundSecondary,
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
                      width: context.width - defaultPadding * 2,
                      accounts: viewModel.walletData?.accounts ?? [],
                      valueNotifier: viewModel.accountValueNotifier,
                    ),
                    const Divider(thickness: 0.2, height: 1),
                  ]),
                Container(
                  color: ProtonColors.backgroundSecondary,
                  padding: const EdgeInsets.all(10),
                  child: viewModel.initialized && !viewModel.loadingAddress
                      ? QrImageView(
                          size: qrCodeSize,
                          data: viewModel.currentAddress?.address ?? "",
                          eyeStyle: QrEyeStyle(
                            eyeShape: QrEyeShape.square,
                            color: ProtonColors.textNorm,
                          ),
                          dataModuleStyle: QrDataModuleStyle(
                            dataModuleShape: QrDataModuleShape.square,
                            color: ProtonColors.textNorm,
                          ),
                        )
                      : SizedBox(
                          height: loadingBoxSize,
                          child: Center(
                            child: SizedBox(
                              width: 50,
                              height: 50,
                              child: CircularProgressIndicator(
                                color: ProtonColors.protonBlue,
                                strokeWidth: 6.0,
                              ),
                            ),
                          ),
                        ),
                ),
                const SizedBox(height: 6),
                if (viewModel.initialized && !viewModel.loadingAddress)
                  GestureDetector(
                    onTap: () {
                      Clipboard.setData(ClipboardData(
                        text: viewModel.currentAddress?.address ?? "",
                      ));
                      LocalToast.showToast(
                        context,
                        context.local.copied_address,
                      );
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: min(
                            context.width - defaultPadding * 2 - 50,
                            200,
                          ),
                          child: Text(
                            viewModel.currentAddress?.address ?? "",
                            style: ProtonStyles.body2Regular(
                              color: ProtonColors.textWeak,
                            ),
                            maxLines: 5,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.copy_rounded,
                          size: 20,
                          color: ProtonColors.textWeak,
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 10),
                if (viewModel.warnUnusedAddress)
                  Text(
                    context.local.warn_you_create_too_many_unused_address,
                    style: ProtonStyles.body2Regular(
                      color: ProtonColors.notificationError,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                if (viewModel.tooManyUnusedAddress)
                  Text(
                    context.local.you_can_not_create_too_many_unused_address,
                    style: ProtonStyles.body2Regular(
                      color: ProtonColors.notificationError,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                const SizedBox(height: 20),
              ],
            ),
          ),
          SizedBoxes.box24,
          ButtonV5(
            key: shareButtonKey,
            onPressed: () {
              final box = shareButtonKey.currentContext?.findRenderObject()
                  as RenderBox?;
              Share.share(
                viewModel.currentAddress?.address ?? "",
                subject: context.local.receive_address,
                sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
              );
            },
            text: S.of(context).share_address_button,
            width: context.width,
            backgroundColor: ProtonColors.protonBlue,
            textStyle: ProtonStyles.body1Medium(
              color: ProtonColors.textInverted,
            ),
            height: 55,
          ),
          SizedBoxes.box12,
          ButtonV5(
            onPressed: () async {
              viewModel.generateNewAddress();
            },
            text: S.of(context).generate_new_address,
            width: context.width,
            textStyle: ProtonStyles.body1Medium(
              color: ProtonColors.textNorm,
            ),
            backgroundColor: ProtonColors.interActionWeakDisable,
            borderColor: ProtonColors.interActionWeakDisable,
            height: 55,
            enable: !viewModel.loadingAddress,
          ),
          if (viewModel.isImportPaperWallet())
            Column(
              children: [
                SizedBoxes.box12,
                CustomExpansionTile(
                    title: Transform.translate(
                      offset: const Offset(-10, 0),
                      child: Text(S.of(context).other_options,
                          style: ProtonStyles.body2Medium(
                              color: ProtonColors.textWeak)),
                    ),
                    scrollController: viewModel.scrollController,
                    children: [
                      const SizedBox(
                        height: 8,
                      ),
                      ButtonV5(
                        onPressed: () async {
                          viewModel.move(NavID.importPaperWallet);
                        },
                        text: S.of(context).import_paper_wallet,
                        width: context.width,
                        textStyle: ProtonStyles.body1Medium(
                          color: ProtonColors.textNorm,
                        ),
                        backgroundColor: ProtonColors.interActionWeakDisable,
                        borderColor: ProtonColors.interActionWeakDisable,
                        height: 55,
                        enable: !viewModel.loadingAddress,
                      ),
                    ]),
                const SizedBox(height: defaultPadding),
              ],
            ),
        ]),
      ]),
    );
  }
}
