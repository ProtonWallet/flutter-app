import 'dart:async';
import 'dart:convert';
import 'package:cryptography/cryptography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:provider/provider.dart';
import 'package:wallet/constants/address.public.key.dart';
import 'package:wallet/constants/app.config.dart';
import 'package:wallet/helper/common_helper.dart';
import 'package:wallet/helper/dbhelper.dart';
import 'package:wallet/helper/event_loop_helper.dart';
import 'package:wallet/helper/exchange.rate.service.dart';
import 'package:wallet/helper/extension/stream.controller.dart';
import 'package:wallet/helper/local_toast.dart';
import 'package:wallet/helper/logger.dart';
import 'package:wallet/helper/user.settings.provider.dart';
import 'package:wallet/helper/wallet_manager.dart';
import 'package:wallet/helper/walletkey_helper.dart';
import 'package:wallet/l10n/generated/locale.dart';
import 'package:wallet/models/account.model.dart';
import 'package:wallet/models/contacts.model.dart';
import 'package:wallet/models/transaction.info.model.dart';
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
  String errorMessage = "";
  late TextEditingController recipientTextController;
  late TextEditingController memoTextController;
  late TextEditingController amountTextController;
  Map<String, String> bitcoinAddresses = {};
  late UserSettingProvider userSettingProvider;

  Map<String, AddressPublicKey> email2AddressKey = {};
  List<AddressPublicKey> addressPublicKeys = [];

  List<String> recipents = [];
  List<ProtonAddress> protonAddresses = [];
  int balance = 0;
  double feeRateHighPriority = 2.0;
  double feeRateMedianPriority = 2.0;
  double feeRateLowPriority = 2.0;
  double feeRateSatPerVByte = 2.0;
  double baseFeeInSAT = 0;
  int estimatedFeeInSAT = 0;
  int amountInSATS = 0; // per recipient
  int totalAmountInSAT = 0; // total value
  int validRecipientCount = 0;
  bool inReview = false;
  TransactionFeeMode userTransactionFeeMode = TransactionFeeMode.medianPriority;
  bool amountTextControllerChanged = false;
  bool amountFiatCurrencyTextControllerChanged = false;
  bool hasEmailIntegrationRecipient = false;
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
  FiatCurrency originFiatCurrency = FiatCurrency.usd;

  String txid = "";

  void editEmailBody();

  void editMemo();

  Future<bool> sendCoin();

  Future<void> updateFeeRate();

  void addRecipient();

  void removeRecipient(int index);

  void updatePageStatus({required bool inReview});

  void addressAutoCompleteCallback();

  void updateTransactionFeeMode(TransactionFeeMode transactionFeeMode);

  List<ContactsModel> contactsEmail = [];
  late TxBuilder txBuilder;
  late TxBuilderResult txBuilderResult;
}

class SendViewModelImpl extends SendViewModel {
  SendViewModelImpl(super.coordinator, super.walletID, super.accountID);

  final datasourceChangedStreamController =
      StreamController<SendViewModel>.broadcast();
  final BdkLibrary _lib = BdkLibrary(coinType: appConfig.coinType);
  late Wallet _wallet;
  late Blockchain? _blockchain;

  @override
  Future<void> dispose() async {
    if (userSettingProvider.walletUserSetting.fiatCurrency.name !=
        originFiatCurrency.name) {
      Future.delayed(Duration.zero, () {
        updateUserSettingProvider(originFiatCurrency);
      });
    }
    datasourceChangedStreamController.close();
  }

  @override
  Future<void> loadData() async {
    EasyLoading.show(
        status: "loading exchange rate..", maskType: EasyLoadingMaskType.black);
    try {
      addressFocusNode = FocusNode();
      amountFocusNode = FocusNode();
      memoFocusNode = FocusNode();
      emailBodyFocusNode = FocusNode();
      memoTextController = TextEditingController();
      emailBodyController = TextEditingController();
      txBuilder = TxBuilder();

      addressFocusNode.addListener(() {
        if (addressFocusNode.hasFocus == false) {
          if (recipientTextController.text.isNotEmpty) {
            addressAutoCompleteCallback();
          }
        }
      });

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
      originFiatCurrency = userSettingProvider.walletUserSetting.fiatCurrency;
      fiatCurrencyNotifier.addListener(() async {
        updateUserSettingProvider(fiatCurrencyNotifier.value);
      });
      recipientTextController = TextEditingController(text: "");
      memoTextController = TextEditingController();
      amountTextController = TextEditingController();
      amountTextController.addListener(() {
        datasourceChangedStreamController.sinkAddSafe(this);
      });

      datasourceChangedStreamController.sinkAddSafe(this);
      _blockchain = await _lib.initializeBlockchain(false);
      updateFeeRate();
      contactsEmail = await WalletManager.getContacts();
      walletModel = await DBHelper.walletDao!.findById(walletID);
      accountModel = await DBHelper.accountDao!.findById(accountID);
      updateWallet();
      logger.i(DateTime.now().toString());
      await WalletManager.initContacts();
      logger.i(DateTime.now().toString());
    } catch (e) {
      errorMessage = e.toString();
    }
    EasyLoading.dismiss();
    if (errorMessage.isNotEmpty) {
      CommonHelper.showErrorDialog(errorMessage);
      errorMessage = "";
    }
    datasourceChangedStreamController.sinkAddSafe(this);
    List<ProtonAddress> addresses = await proton_api.getProtonAddress();
    protonAddresses =
        addresses.where((element) => element.status == 1).toList();
  }

