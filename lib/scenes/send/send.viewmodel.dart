import 'dart:async';
import 'dart:convert';
import 'package:cryptography/cryptography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:wallet/constants/address.key.dart';
import 'package:wallet/constants/address.public.key.dart';
import 'package:wallet/constants/app.config.dart';
import 'package:wallet/constants/constants.dart';
import 'package:wallet/helper/common_helper.dart';
import 'package:wallet/helper/dbhelper.dart';
import 'package:wallet/helper/exchange.caculator.dart';
import 'package:wallet/managers/providers/local.transaction.data.provider.dart';
import 'package:wallet/managers/providers/user.settings.data.provider.dart';
import 'package:wallet/managers/services/exchange.rate.service.dart';
import 'package:wallet/helper/extension/stream.controller.dart';
import 'package:wallet/helper/logger.dart';
import 'package:wallet/managers/event.loop.manager.dart';
import 'package:wallet/managers/providers/contacts.data.provider.dart';
import 'package:wallet/managers/wallet/proton.wallet.manager.dart';
import 'package:wallet/managers/wallet/wallet.manager.dart';
import 'package:wallet/helper/walletkey_helper.dart';
import 'package:wallet/l10n/generated/locale.dart';
import 'package:wallet/models/account.model.dart';
import 'package:wallet/models/bitcoin.address.model.dart';
import 'package:wallet/models/contacts.model.dart';
import 'package:wallet/models/transaction.info.model.dart';
import 'package:wallet/models/wallet.model.dart';
import 'package:wallet/rust/api/api_service/invite_client.dart';
import 'package:wallet/rust/api/bdk_wallet/account.dart';
import 'package:wallet/rust/api/bdk_wallet/blockchain.dart';
import 'package:wallet/rust/api/bdk_wallet/psbt.dart';
import 'package:wallet/rust/api/bdk_wallet/transaction_builder.dart';
import 'package:wallet/rust/api/rust_api.dart';
import 'package:wallet/rust/proton_api/exchange_rate.dart';
import 'package:wallet/rust/proton_api/proton_address.dart';
import 'package:wallet/rust/proton_api/user_settings.dart';
import 'package:wallet/rust/proton_api/wallet.dart';
import 'package:wallet/scenes/core/coordinator.dart';
import 'package:wallet/scenes/core/view.navigatior.identifiers.dart';
import 'package:wallet/scenes/core/viewmodel.dart';
import 'package:wallet/scenes/send/bottom.sheet/invite.dart';
import 'package:wallet/scenes/send/send.coordinator.dart';
import 'package:wallet/rust/api/proton_api.dart' as proton_api;
import 'package:proton_crypto/proton_crypto.dart' as proton_crypto;

enum TransactionFeeMode {
  highPriority,
  medianPriority,
  lowPriority,
}

enum SendFlowStatus {
  addRecipient,
  editAmount,
  reviewTransaction,
  sendSuccess,
}

class ProtonRecipient {
  String email;
  TextEditingController amountController;
  FocusNode focusNode;
  int? amountInSATS;

  ProtonRecipient({
    required this.email,
    required this.amountController,
    required this.focusNode,
  });
}

abstract class SendViewModel extends ViewModel<SendCoordinator> {
  SendViewModel(
    super.coordinator,
    this.walletID,
    this.accountID,
    this.userSettingsDataProvider,
    this.localTransactionDataProvider,
    this.inviteClient,
  );

  int walletID;
  int accountID;
  final int maxRecipientCount = 5;
  String fromAddress = "";
  String errorMessage = "";
  late TextEditingController recipientTextController;
  late TextEditingController memoTextController;
  late TextEditingController amountTextController;
  Map<String, String> bitcoinAddresses = {};
  Map<String, bool> bitcoinAddressesInvalidSignature = {};

  Map<String, AddressPublicKey> email2AddressKey = {};
  List<AddressPublicKey> addressPublicKeys = [];

