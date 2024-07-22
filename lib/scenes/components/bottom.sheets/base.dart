import 'package:flutter/material.dart';
import 'package:wallet/constants/constants.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/scenes/core/responsive.dart';

class HomeModalBottomSheet {
  static void show(
    BuildContext context, {
    Widget? child,
    Widget? header,
    ScrollController? scrollController,
    Color? backgroundColor,
    bool? useIntrinsicHeight,
    double? maxHeight,
    bool? isDismissible,
    bool? enableDrag,
  }) {
    if (Responsive.isMobile(context)) {
      _showMobile(
        context,
        child: child,
        header: header,
        scrollController: scrollController,
        backgroundColor: backgroundColor,
        useIntrinsicHeight: useIntrinsicHeight,
        maxHeight: maxHeight,
        isDismissible: isDismissible,
        enableDrag: enableDrag,
      );
    } else {
      // desktop and tablet
      _showDesktop(
        context,
        child: child,
        header: header,
        scrollController: scrollController,
        backgroundColor: backgroundColor,
        useIntrinsicHeight: useIntrinsicHeight,
        maxHeight: maxHeight,
        isDismissible: isDismissible,
        enableDrag: enableDrag,
      );
    }
  }

  static void _showDesktop(
    BuildContext context, {
    Widget? child,
    Widget? header,
    ScrollController? scrollController,
    Color? backgroundColor,
    bool? useIntrinsicHeight,
    double? maxHeight,
    bool? isDismissible,
    bool? enableDrag,
  }) {
    showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        isDismissible: isDismissible ?? true,
        enableDrag: enableDrag ?? true,
        constraints: BoxConstraints(
          maxWidth: maxDeskTopSheetWidth,
          maxHeight: maxHeight ?? MediaQuery.of(context).size.height,
          minHeight: maxHeight ?? MediaQuery.of(context).size.height,
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
        ),
        builder: (BuildContext context) {
          return PopScope(
              canPop: isDismissible ?? true,
              child: Align(
                child: Container(
                  decoration: BoxDecoration(
                    color: backgroundColor ?? ProtonColors.backgroundProton,
                    borderRadius: const BorderRadius.all(Radius.circular(24.0)),
                  ),
                  margin: const EdgeInsets.symmetric(vertical: 30),
                  padding: const EdgeInsets.all(4),
                  child: GestureDetector(
                    onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
                    child: SafeArea(
                      child: (useIntrinsicHeight ?? true)
                          ? IntrinsicHeight(
                              child: _buildContent(
                                context,
                                child: child,
                                header: header,
                                scrollController: scrollController,
                              ),
                            )
                          : _buildContent(
                              context,
                              child: child,
                              header: header,
                              scrollController: scrollController,
                            ),
                    ),
                  ),
                ),
              ));
        });
  }

  static void _showMobile(
    BuildContext context, {
    Widget? child,
    Widget? header,
    ScrollController? scrollController,
    Color? backgroundColor,
    bool? useIntrinsicHeight,
    double? maxHeight,
    bool? isDismissible,
    bool? enableDrag,
  }) {
    showModalBottomSheet(
        context: context,
        backgroundColor: backgroundColor ?? ProtonColors.backgroundProton,
        isScrollControlled: true,
        isDismissible: isDismissible ?? true,
        enableDrag: enableDrag ?? true,
        constraints: BoxConstraints(
          minWidth: MediaQuery.of(context).size.width,
          maxHeight: maxHeight ?? MediaQuery.of(context).size.height - 60,
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
        ),
        builder: (BuildContext context) {
          return PopScope(
            canPop: isDismissible ?? true,
            child: GestureDetector(
              onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
              child: SafeArea(
                child: (useIntrinsicHeight ?? true)
                    ? IntrinsicHeight(
                        child: _buildContent(
                          context,
                          child: child,
                          header: header,
                          scrollController: scrollController,
                        ),
                      )
                    : _buildContent(
                        context,
                        child: child,
                        header: header,
                        scrollController: scrollController,
                      ),
              ),
            ),
          );
        });
  }

  static Widget _buildContent(
    BuildContext context, {
    Widget? child,
    Widget? header,
    ScrollController? scrollController,
  }) {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      if (header != null) header,
      Expanded(
        child: SingleChildScrollView(
          controller: scrollController,
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
              padding: const EdgeInsets.symmetric(
                  vertical: defaultPadding, horizontal: defaultPadding),
              child: child),
        ),
      ),
    ]);
  }
}
