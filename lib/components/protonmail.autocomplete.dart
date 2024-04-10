import 'package:flutter/material.dart';
import 'package:wallet/constants/constants.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/helper/common_helper.dart';
import 'package:wallet/models/contacts.model.dart';
import 'package:wallet/theme/theme.font.dart';

class ProtonMailAutoComplete extends StatelessWidget {
  final List<ContactsModel> emails;
  final Color color;
  final TextEditingController textEditingController;
  final FocusNode focusNode;
  final VoidCallback? callback;

  const ProtonMailAutoComplete({
    super.key,
    required this.emails,
    required this.textEditingController,
    required this.focusNode,
    this.callback,
    this.color = Colors.transparent,
  });

  @override
  Widget build(BuildContext context) {
    return RawAutocomplete<ContactsModel>(
        textEditingController: textEditingController,
        focusNode: focusNode,
        optionsBuilder: (TextEditingValue textEditingValue) {
          if (textEditingValue.text == '') {
            return emails;
          }
          return emails.where((ContactsModel protonContactEmail) {
            return protonContactEmail.email
                .contains(textEditingValue.text.toLowerCase());
          });
        },
        onSelected: (ContactsModel selection) {
          textEditingController.text = selection.email;
          focusNode.unfocus();
        },
        optionsViewBuilder: (BuildContext context,
            AutocompleteOnSelected<ContactsModel> onSelected,
            Iterable<ContactsModel> options) {
          return Align(
            alignment: Alignment.topLeft,
            child: Material(
              elevation: 4.0,
              child: Container(
                width: MediaQuery.of(context).size.width - defaultPadding * 2,
                constraints: const BoxConstraints(maxHeight: 320),
                child: ListView(
                  shrinkWrap: true,
                  children: options.map((ContactsModel option) {
                    return GestureDetector(
                      onTap: () {
                        onSelected(option);
                      },
                      child: ListTile(
                        leading: getEmailAvatar(option.name),
                        title: Text(option.name),
                        subtitle: Text(option.email),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          );
        },
        fieldViewBuilder: (BuildContext context,
            TextEditingController textEditingController,
            FocusNode focusNode,
            VoidCallback onFieldSubmitted) {
          return Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: TextField(
                  controller: textEditingController,
                  focusNode: focusNode,
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide(color: color, width: 1),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide(
                          color: ProtonColors.interactionNorm, width: 2),
                    ),
                    suffixIcon: callback != null ? IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: callback,
                    ): const Icon(null)
                  )));
        });
  }
}

Widget getEmailAvatar(String name) {
  return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: Text(
          CommonHelper.getFirstNChar(name, 1),
          style: FontManager.body2Median(ProtonColors.white),
        ),
      ));
}
