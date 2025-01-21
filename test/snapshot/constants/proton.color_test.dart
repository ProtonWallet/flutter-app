import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:wallet/constants/fonts.gen.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/constants/text.style.dart';

import '../helper/test.wrapper.dart';

void main() {
  const testPath = 'proton.color';
  setUpAll(() async {
    await loadAppFonts();
  });

  testSnapshot('Proton colors general checks white bg', (tester) async {
    final builder = GoldenBuilder.grid(
      columns: 1,
      widthToHeightRatio: 1,
      bgColor: Colors.white,
    )..addScenario('', ProtonColorsWidget());
    await tester.pumpWidgetBuilder(
      builder.build(),
      wrapper: materialAppWrapper(
        theme: ThemeData(
          fontFamily: FontFamily.inter,
        ),
      ),
      surfaceSize: const Size(1200, 3400),
      textScaleSize: 3.0,
    );
    await screenMatchesGolden(
      tester,
      "$testPath/colors.wbg.grid",
    );
  });

  testSnapshot('Proton colors general checks', (tester) async {
    ProtonColors.updateLightTheme();
    ProtonColors.updateDarkTheme();
    final builder = GoldenBuilder.grid(
      columns: 1,
      widthToHeightRatio: 1,
      bgColor: Colors.black,
    )..addScenario('', ProtonColorsWidget());
    await tester.pumpWidgetBuilder(
      builder.build(),
      wrapper: materialAppWrapper(
        theme: ThemeData(
          fontFamily: FontFamily.inter,
        ),
      ),
      surfaceSize: const Size(1200, 3400),
      textScaleSize: 3.0,
    );
    await screenMatchesGolden(
      tester,
      "$testPath/colors.bbg.grid",
    );
  });
}

class ProtonColorsWidget extends StatelessWidget {
  const ProtonColorsWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// error dialog background color, used when deleting wallet/account has balance
          ColorText(
            ProtonColors.errorBackground,
            "errorBackground",
          ),

          /// text colors
          ColorText(
            ProtonColors.textNorm,
            "textNorm",
          ),
          ColorText(
            ProtonColors.textHint,
            "textHint",
          ),
          ColorText(
            ProtonColors.textWeak,
            "textWeak",
          ),
          ColorText(
            ProtonColors.textInverted,
            "textInverted",
          ),
          ColorText(
            ProtonColors.interActionWeak,
            "interActionWeak",
          ),

          /// slider colors, used for RBF
          ColorText(
            ProtonColors.sliderActiveColor,
            "sliderActiveColor",
          ),
          ColorText(
            ProtonColors.sliderInactiveColor,
            "sliderInactiveColor",
          ),

          /// alert colors
          ColorText(
            ProtonColors.alertWaning,
            "alertWaning",
          ),
          ColorText(
            ProtonColors.alertWaningBackground,
            "alertWaningBackground",
          ),

          /// signal colors, used for btc price chart, status code
          ColorText(
            ProtonColors.signalSuccess,
            "signalSuccess",
          ),
          ColorText(
            ProtonColors.signalError,
            "signalError",
          ),

          /// other one-time custom colors styles for widgets
          ColorText(
            ProtonColors.launchBackground,
            "launchBackground",
          ),
          ColorText(
            ProtonColors.homeActionButtonBackground,
            "homeActionButtonBackground",
          ),
          ColorText(
            ProtonColors.black,
            "black",
          ),
          ColorText(
            ProtonColors.expansionShadow,
            "expansionShadow",
          ),
          ColorText(
            ProtonColors.loadingShadow,
            "loadingShadow",
          ),
          ColorText(
            ProtonColors.inputDoneOverlay,
            "inputDoneOverlay",
          ),
          ColorText(
            ProtonColors.circularProgressIndicatorBackGround,
            "circularProgressIndicatorBackGround",
          ),

          /// interAction-Norm, used for link, button background
          ColorText(
            ProtonColors.protonBlue,
            "protonBlue",
          ),

          /// drawer colors
          ColorText(
            ProtonColors.drawerBackground,
            "drawerBackground",
          ),
          ColorText(
            ProtonColors.drawerBackgroundHighlight,
            "drawerBackgroundHighlight",
          ),

          /// bitcoin wallet avatar text and background colors
          ColorText(
            ProtonColors.pink1Text,
            "pink1Text",
          ),
          ColorText(
            ProtonColors.pink1Background,
            "pink1Background",
          ),
          ColorText(
            ProtonColors.blue1Text,
            "blue1Text",
          ),
          ColorText(
            ProtonColors.blue1Background,
            "blue1Background",
          ),
          ColorText(
            ProtonColors.yellow1Text,
            "yellow1Text",
          ),
          ColorText(
            ProtonColors.yellow1Background,
            "yellow1Background",
          ),
          ColorText(
            ProtonColors.green1Text,
            "green1Text",
          ),
          ColorText(
            ProtonColors.green1Background,
            "green1Background",
          ),

          /// recipient avatar text and background colors
          ColorText(
            ProtonColors.avatarOrange1Text,
            "avatarOrange1Text",
          ),
          ColorText(
            ProtonColors.avatarOrange1Background,
            "avatarOrange1Background",
          ),
          ColorText(
            ProtonColors.avatarPink1Text,
            "avatarPink1Text",
          ),
          ColorText(
            ProtonColors.avatarPink1Background,
            "avatarPink1Background",
          ),
          ColorText(
            ProtonColors.avatarPurple1Text,
            "avatarPurple1TextavatarPurple1Text",
          ),
          ColorText(
            ProtonColors.avatarPurple1Background,
            "avatarPurple1Background",
          ),
          ColorText(
            ProtonColors.avatarBlue1Text,
            "avatarBlue1Text",
          ),
          ColorText(
            ProtonColors.avatarBlue1Background,
            "avatarBlue1Background",
          ),
          ColorText(
            ProtonColors.avatarGreen1Text,
            "avatarGreen1Text",
          ),
          ColorText(
            ProtonColors.avatarGreen1Background,
            "avatarGreen1Background",
          ),
        ],
      ),
    );
  }
}

class ColorText extends StatelessWidget {
  final Color color;
  final String colorString;
  const ColorText(
    this.color,
    this.colorString, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      "$colorString <$color>",
      style: ProtonStyles.body1Regular(
        color: color,
      ),
    );
  }
}
