import 'dart:async';
import 'dart:convert';

import 'package:cryptography/cryptography.dart';
import 'package:flutter/material.dart';
import 'package:proton_crypto/proton_crypto.dart' as proton_crypto;
import 'package:sentry/sentry.dart';
import 'package:wallet/constants/address.key.dart';
import 'package:wallet/constants/address.public.key.dart';
import 'package:wallet/constants/app.config.dart';
import 'package:wallet/constants/constants.dart';
import 'package:wallet/helper/common_helper.dart';
import 'package:wallet/helper/dbhelper.dart';
import 'package:wallet/helper/exceptions.dart';
import 'package:wallet/helper/exchange.caculator.dart';
import 'package:wallet/helper/fiat.currency.helper.dart';
import 'package:wallet/helper/logger.dart';
import 'package:wallet/helper/walletkey_helper.dart';
import 'package:wallet/l10n/generated/locale.dart';
import 'package:wallet/managers/app.state.manager.dart';
import 'package:wallet/managers/event.loop.manager.dart';
import 'package:wallet/managers/providers/contacts.data.provider.dart';
import 'package:wallet/managers/providers/exclusive.invite.data.provider.dart';
import 'package:wallet/managers/providers/proton.email.address.provider.dart';
import 'package:wallet/managers/providers/user.settings.data.provider.dart';
import 'package:wallet/managers/providers/wallet.data.provider.dart';
import 'package:wallet/managers/providers/wallet.keys.provider.dart';
import 'package:wallet/managers/services/exchange.rate.service.dart';
import 'package:wallet/managers/users/user.manager.dart';
import 'package:wallet/managers/wallet/proton.wallet.manager.dart';
import 'package:wallet/managers/wallet/wallet.manager.dart';
import 'package:wallet/models/account.model.dart';
import 'package:wallet/models/bitcoin.address.model.dart';
import 'package:wallet/models/contacts.model.dart';
import 'package:wallet/models/wallet.model.dart';
import 'package:wallet/rust/api/api_service/invite_client.dart';
import 'package:wallet/rust/api/bdk_wallet/account.dart';
import 'package:wallet/rust/api/bdk_wallet/blockchain.dart';
import 'package:wallet/rust/api/bdk_wallet/psbt.dart';
import 'package:wallet/rust/api/bdk_wallet/transaction_builder.dart';
import 'package:wallet/rust/api/proton_api.dart' as proton_api;
import 'package:wallet/rust/api/rust_api.dart';
import 'package:wallet/rust/common/errors.dart';
import 'package:wallet/rust/proton_api/exchange_rate.dart';
import 'package:wallet/rust/proton_api/proton_address.dart';
import 'package:wallet/rust/proton_api/user_settings.dart';
import 'package:wallet/rust/proton_api/wallet.dart';
import 'package:wallet/scenes/core/coordinator.dart';
import 'package:wallet/scenes/core/view.navigatior.identifiers.dart';
import 'package:wallet/scenes/core/viewmodel.dart';
import 'package:wallet/scenes/send/bottom.sheet/send.flow.invite.dart';
import 'package:wallet/scenes/send/send.coordinator.dart';

enum TransactionFeeMode {
  highPriority,
  medianPriority,
  lowPriority,
}

enum SendFlowStatus {
  addRecipient,
  editAmount,
  reviewTransaction,
  broadcasting,
  sendSuccess,
}

class ProtonRecipient {
  String? name;
  String email;
  TextEditingController amountController;
  FocusNode focusNode;
  int? amountInSATS;
  bool isValid;

  ProtonRecipient({
    required this.email,
    required this.amountController,
    required this.focusNode,
    required this.isValid,
    this.name,
  });
}

abstract class SendViewModel extends ViewModel<SendCoordinator> {
  SendViewModel(
    super.coordinator,
    this.walletID,
    this.accountID,
    this.userSettingsDataProvider,
    this.walletDataProvider,
    this.inviteClient,
  );

  String walletID;
  String accountID;
  final int maxRecipientCount = 5;
  String fromAddress = "";
  String errorMessage = "";
  bool isAnonymous = false;
  late ValueNotifier userAddressValueNotifier;
  late TextEditingController recipientTextController;
  late TextEditingController memoTextController;
  late TextEditingController amountTextController;
  Map<String, String> bitcoinAddresses = {};
  Map<String, bool> bitcoinAddressesInvalidSignature = {};

  Map<String, AddressPublicKey> email2AddressKey = {};
  List<AddressPublicKey> addressPublicKeys = [];
  List<ProtonAddress> protonEmailAddresses = [];

