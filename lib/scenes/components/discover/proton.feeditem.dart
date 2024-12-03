import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:intl/intl.dart';
import 'package:wallet/helper/common_helper.dart';
import 'package:wallet/rust/api/api_service/discovery_content_client.dart';
import 'package:wallet/rust/proton_api/discovery_content.dart';
import 'package:wallet/scenes/core/coordinator.dart';

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
    return jsonList
        .map((json) => ProtonFeedItem.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  static List<Map<String, dynamic>> toJsonList(List<ProtonFeedItem> items) {
    return items.map((item) => item.toJson()).toList();
  }

  static Future<List<ProtonFeedItem>> loadJsonFromAsset() async {
    final String jsonString =
        await rootBundle.loadString('assets/json/custom_discovers.json');
    final decodedJsonList = json.decode(jsonString) as List<dynamic>;
    return fromJsonList(decodedJsonList);
  }

  // TODO(fix): this shouldnt be here.
  static Future<List<ProtonFeedItem>> loadFromApi(
    DiscoveryContentClient apiClient,
  ) async {
    final List<ProtonFeedItem> items = [];
    try {
      final List<Content> contents = await apiClient.getDiscoveryContents();
      final BuildContext? context = Coordinator.rootNavigatorKey.currentContext;
      for (Content content in contents) {
        String localeTime = "";
        if (context != null && context.mounted) {
          localeTime = CommonHelper.formatLocaleTime(context, content.pubDate);
        } else {
          final DateTime date =
              DateTime.fromMillisecondsSinceEpoch(content.pubDate * 1000);
          localeTime = DateFormat('yyyy-MM-dd').format(date);
        }
        items.add(ProtonFeedItem(
          title: content.title,
          pubDate: localeTime,
          link: content.link,
          description: content.description,
          category: content.category,
          author: content.author,
        ));
      }
    } catch (e) {
      e.toString();
    }

    return items;
  }
}
