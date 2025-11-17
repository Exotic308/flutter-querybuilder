import 'dart:convert';

import 'models.dart';

/// Utility class for serializing and deserializing query groups.
class QuerySerializer {
  // Private constructor to prevent instantiation
  QuerySerializer._();

  static Map<String, dynamic> toJson(QueryGroup query) {
    return query.toJson();
  }

  static QueryGroup fromJson(Map<String, dynamic> json) {
    try {
      return QueryGroup.fromJson(json);
    } catch (e) {
      throw FormatException('Invalid query JSON: $e');
    }
  }

  static String toJsonString(QueryGroup query, {bool pretty = false}) {
    final json = toJson(query);
    if (pretty) {
      const encoder = JsonEncoder.withIndent('  ');
      return encoder.convert(json);
    }
    return jsonEncode(json);
  }

  static QueryGroup fromJsonString(String jsonString) {
    try {
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return fromJson(json);
    } catch (e) {
      throw FormatException('Invalid query JSON string: $e');
    }
  }

  static QueryGroup clone(QueryGroup query) {
    return fromJson(toJson(query));
  }
}
