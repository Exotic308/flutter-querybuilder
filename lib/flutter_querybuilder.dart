/// A Flutter package for building complex queries with nested groups and operators.
///
/// This library provides a flexible query builder widget with support for:
/// - Nested groups with AND/OR logic
/// - Multiple field types (text, number, date, select, boolean)
/// - Custom operators with typed evaluation
/// - JSON import/export
/// - Evaluation with caching
/// - Responsive UI for mobile and desktop
library;

export 'src/models.dart';
export 'src/evaluator.dart';
export 'src/operators.dart';
export 'src/serializer.dart';
export 'src/exceptions.dart';
export 'src/query_builder_controller.dart';
export 'src/widgets.dart';
