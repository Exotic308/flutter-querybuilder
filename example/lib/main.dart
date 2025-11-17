import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_querybuilder/flutter_querybuilder.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Query Builder Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue, brightness: Brightness.light),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue, brightness: Brightness.dark),
        useMaterial3: true,
      ),
      themeMode: ThemeMode.system,
      home: const ExampleScreen(),
    );
  }
}

class ExampleScreen extends StatefulWidget {
  const ExampleScreen({super.key});

  @override
  State<ExampleScreen> createState() => _ExampleScreenState();
}

class _ExampleScreenState extends State<ExampleScreen> {
  late final QueryBuilderController _controller;
  String _evaluationResult = '';
  final sampleData = [
    {'name': 'John Doe', 'age': 30, 'birthDate': DateTime(1993, 5, 15), 'status': 'active', 'isVerified': true},
    {'name': 'Jane Smith', 'age': 25, 'birthDate': DateTime(1998, 8, 22), 'status': 'active', 'isVerified': false},
    {'name': 'Bob Johnson', 'age': 45, 'birthDate': DateTime(1978, 3, 10), 'status': 'inactive', 'isVerified': true},
    {'name': 'Alice Williams', 'age': 35, 'birthDate': DateTime(1988, 11, 5), 'status': 'pending', 'isVerified': true},
  ];

  @override
  void initState() {
    super.initState();
    _initQueryBuilderController();
  }

  void _initQueryBuilderController() {
    var fields = [
      Field(
        name: 'name',
        label: 'Name',
        inputType: InputType.text,
        operators: const [equals, notEquals, contains, startsWith, endsWith],
        defaultValue: '',
      ),
      Field(
        name: 'age',
        label: 'Age',
        inputType: InputType.number,
        operators: const [equals, notEquals, greaterThan, lessThan, greaterOrEqual, lessOrEqual],
        defaultOperator: greaterThan,
        defaultValue: 18,
      ),
      Field(
        name: 'birthDate',
        label: 'Birth Date',
        inputType: InputType.date,
        operators: const [equals, greaterThan, lessThan, greaterOrEqual, lessOrEqual],
      ),
      Field(
        name: 'status',
        label: 'Status',
        inputType: InputType.select,
        options: const ['active', 'inactive', 'pending'],
        operators: const [equals, notEquals, inList, notInList],
        defaultOperator: equals,
        defaultValue: 'active',
      ),
      Field(
        name: 'isVerified',
        label: 'Is Verified',
        inputType: InputType.boolean,
        operators: const [equals, notEquals],
        defaultValue: true,
      ),
    ];

    var initialQuery = QueryGroup(
      combinator: Combinator.and,
      rules: [
        QueryRule(
          field: fields.first.name,
          operator: fields.first.operators.first.name,
          value: fields.first.defaultValue ?? '',
        ),
      ],
      groups: const [],
    );

    _controller = QueryBuilderController(fields: fields, initialQuery: initialQuery);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _evaluateQuery() {
    final evaluator = QueryEvaluator();
    final matches = <Map<String, dynamic>>[];

    for (final data in sampleData) {
      try {
        var result = evaluator.evaluate(_controller.query, data);
        if (result) matches.add(data);
      } catch (e) {
        setState(() {
          _evaluationResult = 'Error evaluating query: $e';
        });
        return;
      }
    }

    setState(() {
      try {
        _evaluationResult = 'Found ${matches.length} match(es):\n\n';
        for (final match in matches) {
          _evaluationResult += '${_formatMatch(match)}\n';
        }
      } catch (e) {
        _evaluationResult = 'Error evaluating query: $e';
      }
    });
  }

  String _formatMatch(Map<String, dynamic> match) {
    return match.entries.map((e) => '${e.key}: ${e.value}').join(', ');
  }

  Future<void> _importJson() async {
    try {
      final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
      if (clipboardData == null || clipboardData.text == null || clipboardData.text!.isEmpty) {
        _showSnackBar('Clipboard is empty', Colors.orange);
        return;
      }

      try {
        final query = QuerySerializer.fromJsonString(clipboardData.text!);
        _controller.updateQuery(query);
        _showSnackBar('Query imported successfully from clipboard', Colors.green);
      } catch (e) {
        _showSnackBar('Error importing JSON: Invalid format', Colors.red);
      }
    } catch (e) {
      _showSnackBar('Error importing JSON: $e', Colors.red);
    }
  }

  Future<void> _exportJson() async {
    try {
      final json = QuerySerializer.toJsonString(_controller.query, pretty: true);
      await Clipboard.setData(ClipboardData(text: json));
      _showSnackBar('JSON copied to clipboard', Colors.green);
    } catch (e) {
      _showSnackBar('Error copying JSON: $e', Colors.red);
    }
  }

  void _showSnackBar(String message, Color backgroundColor) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: backgroundColor));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Flutter Query Builder Demo'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Query Builder', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            QueryBuilder(controller: _controller),
            const SizedBox(height: 32),

            const Text('JSON Output', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            JsonViewerWidget(controller: _controller, onImport: _importJson, onCopy: _exportJson),
            const SizedBox(height: 24),

            const Text('Sample Data', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            SampleDataViewerWidget(sampleData: sampleData),
            const SizedBox(height: 24),

            ElevatedButton.icon(
              onPressed: _evaluateQuery,
              icon: const Icon(Icons.play_arrow),
              label: const Text('Evaluate Against Sample Data'),
            ),
            const SizedBox(height: 24),

            // Evaluation Results Section
            EvaluationResultWidget(result: _evaluationResult),
          ],
        ),
      ),
    );
  }
}
