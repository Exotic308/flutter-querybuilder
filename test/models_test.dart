import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_querybuilder/flutter_querybuilder.dart' as qb;

void main() {
  group('QueryRule', () {
    test('should create a query rule', () {
      const rule = qb.QueryRule(
        field: 'age',
        operator: '>',
        value: 18,
      );

      expect(rule.field, 'age');
      expect(rule.operator, '>');
      expect(rule.value, 18);
    });

    test('should serialize to JSON', () {
      const rule = qb.QueryRule(
        field: 'name',
        operator: '=',
        value: 'John',
      );

      final json = rule.toJson();
      expect(json['field'], 'name');
      expect(json['operator'], '=');
      expect(json['value'], 'John');
    });

    test('should deserialize from JSON', () {
      final json = {
        'field': 'age',
        'operator': '>',
        'value': 25,
      };

      final rule = qb.QueryRule.fromJson(json);
      expect(rule.field, 'age');
      expect(rule.operator, '>');
      expect(rule.value, 25);
    });

    test('should support copyWith', () {
      const rule = qb.QueryRule(
        field: 'age',
        operator: '>',
        value: 18,
      );

      final newRule = rule.copyWith(value: 21);
      expect(newRule.field, 'age');
      expect(newRule.operator, '>');
      expect(newRule.value, 21);
    });

    test('should be equatable', () {
      const rule1 = qb.QueryRule(field: 'age', operator: '>', value: 18);
      const rule2 = qb.QueryRule(field: 'age', operator: '>', value: 18);
      const rule3 = qb.QueryRule(field: 'age', operator: '>', value: 21);

      expect(rule1, equals(rule2));
      expect(rule1, isNot(equals(rule3)));
    });
  });

  group('QueryGroup', () {
    test('should create an empty query group', () {
      const group = qb.QueryGroup(
        combinator: qb.Combinator.and,
        rules: [],
        groups: [],
      );

      expect(group.combinator, qb.Combinator.and);
      expect(group.rules, isEmpty);
      expect(group.groups, isEmpty);
      expect(group.isEmpty, isTrue);
    });

    test('should create a query group with rules', () {
      const group = qb.QueryGroup(
        combinator: qb.Combinator.or,
        rules: [
          qb.QueryRule(field: 'age', operator: '>', value: 18),
          qb.QueryRule(field: 'name', operator: '=', value: 'John'),
        ],
        groups: [],
      );

      expect(group.combinator, qb.Combinator.or);
      expect(group.rules.length, 2);
      expect(group.isEmpty, isFalse);
      expect(group.ruleCount, 2);
    });

    test('should serialize to JSON', () {
      const group = qb.QueryGroup(
        combinator: qb.Combinator.and,
        rules: [
          qb.QueryRule(field: 'age', operator: '>', value: 18),
        ],
        groups: [],
      );

      final json = group.toJson();
      expect(json['combinator'], 'AND'); // JSON serializes to uppercase string
      expect(json['rules'], isA<List>());
      expect(json['rules'].length, 1);
      expect(json['groups'], isA<List>());
      expect(json['groups'].length, 0);
    });

    test('should deserialize from JSON', () {
      final json = {
        'combinator': 'OR',
        'rules': [
          {'field': 'age', 'operator': '>', 'value': 25}
        ],
        'groups': [],
      };

      final group = qb.QueryGroup.fromJson(json);
      expect(group.combinator, qb.Combinator.or);
      expect(group.rules.length, 1);
      expect(group.groups.length, 0);
    });

    test('should support nested groups', () {
      const group = qb.QueryGroup(
        combinator: qb.Combinator.and,
        rules: [
          qb.QueryRule(field: 'age', operator: '>', value: 18),
        ],
        groups: [
          qb.QueryGroup(
            combinator: qb.Combinator.or,
            rules: [
              qb.QueryRule(field: 'status', operator: '=', value: 'active'),
              qb.QueryRule(field: 'status', operator: '=', value: 'pending'),
            ],
            groups: [],
          ),
        ],
      );

      expect(group.groups.length, 1);
      expect(group.ruleCount, 3); // 1 direct + 2 in nested group
    });

    test('should support copyWith', () {
      const group = qb.QueryGroup(
        combinator: qb.Combinator.and,
        rules: [],
        groups: [],
      );

      final newGroup = group.copyWith(combinator: qb.Combinator.or);
      expect(newGroup.combinator, qb.Combinator.or);
    });
  });

  group('Field', () {
    test('should create a field', () {
      const field = qb.Field(
        name: 'age',
        label: 'Age',
        inputType: qb.InputType.number,
        operators: [qb.equals, qb.greaterThan],
      );

      expect(field.name, 'age');
      expect(field.label, 'Age');
      expect(field.inputType, qb.InputType.number);
      expect(field.operators.length, 2);
    });

    test('should support default values', () {
      const field = qb.Field(
        name: 'status',
        label: 'Status',
        inputType: qb.InputType.select,
        operators: [qb.equals],
        options: ['active', 'inactive'],
        defaultOperator: qb.equals,
        defaultValue: 'active',
      );

      expect(field.defaultOperator, qb.equals);
      expect(field.defaultValue, 'active');
      expect(field.options, ['active', 'inactive']);
    });
  });

  group('Operator', () {
    test('should create an operator', () {
      const op = qb.Operator(
        name: '=',
        label: 'equals',
        evaluators: [_testEvaluator],
      );

      expect(op.name, '=');
      expect(op.label, 'equals');
      expect(op.evaluators.length, 1);
    });

    test('should be equatable by name and label', () {
      const op1 = qb.Operator(name: '=', label: 'equals', evaluators: []);
      const op2 = qb.Operator(name: '=', label: 'equals', evaluators: []);
      const op3 = qb.Operator(name: '!=', label: 'not equals', evaluators: []);

      expect(op1, equals(op2));
      expect(op1, isNot(equals(op3)));
    });
  });
}

bool _testEvaluator(dynamic a, dynamic b) => a == b;

