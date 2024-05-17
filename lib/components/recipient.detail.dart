import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wallet/components/button.v5.dart';
import 'package:wallet/constants/constants.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/helper/common_helper.dart';
import 'package:wallet/l10n/generated/locale.dart';
import 'package:wallet/theme/theme.font.dart';

class RecipientDetail extends StatelessWidget {
  final String? name;
  final String? email;
  final String bitcoinAddress;
  final bool isSelfBitcoinAddress;
  final VoidCallback? callback;

  const RecipientDetail({
    super.key,
    this.name,
    this.email,
    this.isSelfBitcoinAddress = false,
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
          if (!isBitcoinAddress)
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
                      showInvite(context, email ?? "");
                    },
                    child: Row(children: [
                      Text(
                        S.of(context).no_wallet_found,
                        style: FontManager.captionRegular(
                            ProtonColors.signalError),
                      ),
                      const SizedBox(width: 1),
                      Icon(Icons.info_rounded,
                          color: ProtonColors.signalError, size: 14),
                      const SizedBox(width: 16),
                      Text(S.of(context).send_invite,
                          style: FontManager.captionRegular(
                              ProtonColors.protonBlue)),
                      const SizedBox(width: 1),
                      Icon(Icons.email,
                          color: ProtonColors.protonBlue, size: 14),
                    ])),
          if (isSelfBitcoinAddress)
            Text(
              S.of(context).error_you_can_not_send_to_self_account,
              style: FontManager.captionSemiBold(ProtonColors.signalError),
            ),
        ],
      ),
      trailing: IconButton(
        onPressed: callback,
        icon: Icon(Icons.close_rounded, color: ProtonColors.textWeak),
      ),
    );
  }
}

void showInvite(BuildContext context, String email) {
  showModalBottomSheet(
      context: context,
      backgroundColor: ProtonColors.white,
      constraints: BoxConstraints(
        minWidth: MediaQuery.of(context).size.width,
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(8.0)),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
          return SafeArea(
            child: SingleChildScrollView(
                child: Padding(
                    padding: const EdgeInsets.all(defaultPadding),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SvgPicture.asset(
                            "assets/images/icon/no_wallet_found.svg",
                            fit: BoxFit.fill,
                            width: 86,
                            height: 87),
                        const SizedBox(height: 10),
                        Text(S.of(context).no_wallet_found,
                            style:
                                FontManager.body1Median(ProtonColors.textNorm)),
                        const SizedBox(height: 5),
                        Text(S.of(context).no_wallet_found_desc,
                            style: FontManager.body2Regular(
                                ProtonColors.textWeak)),
                        const SizedBox(height: 20),
                        ButtonV5(
                          text: S.of(context).send_invite,
                          width: MediaQuery.of(context).size.width,
                          backgroundColor: ProtonColors.protonBlue,
                          textStyle:
                              FontManager.body1Median(ProtonColors.white),
                          height: 48,
                          onPressed: () {
                            sendEmailInvite(email, S.of(context).invite_subject,
                                S.of(context).invite_body);
                            Navigator.of(context).pop();
                          },
                        ),
                        const SizedBox(height: 10),
                      ],
                    ))),
          );
        });
      });
}

Future<void> sendEmailInvite(String email, String subject, String body) async {
  final Uri params = Uri(
    scheme: 'mailto',
    path: email,
    query: 'subject=$subject&body=$body',
  );
  launchUrl(params);
}
