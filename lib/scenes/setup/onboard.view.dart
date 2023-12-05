import 'package:flutter/material.dart';
import 'package:wallet/components/button.v5.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/constants/sizedbox.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/scenes/setup/onboard.viewmodel.dart';

class SetupOnboardView extends ViewBase<SetupOnboardViewModel> {
  SetupOnboardView(SetupOnboardViewModel viewModel)
      : super(viewModel, const Key("SetupOnboardView"));

  @override
  Widget buildWithViewModel(BuildContext context,
      SetupOnboardViewModel viewModel, ViewSize viewSize) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor:
            Colors.transparent, // Theme.of(context).colorScheme.inversePrimary,
        title: const Text(""),
      ),
      body: buildBackground2(context, viewModel, viewSize),
      // buildNoHistory(context, viewModel, viewSize),
    );
  }

  Widget buildNoHistory(BuildContext context, SetupOnboardViewModel viewModel,
      ViewSize viewSize) {
    return SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SizedBoxes.box41,
              const Text("Welcome to",
                  style: TextStyle(
                      fontSize: 20,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w600)),
              SizedBoxes.box18,
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Logo"),
                  SizedBox(width: 8),
                  Text("Proton Wallet",
                      style: TextStyle(
                          fontSize: 24,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.bold))
                ],
              ),
              SizedBoxes.box58,
              const Text(
                  "--------------------------------------------------------"),
              SizedBoxes.box24,
              const Text(
                  "Financial freedom with rock-solid security and privacy",
                  style: TextStyle(
                      fontSize: 14,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w600)),
              SizedBoxes.box8,
              const Text(
                "Get started and create a brand new wallet or import an existing one.",
                style: TextStyle(
                    fontSize: 14,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.normal),
                textAlign: TextAlign.center,
              ),
              SizedBoxes.box32,
              ButtonV5(
                  text: "Create a new wallet",
                  width: MediaQuery.of(context).size.width - 60,
                  height: 36),
              SizedBoxes.box12,
              ButtonV5(
                  text: "Import an existing wallet",
                  width: MediaQuery.of(context).size.width - 60,
                  backgroundColor: ProtonColors.white,
                  textStyle: const TextStyle(
                    color: ProtonColors.textNorm,
                    fontSize: 14,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                  ),
                  height: 36),
              SizedBoxes.box20,
            ]));
  }

  Widget buildBackground(BuildContext context, SetupOnboardViewModel viewModel,
      ViewSize viewSize) {
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
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6D4AFF), elevation: 0),
                child: Text(
                  "No history".toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),
            const SafeArea(
                child: Text(
                    "aaaaalkfjslkfjasjflksdfkjsklfskfjlksdjflksdjfklsjfklsjdl")),
          ],
        ),
      ),
    );
  }

  Widget buildBackground3(BuildContext context) {
    return Column(
      children: [
        Column(
          children: [
            Column(
              children: [
                Column(
                  children: [
                    Column(
                      children: [
                        const Stack(
                          children: [
                            SizedBox(
                              width: 89.36470031738281,
                              height: 22.870586395263672,
                            ),
                            Stack(
                              children: [
                                SizedBox(
                                  width: 11.200716018676758,
                                  height: 20.542312622070312,
                                ),
                                SizedBox(
                                  width: 15.281938552856445,
                                  height: 15.730466842651367,
                                ),
                                SizedBox(
                                  width: 4.036738395690918,
                                  height: 21.84964942932129,
                                ),
                                SizedBox(
                                  width: 4.036738395690918,
                                  height: 21.84964942932129,
                                ),
                                SizedBox(
                                  width: 15.92269515991211,
                                  height: 15.730466842651367,
                                ),
                                SizedBox(
                                  width: 31.204633712768555,
                                  height: 21.84964942932129,
                                )
                              ],
                            )
                          ],
                        ),
                        Column(
                          children: [
                            Column(
                              children: [
                                const Stack(
                                  children: [
                                    SizedBox(
                                      width: 28,
                                      height: 33.599998474121094,
                                    ),
                                    SizedBox(
                                      width: 23.33333396911621,
                                      height: 25.013378143310547,
                                    )
                                  ],
                                ),
                                Stack(
                                  children: [
                                    const Stack(
                                      children: [
                                        SizedBox(
                                          width: 28,
                                          height: 33.599998474121094,
                                        ),
                                        SizedBox(
                                          width: 23.33333396911621,
                                          height: 25.013378143310547,
                                        )
                                      ],
                                    ),
                                    Container(
                                        width: 28,
                                        height: 28,
                                        decoration: const BoxDecoration(
                                            gradient: LinearGradient(
                                          begin: Alignment.bottomLeft,
                                          end: Alignment.topRight,
                                          colors: [
                                            Color(0x87000000),
                                            Color(0x00676767),
                                            Color(0x00676767),
                                            Color(0x003e3e3e)
                                          ],
                                        )))
                                  ],
                                ),
                                const SizedBox(
                                  width: 35.68627166748047,
                                  height: 37.33333206176758,
                                ),
                                const SizedBox(
                                  width: 26.7166748046875,
                                  height: 28.672330856323242,
                                )
                              ],
                            )
                          ],
                        )
                      ],
                    ),
                    const Text("Welcome to",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ))
                  ],
                ),
                const Column(
                  children: [
                    Text(
                        "Financial freedom with rock-solid security and privacy",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        )),
                    Text(
                        "Get started and create a brand new wallet                  or import an existing one.",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ))
                  ],
                )
              ],
            )
          ],
        ),
        const Row(
          children: [],
        ),
        const Column(
          children: [
            Row(
              children: [
                Row(
                  children: [],
                ),
                Row(
                  children: [
                    Row(
                      children: [
                        Text("Create a new wallet",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ))
                      ],
                    )
                  ],
                )
              ],
            ),
            Row(
              children: [
                Row(
                  children: [],
                ),
                Row(
                  children: [
                    Row(
                      children: [
                        Text("Import an existing wallet",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ))
                      ],
                    )
                  ],
                )
              ],
            ),
            Column(
              children: [
                Row(
                  children: [
                    SizedBox(
                      width: 8,
                      height: 8,
                      child: Text("1238719823789127"),
                    ),
                    SizedBox(
                      width: 8,
                      height: 8,
                    ),
                    SizedBox(
                      width: 8,
                      height: 8,
                    ),
                    SizedBox(
                      width: 8,
                      height: 8,
                    ),
                    SizedBox(
                      width: 8,
                      height: 8,
                    ),
                    SizedBox(
                      width: 8,
                      height: 8,
                    ),
                    SizedBox(
                      width: 8,
                      height: 8,
                    ),
                    SizedBox(
                      width: 8,
                      height: 8,
                    ),
                    SizedBox(
                      width: 8,
                      height: 8,
                    ),
                    SizedBox(
                      width: 8,
                      height: 8,
                    )
                  ],
                )
              ],
            )
          ],
        )
      ],
    );
  }

  Widget buildBackground2(BuildContext context, SetupOnboardViewModel viewModel,
      ViewSize viewSize) {
    return Container(
      width: 500,
      height: 392,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5.0),
          border: Border.all(color: Colors.black),
          gradient: const RadialGradient(
              colors: [Colors.transparent, Colors.blue],
              focal: Alignment.center,
              radius: 2.0)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 252,
            clipBehavior: Clip.antiAlias,
            decoration: const BoxDecoration(color: Colors.white),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 252,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 500,
                        height: 160,
                        decoration: const ShapeDecoration(
                          gradient: RadialGradient(
                            center: Alignment(0.60, 0.35), // Adjusted from CSS
                            radius:
                                0.30, // This needs adjustment, CSS uses different system
                            colors: [
                              Color(0xFF6D4AFF), // Color at 0%
                              Color(0xFF100635), // Color at 37.43%
                              Color(0xFFD45A25), // Color at 100%
                            ],
                            stops: [0.0, 0.3743, 1.0],
                          ),
                          // RadialGradient(
                          //   center: Alignment(0.0, 0.0),
                          //   colors: [
                          //     Color(0xFF6D4AFF),
                          //     Color(0xFF0F0534),
                          //     Color(0xFFD45925)
                          //   ],
                          //   radius: 0.30,
                          // ),
                          shape: RoundedRectangleBorder(
                            side:
                                BorderSide(width: 1, color: Color(0xFFF5F5F4)),
                          ),
                        ),
                        child: Stack(
                          children: [
                            Positioned(
                              left: 111,
                              top: 63,
                              child: SizedBox(
                                width: 248,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: 56,
                                      height: 56,
                                      padding: const EdgeInsets.only(
                                        top: 3.73,
                                        left: 9.33,
                                        right: 10.96,
                                        bottom: 5.60,
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          SizedBox(
                                            width: 35.71,
                                            height: 46.67,
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                const SizedBox(
                                                  width: 28,
                                                  height: 33.60,
                                                  child: Stack(children: []),
                                                ),
                                                SizedBox(
                                                  width: 28,
                                                  height: 33.60,
                                                  child: Stack(
                                                    children: [
                                                      const Positioned(
                                                        left: 0,
                                                        top: 0,
                                                        child: SizedBox(
                                                          width: 28,
                                                          height: 33.60,
                                                          child: Stack(
                                                              children: []),
                                                        ),
                                                      ),
                                                      Positioned(
                                                        left: -0,
                                                        top: -0.75,
                                                        child: Container(
                                                          width: 28,
                                                          height: 28,
                                                          decoration:
                                                              BoxDecoration(
                                                            gradient:
                                                                LinearGradient(
                                                              begin: const Alignment(
                                                                  0.49, 0.87),
                                                              end: const Alignment(
                                                                  -0.49, -0.87),
                                                              colors: [
                                                                Colors.black
                                                                    .withOpacity(
                                                                        0.5299999713897705),
                                                                const Color(
                                                                    0x00676767),
                                                                const Color(
                                                                    0x00676767),
                                                                const Color(
                                                                    0x003E3E3E)
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const SizedBox(
                                      width: 184,
                                      height: 22.87,
                                      child: Stack(
                                        children: [
                                          Positioned(
                                            left: 94.40,
                                            top: 0.57,
                                            child: SizedBox(
                                              width: 89.60,
                                              height: 22.20,
                                              child: Stack(children: []),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const Positioned(
                              left: 23,
                              top: 41,
                              child: SizedBox(
                                width: 452,
                                child: Text(
                                  'Welcome to',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Color(0xFFFEFCFC),
                                    fontSize: 14,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w600,
                                    height: 0.10,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      const SizedBox(
                        height: 68,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: double.infinity,
                              child: Text(
                                'Financial freedom with rock-solid security and privacy',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Color(0xFF0C0C14),
                                  fontSize: 14,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w600,
                                  height: 0.10,
                                ),
                              ),
                            ),
                            SizedBox(height: 8),
                            SizedBox(
                              width: double.infinity,
                              child: Text(
                                'Get started and create a brand new wallet                              or import an existing one.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Color(0xFF0C0C14),
                                  fontSize: 14,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w400,
                                  height: 0.10,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            height: 124,
            padding: const EdgeInsets.only(
              top: 16,
              left: 24,
              right: 24,
              bottom: 24,
            ),
            decoration: const ShapeDecoration(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: double.infinity,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Container(
                          height: 36,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          clipBehavior: Clip.antiAlias,
                          decoration: ShapeDecoration(
                            color: const Color(0xFF6D4AFF),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Create a new wallet',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.w400,
                                        height: 0.10,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Container(
                          height: 36,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          clipBehavior: Clip.antiAlias,
                          decoration: ShapeDecoration(
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                              side: const BorderSide(
                                  width: 1, color: Color(0xFFDEDBD9)),
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Import an existing wallet',
                                      style: TextStyle(
                                        color: Color(0xFF0C0C14),
                                        fontSize: 14,
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.w400,
                                        height: 0.10,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
