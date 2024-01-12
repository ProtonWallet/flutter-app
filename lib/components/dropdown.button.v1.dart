import 'package:flutter/material.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/theme/theme.font.dart';

class DropdownButtonV1 extends StatefulWidget {
  final double width;
  final List items;
  final List itemsText;
  final ValueNotifier valueNotifier;

  const DropdownButtonV1(
      {super.key,
      required this.width,
      required this.items,
      required this.itemsText,
      required this.valueNotifier});

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
        : const Text("No data");
  }

  Widget buildWithList(BuildContext buildContext) {
    return Container(
        width: widget.width,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: ProtonColors.backgroundSecondary,
          // border: Border.all(color: Colors.black, width: 1.0),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: DropdownButton(
          isExpanded: true,
          dropdownColor: ProtonColors.backgroundSecondary,
          value: widget.valueNotifier.value,
          onChanged: (item) {
            setState(() {
              widget.valueNotifier.value = item;
            });
          },
          items: [
            for (int i = 0; i < widget.items.length; i++)
              DropdownMenuItem<dynamic>(
                  value: widget.items[i],
                  child: Text(
                    "${widget.itemsText[i]}",
                    style: FontManager.body2Median(
                        Theme.of(context).colorScheme.primary),
                  ))
          ],
          underline: Container(),
        ));
  }
}