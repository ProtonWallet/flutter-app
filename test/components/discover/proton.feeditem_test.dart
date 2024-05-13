import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:wallet/components/discover/proton.feeditem.dart';

void main() {
  group('ProtonFeedItem', () {
    test('should serialize to JSON', () {
      final item = ProtonFeedItem(
        title: 'Title 1',
        pubDate: '2022-01-01',
        link: 'https://example.com/1',
        description: 'Description 1',
        category: 'Category 1',
        author: 'Author 1',
        coverImage: 'https://example.com/image1.png',
      );

      final jsonMap = item.toJson();
      expect(jsonMap, {
        'title': 'Title 1',
        'pubDate': '2022-01-01',
        'link': 'https://example.com/1',
        'description': 'Description 1',
        'category': 'Category 1',
        'author': 'Author 1',
        'coverImage': 'https://example.com/image1.png',
      });
    });

    test('should deserialize from JSON', () {
      final jsonMap = {
        'title': 'Title 1',
        'pubDate': '2022-01-01',
        'link': 'https://example.com/1',
        'description': 'Description 1',
        'category': 'Category 1',
        'author': 'Author 1',
        'coverImage': 'https://example.com/image1.png',
      };

      final item = ProtonFeedItem.fromJson(jsonMap);
      expect(item.title, 'Title 1');
      expect(item.pubDate, '2022-01-01');
      expect(item.link, 'https://example.com/1');
      expect(item.description, 'Description 1');
      expect(item.category, 'Category 1');
      expect(item.author, 'Author 1');
      expect(item.coverImage, 'https://example.com/image1.png');
    });

    test('should serialize and deserialize a list of ProtonFeedItem', () {
      final items = [
        ProtonFeedItem(
          title: 'Title 1',
          pubDate: '2022-01-01',
          link: 'https://example.com/1',
          description: 'Description 1',
          category: 'Category 1',
          author: 'Author 1',
          coverImage: 'https://example.com/image1.png',
        ),
        ProtonFeedItem(
          title: 'Title 2',
          pubDate: '2022-01-02',
          link: 'https://example.com/2',
          description: 'Description 2',
          category: 'Category 2',
          author: 'Author 2',
          coverImage: 'https://example.com/image2.png',
        ),
      ];

      final jsonList = ProtonFeedItem.toJsonList(items);
      final jsonString = json.encode(jsonList);
      final decodedJsonList = json.decode(jsonString) as List<dynamic>;
      final deserializedItems = ProtonFeedItem.fromJsonList(decodedJsonList);

      expect(deserializedItems.length, 2);
      expect(deserializedItems[0].title, 'Title 1');
      expect(deserializedItems[1].title, 'Title 2');
    });
  });
}
