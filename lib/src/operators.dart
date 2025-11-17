import 'models.dart';

// ============================================================================
// Built-in Operators
// ============================================================================

/// Equality operator (=)
const Operator equals = Operator(
  name: '=',
  label: 'equals',
  evaluators: [
    _equalsInt,
    _equalsDouble,
    _equalsString,
    _equalsDateTime,
    _equalsBool,
    _equalsDynamic,
  ],
);

bool _equalsInt(int a, int b) => a == b;
bool _equalsDouble(double a, double b) => a == b;
bool _equalsString(String a, String b) => a == b;
bool _equalsDateTime(DateTime a, DateTime b) => a.isAtSameMomentAs(b);
bool _equalsBool(bool a, bool b) => a == b;
bool _equalsDynamic(dynamic a, dynamic b) => a == b;

/// Not equals operator (!=)
const Operator notEquals = Operator(
  name: '!=',
  label: 'not equals',
  evaluators: [
    _notEqualsInt,
    _notEqualsDouble,
    _notEqualsString,
    _notEqualsDateTime,
    _notEqualsBool,
    _notEqualsDynamic,
  ],
);

bool _notEqualsInt(int a, int b) => a != b;
bool _notEqualsDouble(double a, double b) => a != b;
bool _notEqualsString(String a, String b) => a != b;
bool _notEqualsDateTime(DateTime a, DateTime b) => !a.isAtSameMomentAs(b);
bool _notEqualsBool(bool a, bool b) => a != b;
bool _notEqualsDynamic(dynamic a, dynamic b) => a != b;

/// Greater than operator (>)
const Operator greaterThan = Operator(
  name: '>',
  label: 'greater than',
  evaluators: [
    _greaterThanInt,
    _greaterThanDouble,
    _greaterThanString,
    _greaterThanDateTime,
    _greaterThanDynamic,
  ],
);

bool _greaterThanInt(int a, int b) => a > b;
bool _greaterThanDouble(double a, double b) => a > b;
bool _greaterThanString(String a, String b) => a.compareTo(b) > 0;
bool _greaterThanDateTime(DateTime a, DateTime b) => a.isAfter(b);
bool _greaterThanDynamic(dynamic a, dynamic b) => a > b;

/// Less than operator (<)
const Operator lessThan = Operator(
  name: '<',
  label: 'less than',
  evaluators: [
    _lessThanInt,
    _lessThanDouble,
    _lessThanString,
    _lessThanDateTime,
    _lessThanDynamic,
  ],
);

bool _lessThanInt(int a, int b) => a < b;
bool _lessThanDouble(double a, double b) => a < b;
bool _lessThanString(String a, String b) => a.compareTo(b) < 0;
bool _lessThanDateTime(DateTime a, DateTime b) => a.isBefore(b);
bool _lessThanDynamic(dynamic a, dynamic b) => a < b;

/// Greater than or equal operator (>=)
const Operator greaterOrEqual = Operator(
  name: '>=',
  label: 'greater than or equal',
  evaluators: [
    _greaterOrEqualInt,
    _greaterOrEqualDouble,
    _greaterOrEqualString,
    _greaterOrEqualDateTime,
    _greaterOrEqualDynamic,
  ],
);

bool _greaterOrEqualInt(int a, int b) => a >= b;
bool _greaterOrEqualDouble(double a, double b) => a >= b;
bool _greaterOrEqualString(String a, String b) => a.compareTo(b) >= 0;
bool _greaterOrEqualDateTime(DateTime a, DateTime b) =>
    a.isAfter(b) || a.isAtSameMomentAs(b);
bool _greaterOrEqualDynamic(dynamic a, dynamic b) => a >= b;

/// Less than or equal operator (<=)
const Operator lessOrEqual = Operator(
  name: '<=',
  label: 'less than or equal',
  evaluators: [
    _lessOrEqualInt,
    _lessOrEqualDouble,
    _lessOrEqualString,
    _lessOrEqualDateTime,
    _lessOrEqualDynamic,
  ],
);

