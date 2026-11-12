import 'json_helpers.dart';
import 'sdui_parse_exception.dart';

/// A named side effect requested by the server, such as `navigate` or `track`.
///
/// The engine never interprets an action itself: it only forwards it to the
/// handler the host app registered for [type].
final class SduiAction {
  /// Creates an action of the given [type] with optional [params].
  const SduiAction({
    required this.type,
    this.params = const <String, Object?>{},
  });

  /// Parses an action from decoded JSON.
  ///
  /// Throws [SduiParseException] when the shape is invalid.
  factory SduiAction.fromJson(Object? json, {String path = r'$'}) {
    final map = asJsonObject(json, path);
    final type = map['type'];
    if (type is! String || type.isEmpty) {
      throw SduiParseException(
        'Action "type" must be a non-empty string.',
        path: '$path.type',
      );
    }
    final rawParams = map['params'];
    final params = rawParams == null
        ? const <String, Object?>{}
        : asJsonObject(rawParams, '$path.params');
    return SduiAction(
      type: type,
      params: Map<String, Object?>.unmodifiable(params),
    );
  }

  /// Identifies which registered handler runs this action.
  final String type;

  /// Free-form arguments for the handler.
  final Map<String, Object?> params;

  /// Serializes this action back to a JSON-compatible map.
  Map<String, Object?> toJson() => <String, Object?>{
        'type': type,
        if (params.isNotEmpty) 'params': params,
      };
}
