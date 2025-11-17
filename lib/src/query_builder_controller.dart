import 'package:flutter/foundation.dart';

import 'exceptions.dart';
import 'models.dart';

/// Controller for managing query builder state, similar to [TextEditingController].
///
/// This controller holds the query state and notifies listeners when the query changes.
/// It also manages field configurations and validates them.
///
/// Example:
/// ```dart
/// final controller = QueryBuilderController(
///   fields: [
///     Field(
///       name: 'age',
///       label: 'Age',
///       inputType: InputType.number,
///       operators: [equals, greaterThan, lessThan],
///     ),
///   ],
/// );
///
/// QueryBuilder(controller: controller)
/// ```
class QueryBuilderController extends ChangeNotifier {
  /// List of available fields for building queries
  final List<Field> fields;

  QueryGroup _query;

  /// The current query state
  QueryGroup get query => _query;

  /// Creates a new query builder controller.
  ///
  /// Validates the configuration and throws [ConfigurationException] if invalid.
  ///
  /// [fields] must not be empty and each field must have at least one operator.
  /// [initialQuery] defaults to an empty AND group if not provided.
  QueryBuilderController({required this.fields, QueryGroup? initialQuery})
    : _query = initialQuery ?? const QueryGroup(combinator: Combinator.and, rules: [], groups: []) {
    validateConfiguration(fields);
  }

  /// Updates the query and notifies listeners.
  ///
  /// This method should be called whenever the query changes.
  void updateQuery(QueryGroup newQuery) {
    if (_query != newQuery) {
      _query = newQuery;
      notifyListeners();
    }
  }

  /// Resets the query to an empty AND group.
  void reset() {
    updateQuery(const QueryGroup(combinator: Combinator.and, rules: [], groups: []));
  }

  /// Validates the query builder configuration.
  ///
  /// Throws [ConfigurationException] if the configuration is invalid.
  ///
  /// Validates:
  /// - At least one field is provided
  /// - Each field has at least one operator
  /// - Each field's defaultOperator is in its operators list
  /// - Each operator has at least one evaluator function
  static void validateConfiguration(List<Field> fields) {
    if (fields.isEmpty) {
      throw const ConfigurationException('At least one field must be provided');
    }

    for (final field in fields) {
      if (field.operators.isEmpty) {
        throw ConfigurationException('Field "${field.name}" must have at least one operator');
      }

      // Validate defaultOperator is in operators list
      if (field.defaultOperator != null && !field.operators.contains(field.defaultOperator)) {
        throw ConfigurationException(
          'Field "${field.name}" has defaultOperator "${field.defaultOperator?.name}" '
          'which is not in its operators list',
        );
      }

      // Validate operators have evaluators
      for (final operator in field.operators) {
        if (operator.evaluators.isEmpty) {
          throw ConfigurationException(
            'Operator "${operator.name}" for field "${field.name}" '
            'must have at least one evaluator function',
          );
        }
      }
    }
  }

}
