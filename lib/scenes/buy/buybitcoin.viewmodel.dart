import 'dart:async';
import 'dart:ui';
import 'package:flutter/services.dart';
import 'package:ramp_flutter/configuration.dart';
import 'package:ramp_flutter/offramp_sale.dart';
import 'package:ramp_flutter/onramp_purchase.dart';
import 'package:ramp_flutter/ramp_flutter.dart';
import 'package:ramp_flutter/send_crypto_payload.dart';
import 'package:wallet/constants/assets.gen.dart';
import 'package:wallet/constants/env.var.dart';
import 'package:wallet/helper/dbhelper.dart';
import 'package:wallet/helper/extension/data.dart';
import 'package:wallet/helper/extension/stream.controller.dart';
import 'package:wallet/helper/logger.dart';
import 'package:wallet/managers/wallet/wallet.manager.dart';
import 'package:wallet/models/account.model.dart';
import 'package:wallet/models/bitcoin.address.model.dart';
import 'package:wallet/models/wallet.model.dart';
import 'package:wallet/rust/api/bdk_wallet/account.dart';
import 'package:wallet/rust/proton_api/payment_gateway.dart';
import 'package:wallet/managers/features/buy.bitcoin/buybitcoin.bloc.dart';
import 'package:wallet/scenes/buy/buybitcoin.coordinator.dart';
import 'package:wallet/managers/features/buy.bitcoin/buybitcoin.bloc.event.dart';
import 'package:wallet/managers/features/buy.bitcoin/buybitcoin.bloc.model.dart';
import 'package:wallet/scenes/buy/payment.dropdown.item.dart';
import 'package:wallet/scenes/core/view.navigatior.identifiers.dart';
import 'package:wallet/scenes/core/viewmodel.dart';

abstract class BuyBitcoinViewModel extends ViewModel<BuyBitcoinCoordinator> {
  BuyBitcoinViewModel(super.coordinator);

  bool get supportOffRamp;

  String receiveAddress = "";

  bool isloading = false;

  void startLoading();

  bool isBuying = true;
  int index = 0;

  BuyBitcoinBloc get bloc;

  void toggleButtons();

  void sellbutton();

  List<DropdownItem> payments = [];
  List<DropdownItem> providers = [];

  /// get prebuild country code
  late List<String> favoriteCountryCode;

  ///
  void selectCountry(String code);
  void selectCurrency(String fiatCurrency);
  void selectAmount(String amount);

  void pay(SelectedInfoModel selected);
}

class BuyBitcoinViewModelImpl extends BuyBitcoinViewModel {
  BuyBitcoinViewModelImpl(super.coordinator, this.userEmail, this.buyBloc);
  final datasourceChangedStreamController =
      StreamController<BuyBitcoinViewModel>.broadcast();

  @override
  void dispose() {
    datasourceChangedStreamController.close();
  }

  /// features
  final BuyBitcoinBloc buyBloc;

  /// ramp
  late final Configuration configuration;
  late final RampFlutter ramp;

  //
  final int walletID = 1;
  final String userEmail;
  final int accountID = 1;

  @override
  List<String> get favoriteCountryCode {
    var currentCode = PlatformDispatcher.instance.locale.countryCode ?? "US";
    return [currentCode];
  }

  @override
  BuyBitcoinBloc get bloc => buyBloc;

  @override
  bool get supportOffRamp => false;
  String apiKey = '';

  @override
  Future<void> loadData() async {
    apiKey = Env.rampApiKey ?? "";

    payments.add(DropdownItem(
      icon: 'assets/images/credit-card.png',
      title: 'Credit Card',
      subtitle: 'Take minutes',
    ));
    payments.add(DropdownItem(
      icon: 'assets/images/bank-transfer.png',
      title: 'Bank Transfer',
      subtitle: 'Take days',
    ));
    payments.add(DropdownItem(
      icon: 'assets/images/apple-pay.png',
      title: 'Apple Pay',
      subtitle: 'Up to 2 business days',
    ));

    providers.add(DropdownItem(
      icon: 'assets/images/coinbase.png',
      title: 'Ramp',
      subtitle: '0.00155 BTC',
    ));
    providers.add(DropdownItem(
      icon: 'assets/images/binance.png',
      title: 'Banxa',
      subtitle: '0.00155 BTC',
    ));

    configuration = Configuration()
      ..hostApiKey = apiKey
      ..hostAppName = "Proton Wallet"
      ..defaultFlow = "ONRAMP"
      ..userAddress = receiveAddress
      ..userEmailAddress = userEmail;

    ramp = RampFlutter();
    ramp.onOnrampPurchaseCreated = onOnrampPurchaseCreated;
    ramp.onSendCryptoRequested = onSendCryptoRequested;
    ramp.onOfframpSaleCreated = onOfframpSaleCreated;
    ramp.onRampClosed = onRampClosed;

    // bloc.add(const LoadCurrencyEvent());
    bloc.add(const LoadCountryEvent());
    // bloc.add(const GetquoteEvent());

    try {
      WalletModel? walletModel;
      if (walletID == 0) {
        walletModel = await DBHelper.walletDao!.getFirstPriorityWallet();
      } else {
        walletModel = await DBHelper.walletDao!.findById(walletID);
      }
      AccountModel accountModel =
          await DBHelper.accountDao!.findById(accountID);
      // await WalletManager.syncBitcoinAddressIndex(
      //     walletModel!.serverWalletID, accountModel.serverAccountID);
      await getAddress(walletModel, accountModel, init: true);
    } catch (e) {
      logger.e(e);
    }

    datasourceChangedStreamController.sinkAddSafe(this);

    // EasyLoading.dismiss();
  }

