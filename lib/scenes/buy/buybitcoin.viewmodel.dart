import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:ramp_flutter/configuration.dart';
import 'package:ramp_flutter/offramp_sale.dart';
import 'package:ramp_flutter/onramp_purchase.dart';
import 'package:ramp_flutter/ramp_flutter.dart';
import 'package:ramp_flutter/send_crypto_payload.dart';
import 'package:wallet/constants/assets.gen.dart';
import 'package:wallet/constants/env.var.dart';
import 'package:wallet/helper/dbhelper.dart';
import 'package:wallet/helper/extension/data.dart';
import 'package:wallet/helper/logger.dart';
import 'package:wallet/managers/features/buy.bitcoin/buybitcoin.bloc.dart';
import 'package:wallet/managers/features/buy.bitcoin/buybitcoin.bloc.event.dart';
import 'package:wallet/managers/features/buy.bitcoin/buybitcoin.bloc.model.dart';
import 'package:wallet/managers/providers/local.bitcoin.address.provider.dart';
import 'package:wallet/managers/wallet/wallet.manager.dart';
import 'package:wallet/models/account.model.dart';
import 'package:wallet/models/wallet.model.dart';
import 'package:wallet/rust/api/bdk_wallet/account.dart';
import 'package:wallet/rust/proton_api/payment_gateway.dart';
import 'package:wallet/scenes/buy/buybitcoin.terms.dart';
import 'package:wallet/scenes/core/view.navigatior.identifiers.dart';
import 'package:wallet/scenes/core/viewmodel.dart';

import 'buybitcoin.coordinator.dart';

abstract class BuyBitcoinViewModel extends ViewModel<BuyBitcoinCoordinator> {
  BuyBitcoinViewModel(super.coordinator, this.bloc);

  final BuyBitcoinBloc bloc;

  bool get supportOffRamp;
  String receiveAddress = "";

  bool isloading = false;
  bool isBuying = true;
  bool hideSell = true;
  int index = 0;
  void toggleButtons();

  void sellbutton();

  /// get prebuild country code
  List<String>? getFavoriteCountry(List<String> availableCountries);

  /// bloc event wrappers
  void selectCountry(String code) {
    bloc.add(SelectCountryEvent(code));
  }

  void selectCurrency(String fiatCurrency) {
    bloc.add(SelectCurrencyEvent(fiatCurrency));
  }

  void selectAmount(String amount) {
    bloc.add(SelectAmountEvent(amount));
  }

  void selectPayment(PaymentMethod method) {
    bloc.add(SelectPaymentEvent(method));
  }

  void selectProvider(GatewayProvider provider) {
    bloc.add(SelectProviderEvent(provider));
  }

  void loadCountry() {
    bloc.add(const LoadCountryEvent());
  }

  Future<void> pay(SelectedInfoModel selected);
  void keyboardDone();

  FocusNode get focusNode;
  TextEditingController get controller;
  OverlayEntry? overlayEntry;

  OnRampTCSheetModel get rampTCModel => OnRampTCSheetModel(
        GatewayProvider.ramp,
        "https://ramp.network",
        "https://ramp.network/terms-of-service",
        "https://ramp.network/cookie-policy",
        "support@ramp.network",
      );

  OnRampTCSheetModel get banxaTCModel => OnRampTCSheetModel(
        GatewayProvider.banxa,
        "https://banxa.com",
        "https://banxa.com/terms-of-use",
        "https://banxa.com/privacy-and-cookies-policy",
        "support@banxa.com",
      );
}

class BuyBitcoinViewModelImpl extends BuyBitcoinViewModel {
  BuyBitcoinViewModelImpl(
    super.coordinator,
    super.bloc,
    this.userEmail,
    this.userID,
    this.walletID,
    this.accountID,
    this.localBitcoinAddressDataProvider,
  );

  @override
  void dispose() {
    focusNode.dispose();
    controller.dispose();
    super.dispose();
  }

  /// provider
  final LocalBitcoinAddressDataProvider localBitcoinAddressDataProvider;

  /// ramp
  late final Configuration configuration;
  late final RampFlutter ramp;

  //
  final String walletID;
  final String userEmail;
  final String userID;
  final String accountID;
  @override
  final FocusNode focusNode = FocusNode();
  @override
  final TextEditingController controller = TextEditingController(text: "200");

  @override
  bool get supportOffRamp => false;
  String apiKey = '';

  @override
  Future<void> loadData() async {
    apiKey = Env.rampApiKey ?? "";

    configuration = Configuration()
      ..hostApiKey = apiKey
      ..hostAppName = "Proton Wallet"
      ..defaultFlow = "ONRAMP";

    ramp = RampFlutter()
      ..onOnrampPurchaseCreated = onOnrampPurchaseCreated
      ..onSendCryptoRequested = onSendCryptoRequested
      ..onOfframpSaleCreated = onOfframpSaleCreated
      ..onRampClosed = onRampClosed;

    loadCountry();

    try {
      WalletModel? walletModel;
      if (walletID.isEmpty) {
        walletModel = await DBHelper.walletDao!.getFirstPriorityWallet(userID);
      } else {
        walletModel = await DBHelper.walletDao!.findByServerID(walletID);
      }

      AccountModel? accountModel;
      if (accountID.isEmpty) {
        accountModel = await DBHelper.accountDao!.findDefaultAccountByWalletID(
          walletModel?.walletID ?? "",
        );
      } else {
        accountModel = await DBHelper.accountDao!.findByServerID(accountID);
      }
      await getAddress(walletModel, accountModel, init: true);
    } catch (e, stacktrace) {
      logger.i(
        "buybitcoin loadData error: $e stacktrace: $stacktrace",
      );
      rethrow;
    }
    sinkAddSafe();
  }

