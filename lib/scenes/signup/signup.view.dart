import 'package:flutter/material.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/scenes/signup/signup.viewmodel.dart';

class SignupView extends ViewBase<SignupViewModel> {
  SignupView(SignupViewModel viewModel)
      : super(viewModel, const Key("SignupView"));

  @override
  Widget buildWithViewModel(
      BuildContext context, SignupViewModel viewModel, ViewSize viewSize) {
    return Scaffold(
      backgroundColor: ProtonColors.backgroundProton,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("SignupView"),
      ),
      body: const Text("SignupView"),
    );
  }
}
