import 'package:flutter/material.dart';
import 'package:wallet/constants/proton.color.dart';

class CustomExpansionTile extends StatefulWidget {
  final List<Widget> children;
  final ScrollController? scrollController;
  final Widget title;
  final bool? expanded;

  const CustomExpansionTile({
    required this.children,
    required this.title,
    this.scrollController,
    this.expanded = false,
    super.key,
  });

  @override
  CustomExpansionTileState createState() => CustomExpansionTileState();
}

class CustomExpansionTileState extends State<CustomExpansionTile> {
  bool isExpanded = false;

  @override
  void initState() {
    super.initState();
    isExpanded = widget.expanded ?? false;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      trailing: Transform.translate(
        offset: Offset(22, 0),
        child: Icon(
            isExpanded ? Icons.expand_less_rounded : Icons.expand_more_rounded),
      ),
      shape: const Border(),
      title: widget.title,
      initiallyExpanded: widget.expanded ?? false,
      iconColor: ProtonColors.textWeak,
      collapsedIconColor: ProtonColors.textWeak,
      onExpansionChanged: (isExpansionExpanded) {
        setState(() {
          isExpanded = isExpansionExpanded;
        });
        if (isExpansionExpanded) {
          Future.delayed(const Duration(milliseconds: 300), () {
            widget.scrollController?.animateTo(
              widget.scrollController?.position.maxScrollExtent ?? 0,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
            );
          });
        }
      },
      children: widget.children,
    );
  }
}
