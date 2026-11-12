import 'sdui_parse_exception.dart';

/// Validates that [value] is a JSON object with string keys and returns it as
/// a `Map<String, Object?>`.
///
/// Throws [SduiParseException] at [path] otherwise.
Map<String, Object?> asJsonObject(Object? value, String path) {
  if (value is! Map<Object?, Object?>) {
    throw SduiParseException('Expected a JSON object.', path: path);
  }
  final result = <String, Object?>{};
  for (final entry in value.entries) {
    final key = entry.key;
    if (key is! String) {
      throw SduiParseException('Object keys must be strings.', path: path);
    }
    result[key] = entry.value;
  }
  return result;
}
