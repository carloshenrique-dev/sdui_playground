import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:sdui_playground/sdui_playground.dart';

import 'samples.dart';

void main() => runApp(const PlaygroundApp());

/// Root of the playground app.
class PlaygroundApp extends StatelessWidget {
  /// Creates the app.
  const PlaygroundApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SDUI Playground',
      theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
      home: const PlaygroundPage(),
    );
  }
}

/// Editor on top, live preview below.
class PlaygroundPage extends StatefulWidget {
  /// Creates the page.
  const PlaygroundPage({super.key});

  @override
  State<PlaygroundPage> createState() => _PlaygroundPageState();
}

class _PlaygroundPageState extends State<PlaygroundPage> {
  late final TextEditingController _controller;
  late final SduiComponentRegistry _components;
  late final SduiActionRegistry _actions;

  String _sample = samples.keys.first;
  Object? _decoded;
  String? _jsonError;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: samples[_sample]);
    _components = SduiComponentRegistry.withDefaults();
    _actions = SduiActionRegistry()
      ..register('showMessage', (action, context) {
        final message = action.params['message'];
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message is String ? message : 'Action ran')),
        );
      });
    _decode(_controller.text);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _decode(String source) {
    try {
      _decoded = jsonDecode(source);
      _jsonError = null;
    } on FormatException catch (error) {
      _jsonError = error.message;
    }
  }

  void _selectSample(String name) {
    setState(() {
      _sample = name;
      _controller.text = samples[name] ?? '';
      _decode(_controller.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SDUI Playground')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: SegmentedButton<String>(
              segments: [
                for (final name in samples.keys)
                  ButtonSegment<String>(value: name, label: Text(name)),
              ],
              selected: {_sample},
              onSelectionChanged: (selection) => _selectSample(selection.first),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: TextField(
                controller: _controller,
                expands: true,
                maxLines: null,
                minLines: null,
                textAlignVertical: TextAlignVertical.top,
                style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  errorText: _jsonError,
                ),
                onChanged: (value) => setState(() => _decode(value)),
              ),
            ),
          ),
          const Divider(height: 24),
          Expanded(
            child: SingleChildScrollView(
              child: _jsonError != null
                  ? const SizedBox.shrink()
                  : SduiView.fromJson(
                      json: _decoded,
                      components: _components,
                      actions: _actions,
                      onFailure: (failure) => debugPrint('$failure'),
                      fallbackBuilder: (context, failure) => Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          'Fallback: ${failure.kind.name}',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
