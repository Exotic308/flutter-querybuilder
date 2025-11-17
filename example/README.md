# Flutter Query Builder Example

A comprehensive example demonstrating the usage of the `flutter_querybuilder` package with a clean, modular structure.

## Project Structure

```
example/
├── lib/
│   ├── main.dart                      # Main app with clear structure
│   └── config/
│       ├── field_config.dart          # Field configurations
│       └── sample_data.dart           # Sample data for evaluation
└── README.md
```

## Clean Architecture

The example follows a clear, step-by-step structure:

### 1. **Create Sample Data**
```dart
final List<Map<String, dynamic>> _sampleData = sampleData;
```

### 2. **Create Query Configuration**
```dart
final List<Field> _fields = buildDemoFields();
```

### 3. **Instantiate Query Builder State**
```dart
late QueryGroup _currentQuery;
// Initialize with default query
```

### 4. **Use Library Widgets**
Pass the query builder state to individual widgets:

- **`QueryBuilder`** - Main query building widget
- **`JsonViewerWidget`** - JSON display with import/copy buttons
- **`SampleDataViewerWidget`** - Generic sample data display
- **`EvaluationResultWidget`** - Query evaluation results

## Features Demonstrated

### Core Functionality
- ✅ Building queries with multiple field types
- ✅ Nested groups with AND/OR logic
- ✅ JSON import/export via clipboard
- ✅ Live query evaluation against sample data
- ✅ Clean, modular widget structure

### Field Types
- **Text**: name
- **Number**: age
- **Date**: birthDate
- **Select**: status (active, inactive, pending)
- **Boolean**: isVerified

### Library Widgets

#### JsonViewerWidget
- Displays JSON with import/copy buttons positioned at top right
- Buttons are inside the JSON display area
- Non-selectable text by default (use copy button)

#### SampleDataViewerWidget
- Generic display of sample data
- Automatically formats all fields
- Shows all fields from the data (no hardcoding)
- Handles DateTime, bool, num, and string types

#### EvaluationResultWidget
- Displays query evaluation results
- Automatically hides when empty
- Clean, styled output

## Code Structure

### main.dart Structure

```dart
class _QueryBuilderDemoState extends State<QueryBuilderDemo> {
  // 1. Sample data - created once
  final List<Map<String, dynamic>> _sampleData = sampleData;

  // 2. Query configuration - created once
  final List<Field> _fields = buildDemoFields();

  // 3. Query builder state - managed here
  late QueryGroup _currentQuery;
  String _jsonOutput = '';
  String _evaluationResult = '';

  // State management methods
  void _handleQueryChanged(QueryGroup query) { ... }
  void _evaluateQuery() { ... }
  Future<void> _importJson() async { ... }
  Future<void> _copyJson() async { ... }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // 4. Pass state to widgets
          QueryBuilder(
            fields: _fields,
            initialQuery: _currentQuery,
            onQueryChanged: _handleQueryChanged,
          ),
          JsonViewerWidget(
            json: _jsonOutput,
            onImport: _importJson,
            onCopy: _copyJson,
          ),
          SampleDataViewerWidget(
            sampleData: _sampleData,
          ),
          EvaluationResultWidget(
            result: _evaluationResult,
          ),
        ],
      ),
    );
  }
}
```

## Running the Example

```bash
cd example
flutter run
```

### For Web
```bash
flutter run -d chrome
```

### For Desktop
```bash
# macOS
flutter run -d macos

# Windows
flutter run -d windows

# Linux
flutter run -d linux
```

## Widget Usage

### QueryBuilder
The main widget for building queries:
```dart
QueryBuilder(
  fields: _fields,
  initialQuery: _currentQuery,
  onQueryChanged: _handleQueryChanged,
)
```

### JsonViewerWidget
Display JSON with import/copy functionality:
```dart
JsonViewerWidget(
  json: _jsonOutput,
  onImport: _importJson,  // Optional
  onCopy: _copyJson,       // Optional
  selectable: false,       // Optional, default false
)
```

### SampleDataViewerWidget
Display sample data generically:
```dart
SampleDataViewerWidget(
  sampleData: _sampleData,
  title: 'My Sample Data',  // Optional
)
```

### EvaluationResultWidget
Display evaluation results:
```dart
EvaluationResultWidget(
  result: _evaluationResult,
  show: true,  // Optional, default true
)
```

## Benefits of This Structure

1. **Clear Separation**: Data, config, and state are clearly separated
2. **Reusable Widgets**: Library widgets can be used in any app
3. **Easy to Understand**: Step-by-step flow is obvious
4. **Maintainable**: Each widget has a single responsibility
5. **Generic**: Sample data viewer works with any data structure

## Customization

### Adding New Fields

Edit `config/field_config.dart`:
```dart
Field(
  name: 'customField',
  label: 'Custom Field',
  inputType: InputType.text,
  operators: const [equals, contains],
  defaultValue: '',
)
```

### Adding Sample Data

Edit `config/sample_data.dart`:
```dart
{
  'name': 'New User',
  'age': 40,
  'birthDate': DateTime(1984, 1, 1),
  'status': 'active',
  'isVerified': true,
  'customField': 'value',  // Any field works!
}
```

The `SampleDataViewerWidget` will automatically display all fields.

## Tips

1. **Modular Design**: Each widget is independent and reusable
2. **State Management**: Query state is managed in one place
3. **Generic Display**: Sample data viewer shows all fields automatically
4. **Library Widgets**: All UI components are in the library, not the example
5. **Clean Code**: Clear separation makes the code easy to understand and maintain

## Learn More

- [Package Documentation](../README.md)
- [API Reference](../README.md#api-reference)
- [Flutter Query Builder on GitHub](https://github.com/yourusername/flutter_querybuilder)
