import 'package:flutter/material.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/helper/common_helper.dart';
import 'package:wallet/l10n/generated/locale.dart';
import 'package:wallet/scenes/backup.seed/backup.introduce.view.dart';
import 'package:wallet/scenes/backup.seed/backup.mnemonic.view.dart';
import 'package:wallet/scenes/backup.seed/backup.viewmodel.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/scenes/recovery/recovery.auth.dialog.dart';
import 'package:wallet/theme/theme.font.dart';

class SetupBackupView extends ViewBase<SetupBackupViewModel> {
  const SetupBackupView(SetupBackupViewModel viewModel)
      : super(viewModel, const Key("SetupBackupView"));

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _handleFlowState(context);
    });

    return Scaffold(
      backgroundColor: ProtonColors.backgroundProton,
      appBar: AppBar(
        surfaceTintColor: ProtonColors.backgroundProton,
        backgroundColor: ProtonColors.backgroundProton,
        title: Text(
          S.of(context).mnemonic_backup_page_title,
          style: FontManager.body2Median(ProtonColors.textNorm),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: ProtonColors.textNorm),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: viewModel.inIntroduce
          ? BackupIntroduceView(onPressed: viewModel.tryLoadMnemonic)
          : BackupMnemonicView(
              itemList: viewModel.itemList,
              onPressed: viewModel.setBackup,
            ),
    );
  }

  void _handleFlowState(BuildContext context) {
    if (viewModel.flowState == SetupBackupState.auth) {
      showAuthDialog(
        context,
        viewModel.twofaStatus,
        viewModel.viewSeed,
        viewModel.reset,
      );
    } else if (viewModel.flowState == SetupBackupState.done) {
      viewModel.setIntroduce(introduce: false);
    }

    if (viewModel.error.isNotEmpty) {
      CommonHelper.showErrorDialog(viewModel.error);
      viewModel.error = "";
    }
  }
}