  List<ProtonRecipient> recipients = [];
  List<String> selfBitcoinAddresses = [];
  List<String> accountAddressIDs = [];
  int balance = 0;
  double feeRateHighPriority = 20.0;
  List<AddressKey> addressKeys = [];
  double feeRateMedianPriority = 15.0;
  double feeRateLowPriority = 10.0;
  double feeRateSatPerVByte = 15.0;
  int estimatedFeeInSAT = 0;
  int estimatedFeeInSATHighPriority = 0;
  int estimatedFeeInSATMedianPriority = 0;
  int estimatedFeeInSATLowPriority = 0;
  int amountInSATS = 0; // per recipient
  bool allowDust = false;
  int totalAmountInSAT = 0; // total value
  SendFlowStatus sendFlowStatus = SendFlowStatus.addRecipient;
  TransactionFeeMode userTransactionFeeMode = TransactionFeeMode.medianPriority;
  bool amountTextControllerChanged = false;
  bool amountFiatCurrencyTextControllerChanged = false;
  bool hasEmailIntegrationRecipient = false;
  bool showInvite = false;
  bool isBitcoinBase = false; // TODO:: add bitcoin base logic
  WalletModel? walletModel;
  AccountModel? accountModel;
  BuildContext? context;
  late FocusNode addressFocusNode;
  late FocusNode amountFocusNode;
  ValueNotifier<FiatCurrency> fiatCurrencyNotifier =
      ValueNotifier(defaultFiatCurrency);

  bool isEditingEmailBody = false;
  bool isEditingMemo = false;
  late TextEditingController emailBodyController;
  late TextEditingController memoController;
  late FocusNode emailBodyFocusNode;
  late FocusNode memoFocusNode;

  String txid = "";

  void editEmailBody();

  void editMemo();

  Future<bool> sendCoin();

  Future<void> updateFeeRate();

  void addRecipient();

  void removeRecipient(int index);

  void updatePageStatus(SendFlowStatus status);

  void addressAutoCompleteCallback();

  int validRecipientCount();

  void splitAmountToRecipients();

  void updateTransactionFeeMode(TransactionFeeMode transactionFeeMode);

  Future<bool> buildTransactionScript();

  Future<bool> sendInvite(String email);

  List<ContactsModel> contactsEmail = [];

  late FrbTxBuilder txBuilder;
  late FrbPsbt frbPsbt;
  late FrbPsbt frbDraftPsbt;

  // late TxBuilderResult txBuilderResult;
  late ValueNotifier accountValueNotifier;
  bool initialized = false;
  ProtonExchangeRate exchangeRate = const ProtonExchangeRate(
      id: 'default',
      bitcoinUnit: BitcoinUnit.btc,
      fiatCurrency: defaultFiatCurrency,
      exchangeRateTime: '',
      exchangeRate: 1,
      cents: 1);

  // user-setting data provider
  final UserSettingsDataProvider userSettingsDataProvider;

  // local transaction data provider
  final LocalTransactionDataProvider localTransactionDataProvider;

  final InviteClient inviteClient;
}

class SendViewModelImpl extends SendViewModel {
  SendViewModelImpl(
    super.coordinator,
    super.walletID,
    super.accountID,
    this.eventLoop,
    this.walletManger,
    this.contactsDataProvider,
    super.userSettingsDataProvider,
    super.localTransactionDataProvider,
    super.inviteClient,
  );

  // event loop
  final EventLoop eventLoop;

  // wallet manger
  final ProtonWalletManager walletManger;

  // contact data provider
  final ContactsDataProvider contactsDataProvider;

  final datasourceChangedStreamController =
      StreamController<SendViewModel>.broadcast();
  late FrbAccount? _frbAccount;
  FrbBlockchainClient? blockClient;
  Timer? _timer;
  bool isValid = false;

  void startExchangeRateUpdateService() {
    isValid = true;
    _timer = Timer.periodic(const Duration(seconds: eventLoopRefreshThreshold),
        (timer) {
      updateExchangeRateJob();
    });
  }

  void stopExchangeRateUpdateService() {
    isValid = false;
    _timer?.cancel();
    _timer = null;
  }

  @override
  Future<void> dispose() async {
    stopExchangeRateUpdateService();
    datasourceChangedStreamController.close();
  }