  @override
  Future<void> move(NavID to) async {
    if (to == NavID.rampExternal) {
      ramp.showRamp(configuration);
    } else if (to == NavID.banaxExternal) {
      coordinator.pushWebview("https://banxa.com/");
    }
  }

  void onOnrampPurchaseCreated(
    OnrampPurchase purchase,
    String purchaseViewToken,
    String apiUrl,
  ) {
    logger.d("purchase created: $purchase");
  }

  void onSendCryptoRequested(SendCryptoPayload payload) {
    logger.d("message received: $payload");
  }

  void onOfframpSaleCreated(
    OfframpSale sale,
    String saleViewToken,
    String apiUrl,
  ) {
    logger.d("sale created: $sale");
  }

  void onRampClosed() {
    logger.d("ramp closed");
  }

  Future<String> loadImageAsBase64() async {
    // Load image bytes from asset
    final ByteData bytes = await rootBundle.load(Assets.images.wallet.path);
    final Uint8List list = bytes.buffer.asUint8List();
    // Encode bytes to Base64
    final String base64String = list.base64encode();
    // Create data URL
    final String dataUrl = 'data:image/png;base64,$base64String';
    return dataUrl;
  }

  Future<String> loadAssetAsBase64(String path) async {
    // Load image bytes from asset
    final ByteData bytes = await rootBundle.load(path);
    final Uint8List list = bytes.buffer.asUint8List();

    // Encode bytes to Base64
    final String base64String = list.base64encode();

    return base64String;
  }

  Future<String> getBase64ImageUrl(String path) async {
    final String base64String = await loadAssetAsBase64(path);
    return 'data:image/png;base64,$base64String';
  }

  Future<void> getAddress(
    WalletModel? walletModel,
    AccountModel? accountModel, {
    bool init = false,
  }) async {
    if (walletModel != null && accountModel != null) {
      FrbAccount? account;
      if (init) {
        account = await WalletManager.loadWalletWithID(
          walletModel.walletID,
          accountModel.accountID,
          serverScriptType: accountModel.scriptType,
        );
      }

      /// check if local highest used bitcoin address index is higher than the one store in wallet account
      /// this will happen when some one send bitcoin via qr code
      final int localLastUsedIndex = await localBitcoinAddressDataProvider
          .getLastUsedIndex(walletModel, accountModel);
      if (localLastUsedIndex > accountModel.lastUsedIndex) {
        accountModel.lastUsedIndex = localLastUsedIndex;
        await WalletManager.updateLastUsedIndex(accountModel);
      }
      int addressIndex = 0;
      if (localLastUsedIndex == -1 && accountModel.lastUsedIndex == 0) {
        addressIndex = accountModel.lastUsedIndex;
      } else {
        addressIndex = accountModel.lastUsedIndex + 1;
      }

      final addressInfo = await account!.getAddress(index: addressIndex);
      receiveAddress = addressInfo.address;
      try {
        await DBHelper.bitcoinAddressDao!.insertOrUpdate(
          serverWalletID: walletModel.walletID,
          serverAccountID: accountModel.accountID,
          bitcoinAddress: receiveAddress,
          bitcoinAddressIndex: addressIndex,
          inEmailIntegrationPool: 0,
          used: 0,
        );
      } catch (e) {
        logger.e(e.toString());
      }
      sinkAddSafe();
    }
  }

  @override
  void toggleButtons() {
    isBuying = !isBuying;
    sinkAddSafe();
  }

  @override
  void sellbutton() {
    isBuying = false;
    sinkAddSafe();
  }

  @override
  void keyboardDone() {
    final amount = bloc.state.selectedModel.amount;
    final check = bloc.toNumberAmount(controller.text);
    if (amount != check) {
      selectAmount(check);
    }
  }

  Future<void> _requestPermissions() async {
    var status = await Permission.camera.request();
    if (status.isGranted) {}

    status = await Permission.microphone.request();
    if (status.isGranted) {}
  }

  @override
  Future<void> pay(SelectedInfoModel selected) async {
    bloc.add(CheckoutLoadingEvnet());
    final check = bloc.toNumberAmount(controller.text);
    // if (amount != check) {
    if (check == "0") {
      return bloc.add(CheckoutFinishedEvnet());
    }
    selectAmount(check);

    await _requestPermissions();

    if (selected.provider == GatewayProvider.ramp) {
      configuration.hostLogoUrl =
          "https://th.bing.com/th/id/R.984dd7865d06ed7186f77236ae88c3ad?rik=gVkHMUQFXNwzJQ&pid=ImgRaw&r=0";
      configuration.enabledFlows =
          supportOffRamp ? ["ONRAMP", "OFFRAMP"] : ["ONRAMP"];
      configuration.swapAsset = "BTC_BTC";
      configuration.defaultAsset = "BTC";
      configuration.fiatValue = check;
      configuration.fiatCurrency = selected.fiatCurrency.symbol;
      configuration.selectedCountryCode = selected.country.code;
      configuration.userAddress = receiveAddress;
      configuration.userEmailAddress = userEmail;

      configuration.variant = "auto";

      move(NavID.rampExternal);
    } else if (selected.provider == GatewayProvider.banxa) {
      try {
        final checkOutUrl = await bloc.checkout(receiveAddress);
        if (checkOutUrl.isNotEmpty) {
          coordinator.pushWebview(checkOutUrl);
        }
      } catch (e) {
        logger.e(e.toString());
      }
    }
    bloc.add(CheckoutFinishedEvnet());
  }

  @override
  List<String>? getFavoriteCountry(List<String> availableCountries) {
    final currentCode = PlatformDispatcher.instance.locale.countryCode ?? "US";
    if (availableCountries.contains(currentCode)) {
      return [currentCode];
    }
    return null;
  }
}
