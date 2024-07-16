import 'package:flutter/material.dart';
import 'package:wallet/constants/constants.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/scenes/components/back.button.v1.dart';
import 'package:wallet/theme/theme.font.dart';

class PageLayoutV1 extends StatelessWidget {
  final Widget? child;
  final Widget? bottomWidget;
  final String? title;

  const PageLayoutV1({super.key, this.child, this.bottomWidget, this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24.0)),
          color: ProtonColors.backgroundProton,
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(defaultPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BackButtonV1(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                Expanded(
                    child: SingleChildScrollView(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                      const SizedBox(height: defaultPadding),
                      if (title != null)
                        Text(title!,
                            style: FontManager.titleSubHero(
                                ProtonColors.textNorm)),
                      if (child != null) child!,
                    ]))),
                if (bottomWidget != null) bottomWidget!,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
