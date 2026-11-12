import 'package:flutter/widgets.dart';

import '../schema/sdui_action.dart';
import '../schema/sdui_node.dart';

/// What a component builder needs from the engine while building a widget.
final class SduiBuildContext {
  /// Creates a build context.
  const SduiBuildContext({required this.context, required this.dispatch});

  /// The Flutter [BuildContext] of the surrounding `SduiView`.
  final BuildContext context;

  /// Sends an action to the registered action handlers.
  final void Function(SduiAction action) dispatch;
}

/// Turns a [SduiNode] into a widget.
///
/// [children] are the already-built widgets for `node.children`, in order.
/// A builder should read props defensively (see `SduiProps`) and never assume
/// the server sent well-formed data.
typedef SduiComponentBuilder = Widget Function(
  SduiBuildContext buildContext,
  SduiNode node,
  List<Widget> children,
);
