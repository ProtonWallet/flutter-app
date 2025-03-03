import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:wallet/constants/constants.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/constants/sizedbox.dart';
import 'package:wallet/constants/text.style.dart';
import 'package:wallet/scenes/components/close.button.v1.dart';
import 'package:wallet/scenes/core/responsive.dart';

/// PageLayoutV2
///
/// This file defines a customizable page layout widget with a **blurred AppBar**,
/// a **scroll-sensitive divider**, and a structured body section. It is designed
/// to be **responsive** and supports **dynamic theming**.
///
/// ## Features:
/// - **Custom AppBar**:
///   - Blurred background with `BackdropFilter` (blurred by `sigmaX: 5`, `sigmaY: 5`).
///   - Supports a dynamic title and actions.
///   - Optional close button with customizable color (default: `ProtonColors.backgroundNorm`).
/// - **Scroll-Sensitive Divider**:
///   - The divider at the bottom of the AppBar **fades in when scrolling**.
///   - Divider visibility is controlled using `_dividerOpacity`, toggled at **`12.0` pixels offset**.
///   - Divider thickness is **`1.0`** (hardcoded).
/// - **Configurable Background**:
///   - Allows changing the background color of the layout.
///   - Default background color: `ProtonColors.backgroundSecondary`.
/// - **Auto-Hides Keyboard on Tap**:
///   - Uses `GestureDetector` to dismiss the keyboard when tapping outside input fields.
/// - **Adaptive Padding**:
///   - **Default padding** is `16.0` pixels.
///   - On **desktop**, horizontal padding is reduced by **`10.0` pixels**.
/// - **Preferred Height for AppBar**:
///   - Default height is **`72.0` pixels**.
///
/// ## Static / Hardcoded Values:
/// - **AppBar blur effect**: `sigmaX: 5`, `sigmaY: 5`
/// - **Divider fade-in offset**: `12.0` pixels
/// - **Divider thickness**: `1.0`
/// - **Default padding**: `16.0` pixels, reduced by `10.0` on desktop.
/// - **Default AppBar height**: `72.0` pixels
/// - **Default close button color**: `ProtonColors.backgroundNorm`
///
/// ## Usage Example:
/// ```dart
/// PageLayoutV2(
///   title: "Transaction Details",
///   child: Column(
///     children: [
///       Text("Your transaction details here"),
///     ],
///   ),
///   backgroundColor: ProtonColors.backgroundSecondary,
///   dividerOffset: 12.0,
/// )
/// ```
///
class PageLayoutV2 extends StatefulWidget {
  final String title;
  final TextStyle? titleStyle;
  // view background color
  final Color? backgroundColor;
  // close button background color
  final Color? cbtBgColor;
  final Widget child;
  final List<Widget>? actions;
  // Divider offset to show when scrolling
  final double dividerOffset;
  final Size preferredHeight;

  final ScrollController? scrollController;

  const PageLayoutV2({
    required this.child,
    this.title = "",
    this.titleStyle,
    this.dividerOffset = 12.0,
    this.preferredHeight = const Size.fromHeight(72.0),
    this.backgroundColor,
    this.cbtBgColor,
    this.actions,
    this.scrollController,
    super.key,
  });

  @override
  PageLayoutState createState() => PageLayoutState();
}

class PageLayoutState extends State<PageLayoutV2> {
  /// Initially divider opacity: hidden
  double _dividerOpacity = 0.0;

  /// Show only when scrolling
  void _onScroll(double offset) {
    setState(() {
      _dividerOpacity = offset > widget.dividerOffset ? 1.0 : 0.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: widget.preferredHeight,
        child: AppBar(
          toolbarHeight: widget.preferredHeight.height,
          surfaceTintColor: Colors.transparent,
          backgroundColor: Colors.transparent,
          // Remove shadow
          elevation: 0,
          centerTitle: true,
          automaticallyImplyLeading: false,
          title: Text(
            widget.title,
            style: widget.titleStyle ??
                ProtonStyles.body2Medium(
                  color: ProtonColors.textNorm,
                ),
          ),
          actions: widget.actions ??
              [
                Row(
                  children: [
                    CloseButtonV1(
                      backgroundColor:
                          widget.cbtBgColor ?? ProtonColors.backgroundNorm,
                      onPressed: () => Navigator.of(context).pop(true),
                    ),
                    SizedBoxes.box16,
                  ],
                )
              ],
          flexibleSpace: ClipRRect(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(24.0),
            ),
            child: BackdropFilter(
              // Apply blur effect
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Container(
                      // Background
                      color: (widget.backgroundColor ??
                              ProtonColors.backgroundSecondary)
                          .withOpacity(0.8),
                    ),
                  ),
                  Positioned(
                    bottom: 0, // Move Divider to bottom
                    left: 0,
                    right: 0,
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 300),
                      opacity: _dividerOpacity,
                      child: Divider(
                        height: 1,
                        thickness: 1,
                        color: ProtonColors.appBarDividerColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      backgroundColor: ProtonColors.clear,
      body: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Container(
          height: double.infinity,
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(24.0),
            ),
            color: widget.backgroundColor ?? ProtonColors.backgroundSecondary,
          ),
          child: NotificationListener<ScrollUpdateNotification>(
            onNotification: (notification) {
              _onScroll(notification.metrics.pixels);
              return false;
            },
            child: SingleChildScrollView(
              controller: widget.scrollController,
              child: SafeArea(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: defaultPadding -
                        (Responsive.isDesktop(context) ? 10 : 0),
                  ),
                  child: widget.child,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
