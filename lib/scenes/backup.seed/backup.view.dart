import 'package:flutter/material.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/helper/common_helper.dart';
import 'package:wallet/scenes/backup.seed/backup.introduce.view.dart';
import 'package:wallet/scenes/backup.seed/backup.mnemonic.view.dart';
import 'package:wallet/scenes/backup.seed/backup.viewmodel.dart';
import 'package:wallet/scenes/components/close.button.v1.dart';
import 'package:wallet/scenes/components/custom.header.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/scenes/recovery/recovery.auth.dialog.dart';

class SetupBackupView extends ViewBase<SetupBackupViewModel> {
  const SetupBackupView(SetupBackupViewModel viewModel)
      : super(viewModel, const Key("SetupBackupView"));

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _handleFlowState(context);
    });

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24.0)),
          color: ProtonColors.white,
        ),
        child: SafeArea(
          child: Column(children: [
            CustomHeader(
              button: CloseButtonV1(
                  backgroundColor: ProtonColors.backgroundProton,
                  onPressed: () {
                    Navigator.of(context).pop();
                  }),
              buttonDirection: AxisDirection.left,
            ),
            Expanded(
              child: viewModel.inIntroduce
                  ? BackupIntroduceView(onPressed: viewModel.tryLoadMnemonic)
                  : BackupMnemonicView(
                      itemList: viewModel.itemList,
                      walletName: viewModel.walletName,
                      onPressed: viewModel.setBackup,
                    ),
            ),
          ]),
        ),
      ),
    );
  }

  void _handleFlowState(BuildContext context) {
    if (viewModel.flowState == SetupBackupState.auth) {
      showAuthBottomSheet(
        context,
        viewModel.twofaStatus,
        viewModel.viewSeed,
        viewModel.reset,
      );
      viewModel.flowState = SetupBackupState.authShown;
    } else if (viewModel.flowState == SetupBackupState.done) {
      viewModel.setIntroduce(introduce: false);
      viewModel.disableScreenShot();
    }

    if (viewModel.error.isNotEmpty) {
      CommonHelper.showErrorDialog(viewModel.error);
      viewModel.error = "";
    }
  }
}
