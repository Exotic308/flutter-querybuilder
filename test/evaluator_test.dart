import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_querybuilder/flutter_querybuilder.dart';

void main() {
  group('QueryEvaluator', () {
    late QueryEvaluator evaluator;

    setUp(() {
      evaluator = QueryEvaluator();
    });

    test('should evaluate simple rule with AND combinator', () {
      final query = QueryGroup(
        combinator: Combinator.and,
        rules: const [
          QueryRule(field: 'age', operator: '>', value: 18),
        ],
        groups: const [],
      );

      final data = {'age': 25};
      expect(evaluator.evaluate(query, data), isTrue);

      final data2 = {'age': 15};
      expect(evaluator.evaluate(query, data2), isFalse);
    });

    test('should evaluate multiple rules with AND combinator', () {
      final query = QueryGroup(
        combinator: Combinator.and,
        rules: const [
          QueryRule(field: 'age', operator: '>', value: 18),
          QueryRule(field: 'name', operator: '=', value: 'John'),
        ],
        groups: const [],
      );

      final data = {'age': 25, 'name': 'John'};
      expect(evaluator.evaluate(query, data), isTrue);

      final data2 = {'age': 25, 'name': 'Jane'};
      expect(evaluator.evaluate(query, data2), isFalse);
    });

    test('should evaluate multiple rules with OR combinator', () {
      final query = QueryGroup(
        combinator: Combinator.or,
        rules: const [
          QueryRule(field: 'age', operator: '>', value: 18),
          QueryRule(field: 'name', operator: '=', value: 'John'),
        ],
        groups: const [],
      );

      final data = {'age': 15, 'name': 'John'};
      expect(evaluator.evaluate(query, data), isTrue);

      final data2 = {'age': 25, 'name': 'Jane'};
      expect(evaluator.evaluate(query, data2), isTrue);

      final data3 = {'age': 15, 'name': 'Jane'};
      expect(evaluator.evaluate(query, data3), isFalse);
    });

    test('should evaluate nested groups', () {
      final query = QueryGroup(
        combinator: Combinator.and,
        rules: const [
          QueryRule(field: 'age', operator: '>', value: 18),
        ],
        groups: const [
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

      final data1 = {'age': 25, 'status': 'active'};
      expect(evaluator.evaluate(query, data1), isTrue);

      final data2 = {'age': 25, 'status': 'pending'};
      expect(evaluator.evaluate(query, data2), isTrue);

      final data3 = {'age': 25, 'status': 'inactive'};
      expect(evaluator.evaluate(query, data3), isFalse);

      final data4 = {'age': 15, 'status': 'active'};
      expect(evaluator.evaluate(query, data4), isFalse);
    });

    test('should cache evaluation results', () {
      final query = QueryGroup(
        combinator: Combinator.and,
        rules: const [
          QueryRule(field: 'age', operator: '>', value: 18),
        ],
        groups: const [],
      );

      final data = {'age': 25};

      // First evaluation
      expect(evaluator.evaluate(query, data), isTrue);

      // Second evaluation should use cache
      expect(evaluator.evaluate(query, data), isTrue);
    });

    test('should clear cache', () {
      final query = QueryGroup(
        combinator: Combinator.and,
        rules: const [
          QueryRule(field: 'age', operator: '>', value: 18),
        ],
        groups: const [],
      );

      final data = {'age': 25};
      evaluator.evaluate(query, data);

      evaluator.clearCache();

      // Should still work after cache clear
      expect(evaluator.evaluate(query, data), isTrue);
    });

    test('should handle empty group', () {
      const query = QueryGroup(
        combinator: Combinator.and,
        rules: [],
        groups: [],
      );

      final data = {'age': 25};
      expect(evaluator.evaluate(query, data), isTrue);
    });
  });

  group('Built-in Operators', () {
    late QueryEvaluator evaluator;

    setUp(() {
      evaluator = QueryEvaluator();
    });

    test('equals operator should work with different types', () {
      final queryInt = QueryGroup(
        combinator: Combinator.and,
        rules: const [QueryRule(field: 'age', operator: '=', value: 25)],
        groups: const [],
      );
      expect(evaluator.evaluate(queryInt, {'age': 25}), isTrue);
      expect(evaluator.evaluate(queryInt, {'age': 30}), isFalse);

      final queryString = QueryGroup(
        combinator: Combinator.and,
        rules: const [QueryRule(field: 'name', operator: '=', value: 'John')],
        groups: const [],
      );
      expect(evaluator.evaluate(queryString, {'name': 'John'}), isTrue);
      expect(evaluator.evaluate(queryString, {'name': 'Jane'}), isFalse);
    });

    test('comparison operators should work with numbers', () {
      final query = QueryGroup(
        combinator: Combinator.and,
        rules: const [QueryRule(field: 'age', operator: '>', value: 18)],
        groups: const [],
      );
      expect(evaluator.evaluate(query, {'age': 25}), isTrue);
      expect(evaluator.evaluate(query, {'age': 18}), isFalse);
      expect(evaluator.evaluate(query, {'age': 10}), isFalse);
    });

    test('contains operator should work case-insensitively', () {
      final query = QueryGroup(
        combinator: Combinator.and,
        rules: const [
          QueryRule(field: 'email', operator: 'contains', value: 'example')
        ],
        groups: const [],
      );
      expect(evaluator.evaluate(query, {'email': 'test@example.com'}), isTrue);
      expect(evaluator.evaluate(query, {'email': 'test@EXAMPLE.com'}), isTrue);
      expect(evaluator.evaluate(query, {'email': 'test@other.com'}), isFalse);
    });

    test('startsWith operator should work', () {
      final query = QueryGroup(
        combinator: Combinator.and,
        rules: const [
          QueryRule(field: 'name', operator: 'startsWith', value: 'Jo')
        ],
        groups: const [],
      );
      expect(evaluator.evaluate(query, {'name': 'John'}), isTrue);
      expect(evaluator.evaluate(query, {'name': 'Joe'}), isTrue);
      expect(evaluator.evaluate(query, {'name': 'Jane'}), isFalse);
    });

    test('endsWith operator should work', () {
      final query = QueryGroup(
        combinator: Combinator.and,
        rules: const [
          QueryRule(field: 'email', operator: 'endsWith', value: '.com')
        ],
        groups: const [],
      );
      expect(evaluator.evaluate(query, {'email': 'test@example.com'}), isTrue);
      expect(evaluator.evaluate(query, {'email': 'test@example.org'}), isFalse);
    });

    test('matchesRegex operator should work', () {
      final query = QueryGroup(
        combinator: Combinator.and,
        rules: const [
          QueryRule(field: 'email', operator: 'matches', value: r'^\w+@\w+\.\w+$')
        ],
        groups: const [],
      );
      expect(evaluator.evaluate(query, {'email': 'test@example.com'}), isTrue);
      expect(evaluator.evaluate(query, {'email': 'invalid-email'}), isFalse);
    });

    test('in operator should work with lists', () {
      final query = QueryGroup(
        combinator: Combinator.and,
        rules: const [
          QueryRule(field: 'status', operator: 'in', value: ['active', 'pending'])
        ],
        groups: const [],
      );
      expect(evaluator.evaluate(query, {'status': 'active'}), isTrue);
      expect(evaluator.evaluate(query, {'status': 'pending'}), isTrue);
      expect(evaluator.evaluate(query, {'status': 'inactive'}), isFalse);
    });

    test('DateTime operators should work', () {
      final date1 = DateTime(2023, 1, 1);
      final date2 = DateTime(2024, 1, 1);

      final query = QueryGroup(
        combinator: Combinator.and,
        rules: [QueryRule(field: 'date', operator: '>', value: date1)],
        groups: const [],
      );
      expect(evaluator.evaluate(query, {'date': date2}), isTrue);
      expect(evaluator.evaluate(query, {'date': date1}), isFalse);
    });
  });
}

