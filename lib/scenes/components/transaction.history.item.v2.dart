import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:wallet/constants/constants.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/l10n/generated/locale.dart';
import 'package:wallet/scenes/components/custom.tooltip.dart';
import 'package:wallet/theme/theme.font.dart';

class TransactionHistoryItemV2 extends StatelessWidget {
  final String title;
  final Widget content;
  final Widget? memo;
  final String? titleTooltip;
  final VoidCallback? titleOptionsCallback; // display at far right of title
  final Color? backgroundColor;

  const TransactionHistoryItemV2({
    required this.title,
    required this.content,
    super.key,
    this.memo,
    this.titleOptionsCallback,
    this.titleTooltip,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(defaultPadding),
      color: backgroundColor ?? ProtonColors.backgroundProton,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            titleTooltip != null
                ? CustomTooltip(
                    message: titleTooltip ?? "",
                    child: Row(
                      children: [
                        Text(title,
                            style:
                                FontManager.body2Median(ProtonColors.textWeak)),
                        const SizedBox(width: 2),
                        if (titleTooltip != null)
                          SvgPicture.asset(
                              "assets/images/icon/ic-info-circle.svg",
                              fit: BoxFit.fill,
                              width: 20,
                              height: 20),
                      ],
                    ),
                  )
                : Text(title,
                    style: FontManager.body2Median(ProtonColors.textWeak)),
            if (titleOptionsCallback != null)
              GestureDetector(
                  onTap: titleOptionsCallback,
                  child: Text(S.of(context).advanced_options,
                      style: FontManager.body2Median(ProtonColors.textWeak)))
          ]),
          content,
          if (memo != null) memo!,
        ],
      ),
    );
  }
}
