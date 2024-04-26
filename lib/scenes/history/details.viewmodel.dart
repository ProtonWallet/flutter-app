import 'dart:async';
import 'dart:convert';
import 'package:cryptography/cryptography.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:wallet/constants/address.key.dart';
import 'package:wallet/constants/constants.dart';
import 'package:wallet/helper/bdk/helper.dart';
import 'package:wallet/helper/currency_helper.dart';
import 'package:wallet/helper/dbhelper.dart';
import 'package:wallet/helper/logger.dart';
import 'package:wallet/helper/secure_storage_helper.dart';
import 'package:wallet/helper/wallet_manager.dart';
import 'package:wallet/helper/walletkey_helper.dart';
import 'package:wallet/models/account.model.dart';
import 'package:wallet/models/transaction.model.dart';
import 'package:wallet/models/wallet.model.dart';
import 'package:wallet/rust/bdk/types.dart';
import 'package:wallet/rust/proton_api/exchange_rate.dart';
import 'package:wallet/rust/proton_api/user_settings.dart';
import 'package:wallet/rust/proton_api/wallet.dart';
import 'package:wallet/scenes/core/view.navigatior.identifiers.dart';
import 'package:wallet/scenes/core/viewmodel.dart';
import 'package:wallet/scenes/debug/bdk.test.dart';
import 'package:wallet/scenes/history/details.coordinator.dart';
import 'package:wallet/rust/api/proton_api.dart' as proton_api;
import 'package:proton_crypto/proton_crypto.dart' as proton_crypto;

abstract class HistoryDetailViewModel
    extends ViewModel<HistoryDetailCoordinator> {
  int walletID;
  int accountID;
  String txid;
  String userLabel = "";

  HistoryDetailViewModel(super.coordinator, this.walletID, this.accountID,
      this.txid, this.userFiatCurrency);

  String strWallet = "";
  String strAccount = "";
  String address = "";
  int? blockConfirmTimestamp;
  double amount = 0.0;
  double notional = 0.0;
  double fee = 0.0;
  bool isSend = false;
  bool initialized = false;
  bool isEditing = false;
  late TextEditingController memoController;
  late FocusNode memoFocusNode;
  late TransactionModel? transactionModel;
  String fromEmail = "";
  String toEmail = "";
  Map<FiatCurrency, ProtonExchangeRate> fiatCurrency2exchangeRate = {};
  int lastExchangeRateTime = 0;
  FiatCurrency userFiatCurrency;

  void editMemo();

  Future<void> updateExchangeRate();
}

class HistoryDetailViewModelImpl extends HistoryDetailViewModel {
  HistoryDetailViewModelImpl(super.coordinator, super.walletID, super.accountID,
      super.txid, super.userFiatCurrency);

  final BdkLibrary _lib = BdkLibrary();
  late Wallet _wallet;
  final datasourceChangedStreamController =
      StreamController<HistoryDetailViewModel>.broadcast();

  @override
  void dispose() {
    datasourceChangedStreamController.close();
  }

