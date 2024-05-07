import 'dart:convert';
import 'dart:typed_data';

extension StringExtension on String {
  bool isPalindrome() {
    String cleanedString = replaceAll(RegExp(r'\s+'), '').toLowerCase();
    String reversedString = cleanedString.split('').reversed.join('');
    return cleanedString == reversedString;
  }

  Uint8List base64decode() {
    return base64Decode(this);
  }
}
