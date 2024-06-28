import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:wallet/components/custom.tooltip.dart';
import 'package:wallet/constants/constants.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/helper/bitcoin.amount.dart';
import 'package:wallet/helper/common_helper.dart';
import 'package:wallet/l10n/generated/locale.dart';
import 'package:wallet/theme/theme.font.dart';

class TransactionHistoryItemV2 extends StatelessWidget {
  final String title;
  final Widget content;
  final Widget? memo;
  final String? titleTooltip;
  final VoidCallback? titleOptionsCallback; // display at far right of title
  final Color? backgroundColor;

  const TransactionHistoryItemV2({
    super.key,
    required this.title,
    required this.content,
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
          Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(title,
                          style:
                              FontManager.body2Median(ProtonColors.textWeak)),
                      const SizedBox(width: 2),
                      if (titleTooltip != null)
                        Transform.translate(
                          offset: const Offset(0, 1),
                          child: CustomTooltip(
                              message: titleTooltip ?? "",
                              child: SvgPicture.asset(
                                  "assets/images/icon/ic-info-circle.svg",
                                  fit: BoxFit.fill,
                                  width: 16,
                                  height: 16)),
                        )
                    ]),
                if (titleOptionsCallback != null)
                  GestureDetector(
                      onTap: titleOptionsCallback,
                      child: Text(S.of(context).advanced_options,
                          style:
                              FontManager.body2Median(ProtonColors.textWeak)))
              ]),
          content,
          if (memo != null) memo!,
        ],
      ),
    );
  }
}
