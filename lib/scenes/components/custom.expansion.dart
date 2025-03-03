import 'package:flutter/material.dart';
import 'package:wallet/constants/constants.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/constants/text.style.dart';
import 'package:wallet/l10n/generated/locale.dart';

class CustomExpansion extends StatefulWidget {
  final List<Widget> children;
  final int totalSteps;
  final int currentStep;

  const CustomExpansion(
      {required this.totalSteps,
      required this.currentStep,
      super.key,
      this.children = const []});

  @override
  CustomExpansionState createState() => CustomExpansionState();
}

class CustomExpansionState extends State<CustomExpansion>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        duration: const Duration(milliseconds: 300), vsync: this);
    _animation =
        CurvedAnimation(parent: _controller, curve: Curves.fastOutSlowIn);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
            onTap: toggleExpansion,
            child: Column(children: [
              Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: defaultPadding),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 20),
                  decoration: BoxDecoration(
                    color: ProtonColors.protonBlue,
                    borderRadius: BorderRadius.circular(24.0),
                  ),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(children: [
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              SizedBox(
                                width: 32,
                                height: 32,
                                child: CircularProgressIndicator(
                                  value: widget.currentStep / widget.totalSteps,
                                  color: ProtonColors.textInverted,
                                  backgroundColor: ProtonColors
                                      .circularProgressIndicatorBackGround,
                                ),
                              ),
                              Text(
                                '${widget.currentStep}/${widget.totalSteps}',
                                style: TextStyle(
                                    fontSize: 9,
                                    color: ProtonColors.textInverted),
                              ),
                            ],
                          ),
                          const SizedBox(
                            width: 20,
                          ),
                          Text(S.of(context).secure_your_wallet,
                              style: ProtonStyles.body2Regular(
                                  color: ProtonColors.textInverted)),
                        ]),
                        RotationTransition(
                            turns: _animation,
                            child: Icon(
                              Icons.expand_more_rounded,
                              color: ProtonColors.textInverted,
                            )),
                      ])),
              if (!_isExpanded)
                Container(
                    margin: const EdgeInsets.symmetric(horizontal: 36),
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: ProtonColors.expansionShadow,
                      borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(24),
                          bottomRight: Radius.circular(24)),
                    )),
              if (!_isExpanded)
                Container(
                    margin: const EdgeInsets.symmetric(horizontal: 56),
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: ProtonColors.interActionWeakDisable,
                      borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(24),
                          bottomRight: Radius.circular(24)),
                    )),
            ])),
        SizeTransition(
          sizeFactor: _animation,
          axisAlignment: -1,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
            child: Column(
              children: widget.children,
            ),
          ),
        ),
      ],
    );
  }

  void toggleExpansion() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
