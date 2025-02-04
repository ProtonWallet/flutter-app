import 'package:flutter/material.dart';
import 'package:wallet/constants/constants.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/constants/text.style.dart';
import 'package:wallet/scenes/components/back.button.v1.dart';
import 'package:wallet/scenes/components/custom.loading.dart';

class PageLayoutV1 extends StatelessWidget {
  final Widget? child;
  final Widget? headerWidget;
  final Widget? bottomWidget;
  final String? title;
  final double? borderRadius;
  final Color? backgroundColor;
  final bool showHeader;
  final bool initialized;
  final ScrollController? scrollController;

  /// we will expanded the child to match parent height if set it to true
  final bool expanded;
  final double? height;

  const PageLayoutV1({
    super.key,
    this.child,
    this.headerWidget,
    this.bottomWidget,
    this.title,
    this.borderRadius,
    this.backgroundColor,
    this.scrollController,
    this.showHeader = true,
    @Deprecated('This parameter will be removed') this.expanded = true,
    this.initialized = true,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(borderRadius ?? 24.0),
        ),
        color: backgroundColor ?? ProtonColors.backgroundNorm,
      ),
      child: SafeArea(
        child: SizedBox(
          height: height,
          child: Padding(
            padding: const EdgeInsets.all(defaultPadding).copyWith(
              top: 30,
            ),
            child: ListView(
              shrinkWrap: true,
              controller: scrollController,
              children: [
                if (showHeader)
                  headerWidget ??
                      BackButtonV1(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                if (!initialized)
                  const Align(
                    child: SizedBox(
                      width: 30,
                      height: 30,
                      child: CustomLoading(size: 30),
                    ),
                  ),
                if (initialized) _buildMain(context),
                if (bottomWidget != null) bottomWidget!,
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMain(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const SizedBox(height: defaultPadding),
      if (title != null)
        Text(
          title!,
          style: ProtonStyles.headline(
            color: ProtonColors.textNorm,
            fontSize: 24.0,
          ),
        ),
      if (child != null) child!,
    ]);
  }
}
