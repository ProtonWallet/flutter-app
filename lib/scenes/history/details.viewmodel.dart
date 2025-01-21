import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:wallet/constants/constants.dart';
import 'package:wallet/helper/common.helper.dart';
import 'package:wallet/helper/dbhelper.dart';
import 'package:wallet/helper/exceptions.dart';
import 'package:wallet/helper/logger.dart';
import 'package:wallet/managers/providers/address.keys.provider.dart';
import 'package:wallet/managers/providers/contacts.data.provider.dart';
import 'package:wallet/managers/providers/data.provider.manager.dart';
import 'package:wallet/managers/providers/server.transaction.data.provider.dart';
import 'package:wallet/managers/providers/user.settings.data.provider.dart';
import 'package:wallet/managers/providers/wallet.keys.provider.dart';
import 'package:wallet/managers/providers/wallet.name.provider.dart';
import 'package:wallet/managers/services/exchange.rate.service.dart';
import 'package:wallet/managers/users/user.manager.dart';
import 'package:wallet/managers/wallet/wallet.manager.dart';
import 'package:wallet/models/contacts.model.dart';
import 'package:wallet/models/exchangerate.model.dart';
import 'package:wallet/models/transaction.info.model.dart';
import 'package:wallet/models/transaction.model.dart';
import 'package:wallet/rust/api/api_service/wallet_client.dart';
import 'package:wallet/rust/api/bdk_wallet/transaction_details.dart';
import 'package:wallet/rust/api/errors.dart';
import 'package:wallet/rust/api/proton_wallet/crypto/wallet_key_helper.dart';
import 'package:wallet/rust/api/proton_wallet/features/transition_layer.dart';
import 'package:wallet/rust/proton_api/exchange_rate.dart';
import 'package:wallet/rust/proton_api/proton_address.dart';
import 'package:wallet/rust/proton_api/user_settings.dart';
import 'package:wallet/rust/proton_api/wallet.dart';
import 'package:wallet/scenes/core/view.navigatior.identifiers.dart';
import 'package:wallet/scenes/core/viewmodel.dart';
import 'package:wallet/scenes/history/details.coordinator.dart';

