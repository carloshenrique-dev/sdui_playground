# sdui_playground

A small, generic **Server-Driven UI** engine for Flutter. The server describes a
screen as versioned JSON; the app renders it with components and action
handlers it registered itself.

Built to be read: a few hundred lines, no dependencies beyond Flutter, tested.

## Why

- **Ship UI changes without an app release**, within the components the app
  already knows.
- **Safe by default.** A bad payload never crashes the screen:
  - malformed or newer-than-supported documents show a fallback;
  - unknown components, throwing builders and over-deep trees are skipped and
    reported, and the rest of the screen still renders.
- **Open for extension.** Register your own components and actions; override any
  built-in.

## Usage

```dart
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:sdui_playground/sdui_playground.dart';

final components = SduiComponentRegistry.withDefaults()
  ..register('badge', (buildContext, node, children) {
    final props = SduiProps(node.props);
    return Chip(label: Text(props.string('label') ?? ''));
  });

final actions = SduiActionRegistry()
  ..register('navigate', (action, context) {
    final route = action.params['route'];
    if (route is String) Navigator.of(context).pushNamed(route);
  });

Widget buildScreen(String payload) {
  return SduiView.fromJson(
    json: jsonDecode(payload),
    components: components,
    actions: actions,
    onFailure: (failure) => debugPrint('$failure'),
    fallbackBuilder: (context, failure) => const Text('Please update the app'),
  );
}
```

Example payload:

```json
{
  "schemaVersion": 1,
  "root": {
    "type": "column",
    "props": { "gap": 12 },
    "children": [
      { "type": "text", "props": { "text": "Hello", "style": "headline" } },
      {
        "type": "button",
        "props": { "label": "Continue" },
        "actions": {
          "onTap": { "type": "navigate", "params": { "route": "/next" } }
        }
      }
    ]
  }
}
```

## Try it

```sh
cd example
flutter create .   # generates platform folders once
flutter run
```

The example is a live editor: change the JSON and the preview updates. It also
has samples for the unknown-component and newer-schema cases.

## Documentation

- [Architecture and failure model](docs/architecture.md)
- [Schema reference](docs/schema.md)

## Development

```sh
flutter pub get
dart format .
flutter analyze
flutter test
```

## Status

Version 0.1.0, a learning and portfolio project (`publish_to: none`). The
schema is versioned, but the API may change before 1.0.

## License

MIT
