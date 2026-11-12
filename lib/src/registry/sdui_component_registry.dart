import '../components/built_in_components.dart';
import 'sdui_build_context.dart';

/// Maps component types (the `type` field of a node) to widget builders.
final class SduiComponentRegistry {
  /// Creates a registry, optionally pre-filled with [builders].
  SduiComponentRegistry({Map<String, SduiComponentBuilder>? builders})
      : _builders = <String, SduiComponentBuilder>{...?builders};

  /// Creates a registry with the built-in components already registered:
  /// `column`, `row`, `text`, `button`, `card`, `padding`, `spacer` and
  /// `divider`.
  factory SduiComponentRegistry.withDefaults() {
    final registry = SduiComponentRegistry();
    registerBuiltInComponents(registry);
    return registry;
  }

  final Map<String, SduiComponentBuilder> _builders;

  /// Registers [builder] for [type]. A later registration replaces an earlier
  /// one for the same type, which is how an app overrides a built-in.
  void register(String type, SduiComponentBuilder builder) {
    _builders[type] = builder;
  }

  /// Whether a builder exists for [type].
  bool contains(String type) => _builders.containsKey(type);

  /// The builder for [type], or `null` when none is registered.
  SduiComponentBuilder? builderFor(String type) => _builders[type];

  /// All registered component types.
  Iterable<String> get types => _builders.keys;
}
