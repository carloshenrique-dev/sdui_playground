/// Thrown when a JSON payload does not conform to the SDUI schema.
class SduiParseException implements Exception {
  /// Creates an exception with a human-readable [message] and the JSON [path]
  /// where the problem was found (for example `$.root.children[1].type`).
  const SduiParseException(this.message, {this.path = r'$'});

  /// What is wrong with the payload.
  final String message;

  /// JSON path of the offending value.
  final String path;

  @override
  String toString() => 'SduiParseException at $path: $message';
}

/// Thrown when a document declares a `schemaVersion` newer than the one this
/// engine understands.
///
/// It is a separate type so callers can show an "update the app" experience
/// instead of treating it as a malformed payload.
class SduiUnsupportedVersionException extends SduiParseException {
  /// Creates an exception for a document with [received] version while the
  /// engine only supports up to [supported].
  SduiUnsupportedVersionException({
    required this.received,
    required this.supported,
  }) : super(
          'Schema version $received is newer than the supported version '
          '$supported.',
          path: r'$.schemaVersion',
        );

  /// The version found in the document.
  final int received;

  /// The highest version this engine supports.
  final int supported;
}