  Future<void> updateWallet() async {
    _wallet = await WalletManager.loadWalletWithID(walletID, accountID);
    var walletBalance = await _wallet.getBalance();
    balance = walletBalance.total;
    datasourceChangedStreamController.sinkAddSafe(this);
  }

  @override
  Future<void> updateTransactionFeeMode(
      TransactionFeeMode transactionFeeMode) async {
    userTransactionFeeMode = transactionFeeMode;
    switch (userTransactionFeeMode) {
      case TransactionFeeMode.highPriority:
        feeRateSatPerVByte = feeRateHighPriority;
        break;
      case TransactionFeeMode.medianPriority:
        feeRateSatPerVByte = feeRateMedianPriority;
        break;
      case TransactionFeeMode.lowPriority:
        feeRateSatPerVByte = feeRateLowPriority;
        break;
    }
    await buildTransactionScript();
    datasourceChangedStreamController.sinkAddSafe(this);
  }

  @override
  Future<void> updatePageStatus({required bool inReview}) async {
    if (inReview == true) {
      hasEmailIntegrationRecipient = false;
      for (String email in recipents) {
        if (email2AddressKey.containsKey(email)) {
          hasEmailIntegrationRecipient = true;
        }
      }
      await updateTransactionFeeMode(userTransactionFeeMode);
    }
    this.inReview = inReview;
    datasourceChangedStreamController.sinkAddSafe(this);
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
    try {
      await loadBitcoinAddresses();
      if (CommonHelper.isBitcoinAddress(bitcoinAddresses[recipent]!)) {
        if (recipent.contains("@")) {
          List<AllKeyAddressKey> recipientAddressKeys = await proton_api
              .getAllPublicKeys(email: recipent, internalOnly: 0);
          if (recipientAddressKeys.isNotEmpty) {
            for (AllKeyAddressKey allKeyAddressKey in recipientAddressKeys) {
              // TODO:: use default key
              email2AddressKey[recipent] =
                  AddressPublicKey(publicKey: allKeyAddressKey.publicKey);
              break;
            }
          }
        }
        validRecipientCount++;
      }
    } catch (e) {
      errorMessage = e.toString();
    }
    EasyLoading.dismiss();
    if (errorMessage.isNotEmpty) {
      CommonHelper.showErrorDialog(errorMessage);
      errorMessage = "";
    }
    datasourceChangedStreamController.sinkAddSafe(this);
  }

  @override
  void removeRecipient(int index) {
    String recipient = recipents[index];
    if (CommonHelper.isBitcoinAddress(bitcoinAddresses[recipient]!)) {
      validRecipientCount--;
    }
    recipents.removeAt(index);
    datasourceChangedStreamController.sinkAddSafe(this);
  }

  @override
  Stream<ViewModel> get datasourceChanged =>
      datasourceChangedStreamController.stream;

  Future<void> buildTransactionScript() async {
    try {
      if (amountTextController.text != "") {
        // bool isBitcoinBase = false;
        double amount = 0.0;
        try {
          amount = double.parse(amountTextController.text);
        } catch (e) {
          amount = 0.0;
        }
        double btcAmount = userSettingProvider.getNotionalInBTC(amount);
        amountInSATS = (btcAmount * 100000000).ceil();
        txBuilder = TxBuilder();

        for (String email in recipents) {
          String bitcoinAddress = "";
          if (email.contains("@")) {
            bitcoinAddress = bitcoinAddresses[email] ?? email;
          } else {
            bitcoinAddress = email;
          }
          if (CommonHelper.isBitcoinAddress(bitcoinAddress)) {
            logger.i("Target addr: $bitcoinAddress\nAmount: $amountInSATS");
            Address address = await Address.create(address: bitcoinAddress);

            final script = await address.scriptPubKey();
            txBuilder = txBuilder.addRecipient(script, amountInSATS);
          }
        }
        txBuilderResult =
            await txBuilder.feeRate(feeRateSatPerVByte).finish(_wallet);
        estimatedFeeInSAT = txBuilderResult.txDetails.fee ?? 0;
        totalAmountInSAT = txBuilderResult.txDetails.sent -
            (txBuilderResult.txDetails.fee ?? 0) -
            txBuilderResult.txDetails.received;
        baseFeeInSAT = estimatedFeeInSAT / feeRateSatPerVByte;
      }
    } catch (e) {
      errorMessage = e.toString();
      if (errorMessage.isNotEmpty) {
        CommonHelper.showErrorDialog(errorMessage);
        errorMessage = "";
      }
      rethrow;
    }
    datasourceChangedStreamController.sinkAddSafe(this);
  }

