import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wallet/components/button.v5.dart';
import 'package:wallet/components/dropdown.button.v2.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/l10n/generated/locale.dart';
import 'package:wallet/models/account.model.dart';
import 'package:wallet/provider/proton.wallet.provider.dart';
import 'package:wallet/components/bottom.sheets/base.dart';
import 'package:wallet/scenes/home.v3/home.viewmodel.dart';
import 'package:wallet/theme/theme.font.dart';

class EmailIntegrationSheet {
  static void show(BuildContext context, HomeViewModel viewModel) {
    AccountModel? userAccount =
        Provider
            .of<ProtonWalletProvider>(context, listen: false)
            .protonWallet
            .currentAccount;
    if (userAccount != null) {
      bool emailIntegrationEnable =
          Provider
              .of<ProtonWalletProvider>(context, listen: false)
              .protonWallet
              .getIntegratedEmailIDs(userAccount)
              .isNotEmpty;
      ValueNotifier emailIntegrationNotifier =
      ValueNotifier(viewModel.protonAddresses.firstOrNull);

      HomeModalBottomSheet.show(context, child:
      StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
        return Column(children: [
          const SizedBox(height: 10),
          Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Email Integration",
                    style: FontManager.body2Regular(
                        ProtonColors.textNorm)),
                CupertinoSwitch(
                  value: emailIntegrationEnable,
                  activeColor: ProtonColors.protonBlue,
                  onChanged: (bool newValue) {
                    setState(() {
                      emailIntegrationEnable = newValue;
                    });
                  },
                )
              ]),
          const SizedBox(height: 10),
          if (emailIntegrationEnable)
            for (String addressID
            in Provider
                .of<ProtonWalletProvider>(context)
                .protonWallet
                .getIntegratedEmailIDs(userAccount))
              Container(
                  margin: const EdgeInsets.only(bottom: 5),
                  child: ListTile(
                    title: Text(
                        viewModel
                            .getProtonAddressByID(addressID)!
                            .email,
                        style: FontManager.body2Regular(
                            ProtonColors.textNorm)),
                    trailing: IconButton(
                      onPressed: () async {
                        await viewModel.removeEmailAddress(
                            Provider
                                .of<ProtonWalletProvider>(
                                context,
                                listen: false)
                                .protonWallet
                                .currentWallet!
                                .serverWalletID,
                            userAccount.serverAccountID,
                            addressID);
                      },
                      icon: const Icon(Icons.close),
                    ),
                  )),
          const SizedBox(height: 10),
          if (emailIntegrationEnable)
            Column(children: [
              const SizedBox(height: 10),
              DropdownButtonV2(
                labelText: S
                    .of(context)
                    .add_email_to_account,
                items: viewModel.protonAddresses,
                itemsText: viewModel.protonAddresses
                    .map((e) => e.email)
                    .toList(),
                valueNotifier: emailIntegrationNotifier,
                width: MediaQuery
                    .of(context)
                    .size
                    .width,
              ),
              const SizedBox(height: 10),
              ButtonV5(
                  onPressed: () async {
                    await viewModel
                        .addEmailAddressToWalletAccount(
                        Provider
                            .of<ProtonWalletProvider>(
                            context,
                            listen: false)
                            .protonWallet
                            .currentWallet!
                            .serverWalletID,
                        userAccount.serverAccountID,
                        emailIntegrationNotifier.value.id);
                  },
                  backgroundColor: ProtonColors.protonBlue,
                  text: S
                      .of(context)
                      .add,
                  width: MediaQuery
                      .of(context)
                      .size
                      .width,
                  textStyle: FontManager.body1Median(
                      ProtonColors.white),
                  radius: 40,
                  height: 52),
              const SizedBox(height: 10),
            ]),
        ]);
      }));
    }
  }
}