  List<ProtonRecipient> recipients = [];
  List<String> selfBitcoinAddresses = [];
  List<String> accountAddressIDs = [];
  int balance = 0;
  double feeRateHighPriority = 20.0;
  List<AddressKey> addressKeys = [];
  double feeRateMedianPriority = 15.0;
  double feeRateLowPriority = 10.0;
  double feeRateSatPerVByte = 15.0;
  bool bitcoinBase = false;
  int estimatedFeeInSAT = 0;
  int estimatedFeeInSATHighPriority = 0;
  int estimatedFeeInSATMedianPriority = 0;
  int estimatedFeeInSATLowPriority = 0;
  int amountInSATS = 0; // per recipient
  bool allowDust = false;
  bool isLoadingBvE = false;
  int totalAmountInSAT = 0; // total value
  SendFlowStatus sendFlowStatus = SendFlowStatus.addRecipient;
  TransactionFeeMode userTransactionFeeMode = TransactionFeeMode.medianPriority;
  bool amountTextControllerChanged = false;
  bool amountFiatCurrencyTextControllerChanged = false;
  bool hasEmailIntegrationRecipient = false;
  bool showInvite = false;
  bool showInviteBvE = false;
  bool isBitcoinBase = false; // TODO(fix): add bitcoin base logic
  WalletModel? walletModel;
  AccountModel? accountModel;
  BuildContext? context;
  late FocusNode addressFocusNode;
  late FocusNode amountFocusNode;
  ValueNotifier<FiatCurrencyWrapper> fiatCurrencyNotifier =
      ValueNotifier(bitcoinCurrencyWrapper);

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

  Future<bool> sendExclusiveInvite(ProtonAddress protonAddress, String email);

  List<ContactsModel> contactsEmails = [];

  late FrbTxBuilder txBuilder;
  late FrbPsbt frbPsbt;
  late FrbPsbt frbDraftPsbt;

  int maxBalanceToSend = 0;
  int accountsCount = 0;

  // late TxBuilderResult txBuilderResult;
  late ValueNotifier accountValueNotifier;
  bool initialized = false;
  bool isSending = false;
  ProtonExchangeRate exchangeRate = ProtonExchangeRate(
      id: 'default',
      bitcoinUnit: BitcoinUnit.btc,
      fiatCurrency: defaultFiatCurrency,
      exchangeRateTime: '',
      exchangeRate: BigInt.one,
      cents: BigInt.one);

  // user-setting data provider
  final UserSettingsDataProvider userSettingsDataProvider;

  final WalletsDataProvider walletDataProvider;

  final InviteClient inviteClient;
  WalletData? walletData;
}

class SendViewModelImpl extends SendViewModel {
  SendViewModelImpl(
    super.coordinator,
    super.walletID,
    super.accountID,
    this.eventLoop,
    this.walletManger,
    this.userManager,
    this.contactsDataProvider,
    this.walletKeysProvider,
    this.protonEmailAddressProvider,
    this.exclusiveInviteDataProvider,
    super.userSettingsDataProvider,
    super.walletDataProvider,
    super.inviteClient,
    this.appStateManager,
  );

  // event loop
  final EventLoop eventLoop;

  final UserManager userManager;

  // wallet manger
  final ProtonWalletManager walletManger;

  /// app state manager
  final AppStateManager appStateManager;

  // contact data provider
  final ContactsDataProvider contactsDataProvider;
  final WalletKeysProvider walletKeysProvider;
  final ProtonEmailAddressProvider protonEmailAddressProvider;
  final ExclusiveInviteDataProvider exclusiveInviteDataProvider;

  late FrbAccount? _frbAccount;
  FrbBlockchainClient? blockClient;
  Timer? _timer;
  bool isValid = false;

