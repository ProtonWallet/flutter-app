import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:wallet/constants/constants.dart';
import 'package:wallet/helper/crypto.price.helper.dart';
import 'package:wallet/helper/crypto.price.info.dart';
import 'package:wallet/helper/wallet_manager.dart';
import 'package:wallet/models/contacts.model.dart';
import 'package:wallet/rust/proton_api/user_settings.dart';
import 'package:wallet/scenes/core/viewmodel.dart';
import 'package:wallet/helper/bdk/helper.dart';
import 'package:wallet/scenes/debug/bdk.test.dart';
import '../../helper/dbhelper.dart';
import '../../helper/logger.dart';

abstract class SendViewModel extends ViewModel {
  SendViewModel(super.coordinator, this.walletID, this.accountID);

  int walletID;
  int accountID;
  String fromAddress = "";
  List userWallets = [];
  List userAccounts = [];
  late TextEditingController coinController;
  late TextEditingController recipientTextController;
  late TextEditingController memoTextController;
  late TextEditingController amountTextController;

  ApiFiatCurrency fiatCurrency = ApiFiatCurrency.chf;

  late ValueNotifier valueNotifier;
  late ValueNotifier valueNotifierForAccount;
  int balance = 2222;
  double feeRate = 1.0;
  Map<ApiFiatCurrency, int> fiatCurrency2exchangeRate = {
    ApiFiatCurrency.eur: 0,
    ApiFiatCurrency.usd: 0,
    ApiFiatCurrency.chf: 0,
  };
  int lastExchangeRateTime = 0;
  bool amountTextControllerChanged = false;
  double fiatCurrencyAmount = 0;

  Future<void> sendCoin();

  Future<void> updateFeeRate();

  Future<void> updateExchangeRate();

  double getFiatCurrencyValue({required double satsAmount});

  void setFiatCurrencyValue();

  void setCryptoCurrencyValue();

  void updateTransactionFee();

  List<String> contactsEmail = [];
  BitcoinTransactionFee bitcoinTransactionFee = BitcoinTransactionFee(
      block1Fee: 1.0,
      block2Fee: 1.0,
      block3Fee: 1.0,
      block5Fee: 1.0,
      block10Fee: 1.0,
      block20Fee: 1.0);
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
    coinController = TextEditingController(text: "BTC");
    recipientTextController = TextEditingController();
    memoTextController = TextEditingController();
    amountTextController = TextEditingController();
    await updateExchangeRate();
    amountTextController.addListener(() {
      if (amountTextControllerChanged == false) {
        setFiatCurrencyValue();
      }
    });
    amountTextController.addListener(() {
      datasourceChangedStreamController.add(this);
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

  @override
  Future<void> updateTransactionFee() async {
    bitcoinTransactionFee = await CryptoPriceHelper.getBitcoinTransactionFee();
    datasourceChangedStreamController.sink.add(this);
    Future.delayed(const Duration(seconds: 30), () {
      updateTransactionFee();
    });
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
    // var walletBalance = await _wallet.getBalance();
    balance = 2222; //walletBalance.total;
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
      for (ApiFiatCurrency apiFiatCurrency in fiatCurrency2exchangeRate.keys) {
        // don't send time since client time may be faster than server time, it will raise error
        fiatCurrency2exchangeRate[apiFiatCurrency] =
            await WalletManager.getExchangeRate(apiFiatCurrency);
      }
      datasourceChangedStreamController.add(this);
    }
  }

  @override
  void setCryptoCurrencyValue() {
    updateExchangeRate();
    double amount = 0;
    double cryptoAmount = 0;
    if (coinController.text == CommonBitcoinUnit.btc.name.toUpperCase()) {
      cryptoAmount = amount * 100 / fiatCurrency2exchangeRate[fiatCurrency]!;
    }
    amountTextController.text = cryptoAmount.toStringAsFixed(8);
    datasourceChangedStreamController.add(this);
  }

  @override
  void setFiatCurrencyValue() {
    updateExchangeRate();
    double amount = 0;
    if (amountTextController.text != "") {
      amount = double.parse(amountTextController.text);
    }
    fiatCurrencyAmount = 0;
    if (coinController.text == CommonBitcoinUnit.btc.name.toUpperCase()) {
      fiatCurrencyAmount = getFiatCurrencyValue(satsAmount: amount * 100000000);
    }
    if (coinController.text == CommonBitcoinUnit.sats.name.toUpperCase()) {
      fiatCurrencyAmount = getFiatCurrencyValue(satsAmount: amount);
    }
    datasourceChangedStreamController.add(this);
  }

  @override
  double getFiatCurrencyValue({required double satsAmount}) {
    return satsAmount *
        fiatCurrency2exchangeRate[fiatCurrency]! /
        100 /
        100000000;
  }
}
