import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:wallet/constants/constants.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/helper/logger.dart';
import 'package:wallet/l10n/generated/locale.dart';
import 'package:wallet/scenes/components/close.button.v1.dart';
import 'package:wallet/scenes/components/custom.header.dart';
import 'package:wallet/scenes/components/custom.tooltip.dart';
import 'package:wallet/scenes/components/textfield.text.v2.dart';
import 'package:wallet/theme/theme.font.dart';

class DropdownButtonV2 extends StatefulWidget {
  final double width;
  final List items;
  final List itemsText;
  final List? itemsLeadingIcons;
  final List? itemsTextForDisplay;
  final List? itemsMoreDetail;
  final ValueNotifier? valueNotifier;
  final String? defaultOption;
  final String? labelText;
  final double? maxSuffixIconWidth;
  final Color? backgroundColor;
  final EdgeInsetsGeometry? padding;
  final TextStyle? textStyle;
  final bool canSearch;
  final Border? border;
  final String? title;

  const DropdownButtonV2({
    required this.width,
    required this.items,
    required this.itemsText,
    super.key,
    this.itemsTextForDisplay,
    this.itemsMoreDetail,
    this.labelText,
    this.backgroundColor,
    this.defaultOption,
    this.padding,
    this.textStyle,
    this.maxSuffixIconWidth = 24,
    this.valueNotifier,
    this.canSearch = false,
    this.itemsLeadingIcons,
    this.border,
    this.title,
  });

  @override
  DropdownButtonV2State createState() => DropdownButtonV2State();
}

class DropdownButtonV2State extends State<DropdownButtonV2> {
  dynamic selected;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _textEditingController = TextEditingController();

  String getDisplayText(int index) {
    try {
      if (widget.itemsTextForDisplay != null) {
        return widget.itemsTextForDisplay![index];
      }
    } catch (e) {
      logger.e(e.toString());
    }
    return widget.itemsText[index];
  }

  @override
  void initState() {
    selected = widget.valueNotifier?.value;
    final int selectedIndex = max(widget.items.indexOf(selected), 0);
    _textEditingController.text = getDisplayText(selectedIndex);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return widget.items.isNotEmpty
        ? buildWithList(context)
        : Text(S.of(context).no_data);
  }

  Widget buildWithList(BuildContext buildContext) {
    return Container(
        padding: const EdgeInsets.symmetric(
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: ProtonColors.white,
          borderRadius: BorderRadius.circular(18.0),
        ),
        child: Container(
            width: widget.width,
            padding: widget.padding ??
                const EdgeInsets.only(
                    left: defaultPadding, right: 8, top: 4, bottom: 4),
            decoration: BoxDecoration(
              color: widget.backgroundColor ?? ProtonColors.white,
              border: widget.border,
              borderRadius: BorderRadius.circular(18.0),
            ),
            child: TextField(
              controller: _textEditingController,
              readOnly: true,
              onTap: () {
                showOptionsInBottomSheet(context);
                Future.delayed(const Duration(milliseconds: 100), () {
                  _scrollTo(widget.items.indexOf(selected) * 60 -
                      MediaQuery.of(context).size.height / 6 +
                      60);
                });
              },
              style: widget.textStyle ??
                  FontManager.body1Median(ProtonColors.textNorm),
              decoration: InputDecoration(
                floatingLabelBehavior: FloatingLabelBehavior.always,
                enabledBorder: InputBorder.none,
                border: InputBorder.none,
                labelText: widget.labelText,
                hintStyle: FontManager.textFieldLabelStyle(ProtonColors.textHint),
                labelStyle:
                    FontManager.textFieldLabelStyle(ProtonColors.textWeak).copyWith(fontSize: 15),
                suffixIconConstraints:
                    BoxConstraints(maxWidth: widget.maxSuffixIconWidth ?? 24.0),
                contentPadding: EdgeInsets.only(
                    top: 4, bottom: widget.padding != null ? 2 : 16),
                suffixIcon: Icon(Icons.keyboard_arrow_down_rounded,
                    color: ProtonColors.textWeak, size: 24),
              ),
            )));
  }

