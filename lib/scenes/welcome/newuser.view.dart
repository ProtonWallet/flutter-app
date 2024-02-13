import 'dart:math';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:flutter_gen/gen_l10n/locale.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/scenes/core/view.navigatior.identifiers.dart';
import 'newuser.viewmodel.dart';

class NewUserView extends ViewBase<NewUserViewModel> {
  NewUserView(NewUserViewModel viewModel)
      : super(viewModel, const Key("NewUserView"));

  final _introKey = GlobalKey<IntroductionScreenState>();
  final ConfettiController _confettiController =
      ConfettiController(duration: const Duration(seconds: 3));

  @override
  Widget buildWithViewModel(
      BuildContext context, NewUserViewModel viewModel, ViewSize viewSize) {
    // TODO: implement buildWithViewModel
    switch (viewSize) {
      case ViewSize.mobile:
        return build(context);
      default:
        return build(context);
    }
  }

  Widget build(BuildContext context) {
    _confettiController.play();
    return Scaffold(
      appBar: AppBar(),
      body: IntroductionScreen(
        key: _introKey,
        pages: [
          PageViewModel(
            title: 'Financial freedom with rock-solid security and privacy',
            bodyWidget: ConfettiWidget(
                gravity: 0.1,
                minBlastForce: 1,
                maxBlastForce: 2,
                confettiController: _confettiController,
                blastDirectionality: BlastDirectionality.explosive,
                // don't specify a direction, blast randomly
                shouldLoop: false,
                // start again as soon as the animation is finished
                colors: const [
                  Colors.green,
                  Colors.blue,
                  Colors.pink,
                  Colors.orange,
                  Colors.purple
                ],
                // manually specify the colors to be used
                createParticlePath: drawStar),
            image: buildSvgImage("assets/images/frame_9444342.svg"),
            //getPageDecoration, a method to customise the page style
            decoration: getPageDecoration(),
          ),
          PageViewModel(
            title:
                'Get started and create a brand new wallet or import an existing one',
            body: '',
            image: buildSvgImage("assets/images/frame_9444342.svg"),
            //getPageDecoration, a method to customise the page style
            decoration: getPageDecoration(),
          ),
          PageViewModel(
            title: 'Create your own digital wallet!',
            body: '',
            image: buildSvgImage("assets/images/frame_create.svg"),
            //getPageDecoration, a method to customise the page style
            decoration: getPageDecoration(),
          ),
        ],
        //ClampingScrollPhysics prevent the scroll offset from exceeding the bounds of the content.
        scrollPhysics: const ClampingScrollPhysics(),
        showDoneButton: false,
        showNextButton: false,
        showSkipButton: false,
        globalFooter: Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: () {
                if (_introKey.currentState!.getCurrentPage() ==
                    _introKey.currentState!.getPagesLength() - 1) {
                  viewModel.done();
                  viewModel.coordinator.move(ViewIdentifiers.welcome, context);
                } else {
                  _introKey.currentState?.next();
                }
              },
              child: viewModel.isLastPage
                  ? Text(S.of(context).done)
                  : Text(S.of(context).next),
            ),
          ),
        ),
        dotsDecorator: getDotsDecorator(),
        onChange: (int page) {
          onPageChange(page);
        },
      ),
    );
  }

  //widget to add the image on screen
  Widget buildImage(String imagePath) {
    return Center(
        child: Image.asset(
      imagePath,
      width: 450,
      height: 200,
    ));
  }

  //widget to add the image on screen
  Widget buildSvgImage(String imagePath) {
    return Center(
        child: SvgPicture.asset(
      imagePath,
      width: 450,
      height: 200,
    ));
  }

  //method to customise the page style
  PageDecoration getPageDecoration() {
    return PageDecoration(
      imagePadding: const EdgeInsets.only(top: 120),
      pageColor: Theme.of(context).colorScheme.background,
      bodyPadding: const EdgeInsets.only(top: 8, left: 20, right: 20),
      titlePadding: const EdgeInsets.only(top: 50),
      bodyTextStyle: const TextStyle(color: Colors.black54, fontSize: 15),
    );
  }

  //method to customize the dots style
  DotsDecorator getDotsDecorator() {
    return const DotsDecorator(
      spacing: EdgeInsets.symmetric(horizontal: 2),
      activeColor: Colors.indigo,
      color: Colors.grey,
      activeSize: Size(12, 5),
      activeShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(25.0)),
      ),
    );
  }

  /// A custom Path to paint stars.
  Path drawStar(Size size) {
    // Method to convert degree to radians
    double degToRad(double deg) => deg * (pi / 180.0);

    const numberOfPoints = 2;
    final halfWidth = size.width / 2;
    final externalRadius = halfWidth;
    final internalRadius = halfWidth / 2.5;
    final degreesPerStep = degToRad(360 / numberOfPoints);
    final halfDegreesPerStep = degreesPerStep / 2;
    final path = Path();
    final fullAngle = degToRad(360);
    path.moveTo(size.width, halfWidth);

    for (double step = 0; step < fullAngle; step += degreesPerStep) {
      path.lineTo(halfWidth + externalRadius * cos(step),
          halfWidth + externalRadius * sin(step));
      path.lineTo(halfWidth + internalRadius * cos(step + halfDegreesPerStep),
          halfWidth + internalRadius * sin(step + halfDegreesPerStep));
    }
    path.close();
    return path;
  }

  void onPageChange(int page) {
    int totalPage = _introKey.currentState!.getPagesLength();
    bool isLastPage = (page == totalPage - 1);
    viewModel.updateLastPageStatus(isLastPage);
  }
}