  @override
  Future<void> loadData() async {
    EasyLoading.show(
        status: "loading exchange rate..", maskType: EasyLoadingMaskType.black);
    try {
      context = Coordinator.rootNavigatorKey.currentContext!;
      addressFocusNode = FocusNode();
      amountFocusNode = FocusNode();
      memoFocusNode = FocusNode();
      emailBodyFocusNode = FocusNode();
      memoTextController = TextEditingController();
      emailBodyController = TextEditingController();
      recipientTextController = TextEditingController(text: "");
      memoTextController = TextEditingController();
      amountTextController = TextEditingController();
      txBuilder = FrbTxBuilder();

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

      addressKeys = await WalletManager.getAddressKeys();
      await userSettingsDataProvider.preLoad();
      exchangeRate = userSettingsDataProvider.exchangeRate;
      startExchangeRateUpdateService();
      fiatCurrencyNotifier.value = userSettingsDataProvider.fiatCurrency;
      fiatCurrencyNotifier.addListener(() async {
        updateExchangeRate(fiatCurrencyNotifier.value);
      });
      amountFocusNode.addListener(() {
        splitAmountToRecipients();
      });

      datasourceChangedStreamController.sinkAddSafe(this);
      blockClient = await Api.createEsploraBlockchainWithApi();
      await updateFeeRate();
      contactsEmail = await contactsDataProvider.getContacts() ?? [];
      walletModel = await DBHelper.walletDao!.findById(walletID);
      if (accountID == 0) {
        accountModel = await DBHelper.accountDao!
            .findDefaultAccountByWalletID(walletModel?.id ?? 0);
      } else {
        accountModel = await DBHelper.accountDao!.findById(accountID);
      }
      accountValueNotifier = ValueNotifier(accountModel);
      accountValueNotifier.addListener(() async {
        accountModel = accountValueNotifier.value;
        await updateWallet();
      });
      updateWallet();
      logger.i(DateTime.now().toString());
    } catch (e) {
      errorMessage = e.toString();
    }
    initialized = true;
    EasyLoading.dismiss();
    if (errorMessage.isNotEmpty) {
      CommonHelper.showErrorDialog(errorMessage);
      errorMessage = "";
    }
    datasourceChangedStreamController.sinkAddSafe(this);
  }

  Future<void> updateExchangeRateJob() async {
    if (isValid) {
      FiatCurrency fiatCurrency = exchangeRate.fiatCurrency;
      await ExchangeRateService.runOnce(fiatCurrency);
      exchangeRate = await ExchangeRateService.getExchangeRate(fiatCurrency);
      if (sendFlowStatus == SendFlowStatus.reviewTransaction) {
        buildTransactionScript();
      }
      logger.i(
          "updateExchangeRateJob result: ${exchangeRate.fiatCurrency.name} = ${exchangeRate.exchangeRate}");
      datasourceChangedStreamController.sinkAddSafe(this);
    }
  }

  @override
  int validRecipientCount() {
    int count = 0;
    for (ProtonRecipient protonRecipient in recipients) {
      String email = protonRecipient.email;
      String bitcoinAddress = bitcoinAddresses[email] ?? "";
      if (CommonHelper.isBitcoinAddress(bitcoinAddress) &&
          selfBitcoinAddresses.contains(bitcoinAddress) == false) {
        count++;
      }
    }
    return count;
  }

  Future<void> updateWallet() async {
    selfBitcoinAddresses.clear();
    List<BitcoinAddressModel> localBitcoinAddresses =
        await DBHelper.bitcoinAddressDao!.findByWalletAccount(
            walletModel!.serverWalletID, accountModel!.serverAccountID);
    selfBitcoinAddresses = localBitcoinAddresses.map((bitcoinAddressModel) {
      return bitcoinAddressModel.bitcoinAddress;
    }).toList();
    _frbAccount =
        await WalletManager.loadWalletWithID(walletID, accountModel?.id ?? 0);
    accountAddressIDs = await WalletManager.getAccountAddressIDs(
        accountModel?.serverAccountID ?? "");
    if (_frbAccount != null) {
      var walletBalance = await _frbAccount!.getBalance();
      balance = walletBalance.trustedSpendable().toSat();
    }
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
    datasourceChangedStreamController.sinkAddSafe(this);
  }

