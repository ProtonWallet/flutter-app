// import 'package:wallet/helper/bdk/exceptions.dart';
// import 'package:wallet/helper/rust.ffi.dart';
// import 'package:wallet/rust/error.dart' as bridge;
// import 'package:wallet/rust/types.dart' as type;
// // import 'package:wallet/generated/bridge_definitions.dart' as bridge;

// ///A Bitcoin address.
// class Address {
//   final String? _address;
//   Address._(this._address);

//   /// Creates an instance of [Address] from address given.
//   ///
//   /// Throws a [GenericException] if the address is not valid
//   static Future<Address> create({required String address}) async {
//     try {
//       final res = await RustFFIProvider.api
//           .createAddressStaticMethodApi(address: address);
//       return Address._(res);
//     } on bridge.Error catch (e) {
//       throw handleBdkException(e);
//     }
//   }

//   /// Creates an instance of [Address] from address given [Script].
//   ///
//   static Future<Address> fromScript(
//       type.Script script, type.Network network) async {
//     try {
//       final res = await RustFFIProvider.api
//           .addressFromScriptStaticMethodApi(script: script, network: network);
//       return Address._(res);
//     } on bridge.Error catch (e) {
//       throw handleBdkException(e);
//     }
//   }

//   ///The type of the address.
//   ///
//   Future<type.Payload> payload() async {
//     try {
//       final res =
//           await RustFFIProvider.api.payloadStaticMethodApi(address: _address!);
//       return res;
//     } on bridge.Error catch (e) {
//       throw handleBdkException(e);
//     }
//   }

//   Future<type.Network> network() async {
//     try {
//       final res = await RustFFIProvider.api
//           .addressNetworkStaticMethodApi(address: _address!);
//       return res;
//     } on bridge.Error catch (e) {
//       throw handleBdkException(e);
//     }
//   }

//   /// Returns the script pub key of the [Address] object
//   Future<type.Script> scriptPubKey() async {
//     try {
//       final res = await RustFFIProvider.api
//           .addressToScriptPubkeyStaticMethodApi(address: _address.toString());
//       return res;
//     } on bridge.Error {
//       rethrow;
//     }
//   }

//   @override
//   String toString() {
//     return _address.toString();
//   }
// }
