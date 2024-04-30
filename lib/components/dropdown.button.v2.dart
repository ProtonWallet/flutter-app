import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:wallet/constants/constants.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/helper/logger.dart';
import 'package:wallet/theme/theme.font.dart';
import 'package:wallet/l10n/generated/locale.dart';

class DropdownButtonV2 extends StatefulWidget {
  final double width;
  final List items;
  final List itemsText;
  final ValueNotifier? valueNotifier;
  final String? defaultOption;
  final String? labelText;
  final double? paddingSize;
  final double? maxSuffixIconWidth;
  final Color? backgroundColor;

  const DropdownButtonV2(
      {super.key,
      required this.width,
      required this.items,
      required this.itemsText,
      this.labelText,
      this.paddingSize,
      this.backgroundColor,
      this.defaultOption,
      this.maxSuffixIconWidth = 24,
      this.valueNotifier});

  @override
  DropdownButtonV2State createState() => DropdownButtonV2State();
}

class DropdownButtonV2State extends State<DropdownButtonV2> {
  dynamic selected;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _textEditingController = TextEditingController();

  @override
  void initState() {
    selected = widget.valueNotifier?.value;
    int selectedIndex = max(widget.items.indexOf(selected), 0);
    _textEditingController.text = widget.itemsText[selectedIndex];
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
        width: widget.width,
        padding: EdgeInsets.only(
            left: defaultPadding,
            right: 8,
            top: widget.paddingSize ?? 12,
            bottom: widget.paddingSize ?? 12),
        decoration: BoxDecoration(
          color: widget.backgroundColor ?? ProtonColors.white,
          // border: Border.all(color: Colors.black, width: 1.0),
          borderRadius: BorderRadius.circular(18.0),
        ),
        child: TextField(
          controller: _textEditingController,
          readOnly: true,
          onTap: () {
            showOptionsInBottomSheet(context);
            Future.delayed(const Duration(milliseconds: 100), () {
              _scrollTo(max(widget.items.indexOf(selected), 0) * 48);
            });
          },
          decoration: InputDecoration(
            enabledBorder: InputBorder.none,
            border: InputBorder.none,
            labelText: widget.labelText,
            labelStyle: FontManager.textFieldLabelStyle(ProtonColors.textWeak),
            suffixIconConstraints:
                BoxConstraints(maxWidth: widget.maxSuffixIconWidth ?? 24.0),
            contentPadding:
                EdgeInsets.only(top: 4, bottom: widget.paddingSize ?? 16),
            suffixIcon: Icon(Icons.arrow_drop_down,
                color: ProtonColors.textNorm, size: 24),
          ),
        ));
  }

  void _scrollTo(double offset) {
    logger.i("Scroll to $offset");
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

  void showOptionsInBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: ProtonColors.white,
      constraints: BoxConstraints(
        minWidth: MediaQuery.of(context).size.width,
        maxHeight: MediaQuery.of(context).size.height / 3,
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
      ),
      builder: (BuildContext context) {
        return Container(
            padding: const EdgeInsets.only(
                bottom: defaultPadding,
                top: defaultPadding * 2,
                left: defaultPadding,
                right: defaultPadding),
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
                      for (int index = 0; index < widget.items.length; index++)
                        Column(children: [
                          ListTile(
                            trailing: selected == widget.items[index]
                                ? SvgPicture.asset(
                                    "assets/images/icon/ic-checkmark.svg",
                                    fit: BoxFit.fill,
                                    width: 20,
                                    height: 20)
                                : null,
                            title: Text(widget.itemsText[index],
                                style: FontManager.body2Regular(
                                    ProtonColors.textNorm)),
                            onTap: () {
                              setState(() {
                                selected = widget.items[index];
                                int selectedIndex =
                                    max(widget.items.indexOf(selected), 0);
                                _textEditingController.text =
                                    widget.itemsText[selectedIndex];
                                widget.valueNotifier?.value = selected;
                                Navigator.of(context).pop();
                              });
                            },
                          ),
                          const Divider(
                            thickness: 0.2,
                            height: 1,
                          )
                        ]),
                      // ListView.separated(
                      //     itemCount: widget.items.length,
                      //     separatorBuilder: (context, _) {
                      //       return const Divider(
                      //         thickness: 0.2,
                      //         height: 1,
                      //       );
                      //     },
                      //     itemBuilder: (context, index) {
                      //       return ListTile(
                      //         trailing: selected == widget.items[index]
                      //             ? SvgPicture.asset(
                      //                 "assets/images/icon/ic-checkmark.svg",
                      //                 fit: BoxFit.fill,
                      //                 width: 20,
                      //                 height: 20)
                      //             : null,
                      //         title: Text(
                      //             widget.itemsText[index],
                      //             style: FontManager.body2Regular(
                      //                 ProtonColors.textNorm)),
                      //         onTap: () {
                      //           setState(() {
                      //             selected = widget.items[index];
                      //           });
                      //         },
                      //       );
                      //     }),
                    ],
                  )
                ],
              ),
            ));
      },
    );
  }
}