  @override
  Future<void> updatePageStatus(SendFlowStatus status) async {
    if (status == SendFlowStatus.reviewTransaction) {
      hasEmailIntegrationRecipient = false;
      for (ProtonRecipient protonRecipient in recipients) {
        String email = protonRecipient.email;
        String bitcoinAddress = bitcoinAddresses[email] ?? "";
        if (email2AddressKey.containsKey(email) &&
            selfBitcoinAddresses.contains(bitcoinAddress) == false) {
          hasEmailIntegrationRecipient = true;
        }
      }
      await updateTransactionFeeMode(userTransactionFeeMode);
      bool success = await buildTransactionScript();
      if (success == false) {
        sendFlowStatus = SendFlowStatus.editAmount;
      } else {
        sendFlowStatus = status;
      }
    } else {
      if (status == SendFlowStatus.editAmount) {
        await initEstimatedFee();

        /// build draft psbt first to get fee
      }
      sendFlowStatus = status;
    }
    datasourceChangedStreamController.sinkAddSafe(this);
  }

  Future<void> updateExchangeRate(FiatCurrency fiatCurrency) async {
    if (exchangeRate.fiatCurrency != fiatCurrency) {
      exchangeRate = await ExchangeRateService.getExchangeRate(fiatCurrency);
    }
    if (sendFlowStatus == SendFlowStatus.editAmount) {
      exchangeRate = await ExchangeRateService.getExchangeRate(fiatCurrency);
      buildTransactionScript();
    }
    datasourceChangedStreamController.sinkAddSafe(this);
  }

  Future<void> loadBitcoinAddresses() async {
    showInvite = false;
    for (ProtonRecipient protonRecipient in recipients) {
      String email = protonRecipient.email;
      if (bitcoinAddresses.containsKey(email)) {
        continue;
      }
      String? bitcoinAddress;
      if (CommonHelper.isBitcoinAddress(email)) {
        bitcoinAddress = email;
      } else {
        try {
          if (email.contains("@")) {
            EmailIntegrationBitcoinAddress? emailIntegrationBitcoinAddress =
                await WalletManager.lookupBitcoinAddress(email);
            if (emailIntegrationBitcoinAddress != null) {
              List<AllKeyAddressKey> recipientAddressKeys = await proton_api
                  .getAllPublicKeys(email: email, internalOnly: 1);
              bool verifySignature = false;
              for (AllKeyAddressKey recipientAddressKey
                  in recipientAddressKeys) {
                verifySignature = await WalletManager.verifySignature(
                    recipientAddressKey.publicKey,
                    emailIntegrationBitcoinAddress.bitcoinAddress ?? "",
                    emailIntegrationBitcoinAddress.bitcoinAddressSignature ??
                        "",
                    gpgContextWalletBitcoinAddress);
                if (verifySignature == true) {
                  break;
                }
              }
              if (verifySignature == true) {
                bitcoinAddress = emailIntegrationBitcoinAddress.bitcoinAddress;
              } else {
                BuildContext? context =
                    Coordinator.rootNavigatorKey.currentContext;
                if (context != null && context.mounted) {
                  CommonHelper.showSnackbar(
                      context,
                      S
                          .of(context)
                          .error_this_bitcoin_address_signature_is_invalid,
                      isError: true);
                }
                bitcoinAddressesInvalidSignature[email] = true;
              }
            } else {
              showInvite = true;
            }
          }
          // TODO:: handle banned bitcoin address alert here
        } catch (e) {
          logger.e(e.toString());
          showInvite = true;
        }
      }
      bitcoinAddresses[email] = bitcoinAddress ?? "";
    }
  }

  void removeRecipientByEmail(String email) {
    ProtonRecipient? toBeRemoved;
    for (ProtonRecipient protonRecipient in recipients) {
      if (protonRecipient.email == email) {
        toBeRemoved = protonRecipient;
      }
    }
    if (toBeRemoved != null) {
      recipients.remove(toBeRemoved);
    }
    bitcoinAddresses.removeWhere((key, value) => value == email);
    bitcoinAddresses.removeWhere((key, value) => key == email);
  }