  @override
  Stream<ViewModel> get datasourceChanged =>
      datasourceChangedStreamController.stream;

  @override
  Future<void> move(NavID to) async {
    if (to == NavID.rampExternal) {
      ramp.showRamp(configuration);
    } else if (to == NavID.banaxExternal) {
      coordinator.pushWebview();
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
    String base64String = await loadAssetAsBase64(path);
    return 'data:image/png;base64,$base64String';
  }

  Future<void> getAddress(WalletModel? walletModel, AccountModel? accountModel,
      {bool init = false}) async {
    if (walletModel != null && accountModel != null) {
      FrbAccount? account;
      if (init) {
        account = await WalletManager.loadWalletWithID(
            walletModel.id!, accountModel.id!);
      }

      int addressIndex = 0;
      BitcoinAddressModel? bitcoinAddressModel =
          await DBHelper.bitcoinAddressDao!.findLatestUnusedLocalBitcoinAddress(
              walletModel.serverWalletID, accountModel.serverAccountID);
      if (bitcoinAddressModel != null && bitcoinAddressModel.used == 0) {
        addressIndex = bitcoinAddressModel.bitcoinAddressIndex;
      } else {
        addressIndex = await WalletManager.getBitcoinAddressIndex(
            walletModel.serverWalletID, accountModel.serverAccountID);
      }
      var addressInfo = await account!.getAddress(index: addressIndex);
      receiveAddress = addressInfo.address;
      try {
        await DBHelper.bitcoinAddressDao!.insertOrUpdate(
            serverWalletID: walletModel.serverWalletID,
            serverAccountID: accountModel.serverAccountID,
            bitcoinAddress: receiveAddress,
            bitcoinAddressIndex: addressIndex,
            inEmailIntegrationPool: 0,
            used: 0);
      } catch (e) {
        logger.e(e.toString());
      }
      datasourceChangedStreamController.sinkAddSafe(this);
    }
  }

  @override
  void startLoading() {
    // bloc.add(const LoadCountryEvent());
    // bloc.add(const LoadAddressEvent());
    // presentRamp();
    // isloading = true;
    // datasourceChangedStreamController.sinkAddSafe(this);
    // Simulate a network request or any async task
    // Future.delayed(const Duration(seconds: 3), () {
    //   isloading = false;
    // });
  }

  @override
  void toggleButtons() {
    isBuying = !isBuying;
    datasourceChangedStreamController.sinkAddSafe(this);
  }

  @override
  void sellbutton() {
    isBuying = false;
    datasourceChangedStreamController.sinkAddSafe(this);
  }

  @override
  void selectCountry(String code) {
    bloc.add(SelectCountryEvent(code));
  }

  @override
  void selectCurrency(String fiatCurrency) {
    bloc.add(SelectCurrencyEvent(fiatCurrency));
  }

  @override
  void selectAmount(String amount) {
    bloc.add(SelectAmountEvent(amount));
  }

  @override
  void pay(SelectedInfoModel selected) {
    if (selected.provider == GatewayProvider.ramp) {
      configuration.hostLogoUrl =
          "https://th.bing.com/th/id/R.984dd7865d06ed7186f77236ae88c3ad?rik=gVkHMUQFXNwzJQ&pid=ImgRaw&r=0";
      configuration.enabledFlows =
          supportOffRamp ? ["ONRAMP", "OFFRAMP"] : ["ONRAMP"];

      configuration.swapAsset = "BTC_BTC";
      configuration.defaultAsset = "BTC";
      configuration.fiatValue = selected.amount.toString();
      configuration.fiatCurrency = selected.fiatCurrency.symbol;
      configuration.selectedCountryCode = selected.country.code;

      configuration.variant = "auto";

      move(NavID.rampExternal);
    }
  }
}
