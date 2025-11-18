import 'package:flutter/material.dart';

import 'models.dart';
import 'query_builder_controller.dart';
import 'serializer.dart';

// ============================================================================
// Query Builder Scope (InheritedWidget)
// ============================================================================

/// Internal InheritedWidget for passing query builder context down the widget tree.
///
/// Provides controller to descendant widgets without prop drilling.
class _QueryBuilderScope extends InheritedWidget {
  final QueryBuilderController controller;

  const _QueryBuilderScope({
    required this.controller,
    required super.child,
  });

  static _QueryBuilderScope of(BuildContext context) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<_QueryBuilderScope>();
    assert(scope != null, 'No _QueryBuilderScope found in context');
    return scope!;
  }

  @override
  bool updateShouldNotify(_QueryBuilderScope oldWidget) {
    return controller != oldWidget.controller;
  }
}

// ============================================================================
// QueryBuilder - Main Widget
// ============================================================================

/// The main query builder widget.
///
/// This widget provides a user interface for building complex queries with
/// nested groups and operators. The configuration is validated when the
/// controller is created.
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
class QueryBuilder extends StatelessWidget {
  /// The controller that manages the query builder state
  final QueryBuilderController controller;

  /// Creates a new query builder widget.
  ///
  /// The [controller] must not be null and should have valid field configurations.
  const QueryBuilder({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        return _QueryBuilderScope(
          controller: controller,
          child: QueryGroupWidget(
            group: controller.query,
            isRoot: true,
          ),
        );
      },
    );
  }
}

// ============================================================================
// QueryGroupWidget - Group Widget
// ============================================================================

/// Widget for displaying and editing a query group.
///
/// Supports nested groups and AND/OR combinator selection.
class QueryGroupWidget extends StatefulWidget {
  final QueryGroup group;
  final bool isRoot;
  final void Function(QueryGroup)? onChanged;

  const QueryGroupWidget({
    super.key,
    required this.group,
    this.isRoot = false,
    this.onChanged,
  });

  @override
  State<QueryGroupWidget> createState() => _QueryGroupWidgetState();
}

class _QueryGroupWidgetState extends State<QueryGroupWidget> {
  late QueryGroup _group;
  QueryBuilderController? _controller;

  @override
  void initState() {
    super.initState();
    _group = widget.group;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _controller ??= _QueryBuilderScope.of(context).controller;
  }

