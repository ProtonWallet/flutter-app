// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:wallet/rust/types.dart';
// import 'package:wallet/rust/wallet.dart';
// import 'package:wallet/scenes/debug/bdk.test.dart';

// // import 'generated/bridge_definitions.dart';
// import 'helper/bdk/helper.dart';
// import 'helper/local_toast.dart';

// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return const MaterialApp(
//       home: MyHomePage(),
//     );
//   }
// }

// class MyHomePage extends StatefulWidget {
//   const MyHomePage({super.key});

//   @override
//   MyHomePageState createState() => MyHomePageState();
// }

// class MyHomePageState extends State<MyHomePage> {
//   TextEditingController inputControllerA = TextEditingController();
//   TextEditingController inputControllerB = TextEditingController();

//   String resultA = '';
//   String resultB = '';
//   String resultC = '';
//   String resultD = '';
//   String resultE = '';
//   final BdkLibrary _lib = BdkLibrary();

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Flutter Page'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             TextField(
//               controller: inputControllerA,
//               decoration: const InputDecoration(labelText: 'Mnemonic'),
//             ),
//             TextField(
//               controller: inputControllerB,
//               decoration: const InputDecoration(labelText: 'Derivation Path'),
//             ),
//             const SizedBox(height: 20),
//             GestureDetector(
//                 onTap: () {
//                   Clipboard.setData(ClipboardData(text: resultA)).then(
//                       (value) => LocalToast.showToast(context, "copied!",
//                           duration: 1));
//                 },
//                 child: Text('descriptorSecretKey.toString(): \n$resultA\n\n')),
//             GestureDetector(
//                 onTap: () {
//                   Clipboard.setData(ClipboardData(text: resultB)).then(
//                       (value) => LocalToast.showToast(context, "copied!",
//                           duration: 1));
//                 },
//                 child: Text('descriptorPrivateKey.toString(): \n$resultB\n\n')),
//             // GestureDetector(
//             //     onTap: () {
//             //       Clipboard.setData(ClipboardData(text: resultC)).then(
//             //           (value) => LocalToast.showToast(context, "copied!",
//             //               duration: 1));
//             //     },
//             //     child: Text(
//             //         'descriptorPrivateKeyInt.toString(): \n$resultC\n\n')),
//             // GestureDetector(
//             //     onTap: () {
//             //       Clipboard.setData(ClipboardData(text: resultD)).then(
//             //               (value) => LocalToast.showToast(context, "copied!",
//             //               duration: 1));
//             //     },
//             //     child: Text(
//             //         'aliceDescriptor: \n$resultD\n\n')),
//             GestureDetector(
//                 onTap: () {
//                   Clipboard.setData(ClipboardData(text: resultE)).then(
//                       (value) => LocalToast.showToast(context, "copied!",
//                           duration: 1));
//                 },
//                 child: Text('Address: \n$resultE\n\n')),
//             const SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: () {
//                 calculateResults();
//               },
//               child: const Text('Calculate'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Future<void> calculateResults() async {
//     // Get input values from the controllers
//     String mnemonic = inputControllerA.text;
//     String path = inputControllerB.text;
//     String pathInt = "${inputControllerB.text}/1";
//     final DerivationPath derivationPath =
//         await DerivationPath.create(path: path);

//     final aliceMnemonic = await Mnemonic.fromString(mnemonic);

//     DescriptorSecretKey descriptorSecretKey = await DescriptorSecretKey.create(
//         network: Network.testnet, mnemonic: aliceMnemonic);

//     DescriptorSecretKey descriptorPrivateKey =
//         await descriptorSecretKey.derive(derivationPath);

//     // final Descriptor descriptorPrivate = await Descriptor.create(
//     //   descriptor: "wpkh(${descriptorPrivateKey.toString()})",
//     //   network: Network.Testnet,
//     // );

//     final derivationPathInt = await DerivationPath.create(path: pathInt);
//     final descriptorPrivateKeyInt =
//         await descriptorSecretKey.derive(derivationPathInt);
//     // final Descriptor descriptorPrivateInt = await Descriptor.create(
//     //   descriptor: "pkh(${descriptorPrivateKeyInt.toString()})",
//     //   network: Network.Testnet,
//     // );

//     final Descriptor descriptor =
//         await _lib.createDerivedDescriptor(aliceMnemonic, derivationPath);

//     final bdkWallet = await Wallet.create(
//       descriptor: descriptor,
//       // changeDescriptor: descriptorPrivateInt,
//       network: Network.testnet,
//       databaseConfig: const DatabaseConfig.memory(),
//     );

//     String a = descriptorSecretKey.toString();
//     String b = descriptorPrivateKey.toString();
//     String c = descriptorPrivateKeyInt.toString();
//     String d = (bdkWallet).toString();
//     List addresses = [];
//     for (int i = 0; i < 10; i++) {
//       var address =
//           await bdkWallet.getAddress(addressIndex: AddressIndex.peek(index: i));
//       addresses.add(address.address);
//     }
//     String e = addresses.join("\n");
//     setState(() {
//       resultA = a;
//       resultB = b;
//       resultC = c;
//       resultD = d;
//       resultE = e;
//     });
//   }
// }
