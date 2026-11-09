/// A business rule was violated. The message is written for the owner and is
/// safe to show directly in the UI.
class RuleException implements Exception {
  RuleException(this.message);
  final String message;

  @override
  String toString() => message;
}