  @override
  void didUpdateWidget(QueryGroupWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.group != oldWidget.group) {
      _group = widget.group;
    }
  }

  void _notifyChanged() {
    if (widget.isRoot && _controller != null) {
      // Root widget updates the controller directly
      _controller!.updateQuery(_group);
    } else if (widget.onChanged != null) {
      // Nested widgets update their parent via callback
      widget.onChanged!(_group);
    }
  }

  void _updateCombinator(Combinator? combinator) {
    if (combinator == null) return;
    setState(() {
      _group = _group.copyWith(combinator: combinator);
    });
    _notifyChanged();
  }

  void _addRule() {
    if (_controller == null) return;
    final firstField = _controller!.fields.first;
    final defaultOperator = firstField.defaultOperator ?? firstField.operators.first;
    final defaultValue = firstField.defaultValue ?? '';

    final newRule = QueryRule(
      field: firstField.name,
      operator: defaultOperator.name,
      value: defaultValue,
    );

    setState(() {
      _group = _group.copyWith(
        rules: [..._group.rules, newRule],
      );
    });
    _notifyChanged();
  }

  void _addGroup() {
    const newGroup = QueryGroup(
      combinator: Combinator.and,
      rules: [],
      groups: [],
    );

    setState(() {
      _group = _group.copyWith(
        groups: [..._group.groups, newGroup],
      );
    });
    _notifyChanged();
  }

  void _removeRule(int index) {
    setState(() {
      final rules = List<QueryRule>.from(_group.rules);
      rules.removeAt(index);
      _group = _group.copyWith(rules: rules);
    });
    _notifyChanged();
  }

  void _updateRule(int index, QueryRule rule) {
    setState(() {
      final rules = List<QueryRule>.from(_group.rules);
      rules[index] = rule;
      _group = _group.copyWith(rules: rules);
    });
    _notifyChanged();
  }

  void _removeGroup(int index) {
    setState(() {
      final groups = List<QueryGroup>.from(_group.groups);
      groups.removeAt(index);
      _group = _group.copyWith(groups: groups);
    });
    _notifyChanged();
  }

  void _updateGroup(int index, QueryGroup group) {
    setState(() {
      final groups = List<QueryGroup>.from(_group.groups);
      groups[index] = group;
      _group = _group.copyWith(groups: groups);
    });
    _notifyChanged();
  }


  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;

        return Card(
          margin: widget.isRoot ? EdgeInsets.zero : const EdgeInsets.all(4.0),
          elevation: widget.isRoot ? 0 : 2,
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Combinator selector and action buttons
                Row(
                  children: [
                    DropdownButton<Combinator>(
                      value: _group.combinator,
                      items: const [
                        DropdownMenuItem(value: Combinator.and, child: Text('All (AND)')),
                        DropdownMenuItem(value: Combinator.or, child: Text('Any (OR)')),
                      ],
                      onChanged: _updateCombinator,
                      isDense: true,
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: _addRule,
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text('Add Rule', style: TextStyle(fontSize: 12)),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                    const SizedBox(width: 6),
                    OutlinedButton.icon(
                      onPressed: _addGroup,
                      icon: const Icon(Icons.add_box, size: 16),
                      label: const Text('Add Group', style: TextStyle(fontSize: 12)),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                    const Spacer(),
                    if (!widget.isRoot)
                      IconButton(
                        icon: const Icon(Icons.delete, size: 18),
                        onPressed: () {
                          // Parent will handle removal
                        },
                        tooltip: 'Remove Group',
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                  ],
                ),
                const SizedBox(height: 10),

                // Rules
                ...List.generate(_group.rules.length, (index) {
                  return Padding(
                    key: ValueKey('rule_$index'),
                    padding: const EdgeInsets.only(bottom: 6.0),
                    child: QueryRuleWidget(
                      key: ValueKey('rule_widget_$index'),
                      rule: _group.rules[index],
                      onChanged: (rule) => _updateRule(index, rule),
                      onRemove: () => _removeRule(index),
                      isMobile: isMobile,
                    ),
                  );
                }),

                // Nested groups
                ...List.generate(_group.groups.length, (index) {
                  return Padding(
                    key: ValueKey('group_${_group.groups[index].hashCode}'),
                    padding: const EdgeInsets.only(bottom: 6.0),
                    child: Stack(
                      children: [
                        QueryGroupWidget(
                          group: _group.groups[index],
                          onChanged: (group) => _updateGroup(index, group),
                        ),
                        Positioned(
                          top: 10,
                          right: 10,
                          child: IconButton(
                            icon: const Icon(Icons.delete, size: 18),
                            onPressed: () => _removeGroup(index),
                            tooltip: 'Remove Group',
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ============================================================================
// QueryRuleWidget - Rule Widget
// ============================================================================

/// Widget for displaying and editing a single query rule.
class QueryRuleWidget extends StatefulWidget {
  final QueryRule rule;
  final void Function(QueryRule) onChanged;
  final VoidCallback onRemove;
  final bool isMobile;

  const QueryRuleWidget({
    super.key,
    required this.rule,
    required this.onChanged,
    required this.onRemove,
    this.isMobile = false,
  });

  @override
  State<QueryRuleWidget> createState() => _QueryRuleWidgetState();
}

class _QueryRuleWidgetState extends State<QueryRuleWidget> {
  late QueryRule _rule;
  late TextEditingController _valueController;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _rule = widget.rule;
    _valueController = TextEditingController(text: _rule.value?.toString() ?? '');
    // Notify parent when focus is lost
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        widget.onChanged(_rule);
      }
    });
  }

  @override
  void didUpdateWidget(QueryRuleWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.rule != oldWidget.rule) {
      _rule = widget.rule;
      final newValue = _rule.value?.toString() ?? '';
      // Only update controller if value actually changed to avoid losing focus
      if (_valueController.text != newValue) {
        _valueController.text = newValue;
      }
    }
  }

  @override
  void dispose() {
    _valueController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Field _getCurrentField() {
    final scope = _QueryBuilderScope.of(context);
    return scope.controller.fields.firstWhere(
      (f) => f.name == _rule.field,
      orElse: () => scope.controller.fields.first,
    );
  }

  void _updateField(String? fieldName) {
    if (fieldName == null) return;

    final scope = _QueryBuilderScope.of(context);
    final field = scope.controller.fields.firstWhere((f) => f.name == fieldName);
    final defaultOperator = field.defaultOperator ?? field.operators.first;
    final defaultValue = field.defaultValue ?? '';

    setState(() {
      _rule = QueryRule(
        field: fieldName,
        operator: defaultOperator.name,
        value: defaultValue,
      );
      _valueController.text = defaultValue?.toString() ?? '';
    });
    widget.onChanged(_rule);
  }

  void _updateOperator(String? operatorName) {
    if (operatorName == null) return;
    setState(() {
      _rule = _rule.copyWith(operator: operatorName);
    });
    widget.onChanged(_rule);
  }

  void _updateValue(dynamic value) {
    setState(() {
      _rule = _rule.copyWith(value: value);
    });
    // Don't call widget.onChanged here - only update local state
    // Parent will be notified when editing completes
  }

  void _notifyParent() {
    widget.onChanged(_rule);
  }

  Widget _buildValueInput(Field field) {
    switch (field.inputType) {
      case InputType.text:
        return TextField(
          controller: _valueController,
          focusNode: _focusNode,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            isDense: true,
            contentPadding: EdgeInsets.all(8),
          ),
          style: const TextStyle(fontSize: 13),
          onChanged: (value) {
            _updateValue(value);
          },
          onEditingComplete: _notifyParent,
          onSubmitted: (_) => _notifyParent(),
        );

      case InputType.number:
        return TextField(
          controller: _valueController,
          focusNode: _focusNode,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            isDense: true,
            contentPadding: EdgeInsets.all(8),
          ),
          style: const TextStyle(fontSize: 13),
          keyboardType: TextInputType.number,
          onChanged: (value) {
            final num = int.tryParse(value) ?? double.tryParse(value);
            _updateValue(num ?? value);
          },
          onEditingComplete: _notifyParent,
          onSubmitted: (_) => _notifyParent(),
        );

      case InputType.date:
        return OutlinedButton(
          onPressed: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: _rule.value is DateTime
                  ? _rule.value as DateTime
                  : DateTime.now(),
              firstDate: DateTime(1900),
              lastDate: DateTime(2100),
            );
            if (date != null) {
              _valueController.text = date.toIso8601String().split('T')[0];
              _updateValue(date);
              _notifyParent();
            }
          },
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            _rule.value is DateTime
                ? (_rule.value as DateTime).toIso8601String().split('T')[0]
                : 'Select Date',
            style: const TextStyle(fontSize: 13),
          ),
        );

      case InputType.select:
        return DropdownButton<String>(
          value: field.options?.contains(_rule.value?.toString())  == true
              ? _rule.value?.toString()
              : field.options?.firstOrNull,
          items: field.options
                  ?.map((option) => DropdownMenuItem(
                        value: option,
                        child: Text(option, style: const TextStyle(fontSize: 13)),
                      ))
                  .toList() ??
              [],
          onChanged: (value) {
            if (value != null) {
              _valueController.text = value;
              _updateValue(value);
              _notifyParent();
            }
          },
          isExpanded: true,
          isDense: true,
        );

      case InputType.boolean:
        return Checkbox(
          value: _rule.value == true || _rule.value == 'true',
          onChanged: (value) {
            _valueController.text = value.toString();
            _updateValue(value ?? false);
            _notifyParent();
          },
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final field = _getCurrentField();
    final scope = _QueryBuilderScope.of(context);

    if (widget.isMobile) {
      // Vertical layout for mobile
      final theme = Theme.of(context);
      final isDark = theme.brightness == Brightness.dark;
      return Container(
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: isDark ? theme.colorScheme.surfaceContainerHighest : Colors.grey[50],
          borderRadius: BorderRadius.circular(4),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Field selector
            DropdownButton<String>(
              value: _rule.field,
              items: scope.controller.fields
                  .map((f) => DropdownMenuItem(
                        value: f.name,
                        child: Text(f.label, style: const TextStyle(fontSize: 13)),
                      ))
                  .toList(),
              onChanged: _updateField,
              isExpanded: true,
              isDense: true,
            ),
            const SizedBox(height: 6),

            // Operator selector
            DropdownButton<String>(
              value: _rule.operator,
              items: field.operators
                  .map((op) => DropdownMenuItem(
                        value: op.name,
                        child: Text(op.label, style: const TextStyle(fontSize: 13)),
                      ))
                  .toList(),
              onChanged: _updateOperator,
              isExpanded: true,
              isDense: true,
            ),
            const SizedBox(height: 6),

            // Value input
            _buildValueInput(field),
            const SizedBox(height: 6),

            // Remove button
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                icon: const Icon(Icons.delete, size: 18),
                onPressed: widget.onRemove,
                tooltip: 'Remove Rule',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ),
          ],
        ),
      );
    } else {
      // Horizontal layout for desktop
      final theme = Theme.of(context);
      final isDark = theme.brightness == Brightness.dark;
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: isDark ? theme.colorScheme.surfaceContainerHighest : Colors.grey[50],
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          children: [
            // Field selector
            Expanded(
              flex: 2,
              child: DropdownButton<String>(
                value: _rule.field,
                items: scope.controller.fields
                    .map((f) => DropdownMenuItem(
                          value: f.name,
                          child: Text(f.label, style: const TextStyle(fontSize: 13)),
                        ))
                    .toList(),
                onChanged: _updateField,
                isExpanded: true,
                isDense: true,
              ),
            ),
            const SizedBox(width: 8),

            // Operator selector
            Expanded(
              flex: 2,
              child: DropdownButton<String>(
                value: _rule.operator,
                items: field.operators
                    .map((op) => DropdownMenuItem(
                          value: op.name,
                          child: Text(op.label, style: const TextStyle(fontSize: 13)),
                        ))
                    .toList(),
                onChanged: _updateOperator,
                isExpanded: true,
                isDense: true,
              ),
            ),
            const SizedBox(width: 8),

            // Value input
            Expanded(
              flex: 3,
              child: _buildValueInput(field),
            ),
            const SizedBox(width: 6),

            // Remove button
            IconButton(
              icon: const Icon(Icons.delete, size: 18),
              onPressed: widget.onRemove,
              tooltip: 'Remove Rule',
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
      );
    }
  }
}

// ============================================================================
// JsonViewerWidget - JSON Display with Import/Copy Buttons
// ============================================================================

/// Widget for displaying JSON with import and copy functionality.
///
/// The buttons are positioned at the top right of the JSON display area.
/// Automatically subscribes to the controller to display current query JSON.
class JsonViewerWidget extends StatelessWidget {
  /// The query builder controller to subscribe to
  final QueryBuilderController controller;

  /// Callback when import button is pressed
  final Future<void> Function()? onImport;

  /// Callback when copy button is pressed
  final Future<void> Function()? onCopy;

  /// Whether the JSON text should be selectable
  final bool selectable;

  /// Creates a JSON viewer widget.
  const JsonViewerWidget({
    super.key,
    required this.controller,
    this.onImport,
    this.onCopy,
    this.selectable = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final json = QuerySerializer.toJsonString(controller.query, pretty: true);
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;
        return Container(
          decoration: BoxDecoration(
            color: isDark ? theme.colorScheme.surfaceContainerHigh : Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isDark ? theme.colorScheme.outline.withOpacity(0.5) : Colors.grey[300]!,
            ),
          ),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: selectable
                    ? SelectableText(
                        json,
                        style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                      )
                    : Text(
                        json,
                        style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                      ),
              ),
              if (onImport != null || onCopy != null)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (onImport != null)
                        IconButton.outlined(
                          icon: const Icon(Icons.content_paste, size: 18),
                          onPressed: onImport,
                          tooltip: 'Import from Clipboard',
                          style: IconButton.styleFrom(
                            padding: const EdgeInsets.all(8),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                        ),
                      if (onImport != null && onCopy != null)
                        const SizedBox(width: 4),
                      if (onCopy != null)
                        IconButton.outlined(
                          icon: const Icon(Icons.content_copy, size: 18),
                          onPressed: onCopy,
                          tooltip: 'Copy to Clipboard',
                          style: IconButton.styleFrom(
                            padding: const EdgeInsets.all(8),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                        ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

// ============================================================================
// SampleDataViewerWidget - Generic Sample Data Display
// ============================================================================

/// Widget for displaying sample data in a generic way.
///
/// Automatically formats data using JSON representation for all fields.
class SampleDataViewerWidget extends StatelessWidget {
  /// List of sample data records to display
  final List<Map<String, dynamic>> sampleData;

  /// Optional title for the viewer
  final String? title;

  /// Creates a sample data viewer widget.
  const SampleDataViewerWidget({
    super.key,
    required this.sampleData,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark 
            ? theme.colorScheme.primaryContainer.withOpacity(0.3)
            : Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark 
              ? theme.colorScheme.primary.withOpacity(0.5)
              : Colors.blue[200]!,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Text(
              title!,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 8),
          ],
          Text(
            'Testing against ${sampleData.length} sample record(s):',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ...sampleData.asMap().entries.map((entry) {
            final index = entry.key;
            final data = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 6.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${index + 1}. ',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  Expanded(
                    child: Text(
                      _formatData(data),
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  String _formatData(Map<String, dynamic> data) {
    // Convert to JSON string, remove braces, and format nicely
    final jsonString = data.entries
        .map((e) => '${e.key}: ${_formatValue(e.value)}')
        .join(', ');
    return jsonString;
  }

  String _formatValue(dynamic value) {
    if (value is DateTime) {
      return value.toIso8601String().split('T')[0];
    } else if (value is bool) {
      return value.toString();
    } else if (value is num) {
      return value.toString();
    } else {
      return value.toString();
    }
  }
}

// ============================================================================
// EvaluationResultWidget - Query Evaluation Results Display
// ============================================================================

/// Widget for displaying query evaluation results.
class EvaluationResultWidget extends StatelessWidget {
  /// The evaluation result message
  final String result;

  /// Whether to show the widget (if result is empty, widget is hidden)
  final bool show;

  /// Creates an evaluation result widget.
  const EvaluationResultWidget({
    super.key,
    required this.result,
    this.show = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!show || result.isEmpty) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark 
            ? theme.colorScheme.tertiaryContainer.withOpacity(0.3)
            : Colors.green[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark 
              ? theme.colorScheme.tertiary.withOpacity(0.5)
              : Colors.green[200]!,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Evaluation Result',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            result,
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }
}