  void _scrollTo(double offset) {
    if (offset > 0) {
      try {
        _scrollController.animateTo(
          offset,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
        );
      } catch (e) {
        e.toString();
      }
    }
  }

  void showOptionsInBottomSheet(BuildContext context) {
    final TextEditingController searchBoxController = TextEditingController();
    final FocusNode searchBoxFocusNode = FocusNode();
    String keyWord = "";
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
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
          if (widget.canSearch) {
            searchBoxController.addListener(() {
              setState(() {
                keyWord = searchBoxController.text;
              });
            });
          }
          return SafeArea(
            child: Container(
              padding: EdgeInsets.only(
                left: defaultPadding,
                right: defaultPadding,
                top: defaultPadding,
                bottom:
                    defaultPadding + MediaQuery.of(context).viewInsets.bottom,
              ),
              child: IntrinsicHeight(
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                CustomHeader(
                  buttonDirection: AxisDirection.right,
                  button: CloseButtonV1(
                      backgroundColor: ProtonColors.backgroundProton,
                      onPressed: () {
                        Navigator.of(context).pop();
                      }),
                  title: widget.title ?? widget.labelText,
                  padding: const EdgeInsets.symmetric(
                    vertical: 6,
                  ),
                ),
                const SizedBox(
                  height: 6,
                ),
                if (widget.canSearch)
                  TextFieldTextV2(
                    borderColor: ProtonColors.textWeak,
                    textController: searchBoxController,
                    myFocusNode: searchBoxFocusNode,
                    validation: (value) {
                      return "";
                    },
                    prefixIcon: Icon(Icons.search_rounded,
                        size: 20, color: ProtonColors.textWeak),
                    paddingSize: 2,
                    labelText: S.of(context).search,
                  ),
                Expanded(
                    child: SingleChildScrollView(
                  controller: _scrollController,
                  child: Column(
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
                          for (int index = 0;
                              index < widget.items.length;
                              index++)
                            if (widget.itemsText[index]
                                .toString()
                                .toLowerCase()
                                .contains(keyWord.toLowerCase()))
                              Container(
                                  height: 60,
                                  alignment: Alignment.center,
                                  child: Column(children: [
                                    ListTile(
                                      trailing: selected == widget.items[index]
                                          ? SvgPicture.asset(
                                              "assets/images/icon/ic-checkmark.svg",
                                              fit: BoxFit.fill,
                                              width: 20,
                                              height: 20)
                                          : null,
                                      leading: widget.itemsMoreDetail != null
                                          ? CustomTooltip(
                                              message: widget
                                                  .itemsMoreDetail![index],
                                              child: SvgPicture.asset(
                                                "assets/images/icon/ic-info-circle.svg",
                                                fit: BoxFit.fill,
                                                width: 20,
                                                height: 20,
                                              ),
                                            )
                                          : null,
                                      title: widget.itemsLeadingIcons != null
                                          ? Row(
                                              children: [
                                                widget
                                                    .itemsLeadingIcons?[index],
                                                const SizedBox(
                                                  width: 6,
                                                ),
                                                Expanded(
                                                  child: Text(
                                                    widget.itemsText[index],
                                                    style: FontManager
                                                        .body2Regular(
                                                            ProtonColors
                                                                .textNorm),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            )
                                          : Text(widget.itemsText[index],
                                              style: FontManager.body2Regular(
                                                  ProtonColors.textNorm)),
                                      onTap: () {
                                        setState(() {
                                          selected = widget.items[index];
                                          final int selectedIndex = max(
                                              widget.items.indexOf(selected),
                                              0);
                                          _textEditingController.text =
                                              getDisplayText(selectedIndex);
                                          widget.valueNotifier?.value =
                                              selected;
                                          Navigator.of(context).pop();
                                        });
                                      },
                                    ),
                                    const Divider(
                                      thickness: 0.2,
                                      height: 1,
                                    )
                                  ])),
                        ],
                      )
                    ],
                  ),
                )),
              ])),
            ),
          );
        });
      },
    );
  }
}
