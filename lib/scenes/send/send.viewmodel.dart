import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:provider/provider.dart';
import 'package:wallet/helper/common_helper.dart';
import 'package:wallet/helper/dbhelper.dart';
import 'package:wallet/helper/exchange.rate.service.dart';
import 'package:wallet/helper/logger.dart';
import 'package:wallet/helper/user.settings.provider.dart';
import 'package:wallet/helper/wallet_manager.dart';
import 'package:wallet/models/account.model.dart';
import 'package:wallet/models/contacts.model.dart';
import 'package:wallet/models/wallet.model.dart';
import 'package:wallet/rust/proton_api/exchange_rate.dart';
import 'package:wallet/rust/proton_api/proton_address.dart';
import 'package:wallet/rust/proton_api/user_settings.dart';
import 'package:wallet/scenes/core/coordinator.dart';
import 'package:wallet/scenes/core/view.navigatior.identifiers.dart';
import 'package:wallet/scenes/core/viewmodel.dart';
import 'package:wallet/helper/bdk/helper.dart';
import 'package:wallet/scenes/debug/bdk.test.dart';
import 'package:wallet/scenes/send/send.coordinator.dart';
import 'package:wallet/rust/api/proton_api.dart' as proton_api;

enum TransactionFeeMode {
  highPriority,
  medianPriority,
  lowPriority,
}

abstract class SendViewModel extends ViewModel<SendCoordinator> {
  SendViewModel(super.coordinator, this.walletID, this.accountID);

  int walletID;
  int accountID;
  final int maxRecipientCount = 5;
  String fromAddress = "";
  late TextEditingController recipientTextController;
  late TextEditingController memoTextController;
  late TextEditingController amountTextController;
  Map<String, String> bitcoinAddresses = {};
  late UserSettingProvider userSettingProvider;

  List<String> recipents = [];
  List<ProtonAddress> protonAddresses = [];
  int balance = 0;
  double feeRate = 1.0;
  bool inReview = false;
  TransactionFeeMode userTransactionFeeMode = TransactionFeeMode.medianPriority;
  bool amountTextControllerChanged = false;
  bool amountFiatCurrencyTextControllerChanged = false;
  WalletModel? walletModel;
  AccountModel? accountModel;
  late FocusNode addressFocusNode;
  late FocusNode amountFocusNode;
  ValueNotifier<FiatCurrency> fiatCurrencyNotifier =
      ValueNotifier(FiatCurrency.usd);

  bool isEditingEmailBody = false;
  bool isEditingMemo = false;
  late TextEditingController emailBodyController;
  late TextEditingController memoController;
  late FocusNode emailBodyFocusNode;
  late FocusNode memoFocusNode;

  void editEmailBody();
  void editMemo();

  Future<void> sendCoin();

  Future<void> updateFeeRate();

  void addRecipient();

  void removeRecipient(int index);

  void updatePageStatus({required bool inReview});

  void updateTransactionFeeMode(TransactionFeeMode transactionFeeMode);

  List<ContactsModel> contactsEmail = [];
}

class SendViewModelImpl extends SendViewModel {
  SendViewModelImpl(super.coordinator, super.walletID, super.accountID);

  final datasourceChangedStreamController =
      StreamController<SendViewModel>.broadcast();
  final BdkLibrary _lib = BdkLibrary();
  late Wallet _wallet;
  late Blockchain? _blockchain;

  @override
  void dispose() {
    datasourceChangedStreamController.close();
  }

  @override
  Future<void> loadData() async {
    EasyLoading.show(
        status: "loading exchange rate..", maskType: EasyLoadingMaskType.black);
    addressFocusNode = FocusNode();
    amountFocusNode = FocusNode();
    memoFocusNode = FocusNode();
    emailBodyFocusNode = FocusNode();
    memoTextController = TextEditingController();
    emailBodyController = TextEditingController();

    memoFocusNode.addListener(() {
      if (memoFocusNode.hasFocus == false) {
        userFinishMemo();
      }
    });

    emailBodyFocusNode.addListener(() {
      if (emailBodyFocusNode.hasFocus == false) {
        userFinishEmailBody();
      }
    });

    userSettingProvider = Provider.of<UserSettingProvider>(
        Coordinator.navigatorKey.currentContext!,
        listen: false);
    fiatCurrencyNotifier.value =
        userSettingProvider.walletUserSetting.fiatCurrency;
    fiatCurrencyNotifier.addListener(() async {
      updateUserSettingProvider(fiatCurrencyNotifier.value);
    });
    recipientTextController = TextEditingController(text: "");
    memoTextController = TextEditingController();
    amountTextController = TextEditingController();
    amountTextController.addListener(() {
      datasourceChangedStreamController.add(this);
    });

    datasourceChangedStreamController.add(this);
    _blockchain = await _lib.initializeBlockchain(false);
    updateFeeRate();
    contactsEmail = await WalletManager.getContacts();
    walletModel = await DBHelper.walletDao!.findById(walletID);
    accountModel = await DBHelper.accountDao!.findById(accountID);
    updateWallet();
    EasyLoading.dismiss();
    datasourceChangedStreamController.add(this);
    List<ProtonAddress> addresses = await proton_api.getProtonAddress();
    protonAddresses =
        addresses.where((element) => element.status == 1).toList();
  }

  Future<void> updateWallet() async {
    _wallet = await WalletManager.loadWalletWithID(walletID, accountID);
    var walletBalance = await _wallet.getBalance();
    balance = walletBalance.total;
    datasourceChangedStreamController.add(this);
  }

