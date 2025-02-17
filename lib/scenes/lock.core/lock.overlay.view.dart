import 'package:flutter/material.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/scenes/lock.core/lock.overlay.viewmodel.dart';

class LockCoreView extends ViewBase<LockCoreViewModel> {
  const LockCoreView(LockCoreViewModel viewModel)
      : super(viewModel, const Key("LockCoreView"));

  @override
  Widget build(BuildContext context) {
    return const SizedBox();
  }
}
