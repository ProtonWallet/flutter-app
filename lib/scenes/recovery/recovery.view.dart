import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wallet/constants/constants.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/constants/text.style.dart';
import 'package:wallet/helper/extension/build.context.extension.dart';
import 'package:wallet/managers/features/proton.recovery/proton.recovery.bloc.dart';
import 'package:wallet/managers/features/proton.recovery/proton.recovery.state.dart';
import 'package:wallet/scenes/components/back.button.v1.dart';
import 'package:wallet/scenes/components/custom.header.dart';
import 'package:wallet/scenes/components/page.layout.v1.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/scenes/recovery/recovery.auth.dialog.dart';
import 'package:wallet/scenes/recovery/recovery.disable.dialog.dart';
import 'package:wallet/scenes/recovery/recovery.mnemonic.dialog.dart';
import 'package:wallet/scenes/recovery/recovery.section.dart';
import 'package:wallet/scenes/recovery/recovery.viewmodel.dart';

class RecoveryView extends ViewBase<RecoveryViewModel> {
  const RecoveryView(RecoveryViewModel viewModel)
      : super(viewModel, const Key("RecoveryView"));

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => viewModel.protonRecoveryBloc,
      child: PageLayoutV1(
        headerWidget: CustomHeader(
          title: context.local.recovery,
          buttonDirection: AxisDirection.left,
          padding: const EdgeInsets.only(bottom: 10.0),
          button: BackButtonV1(onPressed: () {
            Navigator.of(context).pop();
          }),
        ),
        child: BlocListener<ProtonRecoveryBloc, ProtonRecoveryState>(
          listener: (context, state) {
            if (state.requireAuthModel.requireAuth) {
              showAuthBottomSheet(context, state.requireAuthModel.twofaStatus, (
                password,
                twofa,
              ) async {
                if (state.requireAuthModel.isDisable) {
                  viewModel.disableRecoverAuth(password, twofa);
                } else {
                  viewModel.enableRecoverAuth(password, twofa);
                }
              }, viewModel.stateReset);
            }

            if (state.mnemonic.isNotEmpty) {
              showMnemonicDialog(context, state.mnemonic, viewModel.stateReset);
            }
          },
          child: BlocSelector<ProtonRecoveryBloc, ProtonRecoveryState,
              ProtonRecoveryState>(
            selector: (state) {
              return state;
            },
            builder: (context, state) {
              return Column(
                children: [
                  const SizedBox(height: defaultPadding),

                  if (state.error.isNotEmpty)
                    Text(
                      state.error,
                      style: ProtonStyles.body2Regular(
                          color: ProtonColors.signalError),
                    ),

                  RecoverySection(
                    title: 'Recovery phrase',
                    description:
                        'Activate at least one data recovery method to make sure you can continue to access the contents of your Proton Account if you lose your password.',
                    isLoading: state.isLoading,
                    isSwitched: state.isRecoveryEnabled,
                    onChanged: (bool newValue) {
                      // try to disable recovery
                      if (!newValue) {
                        showDisableDialog(context, viewModel.disableRecovery);
                      } else {
                        viewModel.enableRecovery();
                      }
                    },
                  ),

                  const SizedBox(height: 8),
                  if (viewModel.showRecoverySeed)
                    RecoverySection(
                      title: 'Wallet recovery seed',
                      description:
                          'Your secret seed is the ONLY way to recover your fund if you lose access to the wallet',
                      logo: Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 16,
                        color: ProtonColors.textHint,
                      ),
                      warning: Icon(
                        Icons.info_outline_rounded,
                        color: ProtonColors.signalError,
                        size: 16,
                      ),
                      isLoading: false,
                    ),
                  const SizedBox(height: 8),

                  /// Recovery email and phone
                  if (viewModel.showRecoveryEmail)
                    RecoverySection(
                      title: 'Recovery email and phone',
                      description:
                          'Some explanation here, lorem ipsum dolor sit ametmconsectetur adipiscing',
                      logo: Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 16,
                        color: ProtonColors.textHint,
                      ),
                      warning: Icon(
                        Icons.info_outline_rounded,
                        color: ProtonColors.signalError,
                        size: 16,
                      ),
                      isLoading: false,
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
