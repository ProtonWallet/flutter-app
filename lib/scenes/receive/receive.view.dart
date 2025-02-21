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
import 'package:wallet/scenes/components/custom.header.dart';
import 'package:wallet/scenes/components/custom.tooltip.dart';
import 'package:wallet/scenes/components/page.layout.v1.dart';
import 'package:wallet/scenes/components/wallet.account.dropdown.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/scenes/receive/receive.viewmodel.dart';

class ReceiveView extends ViewBase<ReceiveViewModel> {
  const ReceiveView(ReceiveViewModel viewModel)
      : super(viewModel, const Key("ReceiveView"));

  @override
  Widget build(BuildContext context) {
    return PageLayoutV1(
      headerWidget: CustomHeader(
        buttonDirection: AxisDirection.right,
        padding: const EdgeInsets.all(0.0),
      ),
      child: Column(children: [
        Column(
          children: [
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
                      const Divider(
                        thickness: 0.2,
                        height: 1,
                      ),
                    ]),
                  Container(
                    color: ProtonColors.backgroundSecondary,
                    padding: const EdgeInsets.all(10),
                    child: viewModel.initialized && !viewModel.loadingAddress
                        ? QrImageView(
                            size: min(context.width, 180),
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
                        : CircularProgressIndicator(
                            color: ProtonColors.protonBlue,
                          ),
                  ),
                  const SizedBox(
                    height: 6,
                  ),
                  if (viewModel.initialized && !viewModel.loadingAddress)
                    GestureDetector(
                      onTap: () {
                        Clipboard.setData(ClipboardData(
                            text: viewModel.currentAddress?.address ?? ""));
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
                          const SizedBox(
                            width: 4,
                          ),
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
              onPressed: () {
                Share.share(
                  viewModel.currentAddress?.address ?? "",
                  subject: context.local.receive_address,
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
              backgroundColor: ProtonColors.interActionWeak,
              borderColor: ProtonColors.interActionWeak,
              height: 55,
              enable: !viewModel.loadingAddress,
            ),
            const SizedBox(
              height: defaultPadding,
            ),
          ],
        ),
      ]),
    );
  }
}
