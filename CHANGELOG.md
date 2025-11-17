# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.0] - 2025-11-15

### Added
- Initial release of Flutter Query Builder
- Core models: `QueryRule`, `QueryGroup`, `Field`, `Operator`, `InputType`
- Main `QueryBuilder` widget with responsive layout
- Support for nested groups with AND/OR logic
- Built-in operators:
  - Equality: equals, notEquals
  - Comparison: greaterThan, lessThan, greaterOrEqual, lessOrEqual
  - String: contains, startsWith, endsWith, matchesRegex
  - List: inList, notInList
  - Range: between
- Multiple input types: text, number, date, select, boolean
- JSON serialization with `QuerySerializer`
- Query evaluation with `QueryEvaluator` and caching support
- Configuration validation with clear error messages
- Default values for fields and operators
- Responsive UI for mobile and desktop
- Comprehensive test coverage
- Example app with JSON import/export
- Full API documentation

### Features
- Type-safe operator evaluation with multiple typed evaluators
- Automatic type dispatch for operators
- Fail-fast configuration validation
- Performance optimization through evaluation caching
- Material 3 design
- Combinator dropdown (AND/OR selector)
- Add/remove rules and groups
- Nested group support with unlimited depth

### Documentation
- Complete README with usage examples
- API reference documentation
- Example application
- MIT License

[0.1.0]: https://github.com/yourusername/flutter_querybuilder/releases/tag/v0.1.0