  SecretKey? secretKey;

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
    super.dispose();
  }

  @override
  Future<void> loadData() async {
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
        if (!addressFocusNode.hasFocus) {
          if (recipientTextController.text.isNotEmpty) {
            addressAutoCompleteCallback();
          }
        }
      });

      memoFocusNode.addListener(() {
        if (!memoFocusNode.hasFocus) {
          userFinishMemo();
        }
      });

      emailBodyFocusNode.addListener(() {
        if (!emailBodyFocusNode.hasFocus) {
          userFinishEmailBody();
        }
      });

      protonEmailAddresses = [anonymousAddress] +
          await protonEmailAddressProvider.getProtonEmailAddresses();
      userAddressValueNotifier = ValueNotifier(protonEmailAddresses.length > 1
          ? protonEmailAddresses[1]
          : protonEmailAddresses.firstOrNull);

      addressKeys = await WalletManager.getAddressKeys();
      await userSettingsDataProvider.preLoad();
      exchangeRate = userSettingsDataProvider.exchangeRate;
      startExchangeRateUpdateService();
      fiatCurrencyNotifier.value = FiatCurrencyHelper.getFiatCurrencyWrapper(
          userSettingsDataProvider.fiatCurrency);
      fiatCurrencyNotifier.addListener(() async {
        if (fiatCurrencyNotifier.value.bitcoinCurrency != null) {
          bitcoinBase = true;
          updateExchangeRate(userSettingsDataProvider.fiatCurrency);
        } else {
          bitcoinBase = false;
          updateExchangeRate(fiatCurrencyNotifier.value.fiatCurrency ??
              userSettingsDataProvider.fiatCurrency);
        }
      });
      amountFocusNode.addListener(splitAmountToRecipients);

      sinkAddSafe();
      blockClient = await Api.createEsploraBlockchainWithApi();
      await updateFeeRate();
      contactsEmails = await contactsDataProvider.getContacts() ?? [];

      // for account switcher

      walletModel = await DBHelper.walletDao!.findByServerID(walletID);

      walletData = await walletDataProvider.getWalletByServerWalletID(walletID);
      for (AccountModel accModel in walletData?.accounts ?? []) {
        accModel.labelDecrypt =
            await decryptAccountName(base64Encode(accModel.label));
        final balance = await WalletManager.getWalletAccountBalance(
          walletModel?.walletID ?? "",
          accModel.accountID,
        );
        accModel.balance = balance.toDouble();
        if (accModel.accountID == accountID) {
          accountModel = accModel;
        }
      }
      accountsCount = walletData?.accounts.length ?? 0;

      accountModel ??= walletData?.accounts.firstOrNull;
      accountModel ??=
          await DBHelper.accountDao!.findDefaultAccountByWalletID(walletID);

      accountValueNotifier = ValueNotifier(accountModel);
      accountValueNotifier.addListener(() async {
        accountModel = accountValueNotifier.value;
        await updateWallet();
      });

      /// await for balance to be loaded
      await updateWallet();
      logger.d(DateTime.now().toString());
    } on BridgeError catch (e, stacktrace) {
      appStateManager.updateStateFrom(e);
      _processError(e, stacktrace);
    } catch (e) {
      errorMessage = "Init sending error $e";
    }
    initialized = true;
    addressFocusNode.requestFocus();
    if (errorMessage.isNotEmpty) {
      CommonHelper.showErrorDialog(errorMessage);
      errorMessage = "";
    }
    sinkAddSafe();
  }

  Future<void> updateExchangeRateJob() async {
    if (isValid) {
      final FiatCurrency fiatCurrency = exchangeRate.fiatCurrency;
      await ExchangeRateService.runOnce(fiatCurrency);
      exchangeRate = await ExchangeRateService.getExchangeRate(fiatCurrency);
      if (sendFlowStatus == SendFlowStatus.reviewTransaction) {
        if (!isSending) {
          /// need to lock transaction Script if it's in sending process
          /// otherwise we can update transaction script to apply latest exchangeRate
          buildTransactionScript();
        }
      }
      logger.i(
        "updateExchangeRateJob result: ${exchangeRate.fiatCurrency.name} = ${exchangeRate.exchangeRate}",
      );
      sinkAddSafe();
    }
  }

  @override
  int validRecipientCount() {
    int count = 0;
    for (ProtonRecipient protonRecipient in recipients) {
      final String email = protonRecipient.email;
      final String bitcoinAddress = bitcoinAddresses[email] ?? "";
      if (CommonHelper.isBitcoinAddress(bitcoinAddress) &&
          !selfBitcoinAddresses.contains(bitcoinAddress)) {
        count++;
      }
    }
    return count;
  }

  Future<void> updateWallet() async {
    selfBitcoinAddresses.clear();
    final List<BitcoinAddressModel> localBitcoinAddresses = await DBHelper
        .bitcoinAddressDao!
        .findByWalletAccount(walletModel!.walletID, accountModel!.accountID);
    selfBitcoinAddresses = localBitcoinAddresses.map((bitcoinAddressModel) {
      return bitcoinAddressModel.bitcoinAddress;
    }).toList();
    // TODO(fix): fix me
    _frbAccount = await WalletManager.loadWalletWithID(
      walletID,
      accountModel?.accountID ?? "",
      serverScriptType: accountModel?.scriptType ?? -1,
    );
    accountAddressIDs =
        await WalletManager.getAccountAddressIDs(accountModel?.accountID ?? "");
    if (_frbAccount != null) {
      final walletBalance = await _frbAccount!.getBalance();
      balance = walletBalance.trustedSpendable().toSat().toInt();
    }
    sinkAddSafe();
  }

  @override
  Future<void> updateTransactionFeeMode(
      TransactionFeeMode transactionFeeMode) async {
    userTransactionFeeMode = transactionFeeMode;
    switch (userTransactionFeeMode) {
      case TransactionFeeMode.highPriority:
        feeRateSatPerVByte = feeRateHighPriority;
      case TransactionFeeMode.medianPriority:
        feeRateSatPerVByte = feeRateMedianPriority;
      case TransactionFeeMode.lowPriority:
        feeRateSatPerVByte = feeRateLowPriority;
    }
    sinkAddSafe();
  }

  @override
  Future<void> updatePageStatus(SendFlowStatus status) async {
    if (status == SendFlowStatus.reviewTransaction) {
      hasEmailIntegrationRecipient = false;
      for (ProtonRecipient protonRecipient in recipients) {
        final String email = protonRecipient.email;
        final String bitcoinAddress = bitcoinAddresses[email] ?? "";
        if (email2AddressKey.containsKey(email) &&
            !selfBitcoinAddresses.contains(bitcoinAddress)) {
          hasEmailIntegrationRecipient = true;
        }
      }
      await updateTransactionFeeMode(userTransactionFeeMode);
      final bool success = await buildTransactionScript();
      if (!success) {
        sendFlowStatus = SendFlowStatus.editAmount;
      } else {
        sendFlowStatus = status;
      }
    } else {
      if (status == SendFlowStatus.editAmount) {
        final success = await initEstimatedFee();
        if (!success) {
          return;
        }

        /// build draft psbt first to get fee
        maxBalanceToSend = balance - estimatedFeeInSAT;
      }
      sendFlowStatus = status;
      Future.delayed(const Duration(milliseconds: 100), () {
        amountFocusNode.requestFocus();
      });
    }
    sinkAddSafe();
  }

  Future<void> updateExchangeRate(FiatCurrency fiatCurrency) async {
    if (exchangeRate.fiatCurrency != fiatCurrency) {
      exchangeRate = await ExchangeRateService.getExchangeRate(fiatCurrency);
    }
    if (sendFlowStatus == SendFlowStatus.editAmount) {
      exchangeRate = await ExchangeRateService.getExchangeRate(fiatCurrency);
      buildTransactionScript();
    }
    sinkAddSafe();
  }

  Future<void> loadBitcoinAddresses() async {
    showInvite = false;
    showInviteBvE = false;
    for (ProtonRecipient protonRecipient in recipients) {
      final String email = protonRecipient.email;
      if (bitcoinAddresses.containsKey(email)) {
        continue;
      }
      String? bitcoinAddress;
      if (CommonHelper.isBitcoinAddress(email)) {
        bitcoinAddress = email;
        protonRecipient.isValid = true;
      } else {
        try {
          if (email.contains("@")) {
            final EmailIntegrationBitcoinAddress?
                emailIntegrationBitcoinAddress =
                await WalletManager.lookupBitcoinAddress(email);
            if (emailIntegrationBitcoinAddress != null) {
              final List<AllKeyAddressKey> recipientAddressKeys =
                  await proton_api.getAllPublicKeys(
                      email: email, internalOnly: 1);
              bool verifySignature = false;
              for (AllKeyAddressKey recipientAddressKey
                  in recipientAddressKeys) {
                verifySignature = await WalletManager.verifySignature(
                    recipientAddressKey.publicKey,
                    emailIntegrationBitcoinAddress.bitcoinAddress ?? "",
                    emailIntegrationBitcoinAddress.bitcoinAddressSignature ??
                        "",
                    gpgContextWalletBitcoinAddress);
                if (verifySignature) {
                  break;
                }
              }
              if (verifySignature) {
                bitcoinAddress = emailIntegrationBitcoinAddress.bitcoinAddress;
                protonRecipient.isValid = true;
              } else {
                final BuildContext? context =
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
          // TODO(fix): handle banned bitcoin address alert here
        } on BridgeError catch (e, stacktrace) {
          appStateManager.updateStateFrom(e);
          final err = parseResponseError(e);
          final msg = parseSampleDisplayError(e);
          if (err != null) {
            if (err.code == 2001) {
              /// cannot find the email address in BvE pool
              /// should send invite
              showInvite = true;
            } else if (err.code == 2050 && msg.isNotEmpty) {
              /// Invalid email address
            } else if (err.code == 2011) {
              /// Address is not configured to receive Bitcoin
              showInviteBvE = true;
            }
          } else {
            _processError(e, stacktrace);
          }
        } catch (e) {
          logger.e(e.toString());
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
    isLoadingBvE = true;
    sinkAddSafe(); // inform UI to refresh
    final String email = recipientTextController.text.trim();
    recipientTextController.text = "";
    if (!isRecipientExists(email)) {
      if (bitcoinAddresses.values.contains(email)) {
        final BuildContext? context =
            Coordinator.rootNavigatorKey.currentContext;
        if (context != null && context.mounted) {
          CommonHelper.showSnackbar(context,
              S.of(context).error_this_bitcoin_address_already_in_recipients,
              isError: true);
        }
        isLoadingBvE = false;
        sinkAddSafe(); // inform UI to refresh
        return;
      }
      final TextEditingController textEditingController =
          TextEditingController();
      final FocusNode focusNode = FocusNode();
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
        sinkAddSafe();
      });
      recipients.add(ProtonRecipient(
        email: email,
        amountController: textEditingController,
        focusNode: focusNode,
        isValid: false,
        name: await contactsDataProvider.getContactName(email),
      )); // TODO(fix): every recipient has own amountTextController
    }
    try {
      await loadBitcoinAddresses();
      final String bitcoinAddress = bitcoinAddresses[email] ?? "";
      if (CommonHelper.isBitcoinAddress(bitcoinAddress)) {
        if (!selfBitcoinAddresses.contains(bitcoinAddress)) {
          if (bitcoinAddresses.values
                  .where((value) => (bitcoinAddress == value))
                  .length <=
              1) {
            if (email.contains("@")) {
              final List<AllKeyAddressKey> recipientAddressKeys =
                  await proton_api.getAllPublicKeys(
                      email: email, internalOnly: 0);
              if (recipientAddressKeys.isNotEmpty) {
                for (AllKeyAddressKey allKeyAddressKey
                    in recipientAddressKeys) {
                  // TODO(fix): use default key
                  email2AddressKey[email] =
                      AddressPublicKey(publicKey: allKeyAddressKey.publicKey);
                  break;
                }
              }
            }
          } else {
            final BuildContext? context =
                Coordinator.rootNavigatorKey.currentContext;
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
        if (!showInvite && !showInviteBvE) {
          CommonHelper.showSnackbar(
              context!, S.of(context!).incorrect_bitcoin_address,
              isError: true);
        }
      }
    } on BridgeError catch (e, stacktrace) {
      appStateManager.updateStateFrom(e);
      _processError(e, stacktrace);
    } catch (e) {
      errorMessage = "Add recipient error: $e";
    }
    isLoadingBvE = false;
    sinkAddSafe(); // inform UI to refresh
    if (errorMessage.isNotEmpty) {
      CommonHelper.showErrorDialog(errorMessage);
      errorMessage = "";
    }

    if (showInvite) {
      removeRecipientByEmail(email);
      final BuildContext context = Coordinator.rootNavigatorKey.currentContext!;
      if (context.mounted) {
        SendFlowInviteSheet.show(
            context,
            protonEmailAddresses
                .where((e) => e.id != anonymousAddress.id)
                .toList(),
            email,
            _sendInviteForNewComer);
      }
    } else if (showInviteBvE) {
      removeRecipientByEmail(email);
      final BuildContext context = Coordinator.rootNavigatorKey.currentContext!;
      if (context.mounted) {
        SendFlowInviteSheet.show(
            context,
            protonEmailAddresses
                .where((e) => e.id != anonymousAddress.id)
                .toList(),
            email,
            _sendInviteForEmailIntegration);
      }
    }
    if (!isRecipientExists(email) && recipients.isEmpty) {
      return;
    }
    final bool isSelfBitcoinAddress =
        selfBitcoinAddresses.contains(bitcoinAddresses[email]);
    if (isSelfBitcoinAddress) {
      if (context!.mounted) {
        removeRecipientByEmail(email);
        CommonHelper.showSnackbar(
            context!, S.of(context!).error_you_can_not_send_to_self_account,
            isError: true);
      }
    }
    sinkAddSafe();
  }

  @override
  void removeRecipient(int index) {
    if (index < recipients.length) {
      removeRecipientByEmail(recipients[index].email);
      sinkAddSafe();
    }
    if (validRecipientCount() == 0) {
      updatePageStatus(SendFlowStatus.addRecipient);
    }
  }

  Future<bool> initEstimatedFee() async {
    try {
      if (_frbAccount == null) {
        throw Exception("Account is not loaded");
      }
      txBuilder = await _frbAccount!.buildTx();
      totalAmountInSAT = 0;
      for (ProtonRecipient protonRecipient in recipients) {
        amountInSATS = balance ~/ recipients.length;
        final String email = protonRecipient.email;
        String bitcoinAddress = "";
        if (email.contains("@")) {
          bitcoinAddress = bitcoinAddresses[email] ?? email;
        } else {
          bitcoinAddress = email;
        }
        if (CommonHelper.isBitcoinAddress(bitcoinAddress) &&
            !selfBitcoinAddresses.contains(bitcoinAddress)) {
          logger.i("Target addr: $bitcoinAddress\nAmount: $amountInSATS");

          txBuilder = txBuilder.addRecipient(
            addressStr: bitcoinAddress,
            amount: BigInt.from(amountInSATS),
          );
          protonRecipient.amountInSATS = amountInSATS;
        }
      }
      final network = appConfig.coinType.network;
      txBuilder = await txBuilder.setFeeRate(
          satPerVb: BigInt.from(feeRateHighPriority.ceil()));
      txBuilder = await txBuilder.constrainRecipientAmounts();
      frbDraftPsbt = await txBuilder.createDraftPsbt(
        network: network,
        allowDust: allowDust,
      );
      estimatedFeeInSAT = frbDraftPsbt.fee().toSat().toInt();
    } on BridgeError catch (e, stacktrace) {
      appStateManager.updateStateFrom(e);
      return _processError(e, stacktrace);
    } catch (e) {
      errorMessage = e.toString();
      if (errorMessage.isNotEmpty) {
        CommonHelper.showErrorDialog(
            "buildTransactionScript error: $errorMessage");
        errorMessage = "";
      }
      return false;
    }
    sinkAddSafe();
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
          final double btcAmount = bitcoinBase
              ? amount
              : ExchangeCalculator.getNotionalInBTC(exchangeRate, amount);
          amountInSATS = bitcoinBase
              ? (btcAmount * 100000000).round()
              : (btcAmount * 100000000).ceil();
          final String email = protonRecipient.email;
          String bitcoinAddress = "";
          if (email.contains("@")) {
            bitcoinAddress = bitcoinAddresses[email] ?? email;
          } else {
            bitcoinAddress = email;
          }
          if (CommonHelper.isBitcoinAddress(bitcoinAddress) &&
              !selfBitcoinAddresses.contains(bitcoinAddress)) {
            logger.i("Target addr: $bitcoinAddress\nAmount: $amountInSATS");
            if (amountInSATS >= 546) {
              hasValidRecipient = true;
            } else {
              final BuildContext? context =
                  Coordinator.rootNavigatorKey.currentContext;
              if (context != null && context.mounted) {
                CommonHelper.showSnackbar(
                  context,
                  S.of(context).error_you_can_not_send_amount_below_dust,
                  isError: true,
                );
              }
              return false;
            }
            txBuilder = txBuilder.addRecipient(
              addressStr: bitcoinAddress,
              amount: BigInt.from(amountInSATS),
            );
            protonRecipient.amountInSATS = amountInSATS;
            totalAmountInSAT += amountInSATS;
          }
        }
      }
      if (!hasValidRecipient) {
        return false;
      }
      if (totalAmountInSAT > maxBalanceToSend) {
        /// no sufficient money
        final BuildContext? context =
            Coordinator.rootNavigatorKey.currentContext;
        if (context != null && context.mounted) {
          CommonHelper.showSnackbar(
            context,
            S.of(context).error_you_dont_have_sufficient_balance,
            isError: true,
          );
        }
        return false;
      }
      final network = appConfig.coinType.network;
      final txBuilderHighPriority = await txBuilder.setFeeRate(
          satPerVb: BigInt.from(feeRateHighPriority.ceil()));
      final txBuilderMedianPriority = await txBuilder.setFeeRate(
          satPerVb: BigInt.from(feeRateMedianPriority.ceil()));
      final txBuilderLowPriority = await txBuilder.setFeeRate(
          satPerVb: BigInt.from(feeRateLowPriority.ceil()));

      final frbDraftPsbtHighPriority =
          await txBuilderHighPriority.createDraftPsbt(
        network: network,
        allowDust: allowDust,
      );
      final frbDraftPsbtMedianPriority =
          await txBuilderMedianPriority.createDraftPsbt(
        network: network,
        allowDust: allowDust,
      );
      final frbDraftPsbtLowPriority =
          await txBuilderLowPriority.createDraftPsbt(
        network: network,
        allowDust: allowDust,
      );

      estimatedFeeInSATHighPriority =
          frbDraftPsbtHighPriority.fee().toSat().toInt();
      estimatedFeeInSATMedianPriority =
          frbDraftPsbtMedianPriority.fee().toSat().toInt();
      estimatedFeeInSATLowPriority =
          frbDraftPsbtLowPriority.fee().toSat().toInt();

      /// txBuilder will be use to build real psbt
      txBuilder = await txBuilder.setFeeRate(
          satPerVb: BigInt.from(feeRateSatPerVByte.ceil()));
    } on BridgeError catch (e, stacktrace) {
      appStateManager.updateStateFrom(e);
      return _processError(e, stacktrace);
    } catch (e) {
      // TODO(fix): handle exception here
      errorMessage = e.toString();
      if (errorMessage.isNotEmpty) {
        CommonHelper.showErrorDialog(
          "buildTransactionScript error: $errorMessage",
        );
        errorMessage = "";
      }
      return false;
    }
    sinkAddSafe();
    return true;
  }

  @override
  Future<bool> sendCoin() async {
    logger.i("Start sendCoin()");
    addressPublicKeys.clear();
    try {
      isAnonymous = userAddressValueNotifier.value.id == anonymousAddress.id;
      String? emailAddressID;
      if (!isAnonymous) {
        emailAddressID = userAddressValueNotifier.value.id;
      } else {
        // TODO(fix): check if we need default one
        emailAddressID = addressKeys.firstOrNull?.id;
      }
      String? encryptedLabel;
      final SecretKey secretKey =
          await WalletManager.getWalletKey(walletModel!.walletID);
      encryptedLabel =
          await WalletKeyHelper.encrypt(secretKey, memoTextController.text);

      String? encryptedMessage;
      final Map<String, String> apiRecipientsMap = {};
      for (ProtonRecipient protonRecipient in recipients) {
        final String email = protonRecipient.email;
        final String bitcoinAddress = bitcoinAddresses[email] ?? "";
        if (email2AddressKey.containsKey(email) &&
            !selfBitcoinAddresses.contains(bitcoinAddress)) {
          addressPublicKeys.add(email2AddressKey[email]!);
          if (CommonHelper.isBitcoinAddress(bitcoinAddress)) {
            apiRecipientsMap[bitcoinAddress] = email;
          }
        }
      }

      if (addressPublicKeys.isNotEmpty) {
        for (AddressKey addressKey in addressKeys) {
          if (addressKey.id == emailAddressID) {
            // need to use self addressKey to encrypt the body too
            final String pgpArmoredPublicKey =
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
      final network = appConfig.coinType.network;
      frbPsbt = await txBuilder.createPbst(network: network);
      frbPsbt = await _frbAccount!.sign(
        psbt: frbPsbt,
        network: network,
      );

      logger.i("Start broadcastPsbt");
      txid = await blockClient!.broadcastPsbt(
        psbt: frbPsbt,
        walletId: walletModel!.walletID,
        walletAccountId: accountModel!.accountID,
        label: encryptedLabel,
        exchangeRateId: exchangeRate.id,
        addressId: emailAddressID,
        // subject is deprecated, set to default null
        body: encryptedMessage,
        recipients: apiRecipientsMap.isNotEmpty ? apiRecipientsMap : null,
        isAnonymous: isAnonymous ? 1 : 0,
      );

      logger
        ..i("End broadcastPsbt")
        ..i("Start add local transaction record");
      try {
        if (txid.isNotEmpty) {
          logger.i("txid = $txid");
          _frbAccount?.insertUnconfirmedTx(psbt: frbPsbt);
        }
      } catch (e) {
        logger.e(e.toString());
      }
    } on BridgeError catch (e, stacktrace) {
      appStateManager.updateStateFrom(e);
      return _processError(e, stacktrace);
    } catch (e) {
      errorMessage = e.toString();
    }
    if (errorMessage.isNotEmpty) {
      CommonHelper.showErrorDialog("sendCoin() error: $errorMessage");
      errorMessage = "";
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
    return true;
  }

  @override
  Future<void> updateFeeRate() async {
    final fees = await blockClient?.getFeesEstimation();
    if (fees == null) {
      return;
    }
    feeRateHighPriority = fees["1"] ?? 0;
    feeRateMedianPriority = fees["6"] ?? 0;
    feeRateLowPriority = fees["12"] ?? 0;

    sinkAddSafe();
  }

  Future<void> userFinishEmailBody() async {
    isEditingEmailBody = false;
    sinkAddSafe();
  }

  Future<void> userFinishMemo() async {
    isEditingMemo = false;
    sinkAddSafe();
  }

  @override
  void editEmailBody() {
    isEditingEmailBody = true;
    emailBodyFocusNode.requestFocus();
    sinkAddSafe();
  }

  @override
  void editMemo() {
    isEditingMemo = true;
    memoFocusNode.requestFocus();
    sinkAddSafe();
  }

  @override
  Future<void> move(NavID to) async {}

  @override
  void addressAutoCompleteCallback() {
    if (balance > 0) {
      addRecipient();
    } else {
      final BuildContext? context = Coordinator.rootNavigatorKey.currentContext;
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
    final int recipientCount = validRecipientCount();
    if (recipientCount > 0) {
      final double amount = totalAmount / recipientCount;
      for (ProtonRecipient recipient in recipients) {
        if (bitcoinBase) {
          recipient.amountController.text = amount.toStringAsFixed(8);
        } else {
          recipient.amountController.text = amount.toStringAsFixed(
              ExchangeCalculator.getDisplayDigit(exchangeRate));
        }
      }
    }
    sinkAddSafe();
  }

  Future<bool> _sendInviteForEmailIntegration(String email) async {
    String? emailAddressID;
    if (accountAddressIDs.isNotEmpty) {
      emailAddressID = accountAddressIDs.first;
    } else {
      emailAddressID = addressKeys.firstOrNull?.id;
    }
    try {
      await inviteClient.sendEmailIntegrationInvite(
          inviteeEmail: email, inviterAddressId: emailAddressID ?? "");
      exclusiveInviteDataProvider.updateData();
    } on BridgeError catch (e) {
      appStateManager.updateStateFrom(e);
      final errMsg = parseSampleDisplayError(e);
      final BuildContext? context = Coordinator.rootNavigatorKey.currentContext;
      if (context != null && context.mounted) {
        CommonHelper.showErrorDialog(errMsg);
      }
      return false;
    } catch (e) {
      final BuildContext? context = Coordinator.rootNavigatorKey.currentContext;
      if (context != null && context.mounted) {
        CommonHelper.showErrorDialog(e.toString());
      }
      return false;
    }
    return true;
  }

  Future<bool> _sendInviteForNewComer(String email) async {
    String? emailAddressID;
    if (accountAddressIDs.isNotEmpty) {
      emailAddressID = accountAddressIDs.first;
    } else {
      emailAddressID = addressKeys.firstOrNull?.id;
    }
    try {
      await inviteClient.sendNewcomerInvite(
          inviteeEmail: email, inviterAddressId: emailAddressID ?? "");
      exclusiveInviteDataProvider.updateData();
    } on BridgeError catch (e) {
      appStateManager.updateStateFrom(e);
      final errMsg = parseSampleDisplayError(e);
      final BuildContext? context = Coordinator.rootNavigatorKey.currentContext;
      if (context != null && context.mounted) {
        CommonHelper.showErrorDialog(errMsg);
      }
      return false;
    } catch (e) {
      final BuildContext? context = Coordinator.rootNavigatorKey.currentContext;
      if (context != null && context.mounted) {
        CommonHelper.showErrorDialog(e.toString());
      }
      return false;
    }
    return true;
  }

  bool _processError(BridgeError error, Object stacktrace) {
    logger.e(
      "Send sendCoin() error: $error stacktrace: $stacktrace",
    );
    final msg = "Send error process: ${parseSampleDisplayError(error)}";
    if (msg.isNotEmpty) {
      // TODO(fix): improve logic here
      final BuildContext? context = Coordinator.rootNavigatorKey.currentContext;
      if (msg.toLowerCase().contains("outputbelowdustlimit")) {
        if (context != null) {
          CommonHelper.showSnackbar(
            context,
            S.of(context).error_you_dont_have_sufficient_balance,
            isError: true,
          );
        } else {
          CommonHelper.showErrorDialog(
            msg,
            callback: () {
              // TODO(fix): change me back
              // if (Platform.isAndroid || Platform.isIOS) {
              //   coordinator.showNativeReportBugs();
              // }
            },
          );
        }
      } else if (msg.toLowerCase().contains("incorrectchecksumerror")) {
        if (context != null) {
          CommonHelper.showSnackbar(
            context,
            S.of(context).error_this_bitcoin_address_incorrect_checksum,
            isError: true,
          );
        } else {
          CommonHelper.showErrorDialog(
            msg,
            callback: () {
              // TODO(fix): change me back
              // if (Platform.isAndroid || Platform.isIOS) {
              //   coordinator.showNativeReportBugs();
              // }
            },
          );
        }
      } else {
        Sentry.captureException(error, stackTrace: stacktrace);
        CommonHelper.showErrorDialog(
          msg,
          callback: () {
            // TODO(fix): change me back
            // if (Platform.isAndroid || Platform.isIOS) {
            //   coordinator.showNativeReportBugs();
            // }
          },
        );
      }
    }
    return false;
  }

  Future<String> decryptAccountName(String encryptedName) async {
    if (secretKey == null) {
      final walletKey = await walletKeysProvider.getWalletKey(
        walletID,
      );
      if (walletKey != null) {
        final userKey = await userManager.getUserKey(walletKey.userKeyId);
        secretKey = WalletKeyHelper.decryptWalletKey(
          userKey,
          walletKey,
        );
      }
    }
    String decryptedName = "Default Wallet Account";
    if (secretKey != null) {
      try {
        decryptedName = await WalletKeyHelper.decrypt(
          secretKey!,
          encryptedName,
        );
      } catch (e) {
        logger.e(e.toString());
      }
    }
    return decryptedName;
  }

  @override
  Future<bool> sendExclusiveInvite(
      ProtonAddress protonAddress, String email) async {
    final String emailAddressID = protonAddress.id;
    try {
      await inviteClient.sendNewcomerInvite(
        inviteeEmail: email.trim(),
        inviterAddressId: emailAddressID,
      );
      exclusiveInviteDataProvider.updateData();
    } on BridgeError catch (e) {
      appStateManager.updateStateFrom(e);
      final errMsg = parseSampleDisplayError(e);
      final BuildContext? context = Coordinator.rootNavigatorKey.currentContext;
      if (context != null && context.mounted) {
        CommonHelper.showErrorDialog(errMsg);
      }
      return false;
    } catch (e) {
      final BuildContext? context = Coordinator.rootNavigatorKey.currentContext;
      if (context != null && context.mounted) {
        CommonHelper.showErrorDialog(e.toString());
      }
      return false;
    }
    return true;
  }
}
