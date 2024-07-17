import 'package:flutter/material.dart';
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
          ? Container(
              /// Key is necessary to identify the widget uniquely
              key: const ValueKey(
                'locked',
              ),
              color: Colors.grey,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      viewModel.error,
                      style: const TextStyle(color: Colors.red),
                    ),
                    const Center(
                      child: CircularProgressIndicator(),
                    ),
                    const SizedBox(height: 20),
                    ButtonV5(
                      text: "Try again",
                      width: 200,
                      height: 44,
                      onPressed: () async {
                        await viewModel.unlock();
                      },
                    ),
                    const SizedBox(height: 20),
                    ButtonV5(
                      text: "Logout",
                      width: 200,
                      height: 44,
                      onPressed: () async {
                        await viewModel.logout();
                      },
                    )
                  ],
                ),
              ),
            )
          : const SizedBox.shrink(
              key: ValueKey('unlocked'),
            ),
    );
  }
}
