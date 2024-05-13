import 'package:flutter/material.dart';
import 'package:wallet/components/home/custom.homepage.box.dart';
import 'package:wallet/constants/assets.gen.dart';
import 'package:wallet/constants/constants.dart';
import 'package:wallet/l10n/generated/locale.dart';
import 'package:wallet/theme/theme.font.dart';
import 'package:wallet/constants/proton.color.dart';

class BtcTitleActionsView extends StatelessWidget {
  final double price;
  final double priceChange;
  final GestureTapCallback? onSend;
  final GestureTapCallback? onBuy;
  final GestureTapCallback? onReceive;

  const BtcTitleActionsView(
      {super.key,
      required this.price,
      required this.priceChange,
      this.onSend,
      this.onBuy,
      this.onReceive});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      CustomHomePageBox(
        title: S.of(context).current_btc_price,
        icon: Assets.images.icon.bitcoin,
        width: MediaQuery.of(context).size.width - defaultPadding * 2,
        price: price,
        priceChange: priceChange,
        children: buildActions(context),
      ),
    ]);
  }

  List<Widget> buildActions(BuildContext context) {
    return [
      SizedBox(
          width: 80,
          child: GestureDetector(
            onTap: onSend,
            child: Text(
              S.of(context).send_button,
              textAlign: TextAlign.center,
              style: FontManager.body1Regular(ProtonColors.textWeak),
            ),
          )),
      SizedBox(
          width: 80,
          child: GestureDetector(
            onTap: onReceive,
            child: Text(
              S.of(context).receive,
              textAlign: TextAlign.center,
              style: FontManager.body1Regular(ProtonColors.textWeak),
            ),
          )),
      SizedBox(
          width: 80,
          child: GestureDetector(
            onTap: onBuy,
            child: Text(
              S.of(context).buy,
              textAlign: TextAlign.center,
              style: FontManager.body1Regular(ProtonColors.textWeak),
            ),
          )),
    ];
  }
}
