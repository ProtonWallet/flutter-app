import 'package:flutter/material.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/scenes/login/login.viewmodel.dart';
import 'package:wallet/l10n/generated/locale.dart';

class LoginView extends ViewBase<LoginViewModel> {
  LoginView(LoginViewModel viewModel)
      : super(viewModel, const Key("LoginView"));

  @override
  Widget buildWithViewModel(
      BuildContext context, LoginViewModel viewModel, ViewSize viewSize) {
    return Scaffold(
      backgroundColor: ProtonColors.backgroundProton,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("LoginView"),
      ),
      body: Column(
        children: [
          const TextField(
            decoration: InputDecoration(
              labelText: "Username",
            ),
          ),
          const TextField(
            decoration: InputDecoration(
              labelText: "Password",
            ),
          ),
          ElevatedButton(
            onPressed: () {
              // Perform signup logic here
            },
            child: Text(S.of(context).signup),
          ),
          ElevatedButton(
            onPressed: () {
              // Perform login logic here
            },
            child: Text(S.of(context).login),
          ),
        ],
      ),
    );
  }
}
