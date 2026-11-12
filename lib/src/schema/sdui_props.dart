/// Read-only, type-safe view over a node's untyped properties.
///
/// Servers can send the wrong type or omit a value. Every accessor returns
/// `null` instead of throwing in that case, so components can fall back to a
/// sensible default and the screen never crashes on bad data.
final class SduiProps {
  /// Wraps [values], usually `node.props`.
  const SduiProps(this._values);

  final Map<String, Object?> _values;

  /// Whether [key] is present, regardless of its type.
  bool contains(String key) => _values.containsKey(key);

  /// The value for [key] when it is a string, otherwise `null`.
  String? string(String key) {
    final value = _values[key];
    return value is String ? value : null;
  }

  /// The value for [key] when it is any JSON number, as a double.
  double? number(String key) {
    final value = _values[key];
    return value is num ? value.toDouble() : null;
  }

  /// The value for [key] when it is an integer, otherwise `null`.
  int? integer(String key) {
    final value = _values[key];
    return value is int ? value : null;
  }

  /// The value for [key] when it is a boolean, otherwise `null`.
  bool? boolean(String key) {
    final value = _values[key];
    return value is bool ? value : null;
  }
}
