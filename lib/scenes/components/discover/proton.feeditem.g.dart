// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'proton.feeditem.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProtonFeedItem _$ProtonFeedItemFromJson(Map<String, dynamic> json) =>
    ProtonFeedItem(
      title: json['title'] as String,
      pubDate: json['pubDate'] as String,
      link: json['link'] as String,
      description: json['description'] as String,
      category: json['category'] as String,
      author: json['author'] as String,
      coverImage: json['coverImage'] as String? ?? "",
    );

Map<String, dynamic> _$ProtonFeedItemToJson(ProtonFeedItem instance) =>
    <String, dynamic>{
      'title': instance.title,
      'pubDate': instance.pubDate,
      'link': instance.link,
      'description': instance.description,
      'category': instance.category,
      'author': instance.author,
      'coverImage': instance.coverImage,
    };
