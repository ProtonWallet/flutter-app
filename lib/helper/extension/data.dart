import 'dart:convert';

extension DataExtension on List<int> {
  String base64encode() {
    return base64Encode(this);
  }
}
