# Flutter Query Builder

Flutter package for building complex queries with nested groups, operators, and JSON import/export. Features type-safe evaluation with caching.

## Installation

From GitHub:

```yaml
dependencies:
  flutter_querybuilder:
    git:
      url: https://github.com/exotic308/flutter-querybuilder.git
      ref: main
```

From Local:

```yaml
dependencies:
  flutter_querybuilder:
    path: ../flutter-querybuilder  # relative path to package
```

Then run `flutter pub get`.

## Quick Start

```dart
import 'package:flutter/material.dart';
import 'package:flutter_querybuilder/flutter_querybuilder.dart';

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final QueryBuilderController _controller;

  @override
  void initState() {
    super.initState();
    _controller = QueryBuilderController(
      fields: [
        Field(
          name: 'age',
          label: 'Age',
          inputType: InputType.number,
          operators: [equals, greaterThan, lessThan],
          defaultValue: 18,
        ),
        Field(
          name: 'name',
          label: 'Name',
          inputType: InputType.text,
          operators: [equals, contains, startsWith],
        ),
      ],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Query Builder')),
      body: QueryBuilder(controller: _controller),
    );
  }
}
```

## Usage

### Controller Pattern

The package uses a controller pattern similar to `TextEditingController`:

```dart
final controller = QueryBuilderController(
  fields: [/* your fields */],
  initialQuery: QueryGroup(/* optional initial query */),
);

// Access the current query
final query = controller.query;

// Update the query programmatically
controller.updateQuery(newQuery);

// Reset to empty query
controller.reset();

// Listen to changes
controller.addListener(() {
  print('Query changed: ${controller.query}');
});

// Don't forget to dispose
controller.dispose();
```

### Field Configuration

Define fields with their types, operators, and defaults:

```dart
Field(
  name: 'age',
  label: 'Age',
  inputType: InputType.number,
  operators: [equals, greaterThan, lessThan],
  defaultOperator: equals,
  defaultValue: 18,
)
```

### Field Types

- **Text**: `InputType.text` - Text input field
- **Number**: `InputType.number` - Numeric input
- **Date**: `InputType.date` - Date picker
- **Select**: `InputType.select` - Dropdown with `options: ['value1', 'value2']`
- **Boolean**: `InputType.boolean` - Checkbox/switch

### Built-in Operators

- **Equality**: `equals`, `notEquals`
- **Comparison**: `greaterThan`, `lessThan`, `greaterOrEqual`, `lessOrEqual`
- **String**: `contains`, `startsWith`, `endsWith`, `matchesRegex`
- **List**: `inList`, `notInList`
- **Range**: `between`

### Custom Operators

Create operators with typed evaluators:

```dart
const customOperator = Operator(
  name: 'custom',
  label: 'Custom Operation',
  evaluators: [
    (int a, int b) => a % b == 0,
    (String a, String b) => a.length > b.length,
    (dynamic a, dynamic b) => a > b, // Fallback
  ],
);
```

### JSON Serialization

```dart
// Export to JSON
final jsonMap = QuerySerializer.toJson(controller.query);
final jsonString = QuerySerializer.toJsonString(controller.query, pretty: true);

// Import from JSON
final query = QuerySerializer.fromJson(jsonMap);
controller.updateQuery(query);

// Or from string
final query = QuerySerializer.fromJsonString(jsonString);
controller.updateQuery(query);
```

### Query Evaluation

Evaluate queries against your data:

```dart
final evaluator = QueryEvaluator();

final data = {
  'age': 30,
  'name': 'John',
  'status': 'active',
};

final matches = evaluator.evaluate(controller.query, data);
print('Match: $matches'); // true or false

// Clear cache when needed
evaluator.clearCache();
```

### Nested Groups

Create complex queries with nested groups:

```dart
QueryGroup(
  combinator: Combinator.and,
  rules: [
    QueryRule(field: 'age', operator: '>', value: 18),
  ],
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
)
```

This represents: `age > 18 AND (status = 'active' OR status = 'pending')`

## Architecture

The package follows a clean architecture:

- **Models** (`models.dart`): `Field`, `Operator`, `QueryRule`, `QueryGroup`, `Combinator` enum
- **Controller** (`query_builder_controller.dart`): `QueryBuilderController` for state management
- **Widgets** (`widgets.dart`): `QueryBuilder`, `QueryGroupWidget`, `QueryRuleWidget`
- **Evaluator** (`evaluator.dart`): `QueryEvaluator` for query evaluation with caching
- **Serializer** (`serializer.dart`): `QuerySerializer` for JSON conversion
- **Operators** (`operators.dart`): Built-in operators with typed evaluators

## Example

Run it:

```bash
cd example
flutter run
```

<picture>
  <source media="(prefers-color-scheme: dark)" srcset="https://github.com/user-attachments/assets/11b4f104-902d-43a5-b89c-99d43c590995" />
  <source media="(prefers-color-scheme: light)" srcset="https://github.com/user-attachments/assets/0987347c-0fc6-418a-8ad3-6a4c976fd210" />
  <img alt="Splash screen with initialization checklist" src="https://github.com/user-attachments/assets/0987347c-0fc6-418a-8ad3-6a4c976fd210" width="100%" />
</picture>

## Testing

```bash
flutter test
```
