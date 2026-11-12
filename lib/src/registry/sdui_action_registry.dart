import 'dart:async';

import 'package:flutter/widgets.dart';

import '../failures/sdui_failure.dart';
import '../schema/sdui_action.dart';

/// Runs the side effect for a [SduiAction].
///
/// Handlers live in the host app (navigation, analytics, deep links...), so
/// the engine stays free of app-specific code.
typedef SduiActionHandler = FutureOr<void> Function(
  SduiAction action,
  BuildContext context,
);

/// Maps action types to the handlers that execute them.
final class SduiActionRegistry {
  /// Creates a registry, optionally pre-filled with [handlers].
  SduiActionRegistry({Map<String, SduiActionHandler>? handlers})
      : _handlers = <String, SduiActionHandler>{...?handlers};

  final Map<String, SduiActionHandler> _handlers;

  /// Registers [handler] for [type]. A later registration replaces an earlier
  /// one for the same type.
  void register(String type, SduiActionHandler handler) {
    _handlers[type] = handler;
  }

  /// Whether a handler exists for [type].
  bool contains(String type) => _handlers.containsKey(type);

  /// Runs the handler for [action].
  ///
  /// Never throws: an unknown action type or a failing handler is reported to
  /// [onFailure] and the returned future still completes normally.
  Future<void> dispatch(
    SduiAction action,
    BuildContext context, {
    SduiFailureListener? onFailure,
  }) async {
    final handler = _handlers[action.type];
    if (handler == null) {
      onFailure?.call(
        SduiFailure(
          kind: SduiFailureKind.unknownAction,
          message: 'No handler registered for action "${action.type}".',
        ),
      );
      return;
    }
    try {
      await handler(action, context);
    } catch (error) {
      onFailure?.call(
        SduiFailure(
          kind: SduiFailureKind.actionError,
          message: 'Handler for action "${action.type}" threw: $error',
          cause: error,
        ),
      );
    }
  }
}
