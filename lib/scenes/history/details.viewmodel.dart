import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:proton_crypto/proton_crypto.dart' as proton_crypto;
import 'package:wallet/constants/address.key.dart';
import 'package:wallet/constants/constants.dart';
import 'package:wallet/constants/transaction.detail.from.blockchain.dart';
import 'package:wallet/helper/common_helper.dart';
import 'package:wallet/helper/dbhelper.dart';
import 'package:wallet/helper/exceptions.dart';
import 'package:wallet/helper/logger.dart';
import 'package:wallet/helper/walletkey_helper.dart';
import 'package:wallet/managers/providers/contacts.data.provider.dart';
import 'package:wallet/managers/providers/data.provider.manager.dart';
import 'package:wallet/managers/providers/models/wallet.key.dart';
import 'package:wallet/managers/providers/server.transaction.data.provider.dart';
import 'package:wallet/managers/providers/user.settings.data.provider.dart';
import 'package:wallet/managers/providers/wallet.keys.provider.dart';
import 'package:wallet/managers/services/exchange.rate.service.dart';
import 'package:wallet/managers/users/user.key.dart';
import 'package:wallet/managers/users/user.manager.dart';
import 'package:wallet/managers/wallet/wallet.manager.dart';
import 'package:wallet/models/bitcoin.address.model.dart';
import 'package:wallet/models/contacts.model.dart';
import 'package:wallet/models/exchangerate.model.dart';
import 'package:wallet/models/transaction.info.model.dart';
import 'package:wallet/models/transaction.model.dart';
import 'package:wallet/models/wallet.model.dart';
import 'package:wallet/rust/api/api_service/wallet_client.dart';
import 'package:wallet/rust/api/bdk_wallet/account.dart';
import 'package:wallet/rust/api/bdk_wallet/transaction_details.dart';
import 'package:wallet/rust/api/proton_api.dart' as proton_api;
import 'package:wallet/rust/common/errors.dart';
import 'package:wallet/rust/proton_api/exchange_rate.dart';
import 'package:wallet/rust/proton_api/user_settings.dart';
import 'package:wallet/rust/proton_api/wallet.dart';
import 'package:wallet/scenes/core/view.navigatior.identifiers.dart';
import 'package:wallet/scenes/core/viewmodel.dart';
import 'package:wallet/scenes/history/details.coordinator.dart';

