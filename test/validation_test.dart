import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_querybuilder/flutter_querybuilder.dart' hide equals, greaterThan, contains;
import 'package:flutter_querybuilder/src/operators.dart' as ops;

void main() {
  group('Configuration Validation', () {
    test('should throw exception when no fields provided', () {
      expect(
        () => QueryBuilderController.validateConfiguration(const []),
        throwsA(isA<ConfigurationException>()),
      );
    });

    test('should throw exception when field has no operators', () {
      expect(
        () => QueryBuilderController.validateConfiguration(const [
          Field(
            name: 'age',
            label: 'Age',
            inputType: InputType.number,
            operators: [],
          ),
        ]),
        throwsA(isA<ConfigurationException>()),
      );
    });

    test('should throw exception when operator has no evaluators', () {
      const invalidOperator = Operator(
        name: 'invalid',
        label: 'Invalid',
        evaluators: [],
      );

      expect(
        () => QueryBuilderController.validateConfiguration(const [
          Field(
            name: 'age',
            label: 'Age',
            inputType: InputType.number,
            operators: [invalidOperator],
          ),
        ]),
        throwsA(isA<ConfigurationException>()),
      );
    });

    test('should throw exception when defaultOperator is not in operators list',
        () {
      const otherOperator = Operator(
        name: 'other',
        label: 'Other',
        evaluators: [_dummyEvaluator],
      );

      expect(
        () => QueryBuilderController.validateConfiguration(const [
          Field(
            name: 'age',
            label: 'Age',
            inputType: InputType.number,
            operators: [ops.equals],
            defaultOperator: otherOperator,
          ),
        ]),
        throwsA(isA<ConfigurationException>()),
      );
    });

    test('should accept valid configuration', () {
      expect(
        () => QueryBuilderController(
          fields: const [
            Field(
              name: 'age',
              label: 'Age',
              inputType: InputType.number,
              operators: [ops.equals, ops.greaterThan],
              defaultOperator: ops.equals,
              defaultValue: 0,
            ),
          ],
        ),
        returnsNormally,
      );
    });

    testWidgets('should work with QueryBuilder widget', (tester) async {
      final controller = QueryBuilderController(
        fields: const [
          Field(
            name: 'age',
            label: 'Age',
            inputType: InputType.number,
            operators: [ops.equals, ops.greaterThan],
            defaultOperator: ops.equals,
            defaultValue: 0,
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: QueryBuilder(controller: controller),
          ),
        ),
      );

      // If we get here without throwing, the configuration is valid
      expect(find.byType(QueryBuilder), findsOneWidget);
    });
  });

  group('ConfigurationException', () {
    test('should format exception message', () {
      const exception = ConfigurationException('Test error message');
      expect(exception.toString(), contains('ConfigurationException'));
      expect(exception.toString(), contains('Test error message'));
    });
  });

  group('EvaluationException', () {
    test('should format exception message without cause', () {
      const exception = EvaluationException('Test error');
      expect(exception.toString(), contains('EvaluationException'));
      expect(exception.toString(), contains('Test error'));
    });

    test('should format exception message with cause', () {
      const exception = EvaluationException('Test error', 'Root cause');
      expect(exception.toString(), contains('EvaluationException'));
      expect(exception.toString(), contains('Test error'));
      expect(exception.toString(), contains('Caused by'));
      expect(exception.toString(), contains('Root cause'));
    });
  });
}

bool _dummyEvaluator(dynamic a, dynamic b) => true;