  bool isRecipientExists(String email) {
    for (ProtonRecipient protonRecipient in recipients) {
      if (protonRecipient.email == email) {
        return true;
      }
    }
    return false;
  }

  @override
  Future<void> addRecipient() async {
    String email = recipientTextController.text.trim();
    recipientTextController.text = "";
    if (isRecipientExists(email) == false) {
      if (bitcoinAddresses.values.contains(email)) {
        BuildContext? context = Coordinator.rootNavigatorKey.currentContext;
        if (context != null && context.mounted) {
          CommonHelper.showSnackbar(context,
              S.of(context).error_this_bitcoin_address_already_in_recipients,
              isError: true);
        }
        return;
      }
      TextEditingController textEditingController = TextEditingController();
      FocusNode focusNode = FocusNode();
      focusNode.addListener(() {
        double totalAmount = 0;
        for (ProtonRecipient recipient in recipients) {
          double amount = 0;
          try {
            amount = double.parse(recipient.amountController.text);
          } catch (e) {
            // ignore parsing error
          }
          totalAmount += amount;
        }
        amountTextController.text = totalAmount
            .toStringAsFixed(ExchangeCalculator.getDisplayDigit(exchangeRate));
        datasourceChangedStreamController.sinkAddSafe(this);
      });
      recipients.add(ProtonRecipient(
        email: email,
        amountController: textEditingController,
        focusNode: focusNode,
      )); // TODO:: every recipient has own amountTextController
    }
    EasyLoading.show(
        status: "loading bitcoin address..",
        maskType: EasyLoadingMaskType.black);
    try {
      await loadBitcoinAddresses();
      String bitcoinAddress = bitcoinAddresses[email] ?? "";
      if (CommonHelper.isBitcoinAddress(bitcoinAddress)) {
        if (selfBitcoinAddresses.contains(bitcoinAddress) == false) {
          if (bitcoinAddresses.values
                  .where((value) => (bitcoinAddress == value))
                  .length <=
              1) {
            if (email.contains("@")) {
              List<AllKeyAddressKey> recipientAddressKeys = await proton_api
                  .getAllPublicKeys(email: email, internalOnly: 0);
              if (recipientAddressKeys.isNotEmpty) {
                for (AllKeyAddressKey allKeyAddressKey
                    in recipientAddressKeys) {
                  // TODO:: use default key
                  email2AddressKey[email] =
                      AddressPublicKey(publicKey: allKeyAddressKey.publicKey);
                  break;
                }
              }
            }
          } else {
            BuildContext? context = Coordinator.rootNavigatorKey.currentContext;
            if (context != null && context.mounted) {
              CommonHelper.showSnackbar(
                  context,
                  S
                      .of(context)
                      .error_this_bitcoin_address_already_in_recipients,
                  isError: true);
            }
            removeRecipientByEmail(email);
          }
        }
      } else {
        // not a valid bitcoinAddress, remove it
        removeRecipientByEmail(email);
        if (showInvite == false) {
          CommonHelper.showSnackbar(
              context!, S.of(context!).incorrect_bitcoin_address,
              isError: true);
        }
      }
    } catch (e) {
      errorMessage = e.toString();
    }
    EasyLoading.dismiss();
    if (errorMessage.isNotEmpty) {
      CommonHelper.showErrorDialog(errorMessage);
      errorMessage = "";
    }

    if (showInvite) {
      removeRecipientByEmail(email);
      BuildContext context = Coordinator.rootNavigatorKey.currentContext!;
      if (context.mounted) {
        InviteSheet.show(context, this, email);
      }
    }
    if (isRecipientExists(email) == false && recipients.isEmpty) {
      return;
    }
    bool isSelfBitcoinAddress =
        selfBitcoinAddresses.contains(bitcoinAddresses[email]);
    if (isSelfBitcoinAddress) {
      if (context!.mounted) {
        removeRecipientByEmail(email);
        CommonHelper.showSnackbar(
            context!, S.of(context!).error_you_can_not_send_to_self_account,
            isError: true);
      }
    }
    datasourceChangedStreamController.sinkAddSafe(this);
  }

