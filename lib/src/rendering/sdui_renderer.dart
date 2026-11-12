import 'dart:async';

import 'package:flutter/widgets.dart';

import '../failures/sdui_failure.dart';
import '../registry/sdui_action_registry.dart';
import '../registry/sdui_build_context.dart';
import '../registry/sdui_component_registry.dart';
import '../schema/sdui_node.dart';

/// Turns a [SduiNode] tree into a widget tree.
///
/// Rendering is fail-soft: a node whose type is unknown, whose builder throws,
/// or that sits deeper than [SduiNode.maxDepth] is skipped and reported to
/// [onFailure]. The rest of the screen still renders.
final class SduiRenderer {
  /// Creates a renderer that resolves components in [components] and runs
  /// actions through [actions].
  const SduiRenderer({
    required this.components,
    required this.actions,
    this.onFailure,
  });

  /// Where component builders are looked up.
  final SduiComponentRegistry components;

  /// Where actions are dispatched.
  final SduiActionRegistry actions;

  /// Called for every problem the renderer recovered from.
  final SduiFailureListener? onFailure;

  /// Builds the widget for [node], or returns `null` when the node had to be
  /// skipped.
  Widget? build(BuildContext context, SduiNode node, {int depth = 0}) {
    if (depth > SduiNode.maxDepth) {
      _report(
        SduiFailure(
          kind: SduiFailureKind.maxDepthExceeded,
          message: 'Node is deeper than ${SduiNode.maxDepth} levels.',
          nodeType: node.type,
          nodeId: node.id,
        ),
      );
      return null;
    }

    final builder = components.builderFor(node.type);
    if (builder == null) {
      _report(
        SduiFailure(
          kind: SduiFailureKind.unknownComponent,
          message: 'No component registered for type "${node.type}".',
          nodeType: node.type,
          nodeId: node.id,
        ),
      );
      return null;
    }

    final children = <Widget>[];
    for (final child in node.children) {
      final built = build(context, child, depth: depth + 1);
      if (built != null) {
        children.add(built);
      }
    }

    try {
      return builder(
        SduiBuildContext(
          context: context,
          dispatch: (action) => unawaited(
            actions.dispatch(action, context, onFailure: onFailure),
          ),
        ),
        node,
        children,
      );
    } catch (error) {
      _report(
        SduiFailure(
          kind: SduiFailureKind.componentError,
          message: 'Component "${node.type}" threw while building: $error',
          nodeType: node.type,
          nodeId: node.id,
          cause: error,
        ),
      );
      return null;
    }
  }

  void _report(SduiFailure failure) => onFailure?.call(failure);
}
