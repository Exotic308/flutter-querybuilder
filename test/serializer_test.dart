import 'package:flutter_querybuilder/flutter_querybuilder.dart' hide equals, greaterThan, contains;
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('QuerySerializer', () {
    test('should serialize simple query to JSON', () {
      const query = QueryGroup(
        combinator: Combinator.and,
        rules: [QueryRule(field: 'age', operator: '>', value: 18)],
        groups: [],
      );

      final json = QuerySerializer.toJson(query);
      expect(json['combinator'], 'AND'); // JSON serializes to uppercase string
      expect(json['rules'], isA<List>());
      expect(json['rules'].length, 1);
      expect(json['groups'], isA<List>());
      expect(json['groups'].length, 0);
    });

    test('should deserialize simple query from JSON', () {
      final json = {
        'combinator': 'OR',
        'rules': [
          {'field': 'name', 'operator': '=', 'value': 'John'},
        ],
        'groups': [],
      };

      final query = QuerySerializer.fromJson(json);
      expect(query.combinator, Combinator.or);
      expect(query.rules.length, 1);
      expect(query.rules[0].field, 'name');
      expect(query.rules[0].operator, '=');
      expect(query.rules[0].value, 'John');
    });

    test('should serialize nested groups', () {
      const query = QueryGroup(
        combinator: Combinator.and,
        rules: [QueryRule(field: 'age', operator: '>', value: 18)],
        groups: [
          QueryGroup(
            combinator: Combinator.or,
            rules: [
              QueryRule(field: 'status', operator: '=', value: 'active'),
              QueryRule(field: 'status', operator: '=', value: 'pending'),
            ],
            groups: [],
          ),
        ],
      );

      final json = QuerySerializer.toJson(query);
      expect(json['groups'], isA<List>());
      expect(json['groups'].length, 1);
      expect(json['groups'][0]['combinator'], 'OR'); // JSON serializes to uppercase string
      expect(json['groups'][0]['rules'].length, 2);
    });

    test('should deserialize nested groups', () {
      final json = {
        'combinator': 'AND',
        'rules': [
          {'field': 'age', 'operator': '>', 'value': 18},
        ],
        'groups': [
          {
            'combinator': 'OR',
            'rules': [
              {'field': 'status', 'operator': '=', 'value': 'active'},
              {'field': 'status', 'operator': '=', 'value': 'pending'},
            ],
            'groups': [],
          },
        ],
      };

      final query = QuerySerializer.fromJson(json);
      expect(query.groups.length, 1);
      expect(query.groups[0].combinator, Combinator.or);
      expect(query.groups[0].rules.length, 2);
    });

    test('should convert to JSON string', () {
      const query = QueryGroup(
        combinator: Combinator.and,
        rules: [QueryRule(field: 'age', operator: '>', value: 18)],
        groups: [],
      );

      final jsonString = QuerySerializer.toJsonString(query);
      expect(jsonString, isA<String>());
      expect(jsonString.contains('"combinator"'), isTrue);
      expect(jsonString.contains('"AND"'), isTrue);
    });

    test('should convert to pretty JSON string', () {
      const query = QueryGroup(
        combinator: Combinator.and,
        rules: [QueryRule(field: 'age', operator: '>', value: 18)],
        groups: [],
      );

      final jsonString = QuerySerializer.toJsonString(query, pretty: true);
      expect(jsonString, isA<String>());
      expect(jsonString.contains('\n'), isTrue); // Should have newlines
      expect(jsonString.contains('  '), isTrue); // Should have indentation
    });

    test('should parse from JSON string', () {
      const jsonString = '{"combinator":"AND","rules":[{"field":"age","operator":">","value":18}],"groups":[]}';

      final query = QuerySerializer.fromJsonString(jsonString);
      expect(query.combinator, Combinator.and);
      expect(query.rules.length, 1);
      expect(query.rules[0].field, 'age');
    });

    test('should clone a query', () {
      const original = QueryGroup(
        combinator: Combinator.and,
        rules: [QueryRule(field: 'age', operator: '>', value: 18)],
        groups: [],
      );

      final clone = QuerySerializer.clone(original);
      expect(clone, equals(original));
      expect(identical(clone, original), isFalse);
    });

    test('should handle round-trip conversion', () {
      const original = QueryGroup(
        combinator: Combinator.and,
        rules: [
          QueryRule(field: 'age', operator: '>', value: 18),
          QueryRule(field: 'name', operator: '=', value: 'John'),
        ],
        groups: [
          QueryGroup(
            combinator: Combinator.or,
            rules: [QueryRule(field: 'status', operator: '=', value: 'active')],
            groups: [],
          ),
        ],
      );

      final json = QuerySerializer.toJson(original);
      final restored = QuerySerializer.fromJson(json);

      expect(restored, equals(original));
    });

    test('should throw FormatException for invalid JSON string', () {
      const invalidJsonString = 'not valid json';

      expect(() => QuerySerializer.fromJsonString(invalidJsonString), throwsA(isA<FormatException>()));
    });
  });
}
