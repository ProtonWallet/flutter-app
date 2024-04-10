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

abstract class SendReviewViewModel extends ViewModel {
  SendReviewViewModel(super.coordinator, this.walletID, this.accountID);
  int walletID;
  int accountID;
  String fromAddress = "";
  List userWallets = [];
  List userAccounts = [];
  late TextEditingController coinController;
  late TextEditingController recipientTextController;
  late TextEditingController memoTextController;
  late TextEditingController amountTextController;
  late TextEditingController amountFiatCurrencyTextController;

  ValueNotifier fiatCurrencyNotifier = ValueNotifier(FiatCurrency.chf);

  late ValueNotifier valueNotifier;
  late ValueNotifier valueNotifierForAccount;
  int balance = 0;
  double feeRate = 1.0;
  Map<FiatCurrency, int> fiatCurrency2exchangeRate = {
    FiatCurrency.eur: 0,
    FiatCurrency.usd: 0,
    FiatCurrency.chf: 0,
  };
  int lastExchangeRateTime = 0;
  bool amountTextControllerChanged = false;
  bool amountFiatCurrencyTextControllerChanged = false;
  Future<void> sendCoin();
  Future<void> updateFeeRate();
  Future<void> updateExchangeRate();
  void setFiatCurrencyValue();
  void setCryptoCurrencyValue();
  List<String> contactsEmail = [];
}

class SendReviewViewModelImpl extends SendReviewViewModel {
  SendReviewViewModelImpl(super.coordinator, super.walletID, super.accountID);

