import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:cryptography/cryptography.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:provider/provider.dart';
import 'package:wallet/constants/address.key.dart';
import 'package:wallet/constants/constants.dart';
import 'package:wallet/constants/transaction.detail.from.blockchain.dart';
import 'package:wallet/helper/common_helper.dart';
import 'package:wallet/helper/dbhelper.dart';
import 'package:wallet/managers/providers/models/wallet.key.dart';
import 'package:wallet/managers/providers/server.transaction.data.provider.dart';
import 'package:wallet/managers/providers/wallet.keys.provider.dart';
import 'package:wallet/managers/services/exchange.rate.service.dart';
import 'package:wallet/helper/extension/stream.controller.dart';
import 'package:wallet/helper/logger.dart';
import 'package:wallet/helper/user.settings.provider.dart';
import 'package:wallet/managers/users/user.manager.dart';
import 'package:wallet/managers/wallet/wallet.manager.dart';
import 'package:wallet/helper/walletkey_helper.dart';
import 'package:wallet/models/account.model.dart';
import 'package:wallet/models/bitcoin.address.model.dart';
import 'package:wallet/models/exchangerate.model.dart';
import 'package:wallet/models/transaction.info.model.dart';
import 'package:wallet/models/transaction.model.dart';
import 'package:wallet/models/wallet.model.dart';
import 'package:wallet/managers/wallet/proton.wallet.manager.dart';
import 'package:wallet/rust/api/api_service/wallet_client.dart';
import 'package:wallet/rust/api/bdk_wallet/account.dart';
import 'package:wallet/rust/api/bdk_wallet/transaction_details.dart';
import 'package:wallet/rust/proton_api/exchange_rate.dart';
import 'package:wallet/rust/proton_api/user_settings.dart';
import 'package:wallet/rust/proton_api/wallet.dart';
import 'package:wallet/scenes/core/coordinator.dart';
import 'package:wallet/scenes/core/view.navigatior.identifiers.dart';
import 'package:wallet/scenes/core/viewmodel.dart';
import 'package:wallet/scenes/history/details.coordinator.dart';
import 'package:wallet/rust/api/proton_api.dart' as proton_api;
import 'package:proton_crypto/proton_crypto.dart' as proton_crypto;

abstract class HistoryDetailViewModel
    extends ViewModel<HistoryDetailCoordinator> {
  int walletID;
  int accountID;
  String txid;
  String userLabel = "";

  HistoryDetailViewModel(
    super.coordinator,
    this.walletID,
    this.accountID,
    this.txid,
    this.userFiatCurrency,
  );

  String strWallet = "";
  String strAccount = "";
  List<String> addresses = [];
  List<TransactionInfoModel> recipients = [];
  int? blockConfirmTimestamp;
  double amount = 0.0;
  double fee = 0.0;
  bool isSend = false;
  bool initialized = false;
  bool isEditing = false;
  late TextEditingController memoController;
  late FocusNode memoFocusNode;
  late TransactionModel? transactionModel;
  String fromEmail = "";
  String toEmail = "";
  String body = "";
  Map<FiatCurrency, ProtonExchangeRate> fiatCurrency2exchangeRate = {};
  int lastExchangeRateTime = 0;
  FiatCurrency userFiatCurrency;
  ProtonExchangeRate? exchangeRate;
  late UserSettingProvider userSettingProvider;
  String errorMessage = "";
  bool isRecipientsFromBlockChain = false;
  String? selfBitcoinAddress;

  void editMemo();

  Future<void> updateSender(
    String senderName,
    String senderEmail,
  );
}

class HistoryDetailViewModelImpl extends HistoryDetailViewModel {
  HistoryDetailViewModelImpl(
    super.coordinator,
    super.walletID,
    super.accountID,
    super.txid,
    super.userFiatCurrency,
    this.userManager,
    this.protonWalletManager,
    this.serverTransactionDataProvider,
    this.walletClient,
    this.walletKeysProvider,
  );

