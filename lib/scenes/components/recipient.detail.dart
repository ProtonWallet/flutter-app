import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/constants/text.style.dart';
import 'package:wallet/helper/common_helper.dart';
import 'package:wallet/l10n/generated/locale.dart';
import 'package:wallet/scenes/components/bottom.sheets/recipient.detail.dart';
import 'package:wallet/scenes/components/textfield.text.v2.dart';

class RecipientDetail extends StatelessWidget {
  final String? name;
  final String? email;
  final String bitcoinAddress;
  final bool isSelfBitcoinAddress;
  final bool isSignatureInvalid;
  final bool isBlocked;
  final VoidCallback? closeCallback;
  final bool canBeClosed;
  final TextEditingController? amountController;
  final FocusNode? amountFocusNode;
  final bool showAvatar;
  final Color? avatarColor;
  final Color? avatarTextColor;

  const RecipientDetail({
    required this.bitcoinAddress,
    super.key,
    this.name,
    this.email,
    this.isSelfBitcoinAddress = false,
    this.isSignatureInvalid = false,
    this.isBlocked = false,
    this.closeCallback,
    this.canBeClosed = true,
    this.amountController,
    this.amountFocusNode,
    this.showAvatar = true,
    this.avatarColor,
    this.avatarTextColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6.0),
      padding: const EdgeInsets.only(top: 6.0, bottom: 6.0),
      decoration: BoxDecoration(
          color: ProtonColors.white, borderRadius: BorderRadius.circular(12.0)),
      child: buildContent(
        context,
        isBitcoinAddress: CommonHelper.isBitcoinAddress(email ?? ""),
      ),
    );
  }

  Widget buildContent(BuildContext context, {required bool isBitcoinAddress}) {
    return Column(
      children: [
        Row(
          children: [
            if (canBeClosed)
              GestureDetector(
                  onTap: closeCallback,
                  child: CircleAvatar(
                      backgroundColor: ProtonColors.protonBlue,
                      radius: 10,
                      child: Icon(
                        Icons.close,
                        color: ProtonColors.textInverted,
                        size: 12,
                      ))),
            SizedBox(width: canBeClosed ? 8 : 28),
            if (showAvatar)
              isBitcoinAddress
                  ? CircleAvatar(
                      backgroundColor: avatarColor ?? ProtonColors.protonBlue,
                      radius: 16,
                      child: Text(
                        "B",
                        style: ProtonStyles.captionSemibold(
                            color: avatarTextColor ?? ProtonColors.textInverted),
                      ),
                    )
                  : CircleAvatar(
                      backgroundColor: avatarColor ?? ProtonColors.protonBlue,
                      radius: 16,
                      child: Text(
                        name != null
                            ? CommonHelper.getFirstNChar(name!, 1).toUpperCase()
                            : email != null
                                ? CommonHelper.getFirstNChar(email!, 1)
                                    .toUpperCase()
                                : "",
                        style: ProtonStyles.captionSemibold(
                            color: avatarTextColor ?? ProtonColors.textInverted),
                      ),
                    ),
            const SizedBox(width: 6),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  RecipientDetailSheet.show(
                    context,
                    name,
                    email,
                    bitcoinAddress,
                    isBitcoinAddress: isBitcoinAddress,
                    avatarColor: avatarColor,
                    avatarTextColor: avatarTextColor,
                  );
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (name != null)
                      Text(name!,
                          style: ProtonStyles.body2Medium(
                              color: ProtonColors.textNorm)),
                    if (email != null && name == null && !isBitcoinAddress)
                      Text(email!,
                          style: ProtonStyles.body2Medium(
                              color: ProtonColors.textNorm)),
                    if (email != null &&
                        email != name &&
                        name != null &&
                        !isBitcoinAddress)
                      Text(email!,
                          style: ProtonStyles.captionMedium(
                              color: ProtonColors.textHint)),
                    if (email != null && isBitcoinAddress)
                      Text(CommonHelper.shorterBitcoinAddress(email!),
                          style: ProtonStyles.body2Medium(
                              color: ProtonColors.textNorm)),
                    // if (!isBitcoinAddress && !isSignatureInvalid && !isBlocked)
                    //   bitcoinAddress.isNotEmpty
                    //       ? GestureDetector(
                    //           onTap: () {
                    //             Clipboard.setData(
                    //                     ClipboardData(text: bitcoinAddress))
                    //                 .then((_) {
                    //               if (context.mounted) {
                    //                 CommonHelper.showSnackbar(
                    //                     context, S.of(context).copied_address);
                    //               }
                    //             });
                    //           },
                    //           child: Row(
                    //               crossAxisAlignment: CrossAxisAlignment.start,
                    //               children: [
                    //                 SizedBox(
                    //                     width: min(
                    //                         240,
                    //                         MediaQuery.of(context).size.width -
                    //                             260),
                    //                     child: Text(bitcoinAddress,
                    //                         overflow: TextOverflow.ellipsis,
                    //                         style: ProtonStyles.overlineRegular(
                    //                             color: ProtonColors.textWeak))),
                    //                 Icon(Icons.copy_rounded,
                    //                     color: ProtonColors.textWeak, size: 14)
                    //               ]))
                    //       : GestureDetector(
                    //           onTap: () {
                    //             // InviteSheet.show(context, email ?? "");
                    //           },
                    //           child: Row(children: [
                    //             Icon(Icons.info_rounded,
                    //                 color: ProtonColors.signalError, size: 14),
                    //             const SizedBox(width: 1),
                    //             Text(
                    //               S.of(context).no_wallet_found,
                    //               style: ProtonStyles.captionRegular(
                    //                   color: ProtonColors.signalError),
                    //             ),
                    //             const SizedBox(width: 16),
                    //             Text(S.of(context).send_invite,
                    //                 style: ProtonStyles.captionRegular(
                    //                     color: ProtonColors.protonBlue)),
                    //             const SizedBox(width: 1),
                    //             Icon(Icons.email,
                    //                 color: ProtonColors.protonBlue, size: 14),
                    //           ])),
                    if (isSelfBitcoinAddress)
                      Row(children: [
                        Icon(Icons.info_rounded,
                            color: ProtonColors.signalError, size: 14),
                        const SizedBox(width: 1),
                        SizedBox(
                          width: MediaQuery.of(context).size.width - 200,
                          child: Text(
                            S
                                .of(context)
                                .error_you_can_not_send_to_self_account,
                            style: ProtonStyles.captionSemibold(
                                color: ProtonColors.signalError),
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
                            style: ProtonStyles.captionSemibold(
                                color: ProtonColors.signalError),
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
                            style: ProtonStyles.captionSemibold(
                                color: ProtonColors.signalError),
                          ),
                        )
                      ]),
                  ],
                ),
              ),
            ),
            amountController != null
                ? SizedBox(
                    width: 140,
                    child: TextFieldTextV2(
                      textController: amountController!,
                      paddingSize: 2,
                      myFocusNode: amountFocusNode ?? FocusNode(),
                      backgroundColor: ProtonColors.backgroundNorm,
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
                        isBitcoinAddress: isBitcoinAddress,
                        avatarColor: avatarColor,
                        avatarTextColor: avatarTextColor,
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      child: Icon(Icons.expand_more_rounded,
                          size: 20, color: ProtonColors.textHint),
                    ),
                  ),
          ],
        )
      ],
    );
  }
}
