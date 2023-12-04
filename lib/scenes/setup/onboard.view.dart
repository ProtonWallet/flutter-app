import 'package:flutter/material.dart';
import 'package:wallet/components/button.v5.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/constants/sizedbox.dart';
import 'package:wallet/scenes/core/view.dart';
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
        title: const Text(""),
      ),
      body: buildNoHistory(context, viewModel, viewSize),
    );
  }

  Widget buildNoHistory(BuildContext context, SetupOnboardViewModel viewModel,
      ViewSize viewSize) {
    return SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SizedBoxes.box41,
              const Text("Welcome to",
                  style: TextStyle(
                      fontSize: 20,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w600)),
              SizedBoxes.box18,
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Logo"),
                  SizedBox(width: 8),
                  Text("Proton Wallet",
                      style: TextStyle(
                          fontSize: 24,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.bold))
                ],
              ),
              SizedBoxes.box58,
              const Text(
                  "--------------------------------------------------------"),
              SizedBoxes.box24,
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
                  text: "Create a new wallet",
                  width: MediaQuery.of(context).size.width - 60,
                  height: 36),
              SizedBoxes.box12,
              ButtonV5(
                  text: "Import an existing wallet",
                  width: MediaQuery.of(context).size.width - 60,
                  backgroundColor: ProtonColors.white,
                  textStyle: const TextStyle(
                    color: ProtonColors.textNorm,
                    fontSize: 14,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                  ),
                  height: 36),
              SizedBoxes.box20,
            ]));
  }

  Widget buildBackground(BuildContext context, SetupOnboardViewModel viewModel,
      ViewSize viewSize) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SizedBox(
        width: double.infinity,
        height: MediaQuery.of(context).size.height,
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Positioned(
              top: 0,
              left: 0,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6D4AFF), elevation: 0),
                child: Text(
                  "No history".toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),
            const SafeArea(
                child: Text(
                    "aaaaalkfjslkfjasjflksdfkjsklfskfjlksdjflksdjfklsjfklsjdl")),
          ],
        ),
      ),
    );
  }
}
