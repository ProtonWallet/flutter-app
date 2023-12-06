import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_gen/gen_l10n/locale.dart';
import 'package:wallet/components/button.v5.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/constants/sizedbox.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/scenes/core/view.navigatior.identifiers.dart';
import 'package:wallet/scenes/setup/onboard.viewmodel.dart';

class SetupOnboardView extends ViewBase<SetupOnboardViewModel> {
  SetupOnboardView(SetupOnboardViewModel viewModel)
      : super(viewModel, const Key("SetupOnboardView"));

  @override
  Widget buildWithViewModel(BuildContext context,
      SetupOnboardViewModel viewModel, ViewSize viewSize) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor:
            Colors.transparent, // Theme.of(context).colorScheme.inversePrimary,
      ),
      body: buildNoHistory(context, viewModel, viewSize),
    );
  }

  Widget buildNoHistory(BuildContext context, SetupOnboardViewModel viewModel,
      ViewSize viewSize) {
    return Stack(
      children: <Widget>[
        SizedBox(
          width: 500,
          height: 160,
          child: SvgPicture.asset(
            'assets/images/frame_9444342.svg',
            width: 500,
            height: 200,
          ),
        ),
        Container(
          padding: const EdgeInsets.only(top: 41),
          alignment: Alignment.topCenter,
          child: Text(
            S.of(context).welcome_to,
            style: const TextStyle(color: Colors.white, fontSize: 20.0),
          ),
        ),
        Container(
          padding: const EdgeInsets.only(top: 124),
          alignment: Alignment.topCenter,
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                SizedBoxes.box58,
                const Text(
                    "Financial freedom with rock-solid security and privacy",
                    style: TextStyle(
                        fontSize: 14,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w600)),
                SizedBoxes.box8,
                const Text(
                  "Get started and create a brand new wallet or import an existing one.",
                  style: TextStyle(
                      fontSize: 14,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.normal),
                  textAlign: TextAlign.center,
                ),
                SizedBoxes.box32,
                ButtonV5(
                    onPressed: () {
                      viewModel.coordinator
                          .move(ViewIdentifiers.setupCreate, context);
                    },
                    text: S.of(context).createNewWallet,
                    width: MediaQuery.of(context).size.width - 80,
                    height: 36),
                SizedBoxes.box12,
                ButtonV5(
                    onPressed: () {},
                    text: S.of(context).importWallet,
                    width: MediaQuery.of(context).size.width - 80,
                    backgroundColor: ProtonColors.white,
                    borderColor: ProtonColors.wMajor1,
                    textStyle: const TextStyle(
                      color: ProtonColors.textNorm,
                      fontSize: 14,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w400,
                    ),
                    height: 36),
                SizedBoxes.box20,
              ]),
        ),
      ],
    );
  }
}
