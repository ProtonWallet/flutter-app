import 'package:flutter/material.dart';
import 'package:wallet/constants/assets.gen.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/constants/text.style.dart';
import 'package:wallet/l10n/generated/locale.dart';

enum TransactionFilterBy {
  all,
  send,
  receive,
}

class TransactionFilterView extends StatelessWidget {
  final Function(TransactionFilterBy)? updateFilterBy;
  final TransactionFilterBy currentFilterBy;

  const TransactionFilterView({
    required this.currentFilterBy,
    super.key,
    this.updateFilterBy,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              height: 5,
            ),
            ListTile(
              trailing: currentFilterBy == TransactionFilterBy.all
                  ? Assets.images.icon.icCheckmark
                      .svg(fit: BoxFit.fill, width: 20, height: 20)
                  : null,
              title: Text(S.of(context).transaction_filter_all_transactions,
                  style: ProtonStyles.body2Regular(color:ProtonColors.textNorm)),
              onTap: () {
                updateFilterBy?.call(TransactionFilterBy.all);
                Navigator.of(context).pop();
              },
            ),
            const Divider(
              thickness: 0.2,
              height: 1,
            ),
            ListTile(
              trailing: currentFilterBy == TransactionFilterBy.send
                  ? Assets.images.icon.icCheckmark
                      .svg(fit: BoxFit.fill, width: 20, height: 20)
                  : null,
              title: Text(S.of(context).transaction_filter_sent,
                  style: ProtonStyles.body2Regular(color:ProtonColors.textNorm)),
              onTap: () {
                updateFilterBy?.call(TransactionFilterBy.send);
                Navigator.of(context).pop();
              },
            ),
            const Divider(
              thickness: 0.2,
              height: 1,
            ),
            ListTile(
              trailing: currentFilterBy == TransactionFilterBy.receive
                  ? Assets.images.icon.icCheckmark
                      .svg(fit: BoxFit.fill, width: 20, height: 20)
                  : null,
              title: Text(S.of(context).transaction_filter_received,
                  style: ProtonStyles.body2Regular(color:ProtonColors.textNorm)),
              onTap: () {
                updateFilterBy?.call(TransactionFilterBy.receive);
                Navigator.of(context).pop();
              },
            ),
          ],
        )
      ],
    );
  }
}
