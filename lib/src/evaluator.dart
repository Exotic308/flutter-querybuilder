import 'dart:convert';

import 'package:crypto/crypto.dart';

import 'exceptions.dart';
import 'models.dart';
import 'operators.dart';

/// The evaluator recursively evaluates rules and nested groups, respecting
/// the combinator (AND/OR) logic. Results are cached for performance.
class QueryEvaluator {
  final Map<String, bool> _cache = {};

  /// Evaluates a query group against the provided data.
  /// Throws [EvaluationException] if evaluation fails.
  bool evaluate(QueryGroup query, Map<String, dynamic> data) {
    return _evaluateGroup(query, data);
  }

  bool _evaluateGroup(QueryGroup group, Map<String, dynamic> data) {
    if (group.isEmpty) return true;

    if (group.combinator == Combinator.and) {
      // AND logic: all rules and groups must match
      // Evaluate rules
      for (final rule in group.rules) {
        final result = _evaluateRule(rule, data);
        if (!result) return false; // One failure means entire AND fails
      }

      // Evaluate nested groups
      for (final nestedGroup in group.groups) {
        final result = _evaluateGroup(nestedGroup, data);
        if (!result) return false; // One failure means entire AND fails
      }

      // All rules and groups passed
      return true;
    } else {
      // OR logic: at least one rule or group must match
      // Evaluate rules
      for (final rule in group.rules) {
        final result = _evaluateRule(rule, data);
        if (result) return true; // One success means entire OR succeeds
      }

      // Evaluate nested groups
      for (final nestedGroup in group.groups) {
        final result = _evaluateGroup(nestedGroup, data);
        if (result) return true; // One success means entire OR succeeds
      }

      // No rules or groups matched
      return false;
    }
  }

  bool _evaluateRule(QueryRule rule, Map<String, dynamic> data) {
    final fieldValue = data[rule.field];
    final cacheKey = _generateCacheKey(rule.field, rule.operator, rule.value, fieldValue);

    if (_cache.containsKey(cacheKey)) {
      return _cache[cacheKey]!;
    }

    // Find the operator from built-in operators
    Operator? operator;
    try {
      operator = builtInOperators.firstWhere((op) => op.name == rule.operator);
    } catch (e) {
      throw EvaluationException('Unknown operator: ${rule.operator}', e);
    }

    // Try each evaluator in order
    bool result = false;
    bool evaluated = false;

    for (final evaluator in operator.evaluators) {
      try {
        result = evaluator(fieldValue, rule.value) as bool;
        evaluated = true;
        break;
      } catch (e) {
        // Try next evaluator
        continue;
      }
    }

    if (!evaluated) {
      throw EvaluationException(
        'No compatible evaluator found for operator ${rule.operator} '
        'with field ${rule.field} (value type: ${fieldValue.runtimeType})',
      );
    }

    _cache[cacheKey] = result;
    return result;
  }

  String _generateCacheKey(String field, String operator, dynamic ruleValue, dynamic fieldValue) {
    final keyString = '$field|$operator|$ruleValue|$fieldValue';
    return md5.convert(utf8.encode(keyString)).toString();
  }

  /// Clears the evaluation cache.
  void clearCache() {
    _cache.clear();
  }
}
