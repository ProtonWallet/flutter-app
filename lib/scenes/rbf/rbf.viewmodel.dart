import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:wallet/constants/app.config.dart';
import 'package:wallet/constants/constants.dart';
import 'package:wallet/helper/common_helper.dart';
import 'package:wallet/helper/dbhelper.dart';
import 'package:wallet/helper/exceptions.dart';
import 'package:wallet/helper/logger.dart';
import 'package:wallet/managers/event.loop.manager.dart';
import 'package:wallet/managers/providers/address.keys.provider.dart';
import 'package:wallet/managers/providers/bdk.transaction.data.provider.dart';
import 'package:wallet/managers/providers/user.settings.data.provider.dart';
import 'package:wallet/managers/wallet/wallet.manager.dart';
import 'package:wallet/models/transaction.info.model.dart';
import 'package:wallet/models/transaction.model.dart';
import 'package:wallet/rust/api/api_service/transaction_client.dart';
import 'package:wallet/rust/api/bdk_wallet/account.dart';
import 'package:wallet/rust/api/bdk_wallet/blockchain.dart';
import 'package:wallet/rust/api/bdk_wallet/psbt.dart';
import 'package:wallet/rust/api/bdk_wallet/transaction_details.dart';
import 'package:wallet/rust/api/errors.dart';
import 'package:wallet/rust/proton_api/exchange_rate.dart';
import 'package:wallet/rust/proton_api/transaction.dart';
import 'package:wallet/rust/proton_api/user_settings.dart';
import 'package:wallet/scenes/core/view.navigatior.identifiers.dart';
import 'package:wallet/scenes/core/viewmodel.dart';
import 'package:wallet/scenes/rbf/rbf.coordinator.dart';

enum RBFSpeed {
  fast,
  normal,
  low,
}

abstract class RbfViewModel extends ViewModel<RbfCoordinator> {
  RbfViewModel(
    super.coordinator,
    this.exchangeRate,
  );

  final ProtonExchangeRate exchangeRate;
  String fiatCurrencyName = "";
  String fiatCurrencySign = "";
  int displayDigits = defaultDisplayDigits;
  int currentFee = 0;
  int initialNewFee = 0;
  int minNewFee = 0;
  int maxNewFee = 0;
  RBFSpeed rbfSpeed = RBFSpeed.normal;
  int estimatedBlock = 1;
  BitcoinUnit bitcoinUnit = defaultBitcoinUnit;

  bool initialized = false;
  late TextEditingController newFeeController;
  late FrbBlockchainClient blockchainClient;

  Future<bool> bumpTransactionFees();

  int findQuickestBlock(int fee, Map<String, double> estimatedFees);

  RBFSpeed getRBFSpeedByBlock(int block) {
    if (block < 3) {
      return RBFSpeed.fast;
    } else if (block < 10) {
      return RBFSpeed.normal;
    }
    return RBFSpeed.low;
  }
}

class RbfViewModelImpl extends RbfViewModel {
  RbfViewModelImpl(
    super.coordinator,
    this.walletManager,
    this.eventLoop,
    this.userSettingsDataProvider,
    this.addressKeyProvider,
    this.bdkTransactionDataProvider,
    this.transactionClient,
    this.frbTransactionDetails,
    this.transactionModel,
    super.exchangeRate,
    this.walletID,
    this.accountID,
    this.addressID,
    this.recipients,
  );

  final WalletManager walletManager;
  final EventLoop eventLoop;
  final UserSettingsDataProvider userSettingsDataProvider;
  final AddressKeyProvider addressKeyProvider;
  final BDKTransactionDataProvider bdkTransactionDataProvider;
  final TransactionClient transactionClient;
  final FrbTransactionDetails frbTransactionDetails;
  final TransactionModel transactionModel;
  final String walletID;
  final String accountID;
  final String addressID;
  final List<TransactionInfoModel> recipients;
  late FrbAccount? _frbAccount;
  Map<String, double> estimatedFees = {};
  String errorMessage = "";

  void onFeeChange() {
    final newFee = int.parse(newFeeController.text);
    estimatedBlock = findQuickestBlock(newFee, estimatedFees);
    rbfSpeed = getRBFSpeedByBlock(estimatedBlock);
    sinkAddSafe();
  }

