import 'package:flutter/material.dart';
import 'package:wallet/channels/platformchannel.dart';
import 'package:wallet/generated/bridge_definitions.dart';
import 'package:wallet/helper/mnemonic.dart';

class WalletHomePage extends StatefulWidget {
  const WalletHomePage({super.key, required this.title});

  final String title;

  @override
  State<WalletHomePage> createState() => _WalletHomePageState();
}

class _WalletHomePageState extends State<WalletHomePage> {
  // int _counter = 0;
  int _selectedPage = 0;

  List<String> items = List<String>.generate(10000, (i) => 'Item $i');

  @override
  void initState() {
    _selectedPage = 0;
    super.initState();
  }

  @override
  void deactivate() {
    print("_WalletHomePageState is deactivated");
    super.deactivate();
  }

  @override
  void activate() {
    print("_WalletHomePageState is activated");
    super.activate();
  }

  void _incrementCounter() {
    setState(() {
      // _counter++;
    });
  }

  String _mnemonicString = 'No Wallet';

  Future<void> _updateStringValue() async {
    var mnemonic = await Mnemonic.create(WordCount.Words12);
    setState(() {
      _mnemonicString = mnemonic.asString();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              ElevatedButton(
                onPressed: _updateStringValue,
                style: ElevatedButton.styleFrom(
                    primary: const Color(0xFF6D4AFF), elevation: 0),
                child: Text(
                  "Create Wallet".toUpperCase(),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              SizedBox(height: 20),
              Text(
                _mnemonicString,
                style: Theme.of(context).textTheme.headline4,
              ),
            ]),
      ),
      bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.account_balance_wallet),
              label: 'Wallet',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.account_balance),
              label: 'Bank',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.account_circle),
              label: 'Profile',
            ),
          ],
          selectedItemColor: Theme.of(context).colorScheme.primary,
          unselectedItemColor: Theme.of(context).colorScheme.onBackground,
          backgroundColor: Theme.of(context).colorScheme.background,
          currentIndex: _selectedPage,
          onTap: (index) {
            if (index == 2) {
              NativeViewSwitcher.switchToNativeView();
            }
            setState(() {
              _selectedPage = index;
            });
          }),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

class CustomButton extends StatelessWidget {
  final String text;
  final double width;
  final double height;
  final Color backgroundColor;
  final TextStyle textStyle;

  const CustomButton({
    super.key,
    required this.text,
    required this.width,
    required this.height,
    this.backgroundColor = const Color(0xFF6D4AFF),
    this.textStyle = const TextStyle(
      color: Colors.white,
      fontSize: 14,
      fontFamily: 'Inter',
      fontWeight: FontWeight.w400,
    ),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      clipBehavior: Clip.antiAlias,
      decoration: ShapeDecoration(
        color: backgroundColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            text,
            style: textStyle,
          ),
        ],
      ),
    );
  }
}
