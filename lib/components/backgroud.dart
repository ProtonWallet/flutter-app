import 'package:flutter/material.dart';

class Background extends StatelessWidget {
  final Widget child;
  const Background({
    Key? key,
    required this.child,
    // this.topImage = "assets/images/wallet.png",
    // this.bottomImage = "assets/images/wallet.png",
  }) : super(key: key);

  // final String topImage, bottomImage;

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
              child: Text("test"),
            ),
            SafeArea(child: child),
          ],
        ),
      ),
    );
  }
}