  @override
  void updateTransactionFeeMode(TransactionFeeMode transactionFeeMode) {
    userTransactionFeeMode = transactionFeeMode;
    datasourceChangedStreamController.add(this);
  }

  @override
  Future<void> updatePageStatus({required bool inReview}) async {
    if (inReview == true) {}
    this.inReview = inReview;
    datasourceChangedStreamController.add(this);
  }

  Future<void> updateUserSettingProvider(FiatCurrency fiatCurrency) async {
    userSettingProvider.updateFiatCurrency(fiatCurrency);
    ProtonExchangeRate exchangeRate =
        await ExchangeRateService.getExchangeRate(fiatCurrency);
    userSettingProvider.updateExchangeRate(exchangeRate);
  }

  Future<void> loadBitcoinAddresses() async {
    for (String recipent in recipents) {
      if (bitcoinAddresses.containsKey(recipent)) {
        continue;
      }
      String? bitcoinAddress;
      if (CommonHelper.isBitcoinAddress(recipent)) {
        bitcoinAddress = recipent;
      } else {
        try {
          bitcoinAddress = await WalletManager.lookupBitcoinAddress(recipent);
        } catch (e) {
          logger.e(e.toString());
          if (e.toString().contains("http error: channel closed")) {
            await WalletManager.initMuon(WalletManager.apiEnv);
          }
          logger.i("Muon reloaded");
        }
      }
      bitcoinAddresses[recipent] = bitcoinAddress ?? "";
    }
  }

  @override
  Future<void> addRecipient() async {
    String recipent = recipientTextController.text;
    if (recipents.contains(recipent) == false) {
      recipents.add(recipent);
    }
    recipientTextController.text = "";
    EasyLoading.show(
        status: "loading bitcoin address..",
        maskType: EasyLoadingMaskType.black);
    await loadBitcoinAddresses();
    EasyLoading.dismiss();
    datasourceChangedStreamController.add(this);
  }

  @override
  void removeRecipient(int index) {
    recipents.removeAt(index);
    datasourceChangedStreamController.add(this);
  }

  @override
  Stream<ViewModel> get datasourceChanged =>
      datasourceChangedStreamController.stream;

  @override
  Future<void> sendCoin() async {
    EasyLoading.show(
        status: "Broadcasting transaction..", maskType: EasyLoadingMaskType.black);
    if (amountTextController.text != "") {
      bool isBitcoinBase = false;
      double amount = 0.0;
      try {
        amount = double.parse(amountTextController.text);
      } catch (e) {
        amount = 0.0;
      }
      double btcAmount = CommonHelper.getEstimateValue(
          amount: amount,
          isBitcoinBase: isBitcoinBase,
          currencyExchangeRate:
              userSettingProvider.walletUserSetting.exchangeRate.exchangeRate);
      int amountInSats = (btcAmount * 100000000).round();
      // TODO:: email integration here
      for (String email in recipents) {
        String bitcoinAddress = "";
        if (email.contains("@")) {
          bitcoinAddress = bitcoinAddresses[email] ?? email;
        } else {
          bitcoinAddress = email;
        }
        if (bitcoinAddress.startsWith("tb")) {
          var receipinetAddress = bitcoinAddress;
          logger.i("Target addr: $receipinetAddress\nAmount: $amountInSats");
          String? emailAddressID;
          if (protonAddresses.isNotEmpty) {
            emailAddressID = protonAddresses.first.id;
          }
          String transactionID = await _lib.sendBitcoinWithAtlas(
              _blockchain!,
              _wallet,
              walletModel!.serverWalletID,
              accountModel!.serverAccountID,
              receipinetAddress,
              amountInSats,
              emailAddressID: emailAddressID,
              exchangeRateID:
                  userSettingProvider.walletUserSetting.exchangeRate.id);
          logger.i(walletModel!.serverWalletID);
          logger.i(
            accountModel!.serverAccountID,
          );
          logger.i(emailAddressID);
          if (transactionID.toLowerCase().contains("error")) {
            logger.e(transactionID);
          } else {
            logger.i("transaction id: $transactionID");
          }

          await WalletManager.fetchWalletTransactions(); // TODO:: only update by eventloop
          // await _lib.sendBitcoin(
          //     _blockchain!, _wallet, receipinetAddress, amountInSats);
        }
      }
    }
    EasyLoading.dismiss();
  }

  @override
  Future<void> updateFeeRate() async {
    // FeeRate feeRate_ = await _lib.estimateFeeRate(25, _blockchain!);
    // feeRate = feeRate_.asSatPerVb();
    // datasourceChangedStreamController.add(this);
    Future.delayed(const Duration(seconds: 5), () {
      updateFeeRate();
    });
  }

  Future<void> userFinishEmailBody() async {
    isEditingEmailBody = false;
    datasourceChangedStreamController.add(this);
  }

  Future<void> userFinishMemo() async {
    isEditingMemo = false;
    datasourceChangedStreamController.add(this);
  }

  @override
  void editEmailBody() {
    isEditingEmailBody = true;
    emailBodyFocusNode.requestFocus();
    datasourceChangedStreamController.add(this);
  }

  @override
  void editMemo() {
    isEditingMemo = true;
    memoFocusNode.requestFocus();
    datasourceChangedStreamController.add(this);
  }

  @override
  void move(NavigationIdentifier to) {
    // TODO: implement move
  }
}
