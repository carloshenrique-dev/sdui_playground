/// A small, generic Server-Driven UI engine for Flutter.
///
/// The server sends a versioned JSON document describing a screen; the app
/// renders it with components and action handlers it registered itself.
///
/// ```dart
/// final components = SduiComponentRegistry.withDefaults();
/// final actions = SduiActionRegistry()
///   ..register('navigate', (action, context) {
///     Navigator.of(context).pushNamed(action.params['route'] as String);
///   });
///
/// SduiView.fromJson(
///   json: jsonDecode(payload),
///   components: components,
///   actions: actions,
/// );
/// ```
library;

export 'src/failures/sdui_failure.dart';
export 'src/registry/sdui_action_registry.dart';
export 'src/registry/sdui_build_context.dart';
export 'src/registry/sdui_component_registry.dart';
export 'src/rendering/sdui_renderer.dart';
export 'src/rendering/sdui_view.dart';
export 'src/schema/sdui_action.dart';
export 'src/schema/sdui_document.dart';
export 'src/schema/sdui_node.dart';
export 'src/schema/sdui_parse_exception.dart';
export 'src/schema/sdui_props.dart';
