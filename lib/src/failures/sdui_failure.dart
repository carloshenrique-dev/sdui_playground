/// The category of a problem the engine recovered from.
enum SduiFailureKind {
  /// The whole document is malformed and could not be parsed.
  invalidDocument,

  /// The document declares a schema version newer than the engine supports.
  unsupportedVersion,

  /// A node uses a component type that is not registered. The node is skipped.
  unknownComponent,

  /// A component builder threw while building a node. The node is skipped.
  componentError,

  /// The tree is deeper than the allowed maximum. Deeper nodes are skipped.
  maxDepthExceeded,

  /// An action was dispatched but no handler is registered for its type.
  unknownAction,

  /// An action handler threw an error.
  actionError,
}

/// A problem the engine recovered from, reported through [SduiFailureListener].
///
/// The engine never lets these crash the screen; it degrades gracefully and
/// tells the host app so it can log or alert.
final class SduiFailure {
  /// Creates a failure report.
  const SduiFailure({
    required this.kind,
    required this.message,
    this.nodeType,
    this.nodeId,
    this.cause,
  });

  /// What category of problem happened.
  final SduiFailureKind kind;

  /// Human-readable description.
  final String message;

  /// Component type of the node involved, when there is one.
  final String? nodeType;

  /// Identifier of the node involved, when it has one.
  final String? nodeId;

  /// The underlying error or exception, when there is one.
  final Object? cause;

  @override
  String toString() => 'SduiFailure(${kind.name}): $message';
}

/// Receives every [SduiFailure].
///
/// It can be called while a widget is building, so use it for logging and
/// telemetry. Do not trigger a synchronous rebuild from inside it.
typedef SduiFailureListener = void Function(SduiFailure failure);
