import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_gen/gen_l10n/locale.dart';
import 'package:wallet/components/button.v5.dart';
import 'package:wallet/constants/sizedbox.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/scenes/core/view.navigatior.identifiers.dart';
import 'package:wallet/scenes/setup/create.viewmodel.dart';

class SetupCreateView extends ViewBase<SetupCreateViewModel> {
  SetupCreateView(SetupCreateViewModel viewModel)
      : super(viewModel, const Key("SetupCreateView"));

  @override
  Widget buildWithViewModel(
      BuildContext context, SetupCreateViewModel viewModel, ViewSize viewSize) {
    return Scaffold(
      appBar: AppBar(
        // automaticallyImplyLeading: false,
        backgroundColor:
            Colors.transparent, // Theme.of(context).colorScheme.inversePrimary,
      ),
      body: viewModel.inProgress
          ? buildInProgress(context, viewModel, viewSize)
          : buildFinished(context, viewModel, viewSize),
    );
  }

  Widget buildInProgress(
      BuildContext context, SetupCreateViewModel viewModel, ViewSize viewSize) {
    return Stack(
      children: <Widget>[
        SizedBox(
          width: 500, //MediaQuery.of(context).size.width,
          height: 200, //MediaQuery.of(context).size.height - 80,
          child: SvgPicture.asset(
            'assets/images/frame_create.svg',
            fit: BoxFit.contain,
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
          padding: const EdgeInsets.only(top: 160),
          alignment: Alignment.topCenter,
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                SizedBoxes.box58,
                ButtonV5(
                    onPressed: null,
                    text:
                        "Back up your wallet", //S.of(context).createNewWallet,
                    width: MediaQuery.of(context).size.width - 80,
                    height: 36),
                SizedBoxes.box20,
                ButtonV5(
                    onPressed: () {
                      viewModel.updateProgressStatus(!viewModel.inProgress);
                    },
                    text: "Test", //S.of(context).createNewWallet,
                    width: MediaQuery.of(context).size.width - 80,
                    height: 36),
                SizedBoxes.box20,
              ]),
        ),
      ],
    );
  }

  Widget buildFinished(
      BuildContext context, SetupCreateViewModel viewModel, ViewSize viewSize) {
    return Stack(
      children: <Widget>[
        SizedBox(
          width: 500,
          height: 160,
          child: SvgPicture.asset(
            'assets/images/frame_create_finished.svg',
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
                ButtonV5(
                    onPressed: () {
                      viewModel.coordinator
                          .move(ViewIdentifiers.setupBackup, context);
                    },
                    text:
                        "Back up your wallet", //S.of(context).createNewWallet,
                    width: MediaQuery.of(context).size.width - 80,
                    height: 36),
                SizedBoxes.box20,
              ]),
        ),
      ],
    );
  }
}