bool _lessOrEqualInt(int a, int b) => a <= b;
bool _lessOrEqualDouble(double a, double b) => a <= b;
bool _lessOrEqualString(String a, String b) => a.compareTo(b) <= 0;
bool _lessOrEqualDateTime(DateTime a, DateTime b) =>
    a.isBefore(b) || a.isAtSameMomentAs(b);
bool _lessOrEqualDynamic(dynamic a, dynamic b) => a <= b;

/// Contains operator (for strings)
const Operator contains = Operator(
  name: 'contains',
  label: 'contains',
  evaluators: [
    _containsString,
    _containsDynamic,
  ],
);

bool _containsString(String a, String b) =>
    a.toLowerCase().contains(b.toLowerCase());
bool _containsDynamic(dynamic a, dynamic b) =>
    a.toString().toLowerCase().contains(b.toString().toLowerCase());

/// Starts with operator (for strings)
const Operator startsWith = Operator(
  name: 'startsWith',
  label: 'starts with',
  evaluators: [
    _startsWithString,
    _startsWithDynamic,
  ],
);

bool _startsWithString(String a, String b) =>
    a.toLowerCase().startsWith(b.toLowerCase());
bool _startsWithDynamic(dynamic a, dynamic b) =>
    a.toString().toLowerCase().startsWith(b.toString().toLowerCase());

/// Ends with operator (for strings)
const Operator endsWith = Operator(
  name: 'endsWith',
  label: 'ends with',
  evaluators: [
    _endsWithString,
    _endsWithDynamic,
  ],
);

bool _endsWithString(String a, String b) =>
    a.toLowerCase().endsWith(b.toLowerCase());
bool _endsWithDynamic(dynamic a, dynamic b) =>
    a.toString().toLowerCase().endsWith(b.toString().toLowerCase());

/// Matches regex operator
const Operator matchesRegex = Operator(
  name: 'matches',
  label: 'matches regex',
  evaluators: [
    _matchesString,
    _matchesDynamic,
  ],
);

bool _matchesString(String a, String b) {
  try {
    return RegExp(b).hasMatch(a);
  } catch (e) {
    return false;
  }
}

bool _matchesDynamic(dynamic a, dynamic b) {
  try {
    return RegExp(b.toString()).hasMatch(a.toString());
  } catch (e) {
    return false;
  }
}

/// In list operator
const Operator inList = Operator(
  name: 'in',
  label: 'in',
  evaluators: [
    _inListAny,
  ],
);

bool _inListAny(dynamic a, dynamic b) {
  if (b is List) {
    return b.contains(a);
  }
  if (b is String) {
    // Try to parse as comma-separated list
    final list = b.split(',').map((e) => e.trim()).toList();
    return list.contains(a.toString());
  }
  return false;
}

/// Not in list operator
const Operator notInList = Operator(
  name: 'notIn',
  label: 'not in',
  evaluators: [
    _notInListAny,
  ],
);

bool _notInListAny(dynamic a, dynamic b) {
  return !_inListAny(a, b);
}

/// Between operator (inclusive)
const Operator between = Operator(
  name: 'between',
  label: 'between',
  evaluators: [
    _betweenInt,
    _betweenDouble,
    _betweenDateTime,
    _betweenList,
  ],
);

bool _betweenInt(int a, List<int> b) => b.length >= 2 && a >= b[0] && a <= b[1];
bool _betweenDouble(double a, List<double> b) =>
    b.length >= 2 && a >= b[0] && a <= b[1];
bool _betweenDateTime(DateTime a, List<DateTime> b) =>
    b.length >= 2 &&
    (a.isAfter(b[0]) || a.isAtSameMomentAs(b[0])) &&
    (a.isBefore(b[1]) || a.isAtSameMomentAs(b[1]));
bool _betweenList(dynamic a, List<dynamic> b) {
  if (b.length < 2) return false;
  try {
    return a >= b[0] && a <= b[1];
  } catch (e) {
    return false;
  }
}

/// List of all built-in operators
const List<Operator> builtInOperators = [
  equals,
  notEquals,
  greaterThan,
  lessThan,
  greaterOrEqual,
  lessOrEqual,
  contains,
  startsWith,
  endsWith,
  matchesRegex,
  inList,
  notInList,
  between,
];


