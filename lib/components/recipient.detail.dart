import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wallet/components/bottom.sheets/recipient.detail.dart';
import 'package:wallet/components/textfield.text.v2.dart';
import 'package:wallet/constants/constants.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/helper/common_helper.dart';
import 'package:wallet/helper/local_toast.dart';
import 'package:wallet/l10n/generated/locale.dart';
import 'package:wallet/theme/theme.font.dart';

import 'bottom.sheets/base.dart';

class RecipientDetail extends StatelessWidget {
  final String? name;
  final String? email;
  final String bitcoinAddress;
  final bool isSelfBitcoinAddress;
  final bool isSignatureInvalid;
  final bool isBlocked;
  final VoidCallback? callback;
  final TextEditingController? amountController;
  final FocusNode? amountFocusNode;

  const RecipientDetail({
    super.key,
    this.name,
    this.email,
    this.isSelfBitcoinAddress = false,
    this.isSignatureInvalid = false,
    this.isBlocked = false,
    required this.bitcoinAddress,
    this.callback,
    this.amountController,
    this.amountFocusNode,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6.0),
      padding:
          const EdgeInsets.only(left: 0.0, right: 0.0, top: 6.0, bottom: 6.0),
      decoration: BoxDecoration(
          color: ProtonColors.backgroundProton,
          borderRadius: BorderRadius.circular(12.0)),
      child: buildContent(context, CommonHelper.isBitcoinAddress(name ?? "")),
    );
  }

  Widget buildContent(BuildContext context, bool isBitcoinAddress) {
    return Column(
      children: [
        Row(
          children: [
            GestureDetector(
                onTap: callback,
                child: CircleAvatar(
                    backgroundColor: ProtonColors.textHint,
                    radius: 10,
                    child: Icon(
                      Icons.close,
                      color: ProtonColors.white,
                      size: 12,
                    ))),
            const SizedBox(width: 8),
            isBitcoinAddress
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
            const SizedBox(width: 6),
            Expanded(
                child: Column(
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
                            Clipboard.setData(
                                    ClipboardData(text: bitcoinAddress))
                                .then((_) {
                              if (context.mounted) {
                                CommonHelper.showSnackbar(
                                    context, S.of(context).copied_address);
                              }
                            });
                          },
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                    width: min(
                                        240,
                                        MediaQuery.of(context).size.width -
                                            260),
                                    child: Text(bitcoinAddress,
                                        overflow: TextOverflow.ellipsis,
                                        style: FontManager.overlineRegular(
                                            ProtonColors.textWeak))),
                                Icon(Icons.copy_rounded,
                                    color: ProtonColors.textWeak, size: 14)
                              ]))
                      : GestureDetector(
                          onTap: () {
                            // InviteSheet.show(context, email ?? "");
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
                        style: FontManager.captionSemiBold(
                            ProtonColors.signalError),
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
                        S
                            .of(context)
                            .error_this_bitcoin_address_signature_is_invalid,
                        style: FontManager.captionSemiBold(
                            ProtonColors.signalError),
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
                        style: FontManager.captionSemiBold(
                            ProtonColors.signalError),
                      ),
                    )
                  ]),
              ],
            )),
            amountController != null
                ? SizedBox(
                    width: 140,
                    child: TextFieldTextV2(
                      textController: amountController!,
                      paddingSize: 2,
                      myFocusNode: amountFocusNode ?? FocusNode(),
                      backgroundColor: ProtonColors.white,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp(r'^\d*\.?\d*$'))
                      ],
                      labelText: S.of(context).amount,
                      validation: (String value) {
                        return "";
                      },
                    ))
                : GestureDetector(
                    onTap: () {
                      RecipientDetailSheet.show(
                        context,
                        name,
                        email,
                        bitcoinAddress,
                        isBitcoinAddress,
                      );
                    },
                    child: Icon(Icons.expand_more_rounded,
                        size: 20, color: ProtonColors.textHint)),
          ],
        )
      ],
    );
  }
}
