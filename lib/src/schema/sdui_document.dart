import 'json_helpers.dart';
import 'sdui_node.dart';
import 'sdui_parse_exception.dart';

/// A complete server-described screen: a schema version plus a root node.
final class SduiDocument {
  /// Creates a document.
  const SduiDocument({required this.schemaVersion, required this.root});

  /// Parses a document from decoded JSON (for example the result of
  /// `jsonDecode`).
  ///
  /// Throws [SduiUnsupportedVersionException] when `schemaVersion` is newer
  /// than [supportedSchemaVersion], and [SduiParseException] for any other
  /// shape problem. The version is checked before the tree is parsed, because
  /// a newer schema may legitimately have a different tree shape.
  factory SduiDocument.fromJson(Object? json) {
    final map = asJsonObject(json, r'$');

    final version = map['schemaVersion'];
    if (version is! int || version < 1) {
      throw const SduiParseException(
        '"schemaVersion" must be an integer greater than or equal to 1.',
        path: r'$.schemaVersion',
      );
    }
    if (version > supportedSchemaVersion) {
      throw SduiUnsupportedVersionException(
        received: version,
        supported: supportedSchemaVersion,
      );
    }
    if (!map.containsKey('root')) {
      throw const SduiParseException(
        '"root" is required.',
        path: r'$.root',
      );
    }

    return SduiDocument(
      schemaVersion: version,
      root: SduiNode.fromJson(map['root'], path: r'$.root'),
    );
  }

  /// Highest schema version this engine can render.
  static const int supportedSchemaVersion = 1;

  /// Schema version the document was authored against.
  final int schemaVersion;

  /// Top of the UI tree.
  final SduiNode root;

  /// Serializes this document back to a JSON-compatible map.
  Map<String, Object?> toJson() => <String, Object?>{
        'schemaVersion': schemaVersion,
        'root': root.toJson(),
      };
}
