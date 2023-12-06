import 'package:flutter/material.dart';
import 'package:flutter_tags_x/flutter_tags_x.dart';
import 'package:wallet/components/button.v5.dart';
import 'package:wallet/constants/sizedbox.dart';
import 'package:wallet/helper/logger.dart';
import 'package:wallet/scenes/backup/backup.viewmodel.dart';
import 'package:wallet/scenes/core/view.dart';

class SetupBackupView extends ViewBase<SetupBackupViewModel> {
  SetupBackupView(SetupBackupViewModel viewModel)
      : super(viewModel, const Key("SetupBackupView"));

  @override
  Widget buildWithViewModel(
      BuildContext context, SetupBackupViewModel viewModel, ViewSize viewSize) {
    return Scaffold(
      appBar: AppBar(
        // automaticallyImplyLeading: false,
        backgroundColor:
            Colors.transparent, // Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Your mnemonic"),
      ),
      body: buildMnemonicView(context, viewModel, viewSize),
    );
  }

  Widget buildMnemonicView(
      BuildContext context, SetupBackupViewModel viewModel, ViewSize viewSize) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
              "This is your secret recovery phrase. If you lose access to your account, this phrase will help you recover your wallet. "),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 16.0, right: 16.0),
          child: Tags(
            itemCount: viewModel.itemList.length, // required
            itemBuilder: (int index) {
              final item = viewModel.itemList[index];
              return ItemTags(
                key: Key(index.toString()),
                index: index, // required
                title: "${item.index}. ${item.title}",
                customData: item.customData,
                textStyle: const TextStyle(
                  fontSize: 14,
                ),
                pressEnabled: false,
                combine: ItemTagsCombine.withTextBefore,
                borderRadius: BorderRadius.circular(10),
                textActiveColor: const Color(0xFF3A3AA8),
                activeColor: const Color(0xFFE1E1FA),
              );
            },
          ),
        ),
        SizedBoxes.box20,
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
              "Save these 12 words securely and never share them with anyone."),
        ),
        Container(
          alignment: Alignment.topCenter,
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                SizedBoxes.box12,
                ButtonV5(
                    onPressed: () {
                      this.viewModel.coordinator.end();
                      Navigator.of(context).popUntil((route) {
                        logger.d(route.settings.name);
                        if (route.settings.name == null) {
                          return false;
                        }
                        return route.settings.name ==
                            "[<'HomeNavigationView'>]";
                      });
                    },
                    text: "Continue", //S.of(context).createNewWallet,
                    width: MediaQuery.of(context).size.width - 80,
                    height: 36),
                SizedBoxes.box20,
              ]),
        ),
      ],
    );
  }
}