  @override
  void removeRecipient(int index) {
    if (index < recipients.length) {
      removeRecipientByEmail(recipients[index].email);
      datasourceChangedStreamController.sinkAddSafe(this);
    }
    if (validRecipientCount() == 0) {
      updatePageStatus(SendFlowStatus.addRecipient);
    }
  }

  @override
  Stream<ViewModel> get datasourceChanged =>
      datasourceChangedStreamController.stream;

  Future<bool> initEstimatedFee() async {
    try {
      if (_frbAccount == null) {
        throw Exception("Account is not loaded");
      }
      txBuilder = await _frbAccount!.buildTx();
      totalAmountInSAT = 0;
      for (ProtonRecipient protonRecipient in recipients) {
        amountInSATS = balance ~/ recipients.length; // dust size
        String email = protonRecipient.email;
        String bitcoinAddress = "";
        if (email.contains("@")) {
          bitcoinAddress = bitcoinAddresses[email] ?? email;
        } else {
          bitcoinAddress = email;
        }
        if (CommonHelper.isBitcoinAddress(bitcoinAddress) &&
            selfBitcoinAddresses.contains(bitcoinAddress) == false) {
          logger.i("Target addr: $bitcoinAddress\nAmount: $amountInSATS");

          txBuilder = txBuilder.addRecipient(
            addressStr: bitcoinAddress,
            amount: amountInSATS,
          );
          protonRecipient.amountInSATS = amountInSATS;
        }
      }
      var network = appConfig.coinType.network;
      txBuilder =
          await txBuilder.setFeeRate(satPerVb: feeRateHighPriority.ceil());
      frbDraftPsbt = await txBuilder.createDraftPsbt(
        network: network,
        allowDust: allowDust,
      );
      estimatedFeeInSAT = frbDraftPsbt.fee().toSat();
    } catch (e) {
      errorMessage = e.toString();
      if (errorMessage.isNotEmpty) {
        CommonHelper.showErrorDialog(
            "buildTransactionScript error: $errorMessage");
        errorMessage = "";
      }
      // }
      return false;
    }
    datasourceChangedStreamController.sinkAddSafe(this);
    return true;
  }

  @override
  Future<bool> buildTransactionScript() async {
    try {
      if (_frbAccount == null) {
        throw Exception("Account is not loaded");
      }
      txBuilder = await _frbAccount!.buildTx();
      totalAmountInSAT = 0;
      bool hasValidRecipient = false;
      for (ProtonRecipient protonRecipient in recipients) {
        if (protonRecipient.amountController.text.isNotEmpty) {
          double amount = 0.0;
          try {
            amount = double.parse(protonRecipient.amountController.text);
          } catch (e) {
            amount = 0.0;
          }
          double btcAmount =
              ExchangeCalculator.getNotionalInBTC(exchangeRate, amount);
          amountInSATS = (btcAmount * 100000000).ceil();
          String email = protonRecipient.email;
          String bitcoinAddress = "";
          if (email.contains("@")) {
            bitcoinAddress = bitcoinAddresses[email] ?? email;
          } else {
            bitcoinAddress = email;
          }
          if (CommonHelper.isBitcoinAddress(bitcoinAddress) &&
              selfBitcoinAddresses.contains(bitcoinAddress) == false) {
            logger.i("Target addr: $bitcoinAddress\nAmount: $amountInSATS");
            if (amountInSATS >= 546) {
              hasValidRecipient = true;
            }
            txBuilder = txBuilder.addRecipient(
              addressStr: bitcoinAddress,
              amount: amountInSATS,
            );
            protonRecipient.amountInSATS = amountInSATS;
            totalAmountInSAT += amountInSATS;
          }
        }
      }
      if (hasValidRecipient == false) {
        return false;
      }
      var network = appConfig.coinType.network;
      var txBuilderHighPriority =
          await txBuilder.setFeeRate(satPerVb: feeRateHighPriority.ceil());
      var txBuilderMedianPriority =
          await txBuilder.setFeeRate(satPerVb: feeRateMedianPriority.ceil());
      var txBuilderLowPriority =
          await txBuilder.setFeeRate(satPerVb: feeRateLowPriority.ceil());

      var frbDraftPsbtHighPriority =
          await txBuilderHighPriority.createDraftPsbt(
        network: network,
        allowDust: allowDust,
      );
      var frbDraftPsbtMedianPriority =
          await txBuilderMedianPriority.createDraftPsbt(
        network: network,
        allowDust: allowDust,
      );
      var frbDraftPsbtLowPriority = await txBuilderLowPriority.createDraftPsbt(
        network: network,
        allowDust: allowDust,
      );

      estimatedFeeInSATHighPriority = frbDraftPsbtHighPriority.fee().toSat();
      estimatedFeeInSATMedianPriority =
          frbDraftPsbtMedianPriority.fee().toSat();
      estimatedFeeInSATLowPriority = frbDraftPsbtLowPriority.fee().toSat();

      /// txBuilder will be use to build real psbt
      txBuilder =
          await txBuilder.setFeeRate(satPerVb: feeRateSatPerVByte.ceil());
    } catch (e) {
      /// TODO:: handle exception here
      errorMessage = e.toString();
      if (errorMessage.isNotEmpty) {
        CommonHelper.showErrorDialog(
            "buildTransactionScript error: $errorMessage");
        errorMessage = "";
      }
      return false;
    }
    datasourceChangedStreamController.sinkAddSafe(this);
    return true;
  }