  @override
  Future<void> loadData() async {
    final accountModel = await DBHelper.accountDao!.findByServerID(accountID);
    if (accountModel == null) {
      throw Exception("Account not found in rbf view");
    }
    _frbAccount = await walletManager.loadWalletWithID(
      walletID,
      accountID,
      serverScriptType: accountModel!.scriptType,
    );

    if (_frbAccount == null) {
      throw Exception("FrbAccount not found in rbf view");
    }

    fiatCurrencyName = userSettingsDataProvider.getFiatCurrencyName();
    fiatCurrencySign = userSettingsDataProvider.getFiatCurrencySign();
    fiatCurrencyName = userSettingsDataProvider.getFiatCurrencyName(
        fiatCurrency: exchangeRate.fiatCurrency);
    fiatCurrencySign = userSettingsDataProvider.getFiatCurrencySign(
        fiatCurrency: exchangeRate.fiatCurrency);
    displayDigits = (log(exchangeRate.cents.toInt()) / log(10)).round();
    currentFee = frbTransactionDetails.fees?.toInt() ?? 0;

    final MempoolInfo mempoolInfo = await transactionClient.getMempoolInfo();
    final minimumIncrementalFee =
        max(mempoolInfo.mempoolMinFee, mempoolInfo.incrementalRelayFee) *
            100000;
    blockchainClient = FrbBlockchainClient.createEsploraBlockchain();
    estimatedFees = await blockchainClient.getFeesEstimation();
    final nextBlockFee = estimatedFees["1"] ?? 1.0;
    minNewFee = currentFee +
        (minimumIncrementalFee * frbTransactionDetails.vbytesSize.toInt())
            .ceil();
    maxNewFee = max(
          currentFee * 3,
          (nextBlockFee * 2 * frbTransactionDetails.vbytesSize.toInt()).ceil(),
        ) +
        (minimumIncrementalFee * frbTransactionDetails.vbytesSize.toInt())
            .ceil();
    initialNewFee = (minNewFee + (maxNewFee - minNewFee) / 3).ceil();
    newFeeController = TextEditingController(text: initialNewFee.toString());
    newFeeController.addListener(onFeeChange);

    bitcoinUnit = userSettingsDataProvider.bitcoinUnit;
    initialized = true;
    onFeeChange();
    sinkAddSafe();
  }

  @override
  Future<bool> bumpTransactionFees() async {
    final network = appConfig.coinType.network;
    final newFee = int.parse(newFeeController.text);
    bool rbfSuccess = false;

    FrbPsbt frbPsbt = await _frbAccount!.bumpTransactionsFees(
      txid: frbTransactionDetails.txid,
      fees: BigInt.from(newFee),
      network: network,
    );
    frbPsbt = await _frbAccount!.sign(
      psbt: frbPsbt,
      network: network,
    );

    try {
      final Map<String, String> apiRecipientsMap = {};
      for (final recipient in recipients) {
        final String email = recipient.toEmail;
        final String bitcoinAddress = recipient.toBitcoinAddress;
        if (email.isEmpty) {
          /// skip if it's not BvE recipient
          continue;
        }
        apiRecipientsMap[bitcoinAddress] = email;
      }
      await blockchainClient.broadcastPsbt(
        psbt: frbPsbt,
        walletId: walletID,
        walletAccountId: accountID,
        label: utf8.decode(transactionModel.label),
        exchangeRateId: exchangeRate.id,
        addressId: addressID,
        body: transactionModel.body,
        recipients: apiRecipientsMap.isNotEmpty ? apiRecipientsMap : null,
        isAnonymous: transactionModel.isAnonymous,
      );
      rbfSuccess = true;
    } on BridgeError catch (e, _) {
      final err = parseResponseError(e);
      if (err != null) {
        if (err.code == 2001 && err.error == "Recipients list is not valid") {
          /// this is a hotfix for BvE address already been wipe out from BE
          /// so will return recipients list is not valid error
          /// we disable BvE to avoid the error
          try {
            await blockchainClient.broadcastPsbt(
              psbt: frbPsbt,
              walletId: walletID,
              walletAccountId: accountID,
              label: utf8.decode(transactionModel.label),
              exchangeRateId: exchangeRate.id,
              addressId: addressID,
              isAnonymous: transactionModel.isAnonymous,
            );
            rbfSuccess = true;
          } on BridgeError catch (e, _) {
            final err = parseResponseError(e);
            if (err != null) {
              errorMessage = err.error;
            } else {
              errorMessage = e.toString();
            }
          }
        } else {
          errorMessage = err.error;
        }
      }
    } catch (e) {
      errorMessage = e.toString();
    }
    if (errorMessage.isNotEmpty) {
      CommonHelper.showErrorDialog("RBF error: $errorMessage");
      errorMessage = "";
      return false;
    }
    if (rbfSuccess) {
      try {
        await eventLoop.fetchEvents();

        /// fetch for new walletTransaction event
      } catch (e) {
        logger.e(e.toString());
      }
    }
    return rbfSuccess;
  }

  @override
  Future<void> move(NavID to) {
    throw UnimplementedError();
  }

  @override
  int findQuickestBlock(int fee, Map<String, double> estimatedFees) {
    final feeRate = fee / frbTransactionDetails.vbytesSize.toInt();
    final sortedKeys = estimatedFees.keys.toList()
      ..sort((a, b) => int.parse(a).compareTo(int.parse(b)));
    for (final key in sortedKeys) {
      if (feeRate > estimatedFees[key]!) {
        return int.parse(key);
      }
    }
    return 1;
  }
}
