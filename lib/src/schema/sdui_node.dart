import 'json_helpers.dart';
import 'sdui_action.dart';
import 'sdui_parse_exception.dart';

/// One element of a server-described UI tree.
///
/// A node is pure data: a component [type], untyped [props], named [actions]
/// and nested [children]. How it looks is decided by the component registered
/// for [type] in the host app.
final class SduiNode {
  /// Creates a node.
  const SduiNode({
    required this.type,
    this.id,
    this.props = const <String, Object?>{},
    this.actions = const <String, SduiAction>{},
    this.children = const <SduiNode>[],
  });

  /// Parses a node (and its subtree) from decoded JSON.
  ///
  /// Unknown fields are ignored so newer servers can add data without breaking
  /// older apps. Throws [SduiParseException] when the shape is invalid or the
  /// tree is deeper than [maxDepth].
  factory SduiNode.fromJson(
    Object? json, {
    String path = r'$',
    int depth = 0,
  }) {
    if (depth > maxDepth) {
      throw SduiParseException(
        'Tree is deeper than the maximum of $maxDepth levels.',
        path: path,
      );
    }
    final map = asJsonObject(json, path);

    final type = map['type'];
    if (type is! String || type.isEmpty) {
      throw SduiParseException(
        'Node "type" must be a non-empty string.',
        path: '$path.type',
      );
    }

    final id = map['id'];
    if (id != null && id is! String) {
      throw SduiParseException('Node "id" must be a string.', path: '$path.id');
    }

    final rawProps = map['props'];
    final props = rawProps == null
        ? const <String, Object?>{}
        : asJsonObject(rawProps, '$path.props');

    final actions = <String, SduiAction>{};
    final rawActions = map['actions'];
    if (rawActions != null) {
      final actionsMap = asJsonObject(rawActions, '$path.actions');
      for (final entry in actionsMap.entries) {
        actions[entry.key] = SduiAction.fromJson(
          entry.value,
          path: '$path.actions.${entry.key}',
        );
      }
    }

    final children = <SduiNode>[];
    final rawChildren = map['children'];
    if (rawChildren != null) {
      if (rawChildren is! List<Object?>) {
        throw SduiParseException(
          'Node "children" must be a list.',
          path: '$path.children',
        );
      }
      for (var i = 0; i < rawChildren.length; i++) {
        children.add(
          SduiNode.fromJson(
            rawChildren[i],
            path: '$path.children[$i]',
            depth: depth + 1,
          ),
        );
      }
    }

    return SduiNode(
      type: type,
      id: id is String ? id : null,
      props: Map<String, Object?>.unmodifiable(props),
      actions: Map<String, SduiAction>.unmodifiable(actions),
      children: List<SduiNode>.unmodifiable(children),
    );
  }

  /// Maximum nesting depth accepted when parsing or rendering a tree.
  ///
  /// Guards against malformed or hostile payloads that would otherwise
  /// exhaust the stack.
  static const int maxDepth = 32;

  /// Component identifier, such as `column` or `button`.
  final String type;

  /// Optional stable identifier, useful for analytics and debugging.
  final String? id;

  /// Untyped properties. Read them through `SduiProps` to get safe defaults.
  final Map<String, Object?> props;

  /// Actions keyed by the event that triggers them, such as `onTap`.
  final Map<String, SduiAction> actions;

  /// Nested nodes, in display order.
  final List<SduiNode> children;

  /// Serializes this node back to a JSON-compatible map.
  Map<String, Object?> toJson() => <String, Object?>{
        'type': type,
        if (id != null) 'id': id,
        if (props.isNotEmpty) 'props': props,
        if (actions.isNotEmpty)
          'actions': <String, Object?>{
            for (final entry in actions.entries)
              entry.key: entry.value.toJson(),
          },
        if (children.isNotEmpty)
          'children': <Object?>[
            for (final child in children) child.toJson(),
          ],
      };
}