  @override
  Future<bool> sendCoin() async {
    logger.i("Start sendCoin()");
    EasyLoading.show(
        status: "Broadcasting transaction..",
        maskType: EasyLoadingMaskType.black);
    addressPublicKeys.clear();
    try {
      String? emailAddressID;
      if (accountAddressIDs.isNotEmpty) {
        emailAddressID = accountAddressIDs.first;
      } else {
        // TODO:: check if we need default one
        emailAddressID = addressKeys.firstOrNull?.id;
      }
      String? encryptedLabel;
      SecretKey? secretKey =
          await WalletManager.getWalletKey(walletModel!.serverWalletID);
      encryptedLabel =
          await WalletKeyHelper.encrypt(secretKey, memoTextController.text);

      String? encryptedMessage;
      for (ProtonRecipient protonRecipient in recipients) {
        String email = protonRecipient.email;
        String bitcoinAddress = bitcoinAddresses[email] ?? "";
        if (email2AddressKey.containsKey(email) &&
            selfBitcoinAddresses.contains(bitcoinAddress) == false) {
          addressPublicKeys.add(email2AddressKey[email]!);
        }
      }

      if (addressPublicKeys.isNotEmpty) {
        for (AddressKey addressKey in addressKeys) {
          if (addressKey.id == emailAddressID) {
            // need to use self addressKey to encrypt the body too
            String pgpArmoredPublicKey =
                proton_crypto.getArmoredPublicKey(addressKey.privateKey);
            addressPublicKeys
                .add(AddressPublicKey(publicKey: pgpArmoredPublicKey));
            break;
          }
        }
        encryptedMessage = AddressPublicKey.encryptWithKeys(
            addressPublicKeys, emailBodyController.text);
      }

      if (_frbAccount == null) {
        throw Exception("Account is not loaded");
      }

      /// previous frbPsbt is draft one, only need to create real frbPsbt when user press submit button
      /// the reason we use draft PSBT is that the internal address index will get increase everytime when create real PSBT
      var network = appConfig.coinType.network;
      frbPsbt = await txBuilder.createPbst(network: network);
      frbPsbt = await _frbAccount!.sign(
        psbt: frbPsbt,
        network: network,
      );

      logger.i("Start broadcastPsbt");
      txid = await blockClient!.broadcastPsbt(
        psbt: frbPsbt,
        walletId: walletModel!.serverWalletID,
        walletAccountId: accountModel!.serverAccountID,
        label: encryptedLabel,
        exchangeRateId: exchangeRate.id,
        transactionTime: null,
        addressId: emailAddressID,
        subject: null,
        // subject is deprecated, set to default null
        body: encryptedMessage,
      );

      logger.i("End broadcastPsbt");
      logger.i("Start add local transaction record");
      try {
        if (txid.isNotEmpty) {
          logger.i("txid = $txid");

          // for multi-recipients
          for (ProtonRecipient protonRecipient in recipients) {
            String email = protonRecipient.email;
            String bitcoinAddress = "";
            if (email.contains("@")) {
              bitcoinAddress = bitcoinAddresses[email] ?? email;
            } else {
              bitcoinAddress = email;
            }
            if (selfBitcoinAddresses.contains(bitcoinAddress) == false) {
              await localTransactionDataProvider.insert(TransactionInfoModel(
                  id: null,
                  externalTransactionID: utf8.encode(txid),
                  amountInSATS: protonRecipient.amountInSATS ?? 0,
                  feeInSATS: estimatedFeeInSAT,
                  // all recipients have same fee since its same transaction
                  isSend: 1,
                  transactionTime:
                      DateTime.now().millisecondsSinceEpoch ~/ 1000,
                  feeMode: userTransactionFeeMode.index,
                  serverWalletID: walletModel!.serverWalletID,
                  serverAccountID: accountModel!.serverAccountID,
                  toEmail: email.contains("@") ? email : "",
                  toBitcoinAddress: bitcoinAddress));
            }
          }
        }
      } catch (e) {
        logger.e(e.toString());
      }
    } catch (e) {
      errorMessage = e.toString();
    }
    if (errorMessage.isNotEmpty) {
      CommonHelper.showErrorDialog("sendCoin() error: $errorMessage");
      errorMessage = "";
      EasyLoading.dismiss();
      return false;
    }
    logger.i("End add local transaction record");
    try {
      logger.i("Start eventloop runOnce()");
      await eventLoop.runOnce();
      logger.i("End eventloop runOnce()");
    } catch (e) {
      e.toString();
    }
    EasyLoading.dismiss();
    return true;
  }

