import 'package:flutter/material.dart';
import 'package:wallet/constants/constants.dart';
import 'package:wallet/constants/proton.color.dart';

class HomeModalBottomSheet {
  static void show(BuildContext context,
      {Widget? child, ScrollController? scrollController}) {
    showModalBottomSheet(
        context: context,
        backgroundColor: ProtonColors.backgroundProton,
        isScrollControlled: true,
        constraints: BoxConstraints(
          minWidth: MediaQuery.of(context).size.width,
          maxHeight: MediaQuery.of(context).size.height - 60,
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
        ),
        builder: (BuildContext context) {
          return SingleChildScrollView(
              controller: scrollController,
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom),
              child: Container(
                  padding: const EdgeInsets.symmetric(
                      vertical: defaultPadding, horizontal: defaultPadding),
                  child: child));
        });
  }
}
