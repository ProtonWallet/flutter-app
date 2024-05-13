import 'dart:async';
import 'dart:math';
import 'package:wallet/helper/bdk/mnemonic.dart';
import 'package:wallet/helper/common_helper.dart';
import 'package:wallet/helper/extension/stream.controller.dart';
import 'package:wallet/helper/wallet_manager.dart';
import 'package:wallet/rust/bdk/types.dart';
import 'package:wallet/scenes/core/view.navigatior.identifiers.dart';
import 'package:wallet/scenes/core/viewmodel.dart';
import 'package:wallet/scenes/setup/create.coordinator.dart';

class AnimatedSquare {
  double squareSize;
  int alpha;
  double top;
  bool visible = true;

  AnimatedSquare(
      {required this.squareSize, required this.alpha, required this.top});
}

abstract class SetupCreateViewModel extends ViewModel<SetupCreateCoordinator> {
  SetupCreateViewModel(super.coordinator);

  bool inProgress = true;
  bool isAnimationStart = false;
  List<AnimatedSquare> animatedSquares = [];
  String strMnemonic = "";
  String errorMessage = "";

  void startAnimate(bool start);
}

class SetupCreateViewModelImpl extends SetupCreateViewModel {
  SetupCreateViewModelImpl(super.coordinator);

  final datasourceChangedStreamController =
      StreamController<SetupCreateViewModel>.broadcast();

  @override
  void dispose() {
    datasourceChangedStreamController.close();
  }

  @override
  Future<void> loadData() async {
    initSquares();
    Mnemonic mnemonic = await Mnemonic.create(WordCount.words12);
    strMnemonic = mnemonic.asString();
    Future.delayed(const Duration(microseconds: 100), () {
      startAnimate(true);
    });
    bool hasWallet = await WalletManager.hasWallet();
    if (hasWallet == false) {
      try {
        await WalletManager.autoCreateWallet();
        await WalletManager.autoBindEmailAddresses();
      } catch (e) {
        errorMessage = e.toString();
      }
      coordinator.pop();
      if (errorMessage.isNotEmpty) {
        CommonHelper.showErrorDialog(e.toString());
      }
    } else {
      Future.delayed(const Duration(milliseconds: 1000), () {
        coordinator.showPassphrase(strMnemonic);
      });
    }
    return;
  }

  @override
  Stream<ViewModel> get datasourceChanged =>
      datasourceChangedStreamController.stream;

  @override
  void startAnimate(bool start) {
    isAnimationStart = start;
    datasourceChangedStreamController.sinkAddSafe(this);
  }

  void initSquares() {
    var squareSizes = [9, 13, 16];
    var alphas = [26, 80, 178];
    for (int i = 0; i < 80; i++) {
      double squareSize =
          squareSizes[Random().nextInt(squareSizes.length)].toDouble();
      int alpha = alphas[Random().nextInt(alphas.length)];
      animatedSquares.add(AnimatedSquare(
          squareSize: squareSize,
          alpha: alpha,
          top: Random().nextInt(1000).toDouble()));
    }
  }

  @override
  void move(NavID to) {
    switch (to) {
      case NavID.passphrase:
        coordinator.showPassphrase(strMnemonic);
        break;
      default:
        break;
    }
  }
}
