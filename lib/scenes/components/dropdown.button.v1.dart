import 'package:flutter/material.dart';
import 'package:wallet/constants/constants.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/l10n/generated/locale.dart';
import 'package:wallet/theme/theme.font.dart';

class DropdownButtonV1 extends StatefulWidget {
  final double width;
  final List items;
  final List itemsText;
  final ValueNotifier? valueNotifier;
  final String? defaultOption;
  final String? labelText;
  final double? paddingSize;
  final Color? backgroundColor;

  const DropdownButtonV1(
      {required this.width,
      required this.items,
      required this.itemsText,
      super.key,
      this.labelText,
      this.paddingSize,
      this.backgroundColor,
      this.defaultOption,
      this.valueNotifier});

  @override
  DropdownButtonV1State createState() => DropdownButtonV1State();
}

class DropdownButtonV1State extends State<DropdownButtonV1> {
  @override
  void initState() {
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
        child: DropdownButtonFormField(
          decoration: InputDecoration(
            enabledBorder: InputBorder.none,
            border: InputBorder.none,
            labelText: widget.labelText,
            labelStyle: FontManager.textFieldLabelStyle(ProtonColors.textWeak),
            contentPadding:
                EdgeInsets.only(top: 4, bottom: widget.paddingSize ?? 16),
          ),
          isExpanded: true,
          dropdownColor: ProtonColors.white,
          value: widget.valueNotifier?.value,
          onChanged: (item) {
            setState(() {
              widget.valueNotifier?.value = item;
            });
          },
          items: getDropdownMenuItems(),
        ));
  }

  List<DropdownMenuItem> getDropdownMenuItems() {
    final List<DropdownMenuItem> dropdownMenuItems = [];
    if (widget.defaultOption != null) {
      dropdownMenuItems.add(DropdownMenuItem<String>(
          value: widget.defaultOption,
          child: Text(
            "${widget.defaultOption}",
            style: FontManager.body1Median(ProtonColors.textNorm),
          )));
    }
    for (int i = 0; i < widget.items.length; i++) {
      dropdownMenuItems.add(DropdownMenuItem<dynamic>(
          value: widget.items[i],
          child: Text(
            "${widget.itemsText[i]}",
            style: FontManager.body1Median(ProtonColors.textNorm),
          )));
    }
    return dropdownMenuItems;
  }
}