  // final BdkLibrary _lib = BdkLibrary(coinType: appConfig.coinType);
  late FrbAccount _frbAccount;
  final datasourceChangedStreamController =
      StreamController<HistoryDetailViewModel>.broadcast();

  final UserManager userManager;
  final ProtonWalletManager protonWalletManager;
  final ServerTransactionDataProvider serverTransactionDataProvider;
  final WalletClient walletClient;
  final WalletKeysProvider walletKeysProvider;

  Uint8List? entropy;
  SecretKey? secretKey;
  List<AddressKey> addressKeys = [];

  @override
  void dispose() {
    datasourceChangedStreamController.close();
  }

  @override
  Future<void> loadData() async {
    EasyLoading.show(
        status: "decrypting detail..", maskType: EasyLoadingMaskType.black);
    try {
      memoController = TextEditingController();
      memoFocusNode = FocusNode();
      memoFocusNode.addListener(() {
        userFinishMemo();
      });
      userSettingProvider = Provider.of<UserSettingProvider>(
          Coordinator.rootNavigatorKey.currentContext!,
          listen: false);
      WalletModel walletModel = await DBHelper.walletDao!.findById(walletID);
      AccountModel accountModel =
          await DBHelper.accountDao!.findById(accountID);
      addressKeys = await WalletManager.getAddressKeys();

      ServerTransactionData serverTransactionData =
          await serverTransactionDataProvider
              .getServerTransactionDataByWalletAccount(
        walletModel,
        accountModel,
      );

      /// get user key
      var firstUserKey = await userManager.getFirstKey();
      String userPrivateKey = firstUserKey.privateKey;
      String userPassphrase = firstUserKey.passphrase;
      WalletKey? walletKey = await walletKeysProvider.getWalletKey(
        walletModel.serverWalletID,
      );

      if (walletKey != null) {
        var pgpEncryptedWalletKey = walletKey.walletKey;
        entropy = proton_crypto.decryptBinaryPGP(
          userPrivateKey,
          userPassphrase,
          pgpEncryptedWalletKey,
        );
        if (entropy != null) {
          secretKey = WalletKeyHelper.restoreSecretKeyFromEntropy(entropy!);
        }
      }

      for (TransactionModel transactionModel
          in serverTransactionData.transactions) {
        String txid = proton_crypto.decrypt(
            userPrivateKey, userPassphrase, transactionModel.transactionID);
        if (txid.isEmpty) {
          for (AddressKey addressKey in addressKeys) {
            try {
              txid = addressKey.decrypt(transactionModel.transactionID);
            } catch (e) {
              // logger.e(e.toString());
            }
            if (txid.isNotEmpty) {
              break;
            }
          }
        }
        transactionModel.externalTransactionID = utf8.encode(txid);
      }

      transactionModel =
          findServerTransactionByTXID(serverTransactionData.transactions, txid);

      datasourceChangedStreamController.sinkAddSafe(this);
      _frbAccount =
          (await WalletManager.loadWalletWithID(walletID, accountID))!;
      List<FrbTransactionDetails> history = await _frbAccount.getTransactions();
      strWallet = await WalletManager.getNameWithID(walletID);
      strAccount = await WalletManager.getAccountLabelWithID(accountID);

      try {
        recipients = await DBHelper.transactionInfoDao!.findAllRecipients(
            utf8.encode(txid),
            walletModel.serverWalletID,
            accountModel.serverAccountID);
      } catch (e) {
        logger.e(e.toString());
      }

      bool foundedInBDKHistory = false;
      for (var transaction in history) {
        if (transaction.txid == txid) {
          /// TODO:: fix me
          blockConfirmTimestamp = 0; //transaction.confirmationTime?.timestamp;
          amount =
              transaction.received.toDouble() - transaction.sent.toDouble();
          fee = transaction.fees!.toDouble();
          isSend = amount < 0;
          // bdk sent include fee, so need add back to make display send amount without fee
          if (isSend) {
            amount += transaction.fees ?? 0;
          }
          foundedInBDKHistory = true;

          if (isSend) {
            if (recipients.isEmpty) {
              TransactionDetailFromBlockChain? transactionDetailFromBlockChain =
                  await WalletManager.getTransactionDetailsFromBlockStream(
                      txid);
              if (transactionDetailFromBlockChain != null) {
                isRecipientsFromBlockChain = true;
                bool hasFindMineBitcoinAddress = false;
                for (Recipient recipient
                    in transactionDetailFromBlockChain.recipients) {
                  if (hasFindMineBitcoinAddress == false) {
                    if (await WalletManager.isMineBitcoinAddress(
                        _frbAccount, recipient.bitcoinAddress)) {
                      hasFindMineBitcoinAddress = true;
                      continue;
                    }
                  }
                  recipients.add(TransactionInfoModel(
                      id: null,
                      externalTransactionID: Uint8List(0),
                      amountInSATS: recipient.amountInSATS.abs(),
                      feeInSATS: fee.abs().toInt(),
                      isSend: 1,
                      transactionTime: 0,
                      feeMode: 0,
                      serverWalletID: walletModel.serverWalletID,
                      serverAccountID: accountModel.serverAccountID,
                      toEmail: "",
                      toBitcoinAddress: recipient.bitcoinAddress));
                }
              }
            }
          } else {
            addresses.add(txid);
            TransactionDetailFromBlockChain? transactionDetailFromBlockChain =
                await WalletManager.getTransactionDetailsFromBlockStream(txid);
            if (transactionDetailFromBlockChain != null) {
              for (Recipient recipient
                  in transactionDetailFromBlockChain.recipients) {
                if (await WalletManager.isMineBitcoinAddress(
                    _frbAccount, recipient.bitcoinAddress)) {
                  selfBitcoinAddress = recipient.bitcoinAddress;
                  break;
                }
              }
            }
          }
          datasourceChangedStreamController.sinkAddSafe(this);
          break;
        }
      }
      logger.i("transactionModel == null ? ${transactionModel == null}");
      if (transactionModel == null && secretKey != null) {
        String hashedTransactionID =
            await WalletKeyHelper.getHmacHashedString(secretKey!, txid);
        String encryptedLabel = await WalletKeyHelper.encrypt(secretKey!, "");

        var firstUserKey = await userManager.getFirstKey();
        String userPrivateKey = firstUserKey.privateKey;

        String transactionId = proton_crypto.encrypt(userPrivateKey, txid);
        DateTime now = DateTime.now();
        try {
          WalletTransaction walletTransaction =
              await proton_api.createWalletTransactions(
            walletId: walletModel.serverWalletID,
            walletAccountId: accountModel.serverAccountID,
            transactionId: transactionId,
            hashedTransactionId: hashedTransactionID,
            label: encryptedLabel,
            exchangeRateId: userSettingProvider.walletUserSetting.exchangeRate
                .id, // TODO:: fix it after finalize logic
            // transactionTime: blockConfirmTimestamp != null
            //     ? blockConfirmTimestamp.toString()
            //     : (now.millisecondsSinceEpoch ~/ 1000).toString(),
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
              transactionID: walletTransaction.transactionId,
              serverID: walletTransaction.id,
              transactionTime: walletTransaction.transactionTime,
              exchangeRateID: exchangeRateID,
              serverWalletID: walletTransaction.walletId,
              serverAccountID: walletTransaction.walletAccountId!,
              sender: walletTransaction.sender,
              tolist: walletTransaction.tolist,
              subject: walletTransaction.subject,
              body: walletTransaction.body);
          await DBHelper.transactionDao!.insertOrUpdate(transactionModel!);
        } catch (e) {
          if (e.toString().contains("Hashed TransactionId is already used") ||
              e.toString().contains("Code:2011")) {
            // TODO:: fix logic here, only fetch wallet transactions in account or specific hashedTransaction
            if (transactionModel == null) {
              rethrow;
            }
          }
        }
      }
      if (transactionModel!.label.isNotEmpty) {
        if (secretKey != null) {
          userLabel = await WalletKeyHelper.decrypt(
              secretKey!, utf8.decode(transactionModel!.label));

          strWallet = await WalletKeyHelper.decrypt(
            secretKey!,
            walletModel.name,
          );
        }
      }
      memoController.text = userLabel;

      for (AddressKey addressKey in addressKeys) {
        try {
          toEmail = toEmail.isNotEmpty
              ? toEmail
              : addressKey.decrypt(transactionModel!.tolist ?? "");
          fromEmail = fromEmail.isNotEmpty
              ? fromEmail
              : addressKey.decrypt(transactionModel!.sender ?? "");
          body = body.isNotEmpty
              ? body
              : addressKey.decrypt(transactionModel!.body ?? "");
        } catch (e) {
          logger.e(e.toString());
        }
        try {
          toEmail = toEmail.isNotEmpty
              ? toEmail
              : addressKey.decryptBinary(transactionModel!.tolist ?? "");
          fromEmail = fromEmail.isNotEmpty
              ? fromEmail
              : addressKey.decryptBinary(transactionModel!.sender ?? "");
          if (toEmail.isNotEmpty) {
            break;
          }
        } catch (e) {
          logger.e(e.toString());
        }
      }
      if (toEmail == "null") {
        toEmail = "";
      }
      if (fromEmail == "null") {
        fromEmail = "";
      }
      if (foundedInBDKHistory == false) {
        blockConfirmTimestamp = null;
        try {
          if (recipients.isNotEmpty) {
            // get transaction info locally, for sender
            fee = recipients.first.feeInSATS.toDouble();
            isSend = true;
            amount = 0;
            for (TransactionInfoModel recipient in recipients) {
              amount -= recipient.amountInSATS.toDouble();
            }
          } else {
            TransactionDetailFromBlockChain? transactionDetailFromBlockChain =
                await WalletManager.getTransactionDetailsFromBlockStream(txid);
            if (transactionDetailFromBlockChain != null) {
              fee = transactionDetailFromBlockChain.feeInSATS.toDouble();
              Recipient? me;
              for (Recipient recipient
                  in transactionDetailFromBlockChain.recipients) {
                BitcoinAddressModel? bitcoinAddressModel = await DBHelper
                    .bitcoinAddressDao!
                    .findBitcoinAddressInAccount(
                        recipient.bitcoinAddress, accountModel.serverAccountID);
                if (bitcoinAddressModel != null) {
                  me = recipient;
                  break;
                }
              }
              if (me != null) {
                isSend = false;
                selfBitcoinAddress = me.bitcoinAddress;
                amount = me.amountInSATS.toDouble();
              }
            }
          }
        } catch (e) {
          logger.e(e.toString());
        }
      }

      if (recipients.isNotEmpty && isRecipientsFromBlockChain) {
        // TODO:: clean logic here and make sure toEmail structure in backend,
        // It can be [{}, {}], or {"key": "value", "key2": "value2"}...
        try {
          var jsonList = jsonDecode(toEmail) as Map<String, dynamic>;
          for (String bitcoinAddress in jsonList.keys) {
            String email = jsonList[bitcoinAddress];
            for (TransactionInfoModel recipient in recipients) {
              if (recipient.toBitcoinAddress == bitcoinAddress) {
                recipient.toEmail = email;
                break;
              }
            }
          }
        } catch (e) {
          logger.e(e.toString());
          try {
            var jsonList = jsonDecode(toEmail) as List<dynamic>;
            for (dynamic map in jsonList) {
              String bitcoinAddress = map.keys.first;
              String email = map.values.first;
              for (TransactionInfoModel recipient in recipients) {
                if (recipient.toBitcoinAddress == bitcoinAddress) {
                  recipient.toEmail = email;
                  break;
                }
              }
            }
          } catch (e) {
            logger.e(e.toString());
          }
        }
      }
      if ((transactionModel?.exchangeRateID ?? "").isNotEmpty) {
        ExchangeRateModel? exchangeRateModel = await DBHelper.exchangeRateDao!
            .findByServerID(transactionModel!.exchangeRateID);
        if (exchangeRateModel != null) {
          BitcoinUnit bitcoinUnit = BitcoinUnit.values.firstWhere(
              (v) =>
                  v.name.toUpperCase() ==
                  exchangeRateModel.bitcoinUnit.toUpperCase(),
              orElse: () => defaultBitcoinUnit);
          FiatCurrency fiatCurrency = FiatCurrency.values.firstWhere(
              (v) =>
                  v.name.toUpperCase() ==
                  exchangeRateModel.fiatCurrency.toUpperCase(),
              orElse: () => defaultFiatCurrency);
          exchangeRate = ProtonExchangeRate(
            id: exchangeRateModel.serverID,
            bitcoinUnit: bitcoinUnit,
            fiatCurrency: fiatCurrency,
            exchangeRateTime: exchangeRateModel.exchangeRateTime,
            exchangeRate: exchangeRateModel.exchangeRate,
            cents: exchangeRateModel.cents,
          );
        }
      }
      exchangeRate ??= await ExchangeRateService.getExchangeRate(
          Provider.of<UserSettingProvider>(
                  Coordinator.rootNavigatorKey.currentContext!,
                  listen: false)
              .walletUserSetting
              .fiatCurrency,
          time: transactionModel?.transactionTime != null
              ? int.parse(transactionModel?.transactionTime ?? "0")
              : null);

      datasourceChangedStreamController.sinkAddSafe(this);
    } catch (e) {
      errorMessage = e.toString();
    }

    EasyLoading.dismiss();
    if (errorMessage.isNotEmpty) {
      CommonHelper.showErrorDialog(errorMessage);
      errorMessage = "";
    }
    datasourceChangedStreamController.sinkAddSafe(this);
    initialized = true;
  }

