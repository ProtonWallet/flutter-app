import 'package:flutter/material.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/constants/text.style.dart';
import 'package:wallet/helper/extension/build.context.extension.dart';
import 'package:wallet/l10n/generated/locale.dart';
import 'package:wallet/scenes/components/button.v5.dart';

class ExpandableOptions extends StatelessWidget {
  final ScrollController scrollController;
  final Function() onBackupWallet;
  final Function() onDeleteWallet;

  const ExpandableOptions({
    required this.scrollController,
    required this.onBackupWallet,
    required this.onDeleteWallet,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        title: Transform.translate(
          offset: const Offset(-8, 0),
          child: Text(
            S.of(context).view_more,
            style: ProtonStyles.body2Medium(color: ProtonColors.textWeak),
          ),
        ),
        backgroundColor: Colors.transparent,
        collapsedBackgroundColor: Colors.transparent,
        onExpansionChanged: (isExpanded) {
          if (isExpanded) {
            Future.delayed(const Duration(milliseconds: 300), () {
              scrollController.animateTo(
                scrollController.position.maxScrollExtent,
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOut,
              );
            });
          }
        },
        children: [
          const SizedBox(height: 4),
          ButtonV5(
            onPressed: onBackupWallet,
            text: S.of(context).backup_wallet_view_seed_phrase,
            width: context.width,
            backgroundColor: ProtonColors.protonBlue,
            textStyle: ProtonStyles.body1Medium(
              color: ProtonColors.white,
            ),
            height: 55,
          ),
          const SizedBox(height: 8),
          ButtonV5(
            onPressed: onDeleteWallet,
            text: S.of(context).delete_wallet,
            width: context.width,
            backgroundColor: ProtonColors.notificationError,
            textStyle: ProtonStyles.body1Medium(
              color: ProtonColors.white,
            ),
            height: 55,
          ),
        ],
      ),
    );
  }
}