  @override
  Future<void> updateFeeRate() async {
    var fees = await blockClient?.getFeesEstimation();
    if (fees == null) {
      return;
    }
    feeRateHighPriority = fees["1"] ?? 0;
    feeRateMedianPriority = fees["6"] ?? 0;
    feeRateLowPriority = fees["12"] ?? 0;
    try {
      datasourceChangedStreamController.sinkAddSafe(this);
    } catch (e) {
      logger.e(e.toString());
    }
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
  Future<void> move(NavID to) async {}

  @override
  void addressAutoCompleteCallback() {
    if (balance > 0) {
      addRecipient();
    } else {
      BuildContext? context = Coordinator.rootNavigatorKey.currentContext;
      if (context != null) {
        CommonHelper.showSnackbar(
            context, S.of(context).error_you_dont_have_sufficient_balance);
      }
    }
  }

  @override
  void splitAmountToRecipients() {
    double totalAmount = 0;
    try {
      totalAmount = double.parse(amountTextController.text);
    } catch (e) {
      // ignore parsing error
    }
    int recipientCount = validRecipientCount();
    if (recipientCount > 0) {
      double amount = totalAmount / recipientCount;
      for (ProtonRecipient recipient in recipients) {
        recipient.amountController.text = amount
            .toStringAsFixed(ExchangeCalculator.getDisplayDigit(exchangeRate));
      }
    }
    datasourceChangedStreamController.sinkAddSafe(this);
  }

  @override
  Future<bool> sendInvite(String email) async {
    await _sendInviteForNewComer(email);
    await _sendInviteForEmailIntegration(email);
    return true;
  }

  Future<void> _sendInviteForEmailIntegration(String email) async {
    await inviteClient.sendEmailIntegrationInvite(inviteeEmail: email);
  }

  Future<void> _sendInviteForNewComer(String email) async {
    await inviteClient.sendNewcomerInvite(inviteeEmail: email);
  }
}
