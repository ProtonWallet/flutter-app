import 'package:flutter/material.dart';
import 'package:wallet/constants/assets.gen.dart';
import 'package:wallet/constants/constants.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/l10n/generated/locale.dart';
import 'package:wallet/scenes/components/button.v5.dart';
import 'package:wallet/scenes/components/custom.header.dart';
import 'package:wallet/theme/theme.font.dart';

class BuyBitcoinInstruction extends StatelessWidget {
  const BuyBitcoinInstruction({
    required this.onConfirm,
    super.key,
  });

  final VoidCallback? onConfirm;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24.0)),
          color: ProtonColors.white,
        ),
        child: SafeArea(
          child: Column(children: [
            const CustomHeader(
              buttonDirection: AxisDirection.left,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
                child: buildContent(context),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  Widget buildContent(BuildContext context) {
    return SingleChildScrollView(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Transform.translate(
          offset: const Offset(0, -20),
          child: Column(children: [
            Assets.images.icon.bitcoinBigIcon.image(
              width: 240,
              height: 200,
            ),
            const SizedBox(height: 10),
            Text(
              S.of(context).buy_bitcoin,
              style: FontManager.titleHeadline(ProtonColors.textNorm),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(children: [
                Text(
                  S.of(context).buybitcoin_instruction_body_part_one,
                  style: FontManager.body2Regular(ProtonColors.textWeak),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 18),
                Text(
                  S.of(context).buybitcoin_instruction_body_part_two,
                  style: FontManager.body2Regular(ProtonColors.textWeak),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 18),
                Text(
                  S.of(context).buybitcoin_instruction_body_part_three,
                  style: FontManager.body2Regular(ProtonColors.textWeak),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 44),
                ButtonV5(
                  onPressed: () async {
                    Navigator.pop(context);
                    onConfirm?.call();
                  },
                  text: S.of(context).continue_buttion,
                  width: MediaQuery.of(context).size.width,
                  textStyle: FontManager.body1Median(ProtonColors.white),
                  backgroundColor: ProtonColors.protonBlue,
                  borderColor: ProtonColors.protonBlue,
                  height: 48,
                ),
                const SizedBox(height: 24),
              ]),
            ),
          ]),
        )
      ]),
    );
  }
}
