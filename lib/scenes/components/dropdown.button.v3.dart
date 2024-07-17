import 'package:flutter/material.dart';
import 'package:wallet/constants/assets.gen.dart';
import 'package:wallet/constants/constants.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/helper/logger.dart';
import 'package:wallet/l10n/generated/locale.dart';
import 'package:wallet/scenes/components/close.button.v1.dart';
import 'package:wallet/scenes/components/custom.tooltip.dart';
import 'package:wallet/theme/theme.font.dart';

class DropdownButtonV3<T> extends StatelessWidget {
  final double width;
  final List<T> items;
  final List<String> itemsText;
  final List? itemsLeadingIcons;
  final List? itemsTextForDisplay;
  final List? itemsMoreDetail;
  final String? defaultOption;
  final String? labelText;
  final double? maxSuffixIconWidth;
  final Color? backgroundColor;
  final EdgeInsetsGeometry? padding;
  final TextStyle? textStyle;
  final T selected;
  final void Function(T) onChanged;

  DropdownButtonV3({
    required this.width,
    required this.items,
    required this.itemsText,
    required this.selected,
    required this.onChanged,
    super.key,
    this.itemsTextForDisplay,
    this.itemsMoreDetail,
    this.labelText,
    this.backgroundColor,
    this.defaultOption,
    this.padding,
    this.textStyle,
    this.maxSuffixIconWidth = 24,
    this.itemsLeadingIcons,
  });

  @override
  Widget build(BuildContext context) {
    _textEditingController.text = getDisplayText(items.indexOf(selected));
    return items.isNotEmpty
        ? buildWithList(context)
        : Text(S.of(context).no_data);
  }

  final TextEditingController _textEditingController = TextEditingController();

  String getDisplayText(int index) {
    try {
      if (itemsTextForDisplay != null) {
        return itemsTextForDisplay![index];
      }
    } catch (e) {
      logger.e(e.toString());
    }
    return itemsText[index];
  }

  Widget buildWithList(BuildContext context) {
    return Container(
        width: width,
        padding: padding ??
            const EdgeInsets.only(
              left: defaultPadding,
              right: defaultPadding,
              top: 4,
              bottom: 4,
            ),
        decoration: BoxDecoration(
          color: backgroundColor ?? ProtonColors.white,
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: TextField(
          controller: _textEditingController,
          readOnly: true,
          onTap: () {
            showOptionsInBottomSheet(context);
          },
          style: textStyle ?? FontManager.body1Median(ProtonColors.textNorm),
          decoration: InputDecoration(
            enabledBorder: InputBorder.none,
            border: InputBorder.none,
            labelText: labelText,
            labelStyle: FontManager.textFieldLabelStyle(ProtonColors.textWeak),
            suffixIconConstraints: BoxConstraints(
              maxWidth: maxSuffixIconWidth ?? 24.0,
            ),
            contentPadding: EdgeInsets.only(
              top: 4,
              bottom: padding != null ? 2 : 16,
            ),
            suffixIcon: Icon(
              Icons.keyboard_arrow_down_rounded,
              color: ProtonColors.textWeak,
              size: 24,
            ),
          ),
        ));
  }

  void showOptionsInBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: ProtonColors.white,
      constraints: BoxConstraints(
        minWidth: MediaQuery.of(context).size.width,
        maxHeight: MediaQuery.of(context).size.height * 0.8,
      ),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
            child: Container(
          padding: const EdgeInsets.all(defaultPadding),
          child: IntrinsicHeight(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              /// Title and close
              Row(
                children: [
                  Expanded(child: Center(child: Text(labelText ?? ""))),
                  CloseButtonV1(
                    backgroundColor: ProtonColors.backgroundProton,
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),

              ///
              const SizedBox(height: 6),

              /// List of items
              Expanded(
                child: SingleChildScrollView(
                    child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 5),
                    ...List.generate(items.length, (index) {
                      return Column(children: [
                        ListTile(
                          trailing: selected == items[index]
                              ? Assets.images.icon.icCheckmark
                                  .svg(fit: BoxFit.fill, width: 20, height: 20)
                              : null,
                          leading: itemsMoreDetail != null
                              ? CustomTooltip(
                                  message: itemsMoreDetail![index],
                                  child: Assets.images.icon.icInfoCircle.svg(
                                    fit: BoxFit.fill,
                                    width: 20,
                                    height: 20,
                                  ))
                              : null,
                          title: itemsLeadingIcons != null
                              ? Row(
                                  children: [
                                    itemsLeadingIcons?[index],
                                    const SizedBox(
                                      width: 6,
                                    ),
                                    Expanded(
                                      child: Text(
                                        itemsText[index],
                                        style: FontManager.body2Regular(
                                            ProtonColors.textNorm),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                )
                              : Text(
                                  itemsText[index],
                                  style: FontManager.body2Regular(
                                    ProtonColors.textNorm,
                                  ),
                                ),
                          onTap: () {
                            onChanged(items[index]);
                            Navigator.of(context).pop();
                          },
                        ),
                        const Divider(thickness: 0.2, height: 1)
                      ]);
                    })
                  ],
                )),
              ),
            ]),
          ),
        ));
      },
    );
  }
}
