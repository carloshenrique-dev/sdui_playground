import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_playground/sdui_playground.dart';

Map<String, Object?> _document(Map<String, Object?> root) =>
    <String, Object?>{'schemaVersion': 1, 'root': root};

Map<String, Object?> _text(String text) => <String, Object?>{
      'type': 'text',
      'props': <String, Object?>{'text': text},
    };

Widget _host(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  late List<SduiFailure> failures;
  late SduiComponentRegistry components;
  late SduiActionRegistry actions;

  setUp(() {
    failures = <SduiFailure>[];
    components = SduiComponentRegistry.withDefaults();
    actions = SduiActionRegistry();
  });

  Widget view(Object? json, {SduiFallbackBuilder? fallback}) {
    return _host(
      SduiView.fromJson(
        json: json,
        components: components,
        actions: actions,
        onFailure: failures.add,
        fallbackBuilder: fallback,
      ),
    );
  }

  bool reported(SduiFailureKind kind) => failures.any((f) => f.kind == kind);

  group('SduiView rendering', () {
    testWidgets('GIVEN a valid document WHEN rendered THEN built-ins appear',
        (tester) async {
      await tester.pumpWidget(
        view(
          _document(<String, Object?>{
            'type': 'column',
            'children': <Object?>[
              _text('Title'),
              <String, Object?>{
                'type': 'button',
                'props': <String, Object?>{'label': 'Go'},
              },
            ],
          }),
        ),
      );

      expect(find.text('Title'), findsOneWidget);
      expect(find.text('Go'), findsOneWidget);
      expect(failures, isEmpty);
    });

    testWidgets('GIVEN a wrong prop type WHEN rendered THEN defaults are used',
        (tester) async {
      await tester.pumpWidget(
        view(
          _document(<String, Object?>{
            'type': 'text',
            'props': <String, Object?>{'text': 42},
          }),
        ),
      );

      expect(find.byType(Text), findsOneWidget);
      expect(failures, isEmpty);
    });

    testWidgets(
        'GIVEN an unknown component WHEN rendered THEN only it is skipped',
        (tester) async {
      await tester.pumpWidget(
        view(
          _document(<String, Object?>{
            'type': 'column',
            'children': <Object?>[
              _text('A'),
              <String, Object?>{'type': 'hologram'},
              _text('B'),
            ],
          }),
        ),
      );

      expect(find.text('A'), findsOneWidget);
      expect(find.text('B'), findsOneWidget);
      expect(reported(SduiFailureKind.unknownComponent), isTrue);
    });

    testWidgets('GIVEN a builder that throws WHEN rendered THEN it is skipped',
        (tester) async {
      components.register(
        'boom',
        (buildContext, node, children) => throw StateError('broken'),
      );

      await tester.pumpWidget(
        view(
          _document(<String, Object?>{
            'type': 'column',
            'children': <Object?>[
              <String, Object?>{'type': 'boom'},
              _text('still here'),
            ],
          }),
        ),
      );

      expect(find.text('still here'), findsOneWidget);
      expect(reported(SduiFailureKind.componentError), isTrue);
    });

    testWidgets('GIVEN a custom component WHEN registered THEN it is rendered',
        (tester) async {
      components.register(
        'badge',
        (buildContext, node, children) =>
            Text('badge:${SduiProps(node.props).string('label')}'),
      );

      await tester.pumpWidget(
        view(
          _document(<String, Object?>{
            'type': 'badge',
            'props': <String, Object?>{'label': 'new'},
          }),
        ),
      );

      expect(find.text('badge:new'), findsOneWidget);
    });

    testWidgets(
        'GIVEN a node deeper than the limit WHEN rendered THEN it is cut',
        (tester) async {
      var node = const SduiNode(type: 'text');
      for (var i = 0; i < SduiNode.maxDepth + 5; i++) {
        node = SduiNode(type: 'column', children: <SduiNode>[node]);
      }

      await tester.pumpWidget(
        _host(
          SduiView(
            document: SduiDocument(schemaVersion: 1, root: node),
            components: components,
            actions: actions,
            onFailure: failures.add,
          ),
        ),
      );

      expect(reported(SduiFailureKind.maxDepthExceeded), isTrue);
    });
  });

  group('SduiView fallbacks', () {
    testWidgets('GIVEN a newer schema WHEN rendered THEN the fallback shows',
        (tester) async {
      await tester.pumpWidget(
        view(
          <String, Object?>{
            'schemaVersion': SduiDocument.supportedSchemaVersion + 1,
            'root': _text('new'),
          },
          fallback: (context, failure) => const Text('Please update the app'),
        ),
      );

      expect(find.text('Please update the app'), findsOneWidget);
      expect(find.text('new'), findsNothing);
      expect(reported(SduiFailureKind.unsupportedVersion), isTrue);
    });

    testWidgets(
        'GIVEN a malformed payload WHEN rendered THEN it does not crash',
        (tester) async {
      await tester.pumpWidget(view('not a document'));

      expect(tester.takeException(), isNull);
      expect(reported(SduiFailureKind.invalidDocument), isTrue);
    });

    testWidgets('GIVEN an unknown root WHEN rendered THEN the fallback shows',
        (tester) async {
      await tester.pumpWidget(
        view(
          _document(<String, Object?>{'type': 'hologram'}),
          fallback: (context, failure) => const Text('fallback'),
        ),
      );

      expect(find.text('fallback'), findsOneWidget);
    });
  });

  group('SduiView actions', () {
    Map<String, Object?> buttonDocument(String actionType) {
      return _document(<String, Object?>{
        'type': 'button',
        'props': <String, Object?>{'label': 'Go'},
        'actions': <String, Object?>{
          'onTap': <String, Object?>{
            'type': actionType,
            'params': <String, Object?>{'route': '/next'},
          },
        },
      });
    }

    testWidgets(
        'GIVEN a registered handler WHEN tapped THEN it receives params',
        (tester) async {
      SduiAction? received;
      actions.register('navigate', (action, context) => received = action);

      await tester.pumpWidget(view(buttonDocument('navigate')));
      await tester.tap(find.text('Go'));
      await tester.pump();

      expect(received?.type, 'navigate');
      expect(received?.params['route'], '/next');
      expect(failures, isEmpty);
    });

    testWidgets('GIVEN no handler WHEN tapped THEN a failure is reported',
        (tester) async {
      await tester.pumpWidget(view(buttonDocument('nope')));
      await tester.tap(find.text('Go'));
      await tester.pump();

      expect(reported(SduiFailureKind.unknownAction), isTrue);
      expect(tester.takeException(), isNull);
    });

    testWidgets('GIVEN a handler that throws WHEN tapped THEN it is contained',
        (tester) async {
      actions.register('explode', (action, context) => throw StateError('x'));

      await tester.pumpWidget(view(buttonDocument('explode')));
      await tester.tap(find.text('Go'));
      await tester.pump();

      expect(reported(SduiFailureKind.actionError), isTrue);
      expect(tester.takeException(), isNull);
    });

    testWidgets(
        'GIVEN a button without onTap WHEN rendered THEN it is disabled',
        (tester) async {
      await tester.pumpWidget(
        view(
          _document(<String, Object?>{
            'type': 'button',
            'props': <String, Object?>{'label': 'Go'},
          }),
        ),
      );

      final button = tester.widget<FilledButton>(find.byType(FilledButton));
      expect(button.onPressed, isNull);
    });
  });
}
