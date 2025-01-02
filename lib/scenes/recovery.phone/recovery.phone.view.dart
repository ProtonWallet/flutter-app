import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wallet/constants/constants.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/constants/text.style.dart';
import 'package:wallet/l10n/generated/locale.dart';
import 'package:wallet/managers/features/proton.recovery/proton.recovery.bloc.dart';
import 'package:wallet/managers/features/proton.recovery/proton.recovery.state.dart';
import 'package:wallet/scenes/components/page.layout.v1.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/scenes/recovery.phone/recovery.phone.viewmodel.dart';
import 'package:wallet/scenes/recovery/recovery.auth.dialog.dart';
import 'package:wallet/scenes/recovery/recovery.disable.dialog.dart';
import 'package:wallet/scenes/recovery/recovery.mnemonic.dialog.dart';
import 'package:wallet/scenes/recovery/recovery.section.dart';

class RecoveryPhoneView extends ViewBase<RecoveryPhoneViewModel> {
  const RecoveryPhoneView(RecoveryPhoneViewModel viewModel)
      : super(viewModel, const Key("RecoveryPhoneView"));

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => viewModel.protonRecoveryBloc,
      child: PageLayoutV1(
        title: S.of(context).recovery,
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
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Recovery email',
                              style: TextStyle(
                                color: Color(0xFF535964),
                                fontSize: 14,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              height: 80,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(16),
                                        decoration: ShapeDecoration(
                                          color: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                        ),
                                        child: const Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Expanded(
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'Email address',
                                                    style: TextStyle(
                                                      color: Color(0xFF0E0E0E),
                                                      fontSize: 14,
                                                      fontFamily: 'Inter',
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                  SizedBox(height: 4),
                                                  Text(
                                                    'Add',
                                                    style: TextStyle(
                                                      color: Color(0xFF767DFF),
                                                      fontSize: 17,
                                                      fontFamily: 'Inter',
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 23),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Recovery phone',
                              style: TextStyle(
                                color: Color(0xFF535964),
                                fontSize: 14,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              height: 80,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: 343,
                                        padding: const EdgeInsets.all(16),
                                        decoration: ShapeDecoration(
                                          color: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                        ),
                                        child: const Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Expanded(
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'Phone number',
                                                    style: TextStyle(
                                                      color: Color(0xFF0E0E0E),
                                                      fontSize: 14,
                                                      fontFamily: 'Inter',
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                  SizedBox(height: 4),
                                                  Text(
                                                    'Add',
                                                    style: TextStyle(
                                                      color: Color(0xFF767DFF),
                                                      fontSize: 17,
                                                      fontFamily: 'Inter',
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
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