  TransactionModel? findServerTransactionByTXID(
      List<TransactionModel> transactions, String txid) {
    for (TransactionModel transactionModel in transactions) {
      String transactionTXID =
          utf8.decode(transactionModel.externalTransactionID);
      if (transactionTXID == txid) {
        return transactionModel;
      }
    }
    return null;
  }

  @override
  Stream<ViewModel> get datasourceChanged =>
      datasourceChangedStreamController.stream;

  Future<void> userFinishMemo() async {
    EasyLoading.show(status: "updating..", maskType: EasyLoadingMaskType.black);
    try {
      WalletModel _ = await DBHelper.walletDao!.findById(walletID);
      if (!memoFocusNode.hasFocus) {
        if (userLabel != memoController.text && secretKey != null) {
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
    } catch (e) {
      errorMessage = e.toString();
    }
    datasourceChangedStreamController.sinkAddSafe(this);
    EasyLoading.dismiss();
    if (errorMessage.isNotEmpty) {
      CommonHelper.showErrorDialog(errorMessage);
      errorMessage = "";
    }
  }

  @override
  Future<void> move(NavID to) async {}

  @override
  void editMemo() {
    isEditing = true;
    memoFocusNode.requestFocus();
    datasourceChangedStreamController.sinkAddSafe(this);
  }

  @override
  Future<void> updateSender(
    String senderName,
    String senderEmail,
  ) async {
    UserKey userkey = await userManager.getFirstKey();
    Map<String, dynamic> jsonMap = {
      "isExternalTransaction": true,
      "name": senderName,
      "email": senderEmail,
    };
    String jsonString = jsonEncode(jsonMap);
    String encryptedName = userkey.encrypt(jsonString);
    transactionModel!.sender = encryptedName;
    WalletTransaction _ =
        await walletClient.updateExternalWalletTransactionSender(
            walletId: transactionModel!.serverWalletID,
            walletAccountId: transactionModel!.serverAccountID,
            walletTransactionId: transactionModel!.serverID,
            sender: encryptedName);
    await serverTransactionDataProvider.insertOrUpdate(transactionModel!,
        notifyDataUpdate: true);

    /// walletTransaction update event will trigger ServerTransactionDataProvider update
    /// then it will notify wallet transaction bloc will update
    fromEmail = jsonString;
    datasourceChangedStreamController.sinkAddSafe(this);
  }
}