  @override
  Future<bool> sendCoin() async {
    EasyLoading.show(
        status: "Broadcasting transaction..",
        maskType: EasyLoadingMaskType.black);
    try {
      String? emailAddressID;
      if (protonAddresses.isNotEmpty) {
        emailAddressID = protonAddresses.first.id;
        try {
          List<AllKeyAddressKey> recipientAddressKeys =
              await proton_api.getAllPublicKeys(
                  email: protonAddresses.first.email, internalOnly: 0);
          if (recipientAddressKeys.isNotEmpty) {
            for (AllKeyAddressKey allKeyAddressKey in recipientAddressKeys) {
              // TODO:: use default key
              addressPublicKeys
                  .add(AddressPublicKey(publicKey: allKeyAddressKey.publicKey));
              break;
            }
          }
        } catch (e) {
          logger.e(e.toString());
        }
      }
      String? encryptedLabel;
      SecretKey? secretKey =
          await WalletManager.getWalletKey(walletModel!.serverWalletID);
      if (secretKey != null) {
        encryptedLabel =
            await WalletKeyHelper.encrypt(secretKey, memoTextController.text);
      }

      String? encryptedMessage;
      for (String email in recipents) {
        if (email2AddressKey.containsKey(email)) {
          addressPublicKeys.add(email2AddressKey[email]!);
        }
      }

      encryptedMessage = AddressPublicKey.encryptWithKeys(
          addressPublicKeys, emailBodyController.text);

      txid = await _lib.sendBitcoinWithAPI(
          _blockchain!,
          _wallet,
          walletModel!.serverWalletID,
          accountModel!.serverAccountID,
          txBuilderResult,
          emailAddressID: emailAddressID,
          exchangeRateID: userSettingProvider.walletUserSetting.exchangeRate.id,
          encryptedLabel: encryptedLabel,
          encryptedMessage: encryptedMessage);
      try {
        if (txid.isNotEmpty) {
          logger.i("txid = $txid");

          // for multi-recipients
          for (String email in recipents) {
            String bitcoinAddress = "";
            if (email.contains("@")) {
              bitcoinAddress = bitcoinAddresses[email] ?? email;
            } else {
              bitcoinAddress = email;
            }
            await DBHelper.transactionInfoDao!.insert(TransactionInfoModel(
                id: null,
                externalTransactionID: utf8.encode(txid),
                amountInSATS: amountInSATS,
                feeInSATS: estimatedFeeInSAT,
                isSend: 1,
                transactionTime: DateTime.now().millisecondsSinceEpoch ~/ 1000,
                feeMode: userTransactionFeeMode.index,
                serverWalletID: walletModel!.serverWalletID,
                serverAccountID: accountModel!.serverAccountID,
                toEmail: email.contains("@") ? email : "",
                toBitcoinAddress: bitcoinAddress));
          }
        }
      } catch (e) {
        logger.e(e.toString());
      }
    } catch (e) {
      errorMessage = e.toString();
    }
    if (errorMessage.isNotEmpty) {
      CommonHelper.showErrorDialog(errorMessage);
      errorMessage = "";
      EasyLoading.dismiss();
      return false;
    }
    try {
      await EventLoopHelper.runOnce();
    } catch (e) {
      e.toString();
    }
    EasyLoading.dismiss();
    return true;
  }

  @override
  Future<void> updateFeeRate() async {
    FeeRate feeRate_ = await _lib.estimateFeeRate(1, _blockchain!);
    feeRateHighPriority = feeRate_.asSatPerVb();
    feeRate_ = await _lib.estimateFeeRate(6, _blockchain!);
    feeRateMedianPriority = feeRate_.asSatPerVb();
    feeRate_ = await _lib.estimateFeeRate(15, _blockchain!);
    feeRateLowPriority = feeRate_.asSatPerVb();
    // feeRateLowPriority = 2.0;
    try {
      datasourceChangedStreamController.sinkAddSafe(this);
    } catch (e) {
      logger.e(e.toString());
    }
    // TODO:: fixme to avoid crash after coordinate pop
    // Future.delayed(const Duration(seconds: 5), () {
    //   updateFeeRate();
    // });
  }

  Future<void> userFinishEmailBody() async {
    isEditingEmailBody = false;
    datasourceChangedStreamController.sinkAddSafe(this);
  }

  Future<void> userFinishMemo() async {
    isEditingMemo = false;
    datasourceChangedStreamController.sinkAddSafe(this);
  }

  @override
  void editEmailBody() {
    isEditingEmailBody = true;
    emailBodyFocusNode.requestFocus();
    datasourceChangedStreamController.sinkAddSafe(this);
  }

  @override
  void editMemo() {
    isEditingMemo = true;
    memoFocusNode.requestFocus();
    datasourceChangedStreamController.sinkAddSafe(this);
  }

  @override
  void move(NavID to) {
    // TODO: implement move
  }

  @override
  void addressAutoCompleteCallback() {
    if (balance > 0) {
      addRecipient();
    } else {
      if (Coordinator.navigatorKey.currentContext != null) {
        BuildContext context = Coordinator.navigatorKey.currentContext!;
        LocalToast.showErrorToast(
            context, S.of(context).error_you_dont_have_sufficient_balance);
      }
    }
  }
}
