import 'dart:async';
import 'dart:math';
import 'package:wallet/helper/bdk/mnemonic.dart';
import 'package:wallet/rust/bdk/types.dart';
import 'package:wallet/scenes/core/viewmodel.dart';

// import '../../generated/bridge_definitions.dart';
// import '../../helper/bdk/helper.dart';

class AnimatedSquare {
  double squareSize;
  int alpha;
  double top;
  bool visible = true;

  AnimatedSquare(
      {required this.squareSize, required this.alpha, required this.top});
}

abstract class SetupCreateViewModel extends ViewModel {
  SetupCreateViewModel(super.coordinator);

  bool inProgress = true;
  bool isAnimationStart = false;
  List<AnimatedSquare> animatedSquares = [];
  String strMnemonic = "";

  void updateProgressStatus(bool inProgress);

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
    Future.delayed(const Duration(milliseconds: 2400), () {
      updateProgressStatus(!inProgress);
    });
    return;
  }

  @override
  Stream<ViewModel> get datasourceChanged =>
      datasourceChangedStreamController.stream;

  @override
  void updateProgressStatus(bool inProgress) {
    this.inProgress = inProgress;
    datasourceChangedStreamController.add(this);
  }

  @override
  void startAnimate(bool start) {
    isAnimationStart = start;
    datasourceChangedStreamController.add(this);
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
}
