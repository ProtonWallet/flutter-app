import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:wallet/constants/constants.dart';
import 'package:wallet/helper/dbhelper.dart';
import 'package:wallet/helper/logger.dart';
import 'package:wallet/helper/wallet_manager.dart';
import 'package:wallet/models/contacts.model.dart';
import 'package:wallet/rust/proton_api/user_settings.dart';
import 'package:wallet/scenes/core/view.navigatior.identifiers.dart';
import 'package:wallet/scenes/core/viewmodel.dart';
import 'package:wallet/helper/bdk/helper.dart';
import 'package:wallet/scenes/debug/bdk.test.dart';
import 'package:wallet/scenes/send/send.coordinator.dart';

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
  List userWallets = [];
  List userAccounts = [];
  List<TextEditingController> recipientTextControllers = [];
  late TextEditingController memoTextController;
  late TextEditingController amountTextController;
  Map<String, String> bitcoinAddresses = {};

  int balance = 0;
  double feeRate = 1.0;
  bool inReview = false;
  TransactionFeeMode userTransactionFeeMode = TransactionFeeMode.medianPriority;
  FiatCurrency userFiatCurrency = FiatCurrency.usd;
  Map<FiatCurrency, int> fiatCurrency2exchangeRate = {};
  int lastExchangeRateTime = 0;
  bool amountTextControllerChanged = false;
  ValueNotifier isBitcoinBaseValueNotifier = ValueNotifier(true);
  bool amountFiatCurrencyTextControllerChanged = false;

  Future<void> sendCoin();

  Future<void> updateFeeRate();

  Future<void> updateExchangeRate();

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
    recipientTextControllers.add(TextEditingController(text: ""));
    memoTextController = TextEditingController();
    amountTextController = TextEditingController();
    await updateExchangeRate();
    amountTextController.addListener(() {
      datasourceChangedStreamController.add(this);
    });

    datasourceChangedStreamController.add(this);
    _blockchain = await _lib.initializeBlockchain(false);
    userWallets = await DBHelper.walletDao!.findAll();
    updateFeeRate();
    if (walletID == 0) {
      walletID = userWallets.first.id;
    }
    contactsEmail = await WalletManager.getContacts();
    updateWallet();
    EasyLoading.dismiss();
    datasourceChangedStreamController.add(this);
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
    if (inReview == true) {
      EasyLoading.show(
          status: "loading bitcoin address..",
          maskType: EasyLoadingMaskType.black);
      await loadBitcoinAddresses();
      EasyLoading.dismiss();
    }
    this.inReview = inReview;
    datasourceChangedStreamController.add(this);
  }

  Future<void> loadBitcoinAddresses() async {
    bitcoinAddresses.clear();
    for (TextEditingController textEditingController
        in recipientTextControllers) {
      String? bitcoinAddress =
          await WalletManager.lookupBitcoinAddress(textEditingController.text);
      bitcoinAddresses[textEditingController.text] = bitcoinAddress ?? "";
    }
  }

  @override
  void addRecipient() {
    recipientTextControllers.add(TextEditingController(text: ""));
    datasourceChangedStreamController.add(this);
  }

  @override
  void removeRecipient(int index) {
    recipientTextControllers.removeAt(index);
    datasourceChangedStreamController.add(this);
  }

  @override
  Stream<ViewModel> get datasourceChanged =>
      datasourceChangedStreamController.stream;

  @override
  Future<void> sendCoin() async {
    if (amountTextController.text != "") {
      double btcAmount = double.parse(amountTextController.text);
      int amount = (btcAmount * 100000000).round();
      // TODO:: email integration here
      for (TextEditingController textEditingController
          in recipientTextControllers) {
        String email = textEditingController.text;
        String bitcoinAddress = "";
        if (email.contains("@")) {
          bitcoinAddress = bitcoinAddresses[email] ?? email;
        } else {
          bitcoinAddress = email;
        }
        if (bitcoinAddress.startsWith("tb")) {
          var receipinetAddress = bitcoinAddress;
          logger.i("Target addr: $receipinetAddress\nAmount: $amount");
          await _lib.sendBitcoin(
              _blockchain!, _wallet, receipinetAddress, amount);
        }
      }
    }
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

  @override
  Future<void> updateExchangeRate() async {
    if (WalletManager.getCurrentTime() >
        lastExchangeRateTime + exchangeRateRefreshThreshold) {
      lastExchangeRateTime = WalletManager.getCurrentTime();
      fiatCurrency2exchangeRate[userFiatCurrency] = 6000000;
      // await WalletManager.getExchangeRate(userFiatCurrency);
      datasourceChangedStreamController.add(this);
    }
    Future.delayed(const Duration(seconds: exchangeRateRefreshThreshold + 1),
        () {
      updateExchangeRate();
    });
  }

  @override
  void move(NavigationIdentifier to) {
    // TODO: implement move
  }
}
