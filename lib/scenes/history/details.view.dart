import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:wallet/components/textfield.text.v2.dart';
import 'package:wallet/components/transaction.history.item.dart';
import 'package:wallet/constants/app.config.dart';
import 'package:wallet/constants/constants.dart';
import 'package:wallet/helper/user.settings.provider.dart';
import 'package:wallet/helper/wallet_manager.dart';
import 'package:wallet/l10n/generated/locale.dart';
import 'package:wallet/components/button.v5.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/scenes/history/details.viewmodel.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wallet/theme/theme.font.dart';

class HistoryDetailView extends ViewBase<HistoryDetailViewModel> {
  HistoryDetailView(HistoryDetailViewModel viewModel)
      : super(viewModel, const Key("HistoryDetailView"));

  @override
  Widget buildWithViewModel(BuildContext context,
      HistoryDetailViewModel viewModel, ViewSize viewSize) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark, // For Android (dark icons)
          statusBarBrightness: Brightness.light, // For iOS (dark icons)
        ),
        backgroundColor: ProtonColors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
        ),
        scrolledUnderElevation:
            0.0, // don't change background color when scroll down
      ),
      body: buildNoHistory(context, viewModel, viewSize),
    );
  }

  Widget buildNoHistory(BuildContext context, HistoryDetailViewModel viewModel,
      ViewSize viewSize) {
    return Container(
        color: ProtonColors.white,
        height: double.infinity,
        child: SingleChildScrollView(
            child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 26),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: ProtonColors.wMajor1,
                            ),
                            margin: const EdgeInsets.only(right: 4, top: 2),
                            padding: const EdgeInsets.all(2.0),
                            child: Icon(
                                viewModel.isSend
                                    ? Icons.arrow_upward
                                    : Icons.arrow_downward,
                                size: 12,
                                color: ProtonColors.textHint)),
                        Text(
                            viewModel.isSend
                                ? S.of(context).send
                                : S.of(context).receive,
                            style:
                                FontManager.body2Regular(ProtonColors.textHint))
                      ],
                    ),
                    viewModel.isSend
                        ? Text(
                            Provider.of<UserSettingProvider>(context)
                                .getBitcoinUnitLabel(viewModel.amount.toInt()),
                            style:
                                FontManager.titleHero(ProtonColors.signalError))
                        : Text(
                            "+${Provider.of<UserSettingProvider>(context).getBitcoinUnitLabel(viewModel.amount.toInt())}",
                            style: FontManager.titleHero(
                                ProtonColors.signalSuccess)),
                    Text(
                        viewModel.isSend
                            ? "-${Provider.of<UserSettingProvider>(context).getFiatCurrencySign()}${Provider.of<UserSettingProvider>(context).getNotionalInFiatCurrency(viewModel.amount.toInt()).abs()}"
                            : "+${Provider.of<UserSettingProvider>(context).getFiatCurrencySign()}${Provider.of<UserSettingProvider>(context).getNotionalInFiatCurrency(viewModel.amount.toInt()).abs()}",
                        style: FontManager.titleSubHeadline(
                            ProtonColors.textHint)),
                    const SizedBox(height: 20),
                    viewModel.isEditing == false
                        ? Container(
                            margin: const EdgeInsets.symmetric(vertical: 10.0),
                            padding: const EdgeInsets.all(defaultPadding),
                            decoration: BoxDecoration(
                                color: ProtonColors.transactionNoteBackground,
                                borderRadius: BorderRadius.circular(40.0)),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SvgPicture.asset(
                                    "assets/images/icon/ic_note.svg",
                                    fit: BoxFit.fill,
                                    width: 32,
                                    height: 32),
                                const SizedBox(width: 10),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (viewModel
                                        .memoController.text.isNotEmpty)
                                      Text(viewModel.memoController.text,
                                          style: FontManager.body2Median(
                                              ProtonColors.textNorm)),
                                    GestureDetector(
                                        onTap: () {
                                          viewModel.editMemo();
                                        },
                                        child: Text(
                                            S.of(context).trans_edit_note,
                                            style: FontManager.body2Median(
                                                ProtonColors.protonBlue))),
                                  ],
                                )
                              ],
                            ))
                        : Container(
                            margin: const EdgeInsets.symmetric(vertical: 10.0),
                            child: TextFieldTextV2(
                              labelText: S.of(context).trans_userLable,
                              textController: viewModel.memoController,
                              myFocusNode: viewModel.memoFocusNode,
                              paddingSize: 7,
                              validation: (String value) {
                                return "";
                              },
                            ),
                          ),
                    viewModel.isSend
                        ? buildSendInfo(context, viewModel, viewSize)
                        : buildReceiveInfo(context, viewModel, viewSize),
                    const Divider(
                      thickness: 0.2,
                      height: 1,
                    ),
                    TransactionHistoryItem(
                        title: S.of(context).trans_status,
                        content: viewModel.blockConfirmTimestamp != null
                            ? S.of(context).confirmed
                            : S.of(context).in_progress,
                        contentColor: viewModel.blockConfirmTimestamp != null
                            ? ProtonColors.signalSuccess
                            : ProtonColors.signalError),
                    const Divider(
                      thickness: 0.2,
                      height: 1,
                    ),
                    if (viewModel.blockConfirmTimestamp != null)
                      TransactionHistoryItem(
                          title: S.of(context).trans_date,
                          content: parsetime(viewModel.blockConfirmTimestamp!)),
                    const Divider(
                      thickness: 0.2,
                      height: 1,
                    ),
                    ExpansionTile(
                        shape: const Border(),
                        initiallyExpanded: false,
                        title: Text(S.of(context).view_more,
                            style:
                                FontManager.body2Median(ProtonColors.textWeak)),
                        iconColor: ProtonColors.textHint,
                        collapsedIconColor: ProtonColors.textHint,
                        children: [
                          TransactionHistoryItem(
                            title: S.of(context).trans_metworkFee,
                            titleCallback: () {
                              showNetworkFee(context);
                            },
                            content:
                                "${Provider.of<UserSettingProvider>(context).getFiatCurrencySign()}${Provider.of<UserSettingProvider>(context).getNotionalInFiatCurrency(viewModel.fee.toInt()).toStringAsFixed(3)}",
                            memo: Provider.of<UserSettingProvider>(context)
                                .getBitcoinUnitLabel(viewModel.fee.toInt()),
                          ),
                          const Divider(
                            thickness: 0.2,
                            height: 1,
                          ),
                          TransactionHistoryItem(
                              title: S.of(context).trans_total,
                              content: viewModel.isSend
                                  ? "${Provider.of<UserSettingProvider>(context).getFiatCurrencySign()}${Provider.of<UserSettingProvider>(context).getNotionalInFiatCurrency(viewModel.amount.toInt()).abs().toStringAsFixed(3)}"
                                  : "${Provider.of<UserSettingProvider>(context).getFiatCurrencySign()}${Provider.of<UserSettingProvider>(context).getNotionalInFiatCurrency(viewModel.amount.toInt() + viewModel.fee.toInt()).toStringAsFixed(3)}",
                              memo: viewModel.isSend
                                  ? Provider.of<UserSettingProvider>(context)
                                      .getBitcoinUnitLabel(
                                          (viewModel.amount.toInt())
                                              .abs())
                                  : Provider.of<UserSettingProvider>(context)
                                      .getBitcoinUnitLabel(
                                          viewModel.amount.toInt() +
                                              viewModel.fee.toInt())),
                          const SizedBox(height: 20),
                          ButtonV5(
                              onPressed: () {
                                launchUrl(Uri.parse(
                                    "${appConfig.esploraBaseUrl}search?q=${viewModel.txid}"));
                              },
                              text: S.of(context).view_on_blockstream,
                              width: MediaQuery.of(context).size.width,
                              backgroundColor: ProtonColors.protonBlue,
                              textStyle:
                                  FontManager.body1Median(ProtonColors.white),
                              height: 48),
                          const SizedBox(height: 20),
                        ])
                  ],
                ))));
  }

  Widget buildSendInfo(BuildContext context, HistoryDetailViewModel viewModel,
      ViewSize viewSize) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        TransactionHistoryItem(
          title: S.of(context).trans_from,
          content:
              "${WalletManager.getEmailFromWalletTransaction(viewModel.fromEmail)} (You)",
          memo: "${viewModel.strWallet} - ${viewModel.strAccount}",
        ),
        const Divider(
          thickness: 0.2,
          height: 1,
        ),
        TransactionHistoryItem(
          title: S.of(context).trans_to,
          content: viewModel.toEmail.isNotEmpty
              ? WalletManager.getEmailFromWalletTransaction(viewModel.toEmail)
              : viewModel.address,
          copyContent: true,
          memo: viewModel.toEmail.isNotEmpty
              ? WalletManager.getBitcoinAddressFromWalletTransaction(
                  viewModel.toEmail)
              : null,
        ),
      ],
    );
  }

  Widget buildReceiveInfo(BuildContext context,
      HistoryDetailViewModel viewModel, ViewSize viewSize) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        TransactionHistoryItem(
          title: S.of(context).trans_from,
          content: viewModel.fromEmail.isNotEmpty
              ? WalletManager.getEmailFromWalletTransaction(viewModel.fromEmail)
              : viewModel.address,
        ),
        const Divider(
          thickness: 0.2,
          height: 1,
        ),
        TransactionHistoryItem(
          title: S.of(context).trans_to,
          content:
              "${WalletManager.getEmailFromWalletTransaction(viewModel.toEmail)} (You)",
          memo: "${viewModel.strWallet} - ${viewModel.strAccount}",
        ),
      ],
    );
  }

  String parsetime(int timestemp) {
    var millis = timestemp;
    var dt = DateTime.fromMillisecondsSinceEpoch(millis * 1000);

    var d12 =
        DateFormat('MM/dd/yyyy, hh:mm a').format(dt); // 12/31/2000, 10:00 PM

    // var d24 = DateFormat('dd/MM/yyyy, HH:mm').format(dt); // 31/12/2000, 22:00
    return d12.toString();
  }
}

void showNetworkFee(BuildContext context) {
  showModalBottomSheet(
      context: context,
      backgroundColor: ProtonColors.white,
      constraints: BoxConstraints(
        minWidth: MediaQuery.of(context).size.width,
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(8.0)),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
          return SingleChildScrollView(
              child: Padding(
                  padding: const EdgeInsets.all(defaultPadding),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset("assets/images/icon/no_wallet_found.svg",
                          fit: BoxFit.fill, width: 86, height: 87),
                      const SizedBox(height: 10),
                      Text(S.of(context).placeholder,
                          style:
                              FontManager.body1Median(ProtonColors.textNorm)),
                      const SizedBox(height: 5),
                      Text(S.of(context).placeholder,
                          style:
                              FontManager.body2Regular(ProtonColors.textWeak)),
                      const SizedBox(height: 20),
                      ButtonV5(
                        text: S.of(context).ok,
                        width: MediaQuery.of(context).size.width,
                        backgroundColor: ProtonColors.protonBlue,
                        textStyle: FontManager.body1Median(ProtonColors.white),
                        height: 48,
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      const SizedBox(height: 10),
                    ],
                  )));
        });
      });
}