  @override
  Future<void> loadData() async {
    memoController = TextEditingController();
    memoFocusNode = FocusNode();
    memoFocusNode.addListener(() {
      userFinishMemo();
    });
    WalletModel walletModel = await DBHelper.walletDao!.findById(walletID);
    AccountModel accountModel = await DBHelper.accountDao!.findById(accountID);
    SecretKey? secretKey =
        await WalletManager.getWalletKey(walletModel.serverWalletID);

    transactionModel = await DBHelper.transactionDao!
        .findByExternalTransactionID(utf8.encode(txid));

    datasourceChangedStreamController.sink.add(this);
    _wallet = await WalletManager.loadWalletWithID(walletID, accountID);
    List<TransactionDetails> history = await _lib.getAllTransactions(_wallet);
    strWallet = await WalletManager.getNameWithID(walletID);
    strAccount = await WalletManager.getAccountLabelWithID(accountID);
    address = txid.substring(0, 32);
    bool foundedInBDKHistory = false;
    for (var transaction in history) {
      if (transaction.txid == txid) {
        blockConfirmTimestamp = transaction.confirmationTime?.timestamp;
        amount = transaction.received.toDouble() - transaction.sent.toDouble();
        fee = transaction.fee!.toDouble();
        notional = CurrencyHelper.sat2usdt(amount).abs();
        isSend = amount < 0;
        foundedInBDKHistory = true;
        datasourceChangedStreamController.sink.add(this);
        break;
      }
    }
    if (foundedInBDKHistory == false) {
      try {
        Map<String, dynamic> transactionDetail =
            await WalletManager.getTransactionDetailsFromBlockStream(txid);
        logger.i("Get transactionDetail from BlockStream: $transactionDetail");
        blockConfirmTimestamp = null;
        amount = (transactionDetail['fees'] +
                transactionDetail['outputs'][0]['value'])
            .toDouble();
        fee = transactionDetail['fees'].toDouble();
        notional = CurrencyHelper.sat2usdt(amount).abs();
        isSend = true; // TODO:: fix this logic
        datasourceChangedStreamController.sink.add(this);
      } catch (e) {
        logger.e(e.toString());
      }
    }
    logger.i("transactionModel == null ? ${transactionModel == null}");
    if (transactionModel == null) {
      String hashedTransactionID =
          await WalletKeyHelper.getHmacHashedString(secretKey!, txid);
      String encryptedLabel = await WalletKeyHelper.encrypt(secretKey, "");

      String userPrivateKey =
          await SecureStorageHelper.instance.get("userPrivateKey");
      String transactionId = proton_crypto.encrypt(userPrivateKey, txid);
      DateTime now = DateTime.now();
      WalletTransaction walletTransaction =
          await proton_api.createWalletTransactions(
        walletId: walletModel.serverWalletID,
        walletAccountId: accountModel.serverAccountID,
        transactionId: transactionId,
        hashedTransactionId: hashedTransactionID,
        label: encryptedLabel,
        transactionTime: blockConfirmTimestamp != null
            ? blockConfirmTimestamp.toString()
            : (now.millisecondsSinceEpoch ~/ 1000).toString(),
      );
      String exchangeRateID = "";
      if (walletTransaction.exchangeRate != null) {
        exchangeRateID = walletTransaction.exchangeRate!.id;
      }
      transactionModel = TransactionModel(
          id: null,
          walletID: walletID,
          label: utf8.encode(walletTransaction.label ?? ""),
          externalTransactionID: utf8.encode(txid),
          createTime: now.millisecondsSinceEpoch ~/ 1000,
          modifyTime: now.millisecondsSinceEpoch ~/ 1000,
          hashedTransactionID:
              utf8.encode(walletTransaction.hashedTransactionId ?? ""),
          transactionID: walletTransaction.id,
          transactionTime: walletTransaction.transactionTime,
          exchangeRateID: exchangeRateID,
          serverWalletID: walletTransaction.walletId,
          serverAccountID: walletTransaction.walletAccountId!,
          sender: walletTransaction.sender,
          tolist: walletTransaction.tolist,
          subject: walletTransaction.subject,
          body: walletTransaction.body);
      await DBHelper.transactionDao!.insertOrUpdate(transactionModel!);
    }
    if (transactionModel!.label.isNotEmpty) {
      userLabel = await WalletKeyHelper.decrypt(
          secretKey!, utf8.decode(transactionModel!.label));
    }
    memoController.text = userLabel;

    List<AddressKey> addressKeys = await WalletManager.getAddressKeys();

    for (AddressKey addressKey in addressKeys) {
      try {
        toEmail = addressKey.decryptBinary(transactionModel!.tolist);
        fromEmail = addressKey.decryptBinary(transactionModel!.sender);
        if (toEmail.isNotEmpty) {
          break;
        }
      } catch (e) {
        logger.e(e.toString());
      }
    }

    logger.i("txid: $txid");
    logger.i("toEmail: $toEmail, ${transactionModel!.tolist}");
    logger.i("fromEmail: $fromEmail, ${transactionModel!.sender}");
    datasourceChangedStreamController.add(this);
    initialized = true;
    return;
  }

  @override
  Stream<ViewModel> get datasourceChanged =>
      datasourceChangedStreamController.stream;

  Future<void> userFinishMemo() async {
    EasyLoading.show(status: "updating..", maskType: EasyLoadingMaskType.black);
    WalletModel walletModel = await DBHelper.walletDao!.findById(walletID);
    SecretKey? secretKey =
        await WalletManager.getWalletKey(walletModel.serverWalletID);
    if (!memoFocusNode.hasFocus) {
      if (userLabel != memoController.text) {
        userLabel = memoController.text;
        String encryptedLabel =
            await WalletKeyHelper.encrypt(secretKey!, userLabel);
        transactionModel!.label = utf8.encode(encryptedLabel);
        DBHelper.transactionDao!.insertOrUpdate(transactionModel!);
        await proton_api.updateWalletTransactionLabel(
          walletId: transactionModel!.serverWalletID,
          walletAccountId: transactionModel!.serverAccountID,
          walletTransactionId: transactionModel!.transactionID,
          label: encryptedLabel,
        );
      }
      isEditing = false;
    }
    datasourceChangedStreamController.add(this);
    EasyLoading.dismiss();
  }

  @override
  Future<void> updateExchangeRate() async {
    if (WalletManager.getCurrentTime() >
        lastExchangeRateTime + exchangeRateRefreshThreshold) {
      lastExchangeRateTime = WalletManager.getCurrentTime();
      fiatCurrency2exchangeRate[userFiatCurrency] =
          await WalletManager.getExchangeRate(userFiatCurrency);
      datasourceChangedStreamController.add(this);
    }
    Future.delayed(const Duration(seconds: exchangeRateRefreshThreshold + 1),
        () {
      updateExchangeRate();
    });
  }

  @override
  void move(NavigationIdentifier to) {}

  @override
  void editMemo() {
    isEditing = true;
    memoFocusNode.requestFocus();
    datasourceChangedStreamController.add(this);
  }
}
