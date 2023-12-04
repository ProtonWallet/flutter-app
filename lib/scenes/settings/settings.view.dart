import 'package:flutter/material.dart';
import 'package:wallet/helper/logger.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/scenes/core/view.navigatior.identifiers.dart';
import 'package:wallet/scenes/settings/settings.account.view.dart';
import 'package:wallet/scenes/settings/settings.common.view.dart';
import 'package:wallet/scenes/settings/settings.viewmodel.dart';

class SettingsView extends ViewBase<SettingsViewModel> {
  SettingsView(SettingsViewModel viewModel)
      : super(viewModel, const Key("SettingsView"));

  @override
  Widget buildWithViewModel(
      BuildContext context, SettingsViewModel viewModel, ViewSize viewSize) {
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: const Icon(Icons.account_balance_wallet),
            onPressed: () {
              logger.d("appBar icon butttion clicked");
              viewModel.coordinator.move(ViewIdentifiers.welcome, context);
            },
          ),
          // Theme.of(context).colorScheme.inversePrimary,
          backgroundColor: const Color.fromRGBO(0, 0, 0, 0),
          forceMaterialTransparency: true,
          title: const Text("Settings",
              style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        body: SingleChildScrollView(
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  const AccountInfo(),
                  const SizedBox(
                    height: 5,
                  ),
                  const CommonSettings(),
                  const SizedBox(
                    height: 5,
                  ),
                  ElevatedButton(
                    onPressed: viewModel.updateStringValue,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6D4AFF), elevation: 0),
                    child: Text(
                      "Create Wallet".toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    viewModel.mnemonicString,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(
                    height: 50,
                  ),
                  ElevatedButton(
                    onPressed: viewModel.updateStringValue,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6D4AFF), elevation: 0),
                    child: Text(
                      "Logout".toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 50,
                  ),
                ]),
          ),
        ));
  }
}
