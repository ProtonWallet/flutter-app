import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/scenes/settings/mail_integration/maillist.viewmodel.dart';

import '../../../components/custom.mailbox.dart';
import '../../../constants/proton.color.dart';
import '../../../theme/theme.font.dart';
import '../../core/view.navigatior.identifiers.dart';

class MailListView extends ViewBase<MailListViewModel> {
  MailListView(MailListViewModel viewModel)
      : super(viewModel, const Key("MailListView"));

  @override
  Widget buildWithViewModel(
      BuildContext context, MailListViewModel viewModel, ViewSize viewSize) {
    return Scaffold(
      appBar: AppBar(
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark, // For Android (dark icons)
          statusBarBrightness: Brightness.light, // For iOS (dark icons)
        ),
        backgroundColor: Theme.of(context).colorScheme.background,
        title: const Text("Settings"),
        scrolledUnderElevation:
            0.0, // don't change background color when scroll down
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
              height: 40,
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Padding(
                        padding: const EdgeInsets.only(left: 26.0, right: 26.0),
                        child: Text("Email Integration",
                            style: FontManager.body2Median(
                                Theme.of(context).colorScheme.primary))),
                    GestureDetector(
                        onTap: () {
                          viewModel.mailSettingID =
                              0; // 0 as create, otherwise its editing existing mailSetting
                          viewModel.coordinator
                              .move(ViewIdentifiers.mailEdit, context);
                        },
                        child: Padding(
                            padding:
                                const EdgeInsets.only(left: 26.0, right: 26.0),
                            child: Text("Add Email",
                                style: FontManager.body2Median(
                                    ProtonColors.interactionNorm)))),
                  ])),
          Expanded(
            child: SingleChildScrollView(
                child: Column(
              children: [
                for (String mail in [
                  "1234567@proton.me",
                  "test@proton.me",
                  "hello.world@proton.me",
                ])
                  CustomMailBox(
                    mail: mail,
                    subTitle: "Not connected",
                    onTap: () {
                      // TODO:: add perisist table to store mail setting
                      viewModel.mailSettingID = 1;
                      viewModel.coordinator
                          .move(ViewIdentifiers.mailEdit, context);
                    },
                  )
              ],
            )),
          ),
        ],
      ),
    );
  }
}
