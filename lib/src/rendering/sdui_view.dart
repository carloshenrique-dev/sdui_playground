import 'package:flutter/widgets.dart';

import '../failures/sdui_failure.dart';
import '../registry/sdui_action_registry.dart';
import '../registry/sdui_component_registry.dart';
import '../schema/sdui_document.dart';
import '../schema/sdui_parse_exception.dart';
import 'sdui_renderer.dart';

/// Builds the widget shown when the whole document cannot be rendered.
typedef SduiFallbackBuilder = Widget Function(
  BuildContext context,
  SduiFailure failure,
);

/// Renders a server-described screen.
///
/// Give it either an already-parsed [SduiDocument] or raw decoded JSON through
/// [SduiView.fromJson]. If the document is malformed or uses a schema version
/// newer than the engine supports, [fallbackBuilder] is shown instead of
/// crashing, and the problem is reported to [onFailure].
class SduiView extends StatelessWidget {
  /// Renders an already-parsed [document].
  const SduiView({
    super.key,
    required SduiDocument this.document,
    required this.components,
    required this.actions,
    this.onFailure,
    this.fallbackBuilder,
  }) : json = null;

  /// Parses [json] (for example the result of `jsonDecode`) and renders it.
  ///
  /// Parsing happens in `build`, so prefer parsing once and using the default
  /// constructor when the same payload is rebuilt often.
  const SduiView.fromJson({
    super.key,
    required this.json,
    required this.components,
    required this.actions,
    this.onFailure,
    this.fallbackBuilder,
  }) : document = null;

  /// The parsed document, when built with the default constructor.
  final SduiDocument? document;

  /// The raw JSON, when built with [SduiView.fromJson].
  final Object? json;

  /// Component builders available to this view.
  final SduiComponentRegistry components;

  /// Action handlers available to this view.
  final SduiActionRegistry actions;

  /// Receives every problem the engine recovered from.
  final SduiFailureListener? onFailure;

  /// Shown when the whole document cannot be rendered. Defaults to an empty
  /// box.
  final SduiFallbackBuilder? fallbackBuilder;

  @override
  Widget build(BuildContext context) {
    final SduiDocument parsed;
    final parsedDocument = document;
    if (parsedDocument != null) {
      parsed = parsedDocument;
    } else {
      try {
        parsed = SduiDocument.fromJson(json);
      } on SduiUnsupportedVersionException catch (error) {
        return _fallback(
          context,
          SduiFailure(
            kind: SduiFailureKind.unsupportedVersion,
            message: error.toString(),
            cause: error,
          ),
        );
      } on SduiParseException catch (error) {
        return _fallback(
          context,
          SduiFailure(
            kind: SduiFailureKind.invalidDocument,
            message: error.toString(),
            cause: error,
          ),
        );
      }
    }

    final renderer = SduiRenderer(
      components: components,
      actions: actions,
      onFailure: onFailure,
    );
    final rendered = renderer.build(context, parsed.root);
    if (rendered == null) {
      return _fallback(
        context,
        SduiFailure(
          kind: SduiFailureKind.invalidDocument,
          message: 'The root node could not be rendered.',
          nodeType: parsed.root.type,
          nodeId: parsed.root.id,
        ),
      );
    }
    return rendered;
  }

  Widget _fallback(BuildContext context, SduiFailure failure) {
    onFailure?.call(failure);
    final builder = fallbackBuilder;
    return builder == null
        ? const SizedBox.shrink()
        : builder(context, failure);
  }
}
