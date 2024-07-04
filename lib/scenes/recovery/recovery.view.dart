import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wallet/scenes/components/page.layout.v1.dart';
import 'package:wallet/constants/constants.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/l10n/generated/locale.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/scenes/recovery/recovery.section.dart';
import 'package:wallet/scenes/recovery/recovery.viewmodel.dart';
import 'package:wallet/theme/theme.font.dart';

class RecoveryView extends ViewBase<RecoveryViewModel> {
  const RecoveryView(RecoveryViewModel viewModel)
      : super(viewModel, const Key("RecoveryView"));

  @override
  Widget build(BuildContext context) {
    return PageLayoutV1(
      title: S.of(context).recovery,
      child: Column(
        children: [
          const SizedBox(height: defaultPadding),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text("Allow recovery by recovery phrase",
                style: FontManager.body2Regular(ProtonColors.textNorm)),
            CupertinoSwitch(
              value: viewModel.recoveryEnabled,
              activeColor: ProtonColors.protonBlue,
              onChanged: (bool newValue) {
                viewModel.updateRecovery(newValue);
              },
            )
          ]),
          const SizedBox(height: 16),
          RecoverySection(
            title: 'Account recovery phrase',
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
              size: 14,
            ),
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
              size: 14,
            ),
          ),
          const SizedBox(height: 34),
          // RecoverySection(
          //   title: 'Recovery email and phone',
          //   description:
          //       'Some explanation here, lorem ipsum dolor sit ametmconsectetur adipiscing',
          //   logo: Icon(
          //     Icons.arrow_forward_ios_rounded,
          //     size: 12,
          //     color: ProtonColors.textHint,
          //   ),
          // warning: Icon(
          //   Icons.info_outline_rounded,
          //   color: ProtonColors.signalError,
          //   size: 24,
          // ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
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
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: ShapeDecoration(
                                  color: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
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
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          SizedBox(height: 4),
                                          Text(
                                            'Add',
                                            style: TextStyle(
                                              color: Color(0xFF767DFF),
                                              fontSize: 17,
                                              fontFamily: 'Inter',
                                              fontWeight: FontWeight.w500,
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
                  mainAxisAlignment: MainAxisAlignment.start,
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
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 343,
                                padding: const EdgeInsets.all(16),
                                decoration: ShapeDecoration(
                                  color: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
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
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          SizedBox(height: 4),
                                          Text(
                                            'Add',
                                            style: TextStyle(
                                              color: Color(0xFF767DFF),
                                              fontSize: 17,
                                              fontFamily: 'Inter',
                                              fontWeight: FontWeight.w500,
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
      ),
    );
  }
}
