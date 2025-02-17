import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/constants/text.style.dart';
import 'package:wallet/helper/avatar.color.helper.dart';
import 'package:wallet/helper/common.helper.dart';
import 'package:wallet/models/contacts.model.dart';
import 'package:wallet/scenes/components/bottom.sheets/qr.code.scanner.dart';

class ProtonMailAutoComplete extends StatelessWidget {
  final List<ContactsModel> emails;
  final Color color;
  final TextEditingController textEditingController;
  final FocusNode focusNode;
  final String? labelText;
  final String? hintText;
  final VoidCallback? callback;
  final bool? showBorder;
  final Color? itemBackgroundColor;
  final bool updateTextController;
  final bool showQRcodeScanner;
  final double maxHeight;
  final TextInputType? keyboardType;

  const ProtonMailAutoComplete({
    required this.emails,
    required this.textEditingController,
    required this.focusNode,
    super.key,
    this.callback,
    this.labelText,
    this.hintText,
    this.color = Colors.transparent,
    this.showBorder = true,
    this.maxHeight = 320,
    this.itemBackgroundColor,
    this.updateTextController = true,
    this.showQRcodeScanner = true,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
        builder: (context, constraints) => RawAutocomplete<ContactsModel>(
            textEditingController: textEditingController,
            focusNode: focusNode,
            optionsBuilder: (TextEditingValue textEditingValue) {
              if (textEditingValue.text == '') {
                return emails;
              }
              return emails.where((ContactsModel protonContactEmail) {
                return protonContactEmail.email
                        .toLowerCase()
                        .contains(textEditingValue.text.toLowerCase()) ||
                    protonContactEmail.name
                        .toLowerCase()
                        .contains(textEditingValue.text.toLowerCase());
              });
            },
            onSelected: (ContactsModel selection) {
              if (updateTextController) {
                textEditingController.text = selection.email;
              }
              if (callback != null) {
                callback!();
              }
              focusNode.unfocus();
            },
            optionsViewBuilder: (BuildContext context,
                AutocompleteOnSelected<ContactsModel> onSelected,
                Iterable<ContactsModel> options) {
              return Align(
                alignment: Alignment.topLeft,
                child: Container(
                  constraints: BoxConstraints(
                    maxHeight: maxHeight,
                    maxWidth: constraints.biggest.width,
                  ),
                  decoration: BoxDecoration(
                    color: itemBackgroundColor ?? ProtonColors.backgroundSecondary,
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  child: ListView(
                    shrinkWrap: true,
                    children: options.map((ContactsModel option) {
                      return GestureDetector(
                        onTap: () {
                          onSelected(option);
                        },
                        child: Column(children: [
                          option.name != option.email
                              ? ListTile(
                                  leading: getEmailAvatar(option.name),
                                  title: Text(option.name),
                                  subtitle: Text(option.email),
                                )
                              : Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8),
                                  child: ListTile(
                                    leading: getEmailAvatar(option.name),
                                    title: Text(option.name),
                                  ),
                                ),
                        ]),
                      );
                    }).toList(),
                  ),
                ),
              );
            },
            fieldViewBuilder: (BuildContext context,
                TextEditingController textEditingController,
                FocusNode focusNode,
                VoidCallback onFieldSubmitted) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 4,
                ),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: const BorderRadius.all(Radius.circular(18.0)),
                  border: showBorder!
                      ? Border.all(
                          width: 1.6,
                          color: focusNode.hasFocus
                              ? ProtonColors.protonBlue
                              : ProtonColors.interActionWeak,
                        )
                      : null,
                ),
                child: TextFormField(
                  focusNode: focusNode,
                  controller: textEditingController,
                  style: ProtonStyles.body1Medium(color: ProtonColors.textNorm),
                  keyboardType: keyboardType,
                  autocorrect: false,
                  // turn off for email input
                  onFieldSubmitted: (value) {
                    if (callback != null) {
                      callback!();
                    }
                  },
                  decoration: InputDecoration(
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    suffixIcon: showQRcodeScanner
                        ? IconButton(
                            onPressed: () {
                              if (defaultTargetPlatform ==
                                      TargetPlatform.android ||
                                  defaultTargetPlatform == TargetPlatform.iOS) {
                                focusNode.unfocus();
                                showQRScanBottomSheet(
                                    context, textEditingController, callback);
                              }
                            },
                            icon: Icon(Icons.qr_code_rounded,
                                size: 26, color: ProtonColors.textWeak),
                          )
                        : null,
                    labelText: labelText,
                    labelStyle: ProtonStyles.body2Regular(
                        color: ProtonColors.textWeak, fontSize: 15.0),
                    hintText: hintText,
                    hintStyle:
                        ProtonStyles.body2Regular(color: ProtonColors.textHint),
                    contentPadding: const EdgeInsets.only(
                        left: 10, right: 10, top: 4, bottom: 16),
                    enabledBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    border: InputBorder.none,
                    errorStyle: const TextStyle(height: 0),
                    focusedErrorBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                  ),
                ),
              );
            }));
  }
}

Widget getEmailAvatar(String name) {
  return Container(
      margin: const EdgeInsets.only(top: 8),
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: AvatarColorHelper.getAvatarBackgroundColor(
            AvatarColorHelper.getIndexFromString(name)),
        borderRadius: BorderRadius.circular(21),
      ),
      child: Center(
        child: Text(
          CommonHelper.getFirstNChar(name, 1).toUpperCase(),
          style: ProtonStyles.body2Medium(
            color: AvatarColorHelper.getAvatarTextColor(
                AvatarColorHelper.getIndexFromString(name)),
          ),
        ),
      ));
}
