import 'package:flutter/material.dart';
import 'package:wallet/constants/assets.gen.dart';
import 'package:wallet/constants/constants.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/constants/text.style.dart';
import 'package:wallet/helper/extension/asset.gen.image.extension.dart';
import 'package:wallet/helper/extension/build.context.extension.dart';
import 'package:wallet/helper/extension/svg.gen.image.extension.dart';
import 'package:wallet/scenes/components/button.v5.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/scenes/lock/lock.overlay.viewmodel.dart';

class LockOverlayView extends ViewBase<LockViewModel> {
  const LockOverlayView(LockViewModel viewModel)
      : super(viewModel, const Key("LockOverlayView"));

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      transitionBuilder: (Widget child, Animation<double> animation) {
        return !viewModel.isLocked
            ? FadeTransition(opacity: animation, child: child)
            : child;
      },
      child: viewModel.isLocked
          ? SizedBox.expand(
              child: ColoredBox(
                /// Key is necessary to identify the widget uniquely
                key: const ValueKey(
                  'locked',
                ),
                color: ProtonColors.backgroundSecondary,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 264,
                        height: 54,
                        child: Assets
                            .images.walletCreation.protonWalletLogoLight
                            .applyThemeIfNeeded(context)
                            .svg(
                              fit: BoxFit.fitHeight,
                            ),
                      ),
                      Assets.images.icon.lock.applyThemeIfNeeded(context).image(
                            fit: BoxFit.fitHeight,
                            width: 240,
                            height: 167,
                          ),
                      Text(
                        viewModel.error,
                        style: ProtonStyles.body2Medium(
                            color: ProtonColors.notificationError),
                      ),
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: defaultPadding),
                        child: Visibility(
                          visible: viewModel.isLockTimerNeedUnlock,
                          maintainSize: true,
                          maintainAnimation: true,
                          maintainState: true,
                          child: ButtonV5(
                            text: context.local.unlock_app,
                            width: context.width,
                            height: 55,
                            backgroundColor: ProtonColors.protonBlue,
                            textStyle: ProtonStyles.body1Medium(
                              color: ProtonColors.white,
                            ),
                            onPressed: () async {
                              await viewModel.unlock();
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: defaultPadding),
                        child: Visibility(
                          visible: viewModel.isLockTimerNeedUnlock,
                          maintainSize: true,
                          maintainAnimation: true,
                          maintainState: true,
                          child: ButtonV5(
                            text: context.local.logout,
                            width: context.width,
                            height: 55,
                            backgroundColor: ProtonColors.interActionWeak,
                            borderColor: ProtonColors.interActionWeak,
                            textStyle: ProtonStyles.body1Medium(
                              color: ProtonColors.textNorm,
                            ),
                            onPressed: () async {
                              await viewModel.logout();
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          : const SizedBox.shrink(
              key: ValueKey('unlocked'),
            ),
    );
  }
}