  final datasourceChangedStreamController =
      StreamController<SendReviewViewModel>.broadcast();
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
    coinController = TextEditingController(text: "BTC");
    recipientTextController = TextEditingController();
    memoTextController = TextEditingController();
    amountTextController = TextEditingController();
    amountFiatCurrencyTextController = TextEditingController();
    await updateExchangeRate();
    amountTextController.addListener(() {
      if (amountTextControllerChanged == false) {
        setFiatCurrencyValue();
      }
    });
    amountFiatCurrencyTextController.addListener(() {
      if (amountFiatCurrencyTextControllerChanged == false) {
        setCryptoCurrencyValue();
      }
    });
    amountTextController.addListener(() {
      datasourceChangedStreamController.add(this);
    });
    amountFiatCurrencyTextController.addListener(() {
      datasourceChangedStreamController.add(this);
    });
    fiatCurrencyNotifier.addListener(() {
      setCryptoCurrencyValue();
    });
    coinController.addListener(() {
      setFiatCurrencyValue();
      datasourceChangedStreamController.add(this);
    });
    recipientTextController.text = "tb1qw2c3lxufxqe2x9s4rdzh65tpf4d7fssjgh8nv6";
    datasourceChangedStreamController.add(this);
    _blockchain = await _lib.initializeBlockchain(false);
    userWallets = await DBHelper.walletDao!.findAll();
    updateFeeRate();
    if (walletID == 0) {
      walletID = userWallets.first.id;
    }
    for (var element in userWallets) {
      if (element.id == walletID) {
        valueNotifier = ValueNotifier(element);
        valueNotifier.addListener(() {
          updateAccountList();
        });
      }
    }
    updateAccountList();
    List<ContactsModel> contacts = await WalletManager.getContacts();
    contactsEmail = contacts.map((e) => e.canonicalEmail).toList();
    EasyLoading.dismiss();
    datasourceChangedStreamController.add(this);
  }

  Future<void> updateAccountList() async {
    userAccounts =
        await DBHelper.accountDao!.findAllByWalletID(valueNotifier.value.id);
    accountID = userAccounts.first.id;
    valueNotifierForAccount = ValueNotifier(userAccounts.first);
    valueNotifierForAccount.addListener(() {
      walletID = valueNotifier.value.id;
      accountID = valueNotifierForAccount.value.id;
      updateWallet();
    });
    walletID = valueNotifier.value.id;
    accountID = valueNotifierForAccount.value.id;
    updateWallet();
    datasourceChangedStreamController.add(this);
  }

  Future<void> updateWallet() async {
    _wallet = await WalletManager.loadWalletWithID(walletID, accountID);
    var walletBalance = await _wallet.getBalance();
    balance = walletBalance.total;
    datasourceChangedStreamController.add(this);
  }

  @override
  Stream<ViewModel> get datasourceChanged =>
      datasourceChangedStreamController.stream;

  @override
  Future<void> sendCoin() async {
    if (amountTextController.text != "") {
      var receipinetAddress = recipientTextController.text;
      double btcAmount = double.parse(amountTextController.text);
      int amount = (btcAmount * 100000000).round();
      logger.i("Target addr: $receipinetAddress\nAmount: $amount");
      await _lib.sendBitcoin(_blockchain!, _wallet, receipinetAddress, amount);
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
      for (FiatCurrency apiFiatCurrency in fiatCurrency2exchangeRate.keys) {
        fiatCurrency2exchangeRate[apiFiatCurrency] = 6000000;
        // await WalletManager.getExchangeRate(apiFiatCurrency,
        //     time: lastExchangeRateTime);
      }
      datasourceChangedStreamController.add(this);
    }
  }

  @override
  void setCryptoCurrencyValue() {
    lockAmountTextController();
    updateExchangeRate();
    double amount = 0;
    if (amountFiatCurrencyTextController.text != "") {
      amount = double.parse(amountFiatCurrencyTextController.text);
    }
    double cryptoAmount = 0;
    if (coinController.text == CommonBitcoinUnit.btc.name.toUpperCase()) {
      cryptoAmount =
          amount * 100 / fiatCurrency2exchangeRate[fiatCurrencyNotifier.value]!;
    }
    // if (coinController.text == CommonBitcoinUnit.sats.name.toUpperCase()) {
    //   cryptoAmount = amount * 100 * 100000000 / fiatCurrency2exchangeRate[fiatCurrencyNotifier.value]! ;
    // }
    // if (cryptoAmount > balance / 100000000) {
    //   amountTextController.text = (balance / 100000000).toString();
    //   setFiatCurrencyValue();
    // } else {
    //   amountTextController.text = cryptoAmount.toString();
    // }
    amountTextController.text = cryptoAmount.toStringAsFixed(8);
    unlockAmountTextController();
    datasourceChangedStreamController.add(this);
  }

  void lockAmountTextController() {
    amountTextControllerChanged = true;
    amountFiatCurrencyTextControllerChanged = true;
  }

  void unlockAmountTextController() {
    amountTextControllerChanged = false;
    amountFiatCurrencyTextControllerChanged = false;
  }

  @override
  void setFiatCurrencyValue() {
    lockAmountTextController();
    updateExchangeRate();
    double amount = 0;
    if (amountTextController.text != "") {
      amount = double.parse(amountTextController.text);
    }
    // if (amount > balance / 100000000) {
    //   amount = balance / 100000000;
    //   amountTextController.text = (balance / 100000000).toString();
    // }
    double fiatCurrencyAmount = 0;
    if (coinController.text == CommonBitcoinUnit.btc.name.toUpperCase()) {
      fiatCurrencyAmount =
          amount * fiatCurrency2exchangeRate[fiatCurrencyNotifier.value]! / 100;
    }
    // if (coinController.text == CommonBitcoinUnit.sats.name.toUpperCase()) {
    //   fiatCurrencyAmount = amount *
    //       fiatCurrency2exchangeRate[fiatCurrencyNotifier.value]! /
    //       100 /
    //       100000000;
    // }
    amountFiatCurrencyTextController.text = fiatCurrencyAmount.toString();
    unlockAmountTextController();
    datasourceChangedStreamController.add(this);
  }

  @override
  void move(NavigationIdentifier to) {}
}
