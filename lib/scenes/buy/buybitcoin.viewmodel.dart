import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:ramp_flutter/configuration.dart';
import 'package:ramp_flutter/offramp_sale.dart';
import 'package:ramp_flutter/onramp_purchase.dart';
import 'package:ramp_flutter/ramp_flutter.dart';
import 'package:ramp_flutter/send_crypto_payload.dart';
import 'package:wallet/constants/app.config.dart';
import 'package:wallet/constants/assets.gen.dart';
import 'package:wallet/helper/bdk/helper.dart';
import 'package:wallet/helper/dbhelper.dart';
import 'package:wallet/helper/extension/data.dart';
import 'package:wallet/helper/extension/stream.controller.dart';
import 'package:wallet/helper/logger.dart';
import 'package:wallet/helper/secure_storage_helper.dart';
import 'package:wallet/helper/wallet_manager.dart';
import 'package:wallet/models/account.model.dart';
import 'package:wallet/models/wallet.model.dart';
import 'package:wallet/scenes/buy/buybitcoin.coordinator.dart';
import 'package:wallet/scenes/core/view.navigatior.identifiers.dart';
import 'package:wallet/scenes/core/viewmodel.dart';
import 'package:wallet/scenes/debug/bdk.test.dart';

abstract class BuyBitcoinViewModel extends ViewModel<BuyBitcoinCoordinator> {
  BuyBitcoinViewModel(super.coordinator, this.walletID, this.accountID);
  late final Configuration configuration;
  late final RampFlutter ramp;
  bool get isTestEnv;
  bool get supportOffRamp;
  String receiveAddress = "";
  String userEmail = "";

  final int walletID;
  final int accountID;
}

class BuyBitcoinViewModelImpl extends BuyBitcoinViewModel {
  BuyBitcoinViewModelImpl(super.coordinator, super.walletID, super.accountID);
  final datasourceChangedStreamController =
      StreamController<BuyBitcoinViewModel>.broadcast();
  @override
  void dispose() {
    datasourceChangedStreamController.close();
  }

  @override
  bool get isTestEnv => false;
  @override
  bool get supportOffRamp => false;
  String apiKey = '';

  final BdkLibrary _lib = BdkLibrary(coinType: appConfig.coinType);
  @override
  Future<void> loadData() async {
    EasyLoading.show(
        status: "syncing bitcoin address index..",
        maskType: EasyLoadingMaskType.black);
    try {
      userEmail = await SecureStorageHelper.instance.get("userMail");
      WalletModel? walletModel;
      if (walletID == 0) {
        walletModel = await DBHelper.walletDao!.getFirstPriorityWallet();
      } else {
        walletModel = await DBHelper.walletDao!.findById(walletID);
      }
      AccountModel accountModel =
          await DBHelper.accountDao!.findById(accountID);
      await WalletManager.syncBitcoinAddressIndex(
          walletModel!.serverWalletID, accountModel.serverAccountID);
      await getAddress(walletModel, accountModel, init: true);
    } catch (e) {
      logger.e(e);
    }

    datasourceChangedStreamController.sinkAddSafe(this);

    // String base64LogoUrl = await getBase64ImageUrl('assets/images/wallet.png');
    configuration = Configuration()
      ..url = isTestEnv
          ? "https://app.demo.ramp.network/"
          : "https://app.ramp.network"
      ..hostApiKey = apiKey
      ..hostAppName = "Proton Wallet"
      ..defaultFlow = "ONRAMP"
      ..userAddress = receiveAddress
      ..userEmailAddress = userEmail;
    configuration.hostLogoUrl =
        "https://th.bing.com/th/id/R.984dd7865d06ed7186f77236ae88c3ad?rik=gVkHMUQFXNwzJQ&pid=ImgRaw&r=0";
    configuration.enabledFlows =
        supportOffRamp ? ["ONRAMP", "OFFRAMP"] : ["ONRAMP"];

    configuration.swapAsset = "BTC_BTC";
    configuration.defaultAsset = "BTC";
    configuration.fiatCurrency = "USD";
    configuration.selectedCountryCode = "US";

    configuration.variant = "auto";

    ramp = RampFlutter();
    ramp.onOnrampPurchaseCreated = onOnrampPurchaseCreated;
    ramp.onSendCryptoRequested = onSendCryptoRequested;
    ramp.onOfframpSaleCreated = onOfframpSaleCreated;
    ramp.onRampClosed = onRampClosed;

    EasyLoading.dismiss();
  }

  @override
  Stream<ViewModel> get datasourceChanged =>
      datasourceChangedStreamController.stream;

  @override
  void move(NavID to) {
    if (to == NavID.rampExternal) {
      presentRamp();
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
      Wallet? wallet;
      if (init) {
        wallet = await WalletManager.loadWalletWithID(
            walletModel.id!, accountModel.id!);
        List<String> emailIntegrationAddresses =
            await WalletManager.getAccountAddressIDs(
                accountModel.serverAccountID ?? "");
        // hasEmailIntegration = emailIntegrationAddresses.isNotEmpty;
      }
      int addressIndex = await WalletManager.getBitcoinAddressIndex(
          walletModel.serverWalletID, accountModel.serverAccountID);
      var addressInfo =
          await _lib.getAddress(wallet!, addressIndex: addressIndex);
      receiveAddress = addressInfo.address;
      try {
        await DBHelper.bitcoinAddressDao!.insertOrUpdate(
            walletID: walletID,
            accountID: accountID,
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

  void presentRamp() {
    ramp.showRamp(configuration);
  }
}
