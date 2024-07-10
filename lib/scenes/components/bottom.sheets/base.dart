import 'package:flutter/material.dart';
import 'package:wallet/constants/constants.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/scenes/core/responsive.dart';

class HomeModalBottomSheet {
  static void show(BuildContext context,
      {Widget? child, ScrollController? scrollController}) {
    if (Responsive.isMobile(context)) {
      _showMobile(context, child: child, scrollController: scrollController);
    } else {
      // desktop and tablet
      _showDesktop(context, child: child, scrollController: scrollController);
    }
  }

  static void _showDesktop(BuildContext context,
      {Widget? child, ScrollController? scrollController}) {
    showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        constraints: BoxConstraints(
          maxWidth: 400,
          maxHeight: MediaQuery.of(context).size.height,
          minHeight: MediaQuery.of(context).size.height,
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
        ),
        builder: (BuildContext context) {
          return Align(
              alignment: Alignment.center,
              child: Container(
                  decoration: BoxDecoration(
                    color: ProtonColors.backgroundProton,
                    borderRadius: const BorderRadius.all(Radius.circular(24.0)),
                  ),
                  margin: const EdgeInsets.symmetric(vertical: 30),
                  padding: const EdgeInsets.all(4),
                  child: GestureDetector(
                    onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
                    child: SafeArea(
                        child: SingleChildScrollView(
                            controller: scrollController,
                            padding: EdgeInsets.only(
                                bottom:
                                    MediaQuery.of(context).viewInsets.bottom),
                            child: Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: defaultPadding,
                                    horizontal: defaultPadding),
                                child: child))),
                  )));
        });
  }

  static void _showMobile(BuildContext context,
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
          return GestureDetector(
            onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
            child: SafeArea(
                child: SingleChildScrollView(
                    controller: scrollController,
                    padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).viewInsets.bottom),
                    child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: defaultPadding,
                            horizontal: defaultPadding),
                        child: child))),
          );
        });
  }
}