abstract class HistoryDetailViewModel
    extends ViewModel<HistoryDetailCoordinator> {
  String walletID;
  String accountID;
  String txID;
  String userLabel = "";

  HistoryDetailViewModel(
    super.coordinator,
    this.walletID,
    this.accountID,
    this.txID,
    this.userFiatCurrency,
    this.userSettingsDataProvider,
    this.contactsDataProvider,
  );

  String strWallet = "";
  String strAccount = "";
  List<String> addresses = [];
  List<ContactsModel> contactsEmails = [];
  List<TransactionInfoModel> recipients = [];
  int? transactionTime;
  double amount = 0.0;
  double fee = 0.0;
  bool isInternalTransaction = false;
  bool isSend = false;
  bool initialized = false;
  bool isEditing = false;
  bool displayBalance = true;
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
  String errorMessage = "";
  bool isRecipientsFromBlockChain = false;
  String? selfBitcoinAddress;
  final UserSettingsDataProvider userSettingsDataProvider;

  // contact data provider
  final ContactsDataProvider contactsDataProvider;
  late ScrollController scrollController;

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
    super.txID,
    super.userFiatCurrency,
    this.userManager,
    this.serverTransactionDataProvider,
    this.walletClient,
    this.walletKeysProvider,
    super.userSettingsDataProvider,
    super.contactsDataProvider,
  );

  late FrbAccount _frbAccount;

  final UserManager userManager;
  final ServerTransactionDataProvider serverTransactionDataProvider;
  final WalletClient walletClient;
  final WalletKeysProvider walletKeysProvider;

  Uint8List? entropy;
  SecretKey? secretKey;
  List<AddressKey> addressKeys = [];

  @override
  Future<void> loadData() async {
    memoController = TextEditingController();
    memoFocusNode = FocusNode();
    memoFocusNode.addListener(userFinishMemo);
    scrollController = ScrollController();
    displayBalance = await userSettingsDataProvider.getDisplayBalance();

    contactsEmails = await contactsDataProvider.getContacts() ?? [];

    if (addressKeys.isEmpty) {
      addressKeys = await WalletManager.getAddressKeys();
    }

    var serverTrans = await serverTransactionDataProvider.getTransByAccountID(
      walletID,
      accountID,
    );

    /// get user key
    final WalletKey? walletKey = await walletKeysProvider.getWalletKey(
      walletID,
    );
    if (walletKey != null) {
      final userKey = await userManager.getUserKey(walletKey.userKeyId);
      secretKey = WalletKeyHelper.decryptWalletKey(userKey, walletKey);
    }

    transactionModel = await findServerTransactionByTxID(
      serverTrans,
      txID,
    );

    if (transactionModel != null) {
      isInternalTransaction =
          (transactionModel!.type == TransactionType.protonToProtonSend.index ||
              transactionModel!.type ==
                  TransactionType.protonToProtonReceive.index);
    }

    sinkAddSafe();
    _frbAccount = (await WalletManager.loadWalletWithID(
      walletID,
      accountID,
    ))!;
    final List<FrbTransactionDetails> history =
        await _frbAccount.getTransactions();
    strWallet = await WalletManager.getNameWithID(walletID);
    strAccount = await WalletManager.getAccountLabelWithID(accountID);

    try {
      recipients = await DBHelper.transactionInfoDao!.findAllRecipients(
        utf8.encode(txID),
        walletID,
        accountID,
      );
    } catch (e, stacktrace) {
      logger.e(
        "details.viewmodel error: $e stacktrace: $stacktrace",
      );
    }

    bool foundedInBDKHistory = false;
    for (var transaction in history) {
      if (transaction.txid == txID) {
        amount = transaction.received.toDouble() - transaction.sent.toDouble();
        fee = transaction.fees!.toDouble();
        isSend = amount < 0;
        // bdk sent include fee, so need add back to make display send amount without fee
        if (isSend) {
          amount += (transaction.fees ?? BigInt.zero).toDouble();
        }

        transaction.time.when(
          confirmed: (confirmationTime) {
            logger.d('Confirmed transaction time: $confirmationTime');
            transactionTime = confirmationTime.toInt();
          },
          unconfirmed: (lastSeen) {
            logger.d('Unconfirmed transaction last seen: $lastSeen');
            // needs to show in progress if it's not confirmed
            // transactionTime = lastSeen;
          },
        );

        foundedInBDKHistory = true;
        if (isSend) {
          if (recipients.isEmpty) {
            final TransactionDetailFromBlockChain?
                transactionDetailFromBlockChain =
                await WalletManager.getTransactionDetailsFromBlockStream(txID);
            if (transactionDetailFromBlockChain != null) {
              isRecipientsFromBlockChain = true;
              bool hasFindMineBitcoinAddress = false;
              for (Recipient recipient
                  in transactionDetailFromBlockChain.recipients) {
                if (!hasFindMineBitcoinAddress) {
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
                    serverWalletID: walletID,
                    serverAccountID: accountID,
                    toEmail: "",
                    toBitcoinAddress: recipient.bitcoinAddress));
              }
            }
          }
        } else {
          addresses.add(txID);
          final TransactionDetailFromBlockChain?
              transactionDetailFromBlockChain =
              await WalletManager.getTransactionDetailsFromBlockStream(txID);
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
        sinkAddSafe();
        break;
      }
    }

    if (!foundedInBDKHistory) {
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
          final TransactionDetailFromBlockChain?
              transactionDetailFromBlockChain =
              await WalletManager.getTransactionDetailsFromBlockStream(txID);
          if (transactionDetailFromBlockChain != null) {
            fee = transactionDetailFromBlockChain.feeInSATS.toDouble();
            Recipient? me;
            for (Recipient recipient
                in transactionDetailFromBlockChain.recipients) {
              final BitcoinAddressModel? bitcoinAddressModel =
                  await DBHelper.bitcoinAddressDao!.findBitcoinAddressInAccount(
                recipient.bitcoinAddress,
                accountID,
              );
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
      } catch (e, stacktrace) {
        logger.e(
          "details.viewmodel error: $e stacktrace: $stacktrace",
        );
      }
    }
    logger.i("transactionModel == null ? ${transactionModel == null}");
    if (transactionModel == null && secretKey != null) {
      final String hashedTransactionID =
          await WalletKeyHelper.getHmacHashedString(
        secretKey!,
        txID,
      );

      /// default label
      final String encryptedLabel = await WalletKeyHelper.encrypt(
        secretKey!,
        "",
      );

      final primaryUserKey = await userManager.getPrimaryKey();
      final String transactionId = proton_crypto.encrypt(
        primaryUserKey.privateKey,
        txID,
      );
      final DateTime now = DateTime.now();
      try {
        // TODO(fix): move this to provider
        final walletTransaction = await proton_api.createWalletTransactions(
          walletId: walletID,
          walletAccountId: accountID,
          transactionId: transactionId,
          hashedTransactionId: hashedTransactionID,
          label: encryptedLabel,
          exchangeRateId: userSettingsDataProvider
              .exchangeRate.id, // TODO(fix): fix it after finalize logic
        );

        String exchangeRateID = userSettingsDataProvider.exchangeRate.id;
        if (walletTransaction.exchangeRate != null) {
          exchangeRateID = walletTransaction.exchangeRate!.id;
        }
        transactionModel = TransactionModel(
            id: -1,
            type: isSend
                ? TransactionType.externalSend.index
                : TransactionType.externalReceive.index,
            label: utf8.encode(walletTransaction.label ?? ""),
            externalTransactionID: utf8.encode(txID),
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
      } on BridgeError catch (e, stacktrace) {
        logger.e(
          "details.viewmodel error: $e stacktrace: $stacktrace",
        );
        // parse the server error code
        final responseError = parseResponseError(e);
        if (responseError != null) {
          if (responseError.code == 2011) {
            if (transactionModel == null) {
              /// this will only happend when user open web app and mobile app in same time (race condition)
              /// need to reload wallet transactions from server
              /// throw exceptions if it's still happening
              await serverTransactionDataProvider.reloadAccountTransactions(
                walletID,
                accountID,
              );
              serverTrans =
                  await serverTransactionDataProvider.getTransByAccountID(
                walletID,
                accountID,
              );
              transactionModel = await findServerTransactionByTxID(
                serverTrans,
                txID,
              );
              if (transactionModel == null) {
                rethrow;
              }
            }
          }
        }
      } catch (e, stacktrace) {
        logger.e(
          "details.viewmodel error: $e stacktrace: $stacktrace",
        );
      }
    }
    if (secretKey != null) {
      if (transactionModel!.label.isNotEmpty) {
        userLabel = await WalletKeyHelper.decrypt(
            secretKey!, utf8.decode(transactionModel!.label));
      }
      final walletModel = await DBHelper.walletDao!.findByServerID(walletID);
      try {
        strWallet = await WalletKeyHelper.decrypt(
          secretKey!,
          walletModel.name,
        );
      } catch (e) {
        strWallet = walletModel.name;
      }
    }
    memoController.text = userLabel;

    for (AddressKey addressKey in addressKeys) {
      try {
        /// Decrypt 'to' email if needed
        if (toEmail.isEmpty) {
          final encToList = transactionModel?.tolist;
          if (encToList != null) {
            toEmail = addressKey.decrypt(encToList);
          }
        }

        /// Decrypt 'from' email if needed
        if (fromEmail.isEmpty) {
          final encSender = transactionModel?.sender;
          if (encSender != null) {
            fromEmail = addressKey.decrypt(encSender);
          }
        }

        /// Decrypt body if needed
        if (body.isEmpty) {
          final encBody = transactionModel?.body;
          if (encBody != null) {
            body = addressKey.decrypt(encBody);
          }
        }
      } catch (e, stacktrace) {
        logger.e(
          "details.viewmodel error: $e stacktrace: $stacktrace",
        );
      }
    }

    final userKeys = await userManager.getUserKeys();
    for (final userKey in userKeys) {
      try {
        /// Decrypt 'to' email if needed
        if (toEmail.isEmpty) {
          final encToList = transactionModel?.tolist;
          if (encToList != null) {
            toEmail = userKey.decrypt(encToList);
          }
        }

        /// Decrypt 'from' email if needed
        if (fromEmail.isEmpty) {
          final encSender = transactionModel?.sender;
          if (encSender != null) {
            fromEmail = userKey.decrypt(encSender);
          }
        }

        /// Decrypt body if needed
        if (body.isEmpty) {
          final encBody = transactionModel?.body;
          if (encBody != null) {
            body = userKey.decrypt(encBody);
          }
        }
      } catch (e, stacktrace) {
        logger.e(
          "details.viewmodel error: $e stacktrace: $stacktrace",
        );
      }
    }

    if (toEmail == "null") {
      toEmail = "";
    }
    if (fromEmail == "null") {
      fromEmail = "";
    }

    if (recipients.isNotEmpty && isRecipientsFromBlockChain) {
      // TODO(fix): clean logic here and make sure toEmail structure in backend,
      // TODO(fix): abstract this logic and if toEmail is "" we can skip this logic
      // It can be [{}, {}], or {"key": "value", "key2": "value2"}...
      try {
        final jsonList = jsonDecode(toEmail) as Map<String, dynamic>;
        for (String bitcoinAddress in jsonList.keys) {
          final String email = jsonList[bitcoinAddress];
          for (TransactionInfoModel recipient in recipients) {
            if (recipient.toBitcoinAddress == bitcoinAddress) {
              recipient.toEmail = email;
              break;
            }
          }
        }
      } catch (e, stacktrace) {
        logger.e(
          "details.viewmodel error: $e stacktrace: $stacktrace",
        );
        try {
          final jsonList = jsonDecode(toEmail) as List<dynamic>;
          for (dynamic map in jsonList) {
            final String bitcoinAddress = map.keys.first;
            final String email = map.values.first;
            for (TransactionInfoModel recipient in recipients) {
              if (recipient.toBitcoinAddress == bitcoinAddress) {
                recipient.toEmail = email;
                break;
              }
            }
          }
        } catch (e, stacktrace) {
          logger.e(
            "details.viewmodel error: $e stacktrace: $stacktrace",
          );
        }
      }
    }
    if ((transactionModel?.exchangeRateID ?? "").isNotEmpty) {
      final ExchangeRateModel? exchangeRateModel = await DBHelper
          .exchangeRateDao!
          .findByServerID(transactionModel!.exchangeRateID);
      if (exchangeRateModel != null) {
        final BitcoinUnit bitcoinUnit = BitcoinUnit.values.firstWhere(
            (v) =>
                v.name.toUpperCase() ==
                exchangeRateModel.bitcoinUnit.toUpperCase(),
            orElse: () => defaultBitcoinUnit);
        final FiatCurrency fiatCurrency = FiatCurrency.values.firstWhere(
            (v) =>
                v.name.toUpperCase() ==
                exchangeRateModel.fiatCurrency.toUpperCase(),
            orElse: () => defaultFiatCurrency);
        exchangeRate = ProtonExchangeRate(
          id: exchangeRateModel.serverID,
          bitcoinUnit: bitcoinUnit,
          fiatCurrency: fiatCurrency,
          exchangeRateTime: exchangeRateModel.exchangeRateTime,
          exchangeRate: BigInt.from(exchangeRateModel.exchangeRate),
          cents: BigInt.from(exchangeRateModel.cents),
        );
      }
    }
    exchangeRate ??= await ExchangeRateService.getExchangeRate(
        userSettingsDataProvider.fiatCurrency,
        time: transactionModel?.transactionTime != null
            ? int.parse(transactionModel?.transactionTime ?? "0")
            : null);

    sinkAddSafe();

    if (errorMessage.isNotEmpty) {
      CommonHelper.showErrorDialog(errorMessage);
      errorMessage = "";
    }
    sinkAddSafe();
    initialized = true;
  }

  Future<TransactionModel?> findServerTransactionByTxID(
    List<TransactionModel> transactions,
    String lookupTxID,
  ) async {
    final userKeys = await userManager.getUserKeys();
    for (var tranMode in transactions) {
      final String encryptedTxID = tranMode.transactionID;
      String clearTxID = "";
      for (final userKey in userKeys) {
        try {
          clearTxID = proton_crypto.decrypt(
            userKey.privateKey,
            userKey.passphrase,
            encryptedTxID,
          );
          break;
        } catch (e, stacktrace) {
          logger.i(
            "details.viewmodel error: $e stacktrace: $stacktrace",
          );
        }
      }
      if (clearTxID.isEmpty) {
        for (AddressKey addressKey in addressKeys) {
          try {
            clearTxID = addressKey.decrypt(encryptedTxID);
          } catch (e, stacktrace) {
            logger.e(
              "details.viewmodel error: $e stacktrace: $stacktrace",
            );
          }
          if (clearTxID.isNotEmpty) {
            break;
          }
        }
      }
      tranMode.externalTransactionID = utf8.encode(clearTxID);
      if (lookupTxID == clearTxID) {
        return tranMode;
      }
    }

    return null;
  }

  Future<void> userFinishMemo() async {
    EasyLoading.show(maskType: EasyLoadingMaskType.black);
    try {
      final WalletModel _ = await DBHelper.walletDao!.findByServerID(walletID);
      if (!memoFocusNode.hasFocus) {
        if (userLabel != memoController.text && secretKey != null) {
          userLabel = memoController.text;
          final String encryptedLabel =
              await WalletKeyHelper.encrypt(secretKey!, userLabel);
          transactionModel!.label = utf8.encode(encryptedLabel);
          await proton_api.updateWalletTransactionLabel(
            walletId: transactionModel!.serverWalletID,
            walletAccountId: transactionModel!.serverAccountID,
            walletTransactionId: transactionModel!.serverID,
            label: encryptedLabel,
          );
          await serverTransactionDataProvider.insertOrUpdate(transactionModel!,
              notifyDataUpdate: true);
        }
        isEditing = false;
      }
    } catch (e, stacktrace) {
      logger.e(
        "details.viewmodel error: $e stacktrace: $stacktrace",
      );
      errorMessage = e.toString();
    }
    sinkAddSafe();
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
    sinkAddSafe();
  }

  @override
  Future<void> updateSender(
    String senderName,
    String senderEmail,
  ) async {
    final UserKey primaryUserkey = await userManager.getPrimaryKey();
    final Map<String, dynamic> jsonMap = {
      "name": senderName,
      "email": senderEmail,
    };
    final String jsonString = jsonEncode(jsonMap);
    final String encryptedName = primaryUserkey.encrypt(jsonString);
    transactionModel!.sender = encryptedName;
    final WalletTransaction _ =
        await walletClient.updateExternalWalletTransactionSender(
            walletId: transactionModel!.serverWalletID,
            walletAccountId: transactionModel!.serverAccountID,
            walletTransactionId: transactionModel!.serverID,
            sender: encryptedName);
    await serverTransactionDataProvider.insertOrUpdate(
      transactionModel!,
      notifyDataUpdate: true,
      updateType: UpdateType.updated,
    );

    /// walletTransaction update event will trigger ServerTransactionDataProvider update
    /// then it will notify wallet transaction bloc will update
    fromEmail = jsonString;
    sinkAddSafe();
  }
}
