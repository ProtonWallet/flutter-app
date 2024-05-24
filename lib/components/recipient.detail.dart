import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/helper/common_helper.dart';
import 'package:wallet/l10n/generated/locale.dart';
import 'package:wallet/scenes/send/bottom.sheet/invite.dart';
import 'package:wallet/theme/theme.font.dart';

class RecipientDetail extends StatelessWidget {
  final String? name;
  final String? email;
  final String bitcoinAddress;
  final bool isSelfBitcoinAddress;
  final bool isSignatureInvalid;
  final bool isBlocked;
  final VoidCallback? callback;

  const RecipientDetail({
    super.key,
    this.name,
    this.email,
    this.isSelfBitcoinAddress = false,
    this.isSignatureInvalid = false,
    this.isBlocked = false,
    required this.bitcoinAddress,
    this.callback,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6.0),
      padding:
          const EdgeInsets.only(left: 6.0, right: 0.0, top: 2.0, bottom: 2.0),
      decoration: BoxDecoration(
          color: ProtonColors.backgroundProton,
          borderRadius: BorderRadius.circular(12.0)),
      child: buildContent(context, CommonHelper.isBitcoinAddress(name ?? "")),
    );
  }

  Widget buildContent(BuildContext context, bool isBitcoinAddress) {
    return ListTile(
      leading: isBitcoinAddress
          ? CircleAvatar(
              backgroundColor: ProtonColors.protonBlue,
              radius: 16,
              child: Text(
                "B",
                style: FontManager.captionSemiBold(ProtonColors.white),
              ),
            )
          : CircleAvatar(
              backgroundColor: ProtonColors.protonBlue,
              radius: 16,
              child: Text(
                name != null
                    ? CommonHelper.getFirstNChar(name!, 1).toUpperCase()
                    : "",
                style: FontManager.captionSemiBold(ProtonColors.white),
              ),
            ),
      title: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (name != null)
            Text(name!,
                style: FontManager.captionMedian(ProtonColors.textNorm)),
          if (email != null && name != email && !isBitcoinAddress)
            Text(email!,
                style: FontManager.captionMedian(ProtonColors.textNorm)),
          if (!isBitcoinAddress && !isSignatureInvalid && !isBlocked)
            bitcoinAddress.isNotEmpty
                ? GestureDetector(
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: bitcoinAddress))
                          .then((_) {
                        CommonHelper.showSnackbar(
                            context, S.of(context).copied_address);
                      });
                    },
                    child: Row(children: [
                      SizedBox(
                          width: 150,
                          child: Text(bitcoinAddress,
                              overflow: TextOverflow.ellipsis,
                              style: FontManager.overlineRegular(
                                  ProtonColors.textWeak))),
                      Icon(Icons.copy_rounded,
                          color: ProtonColors.textWeak, size: 14)
                    ]))
                : GestureDetector(
                    onTap: () {
                      InviteSheet.show(context, email ?? "");
                    },
                    child: Row(children: [
                      Icon(Icons.info_rounded,
                          color: ProtonColors.signalError, size: 14),
                      const SizedBox(width: 1),
                      Text(
                        S.of(context).no_wallet_found,
                        style: FontManager.captionRegular(
                            ProtonColors.signalError),
                      ),
                      const SizedBox(width: 16),
                      Text(S.of(context).send_invite,
                          style: FontManager.captionRegular(
                              ProtonColors.protonBlue)),
                      const SizedBox(width: 1),
                      Icon(Icons.email,
                          color: ProtonColors.protonBlue, size: 14),
                    ])),
          if (isSelfBitcoinAddress)
            Row(children: [
              Icon(Icons.info_rounded,
                  color: ProtonColors.signalError, size: 14),
              const SizedBox(width: 1),
              SizedBox(
                width: MediaQuery.of(context).size.width - 200,
                child: Text(
                  S.of(context).error_you_can_not_send_to_self_account,
                  style: FontManager.captionSemiBold(ProtonColors.signalError),
                ),
              )
            ]),
          if (isSignatureInvalid)
            Row(children: [
              Icon(Icons.info_rounded,
                  color: ProtonColors.signalError, size: 14),
              const SizedBox(width: 1),
              SizedBox(
                width: MediaQuery.of(context).size.width - 200,
                child: Text(
                  S.of(context).error_this_bitcoin_address_signature_is_invalid,
                  style: FontManager.captionSemiBold(ProtonColors.signalError),
                ),
              )
            ]),
          if (isBlocked)
            Row(children: [
              Icon(Icons.info_rounded,
                  color: ProtonColors.signalError, size: 14),
              const SizedBox(width: 1),
              SizedBox(
                width: MediaQuery.of(context).size.width - 200,
                child: Text(
                  S.of(context).error_this_bitcoin_address_is_blocked,
                  style: FontManager.captionSemiBold(ProtonColors.signalError),
                ),
              )
            ])
        ],
      ),
      trailing: IconButton(
        onPressed: callback,
        icon: Icon(Icons.close_rounded, color: ProtonColors.textWeak),
      ),
    );
  }
}

// Future<void> sendEmailInvite(String email, String subject, String body) async {
//   final Uri params = Uri(
//     scheme: 'mailto',
//     path: email,
//     query: 'subject=$subject&body=$body',
//   );
//   launchUrl(params);
// }
