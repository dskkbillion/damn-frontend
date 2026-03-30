import 'package:flutter_test/flutter_test.dart';

/// 辅助方法：复制 _sortedMapString 的逻辑，用于测试验证
String sortedMapString(Map<String, String> map) {
  final entries = map.entries.toList()..sort((a, b) => a.key.compareTo(b.key));
  return entries.map((e) => '${e.key}=${e.value}').join('&');
}

/// 模拟 buildSmartPage 中的 key 生成逻辑
String buildPageKey(
  String matchedLocation,
  Map<String, String> pathParameters,
  Map<String, String> queryParameters,
) {
  return '$matchedLocation:${sortedMapString(pathParameters)}:${sortedMapString(queryParameters)}';
}

void main() {
  group('buildSmartPage key 确定性测试', () {
    test('同一路由同一参数调用两次 → key 相同', () {
      const location = '/product/123';
      final pathParams = {'id': '123'};
      final queryParams = {'tab': 'detail'};

      final key1 = buildPageKey(location, pathParams, queryParams);
      final key2 = buildPageKey(location, pathParams, queryParams);

      expect(key1, equals(key2));
    });

    test('不同参数 → key 不同', () {
      const location = '/product/123';

      final key1 = buildPageKey(location, {'id': '123'}, {'tab': 'detail'});
      final key2 = buildPageKey(location, {'id': '456'}, {'tab': 'detail'});

      expect(key1, isNot(equals(key2)));
    });

    test('不同查询参数 → key 不同', () {
      const location = '/product/123';
      final pathParams = {'id': '123'};

      final key1 = buildPageKey(location, pathParams, {'tab': 'detail'});
      final key2 = buildPageKey(location, pathParams, {'tab': 'reviews'});

      expect(key1, isNot(equals(key2)));
    });

    test('参数顺序不同但内容相同 → key 相同（排序保证）', () {
      const location = '/search';
      final pathParams = <String, String>{};

      // 插入顺序不同
      final queryParams1 = {'page': '1', 'keyword': 'apple', 'sort': 'asc'};
      final queryParams2 = {'sort': 'asc', 'keyword': 'apple', 'page': '1'};

      final key1 = buildPageKey(location, pathParams, queryParams1);
      final key2 = buildPageKey(location, pathParams, queryParams2);

      expect(key1, equals(key2));
    });

    test('空参数 → key 仅含路由路径', () {
      const location = '/home';
      final key = buildPageKey(location, {}, {});

      expect(key, equals('/home::'));
    });

    test('不同路由 → key 不同', () {
      final key1 = buildPageKey('/home', {}, {});
      final key2 = buildPageKey('/profile', {}, {});

      expect(key1, isNot(equals(key2)));
    });
  });

  group('sortedMapString 辅助方法测试', () {
    test('空 map → 空字符串', () {
      expect(sortedMapString({}), equals(''));
    });

    test('单个条目', () {
      expect(sortedMapString({'key': 'value'}), equals('key=value'));
    });

    test('多个条目按 key 字母排序', () {
      final result = sortedMapString({'b': '2', 'a': '1', 'c': '3'});
      expect(result, equals('a=1&b=2&c=3'));
    });

    test('相同内容不同插入顺序产生相同结果', () {
      final r1 = sortedMapString({'z': '26', 'a': '1'});
      final r2 = sortedMapString({'a': '1', 'z': '26'});
      expect(r1, equals(r2));
    });
  });
}
