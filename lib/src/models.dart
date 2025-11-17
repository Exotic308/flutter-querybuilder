import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

enum InputType { text, number, date, select, boolean }

enum Combinator {
  and,
  or;

  String toJson() => name.toUpperCase();

  static Combinator fromJson(String value) {
    switch (value.toUpperCase()) {
      case 'AND':
        return Combinator.and;
      case 'OR':
        return Combinator.or;
      default:
        throw FormatException('Invalid combinator: $value');
    }
  }
}

/// Represents an operator that can be applied to a field.
///
/// Operators can have multiple typed evaluators to handle different data types.
/// The evaluator will try each function in order until one succeeds.
///
/// Example:
/// ```dart
/// final greaterThan = Operator(
///   name: '>',
///   label: 'greater than',
///   evaluators: [
///     (int a, int b) => a > b,
///     (double a, double b) => a > b,
///     (DateTime a, DateTime b) => a.isAfter(b),
///     (dynamic a, dynamic b) => a > b,
///   ],
/// );
/// ```
@immutable
class Operator extends Equatable {
  /// Unique identifier for the operator
  final String name;

  /// Display label for the operator
  final String label;

  /// List of typed evaluation functions.
  ///
  /// The evaluator will try these functions in order. Each function should
  /// take two parameters and return a boolean. Include a fallback function
  /// with (dynamic, dynamic) signature at the end.
  final List<Function> evaluators;

  /// Creates a new operator with the given name, label, and evaluators.
  const Operator({required this.name, required this.label, required this.evaluators});

  @override
  List<Object?> get props => [name, label];

  @override
  String toString() => 'Operator($name, $label)';
}

/// Represents a field configuration in the query builder.
///
/// Fields define what data can be queried, including the available operators,
/// input type, and optional default values.
@immutable
class Field extends Equatable {
  /// Unique identifier for the field
  final String name;

  /// Display label for the field
  final String label;

  /// The type of input control to display
  final InputType inputType;

  /// List of operators valid for this field
  final List<Operator> operators;

  /// Options for select input type
  final List<String>? options;

  /// Default operator to pre-select when adding a new rule
  final Operator? defaultOperator;

  /// Default value to pre-fill when adding a new rule
  final dynamic defaultValue;

  /// Creates a new field configuration.
  const Field({
    required this.name,
    required this.label,
    required this.inputType,
    required this.operators,
    this.options,
    this.defaultOperator,
    this.defaultValue,
  });

  /// Creates a copy of this field with the given parameters overridden.
  Field copyWith({
    String? name,
    String? label,
    InputType? inputType,
    List<Operator>? operators,
    List<String>? options,
    Operator? defaultOperator,
    dynamic defaultValue,
  }) {
    return Field(
      name: name ?? this.name,
      label: label ?? this.label,
      inputType: inputType ?? this.inputType,
      operators: operators ?? this.operators,
      options: options ?? this.options,
      defaultOperator: defaultOperator ?? this.defaultOperator,
      defaultValue: defaultValue ?? this.defaultValue,
    );
  }

  @override
  List<Object?> get props => [name, label, inputType, operators, options, defaultOperator, defaultValue];

  @override
  String toString() => 'Field($name, $label, $inputType)';
}

/// Represents a single query rule with a field, operator, and value.
@immutable
class QueryRule extends Equatable {
  /// The field name this rule applies to
  final String field;

  /// The operator name to apply
  final String operator;

  /// The value to compare against
  final dynamic value;

  /// Creates a new query rule.
  const QueryRule({required this.field, required this.operator, required this.value});

  /// Creates a copy of this rule with the given parameters overridden.
  QueryRule copyWith({String? field, String? operator, dynamic value}) {
    return QueryRule(field: field ?? this.field, operator: operator ?? this.operator, value: value ?? this.value);
  }

  /// Converts this rule to a JSON map.
  Map<String, dynamic> toJson() {
    return {'field': field, 'operator': operator, 'value': value};
  }

  /// Creates a rule from a JSON map.
  factory QueryRule.fromJson(Map<String, dynamic> json) {
    return QueryRule(field: json['field'] as String, operator: json['operator'] as String, value: json['value']);
  }

  @override
  List<Object?> get props => [field, operator, value];

  @override
  String toString() => 'QueryRule($field $operator $value)';
}

/// Represents a group of rules and nested groups with a combinator.
///
/// Groups can be nested to create complex query logic.
@immutable
class QueryGroup extends Equatable {
  /// The combinator to use between rules and groups
  final Combinator combinator;

  /// List of rules in this group
  final List<QueryRule> rules;

  /// List of nested groups in this group
  final List<QueryGroup> groups;

  /// Creates a new query group.
  const QueryGroup({required this.combinator, required this.rules, required this.groups});

  /// Creates a copy of this group with the given parameters overridden.
  QueryGroup copyWith({Combinator? combinator, List<QueryRule>? rules, List<QueryGroup>? groups}) {
    return QueryGroup(
      combinator: combinator ?? this.combinator,
      rules: rules ?? this.rules,
      groups: groups ?? this.groups,
    );
  }

  /// Converts this group to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'combinator': combinator.toJson(),
      'rules': rules.map((r) => r.toJson()).toList(),
      'groups': groups.map((g) => g.toJson()).toList(),
    };
  }

  /// Creates a group from a JSON map.
  factory QueryGroup.fromJson(Map<String, dynamic> json) {
    return QueryGroup(
      combinator: Combinator.fromJson(json['combinator'] as String),
      rules:
          (json['rules'] as List<dynamic>?)?.map((r) => QueryRule.fromJson(r as Map<String, dynamic>)).toList() ?? [],
      groups:
          (json['groups'] as List<dynamic>?)?.map((g) => QueryGroup.fromJson(g as Map<String, dynamic>)).toList() ?? [],
    );
  }

  /// Returns true if this group has no rules and no nested groups.
  bool get isEmpty => rules.isEmpty && groups.isEmpty;

  /// Returns the total number of rules (including nested groups).
  int get ruleCount {
    int count = rules.length;
    for (final group in groups) {
      count += group.ruleCount;
    }
    return count;
  }

  @override
  List<Object?> get props => [combinator, rules, groups];

  @override
  String toString() => 'QueryGroup(${combinator.name.toUpperCase()}, ${rules.length} rules, ${groups.length} groups)';
}
