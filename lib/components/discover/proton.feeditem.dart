import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'proton.feeditem.g.dart';

@JsonSerializable()
class ProtonFeedItem {
  String title;
  String pubDate;
  String link;
  String description;
  String category;
  String author;
  String coverImage;

  ProtonFeedItem({
    required this.title,
    required this.pubDate,
    required this.link,
    required this.description,
    required this.category,
    required this.author,
    this.coverImage = "",
  });

  /// Connect the generated [_$ProtonFeedItemFromJson] function to the `fromJson`
  /// factory.
  factory ProtonFeedItem.fromJson(Map<String, dynamic> json) =>
      _$ProtonFeedItemFromJson(json);

  /// Connect the generated [_$ProtonFeedItemToJson] function to the `toJson` method.
  Map<String, dynamic> toJson() => _$ProtonFeedItemToJson(this);

  /// Handling a list of ProtonFeedItem instances
  static List<ProtonFeedItem> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => ProtonFeedItem.fromJson(json)).toList();
  }

  static List<Map<String, dynamic>> toJsonList(List<ProtonFeedItem> items) {
    return items.map((item) => item.toJson()).toList();
  }

  static Future<List<ProtonFeedItem>> loadJsonFromAsset() async {
    String jsonString =
        await rootBundle.loadString('assets/custom_discovers.json');
    final decodedJsonList = json.decode(jsonString) as List<dynamic>;
    return fromJsonList(decodedJsonList);
  }
}
