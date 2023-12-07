import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class Background extends StatelessWidget {
  final Widget child;
  const Background({
    super.key,
    required this.child,
    this.topImage = "assets/images/frame_background.svg",
    // this.bottomImage = "assets/images/wallet.png",
  });

  final String topImage; //, bottomImage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SizedBox(
        width: double.infinity,
        height: MediaQuery.of(context).size.height,
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Positioned(
              top: 0,
              left: 0,
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                height: 350, //MediaQuery.of(context).size.height - 80,
                child: SvgPicture.asset(
                  topImage,
                  fit: BoxFit.fitWidth,
                ),
              ),
            ),
            SafeArea(child: child),
          ],
        ),
      ),
    );
  }
}
