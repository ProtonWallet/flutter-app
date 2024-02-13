import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/locale.dart';
import 'package:flutter_screen_lock/flutter_screen_lock.dart';
import 'package:wallet/components/button.v5.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/scenes/core/view.navigatior.identifiers.dart';
import 'package:wallet/scenes/debug/wallet.view.dart';
import 'package:wallet/scenes/home/home.viewmodel.dart';
import 'package:wallet/scenes/setup/onboard.coordinator.dart';

class HomeView extends ViewBase<HomeViewModel> {
  HomeView(HomeViewModel viewModel) : super(viewModel, const Key("HomeView"));

  @override
  Widget buildWithViewModel(
      BuildContext context, HomeViewModel viewModel, ViewSize viewSize) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(S.of(context).tab_home),
      ),
      body: Center(
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(S.of(context).confirmed_trans(viewModel.confirmed)),
              Text(S.of(context).unconfirmed_trans(viewModel.unconfirmed)),
              const SizedBox(
                height: 50,
              ),
              Text(S.of(context).balance,
                  style: const TextStyle(
                    fontSize: 20,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.bold,
                  )),
              Text(S.of(context).trans_sat(viewModel.sats),
                  style: const TextStyle(
                    fontSize: 16,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                  )),
              const Text("\$30 USD",
                  style: TextStyle(
                    fontSize: 12,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.normal,
                  )),
              const SizedBox(
                height: 10,
              ),
              Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    ElevatedButton(
                      onPressed: () {
                        viewModel.coordinator
                            .move(ViewIdentifiers.send, context);
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6D4AFF),
                          elevation: 0),
                      child: const Text(
                        "Send",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    ElevatedButton(
                      onPressed: () {
                        viewModel.coordinator
                            .move(ViewIdentifiers.receive, context);
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6D4AFF),
                          elevation: 0),
                      child: const Text(
                        "Receive",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ]),
              const SizedBox(height: 20),
              const Text("----------------IF no wallet----------------"),
              const SizedBox(height: 20),
              ButtonV5(
                onPressed: () {
                  // showDialog(
                  //     context: context,
                  //     barrierDismissible: true,
                  //     builder: (BuildContext cxt) {
                  //       return AlertDialog(content: NestedDialog());
                  //     });
                  viewModel.coordinator
                      .move(ViewIdentifiers.setupOnboard, context);
                },
                height: 36,
                width: 200,
                text: S.of(context).createNewWallet,
              ),
              const SizedBox(height: 20),
              CupertinoButton(
                onPressed: () {
                  screenLock(
                    context: context,
                    correctString: '1234',
                    canCancel: false,
                  );
                },
                color: ProtonColors.interactionNorm,
                child: const Text('Button'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const SimpleWallet(),
                    fullscreenDialog: false,
                  ));
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6D4AFF), elevation: 0),
                child: const Text(
                  "Test Wallet",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              SizedBox(
                height: 80,
                child: viewModel.isSyncing
                    ? Text(S.of(context).syncing)
                    : CupertinoButton(
                        onPressed: viewModel.syncWallet,
                        color: ProtonColors.interactionNorm,
                        child: const Text('Button'),
                      ),
              ),
              ButtonV5(
                onPressed: () {
                  viewModel.coordinator
                      .move(ViewIdentifiers.testWebsocket, context);
                },
                height: 36,
                width: 200,
                text: "Test Websocket",
              ),
            ]),
      ),
    );
  }
}

class NestedDialog extends StatelessWidget {
  const NestedDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Navigator(
            key: const Key(
                "NestedDialogForSetup"), // add a unique key to refer to this navigator programmatically

            initialRoute: '/',
            onGenerateRoute: (RouteSettings settings) {
              return MaterialPageRoute(
                  builder: (_) => SetupOnbaordCoordinator().start());
            }));
  }
}
