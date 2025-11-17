/// Exception thrown when the query builder configuration is invalid
/// to fail-fast and help developers identify configuration issues early.
class ConfigurationException implements Exception {
  final String message;
  const ConfigurationException(this.message);

  @override
  String toString() => 'ConfigurationException: $message';
}

/// Exception thrown when query evaluation fails.
class EvaluationException implements Exception {
  final String message;
  final Object? cause;
  const EvaluationException(this.message, [this.cause]);

  @override
  String toString() =>
      cause != null ? 'EvaluationException: $message\nCaused by: $cause' : 'EvaluationException: $message';
}