abstract class HistoryDetailViewModel
    extends ViewModel<HistoryDetailCoordinator> {
  /// required data for this viewModel
  String walletID;
  String accountID;
  FrbTransactionDetails frbTransactionDetails;

  /// external data providers
  final UserSettingsDataProvider userSettingsDataProvider;
  final ContactsDataProvider contactsDataProvider;

  HistoryDetailViewModel(
    super.coordinator,
    this.walletID,
    this.accountID,
    this.frbTransactionDetails,
    this.userSettingsDataProvider,
    this.contactsDataProvider,
  );

  /// integer attributes
  int? transactionTime;
  int lastExchangeRateTime = 0;

  /// double attributes
  double amount = 0.0;
  double fee = 0.0;

  /// string attributes
  String userLabel = "";
  String walletName = "";
  String accountName = "";
  String fromEmail = "";
  String toEmail = "";
  String body = "";
  String errorMessage = "";
  List<String> selfBitcoinAddresses = [];
  String senderAddressID = "";

  /// boolean attributes
  bool isInternalTransaction = false;
  bool isSend = false;
  bool initialized = false;
  bool isEditing = false;
  bool displayBalance = true;

  /// other struct attributes
  ProtonExchangeRate? exchangeRate;
  TransactionModel? transactionModel;
  List<ContactsModel> contactsEmails = [];
  List<TransactionInfoModel> recipients = [];
  Map<FiatCurrency, ProtonExchangeRate> fiatCurrency2exchangeRate = {};

  /// UI controllers
  late ScrollController scrollController;
  late TextEditingController memoController;

  /// UI focusNode
  late FocusNode memoFocusNode;

  void editMemo();

  String getToEmail();

  String getWalletAccountName();

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
    super.frbTransactionDetails,
    this.userManager,
    this.walletManager,
    this.serverTransactionDataProvider,
    this.walletClient,
    this.walletKeysProvider,
    super.userSettingsDataProvider,
    super.contactsDataProvider,
    this.walletNameProvider,
    this.addressKeyProvider,
  );

  /// required data for this viewModel, and we don't need to expose for UI
  final UserManager userManager;
  final WalletManager walletManager;
  final ServerTransactionDataProvider serverTransactionDataProvider;
  final WalletClient walletClient;
  final WalletKeysProvider walletKeysProvider;
  final WalletNameProvider walletNameProvider;
  final AddressKeyProvider addressKeyProvider;

  /// attributes that we don't need to expose for UI
  Uint8List? entropy;
  List<ProtonAddressKey> addressKeys = [];

  void initUIComponents() {
    memoController = TextEditingController();
    memoFocusNode = FocusNode();
    memoFocusNode.addListener(userFinishMemo);
    scrollController = ScrollController();
  }

  @override
  Future<void> loadData() async {
    initUIComponents();

    /// check if we need to display balance
    displayBalance = await userSettingsDataProvider.getDisplayBalance();

    /// load contacts
    contactsEmails = await contactsDataProvider.getContacts() ?? [];

    /// load addressKeys
    addressKeys = await addressKeyProvider.getAddressKeysForTL();

    /// load walletKey
    final unlockedWalletKey = await walletKeysProvider.getWalletSecretKey(
      walletID,
    );

    /// load server wallet transactions
    var serverTrans = await serverTransactionDataProvider.getTransByAccountID(
      walletID,
      accountID,
    );

    /// find wallet transaction with txID
    transactionModel = await findServerTransactionByTxID(
      serverTrans,
      frbTransactionDetails.txid,
    );

    if (transactionModel != null) {
      /// set isInternalTransaction so UI can know what content to display when we don't have sender information
      isInternalTransaction =
          (transactionModel!.type == TransactionType.protonToProtonSend.index ||
              transactionModel!.type ==
                  TransactionType.protonToProtonReceive.index);
    }

    /// load walletName
    walletName = await walletNameProvider.getNameWithID(walletID);

    /// load accountName
    accountName = await walletNameProvider.getAccountLabelWithID(accountID);

    /// load amount of this transaction
    amount = frbTransactionDetails.received.toDouble() -
        frbTransactionDetails.sent.toDouble();

    /// load fee of this transaction
    fee = frbTransactionDetails.fees!.toDouble();

    /// mark if it's send
    isSend = amount < 0;

    /// bdk sent include fee, so need add back to make displayed send amount is without fee
    if (isSend) {
      amount += (frbTransactionDetails.fees ?? BigInt.zero).toDouble();
    }

    frbTransactionDetails.time.when(
      confirmed: (confirmationTime) {
        transactionTime = confirmationTime.toInt();
      },
      unconfirmed: (lastSeen) {
        /// mark transactionTime = null so UI will show it's inprogress
        transactionTime = null;
      },
    );

    for (final txOut in frbTransactionDetails.outputs) {
      final String? bitcoinAddress = txOut.address;
      if (bitcoinAddress == null) {
        continue;
      }
      if (isSend) {
        /// add to recipient list if it's not self address
        if (!txOut.isMine) {
          recipients.add(TransactionInfoModel(
              id: null,
              externalTransactionID: Uint8List(0),
              amountInSATS: txOut.value.toInt(),
              feeInSATS: fee.abs().toInt(),
              isSend: 1,
              transactionTime: 0,
              feeMode: 0,
              serverWalletID: walletID,
              serverAccountID: accountID,
              toEmail: "",
              toBitcoinAddress: bitcoinAddress));
        }
      } else {
        /// if it's receive
        if (txOut.isMine) {
          /// set selfBitcoinAddress for display
          /// In general, we will only have one self address been used in transaction.
          /// but there is still a case that user send transaction to different address in same wallet in one transaction
          selfBitcoinAddresses.add(bitcoinAddress);
        }
      }
    }

    /// no server walletTransaction found, create one, encrypted it and send to server
    if (transactionModel == null) {
      /// default label
      final String encryptedLabel = FrbWalletKeyHelper.encrypt(
        base64SecureKey: unlockedWalletKey.toBase64(),
        plaintext: "",
      );

      final primaryUserKey = await userManager.getPrimaryKeyForTL();
      final transactionId = await FrbTransitionLayer.encryptMessagesWithUserkey(
          userKey: primaryUserKey, message: frbTransactionDetails.txid);

      final now = DateTime.now();
      try {
        final hashedTransactionID = FrbTransitionLayer.getHmacHashedString(
          base64SecureKey: unlockedWalletKey.toBase64(),
          transactionId: frbTransactionDetails.txid,
        );

        /// create wallet transaction
        final walletTransaction = await walletClient.createWalletTransactions(
          walletId: walletID,
          walletAccountId: accountID,
          transactionId: transactionId,
          hashedTransactionId: hashedTransactionID,
          label: encryptedLabel,
          exchangeRateId: userSettingsDataProvider.exchangeRate.id,
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
          externalTransactionID: utf8.encode(frbTransactionDetails.txid),
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
          body: walletTransaction.body,
          isSuspicious: walletTransaction.isSuspicious,
          isPrivate: walletTransaction.isPrivate,
          isAnonymous: walletTransaction.isAnonymous,
        );

        /// save to db
        await DBHelper.transactionDao!.insertOrUpdate(transactionModel!);
      } on BridgeError catch (e, stacktrace) {
        logger.e(
          "details.viewmodel error: $e stacktrace: $stacktrace",
        );

        /// parse the server error code
        final responseError = parseResponseError(e);
        if (responseError != null) {
          if (responseError.code == 2011) {
            if (transactionModel == null) {
              /// this will only happened when user open web app and mobile app in same time (race condition)
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
                frbTransactionDetails.txid,
              );
              if (transactionModel == null) {
                /// show hashedTXID has been used error
                CommonHelper.showErrorDialog(responseError.error);
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

    /// try decrypt wallet label
    if (transactionModel!.label.isNotEmpty) {
      userLabel = FrbWalletKeyHelper.decrypt(
        base64SecureKey: unlockedWalletKey.toBase64(),
        encryptText: utf8.decode(transactionModel!.label),
      );
    }

    /// update UI controller with decrypted label
    memoController.text = userLabel;

    /// decrypt BvE message
    final decryptedBody = await FrbTransitionLayer.decryptMessages(
      userKeys: await userManager.getUserKeysForTL(),
      addrKeys: addressKeys.isEmpty
          ? addressKeys
          : await addressKeyProvider.getAddressKeysForTL(),
      userKeyPassword: userManager.getUserKeyPassphrase(),
      encBody: transactionModel?.body,
      encToList: transactionModel?.tolist,
      encSender: transactionModel?.sender,
    );
    toEmail = decryptedBody.toList;
    fromEmail = decryptedBody.sender;
    body = decryptedBody.body;

    if (recipients.isNotEmpty) {
      /// It can be [{}, {}], or {"key": "value", "key2": "value2"}...
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
      /// try load exchange rate from db
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

    /// load exchange rate if we cannot find it in db
    exchangeRate ??= await ExchangeRateService.getExchangeRate(
        userSettingsDataProvider.fiatCurrency,
        time: transactionModel?.transactionTime != null
            ? int.parse(transactionModel?.transactionTime ?? "0")
            : null);

    /// load sender address ID, used for RBF feature
    if (isSend) {
      await loadSenderAddressID();
    }

    if (errorMessage.isNotEmpty) {
      CommonHelper.showErrorDialog(errorMessage);
      errorMessage = "";
    }

    /// mark viewModel as initialized and notify UI to refresh
    initialized = true;
    sinkAddSafe();
  }

  /// find transaction from given transaction lists with specific txID
  Future<TransactionModel?> findServerTransactionByTxID(
    List<TransactionModel> transactions,
    String lookupTxID,
  ) async {
    final userKeys = await userManager.getUserKeysForTL();
    final addressKeys = await addressKeyProvider.getAddressKeysForTL();
    final passphrase = userManager.getUserKeyPassphrase();

    final frbTransactionIds = await FrbTransitionLayer.decryptTransactionIds(
      userKeys: userKeys,
      addrKeys: addressKeys,
      userKeyPassword: passphrase,
      encTransactionIds: transactions.toFrbTLEncryptedTransactionID(),
    );

    for (var tranMode in transactions) {
      final foundTxID = frbTransactionIds
          .firstWhere((element) => element.index == tranMode.id)
          .transactionId;
      if (foundTxID == lookupTxID && foundTxID.isNotEmpty) {
        return tranMode;
      }
    }
    return null;
  }

  /// callback when user finish memo
  Future<void> userFinishMemo() async {
    EasyLoading.show(maskType: EasyLoadingMaskType.black);
    try {
      if (!memoFocusNode.hasFocus) {
        final unlockedWalletKey = await walletKeysProvider.getWalletSecretKey(
          walletID,
        );

        /// only need to do actions when user has update the content
        if (userLabel != memoController.text) {
          /// update cached user label
          userLabel = memoController.text;

          /// encrypt label
          final encryptedLabel = FrbWalletKeyHelper.encrypt(
            base64SecureKey: unlockedWalletKey.toBase64(),
            plaintext: userLabel,
          );

          /// send api request
          await walletClient.updateWalletTransactionLabel(
            walletId: transactionModel!.serverWalletID,
            walletAccountId: transactionModel!.serverAccountID,
            walletTransactionId: transactionModel!.serverID,
            label: encryptedLabel,
          );

          /// update db record
          transactionModel!.label = utf8.encode(encryptedLabel);
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
  Future<void> move(NavID to) async {
    switch (to) {
      case NavID.rbf:
        coordinator.showRBF(
          exchangeRate!,
          transactionModel!,
          senderAddressID,
          recipients,
        );
      default:
        break;
    }
  }

  /// callback when user click edit button
  @override
  void editMemo() {
    isEditing = true;
    memoFocusNode.requestFocus();
    sinkAddSafe();
  }

  Future<void> loadSenderAddressID() async {
    final protonAddresses = await addressKeyProvider.getAddresses();
    for (final address in protonAddresses) {
      if (address.email == fromEmail) {
        senderAddressID = address.id;
        break;
      }
    }

    /// use default address if we cannot find from wallet transaction's fromList
    senderAddressID = protonAddresses.first.id;
  }

  /// user can modify non-BvE sender by themselves
  @override
  Future<void> updateSender(
    String senderName,
    String senderEmail,
  ) async {
    final primaryUserkey = await userManager.getPrimaryKeyForTL();
    final Map<String, dynamic> jsonMap = {
      "name": senderName,
      "email": senderEmail,
    };
    final String jsonString = jsonEncode(jsonMap);

    /// encrypt the sender with userKey
    final encryptedName = await FrbTransitionLayer.encryptMessagesWithUserkey(
      userKey: primaryUserkey,
      message: jsonString,
    );

    /// send request to api to update wallet transaction sender
    await walletClient.updateExternalWalletTransactionSender(
      walletId: transactionModel!.serverWalletID,
      walletAccountId: transactionModel!.serverAccountID,
      walletTransactionId: transactionModel!.serverID,
      sender: encryptedName,
    );

    /// update db record
    transactionModel!.sender = encryptedName;
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

  @override
  String getToEmail() {
    if (toEmail.isNotEmpty) {
      return "${WalletManager.getEmailFromWalletTransaction(toEmail)} (You)";
    }
    return getWalletAccountName();
  }

  @override
  String getWalletAccountName() {
    return "$walletName - $accountName";
  }
}
