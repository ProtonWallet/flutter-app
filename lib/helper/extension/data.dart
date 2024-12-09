import 'dart:convert';

/// An extension on [List<int>] that provides a method to
/// convert byte data to a Base64-encoded string.
extension Base64EncodingExtension on List<int> {
  /// Encodes the list of bytes as a Base64 string.
  String toBase64() => base64Encode(this);
}
