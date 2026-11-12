import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_playground/sdui_playground.dart';

Map<String, Object?> _nested(int levels) {
  var node = <String, Object?>{'type': 'text'};
  for (var i = 0; i < levels; i++) {
    node = <String, Object?>{
      'type': 'column',
      'children': <Object?>[node],
    };
  }
  return node;
}

void main() {
  group('SduiDocument.fromJson', () {
    test('GIVEN a valid document WHEN parsed THEN it exposes the full tree',
        () {
      final document = SduiDocument.fromJson(<String, Object?>{
        'schemaVersion': 1,
        'root': <String, Object?>{
          'type': 'column',
          'id': 'main',
          'props': <String, Object?>{'gap': 8},
          'children': <Object?>[
            <String, Object?>{
              'type': 'button',
              'props': <String, Object?>{'label': 'Go'},
              'actions': <String, Object?>{
                'onTap': <String, Object?>{
                  'type': 'navigate',
                  'params': <String, Object?>{'route': '/next'},
                },
              },
            },
          ],
        },
      });

      expect(document.schemaVersion, 1);
      expect(document.root.type, 'column');
      expect(document.root.id, 'main');
      expect(document.root.props['gap'], 8);
      final button = document.root.children.single;
      expect(button.actions['onTap']?.type, 'navigate');
      expect(button.actions['onTap']?.params['route'], '/next');
    });

    test('GIVEN a parsed document WHEN serialized THEN it round-trips', () {
      final json = <String, Object?>{
        'schemaVersion': 1,
        'root': <String, Object?>{
          'type': 'column',
          'children': <Object?>[
            <String, Object?>{
              'type': 'text',
              'props': <String, Object?>{'text': 'Hello'},
            },
          ],
        },
      };

      expect(SduiDocument.fromJson(json).toJson(), json);
    });

    test('GIVEN unknown extra fields WHEN parsed THEN they are ignored', () {
      final document = SduiDocument.fromJson(<String, Object?>{
        'schemaVersion': 1,
        'futureField': true,
        'root': <String, Object?>{'type': 'text', 'futureNodeField': 1},
      });

      expect(document.root.type, 'text');
    });

    test(
        'GIVEN a newer schemaVersion WHEN parsed THEN it throws a version error',
        () {
      expect(
        () => SduiDocument.fromJson(<String, Object?>{
          'schemaVersion': SduiDocument.supportedSchemaVersion + 1,
          'root': <String, Object?>{'type': 'text'},
        }),
        throwsA(isA<SduiUnsupportedVersionException>()),
      );
    });

    test('GIVEN a missing schemaVersion WHEN parsed THEN it throws', () {
      expect(
        () => SduiDocument.fromJson(<String, Object?>{
          'root': <String, Object?>{'type': 'text'},
        }),
        throwsA(isA<SduiParseException>()),
      );
    });

    test('GIVEN a missing root WHEN parsed THEN it throws', () {
      expect(
        () => SduiDocument.fromJson(<String, Object?>{'schemaVersion': 1}),
        throwsA(isA<SduiParseException>()),
      );
    });

    test('GIVEN a node without type WHEN parsed THEN the error names the path',
        () {
      expect(
        () => SduiDocument.fromJson(<String, Object?>{
          'schemaVersion': 1,
          'root': <String, Object?>{
            'type': 'column',
            'children': <Object?>[
              <String, Object?>{'props': <String, Object?>{}},
            ],
          },
        }),
        throwsA(
          isA<SduiParseException>().having(
            (e) => e.path,
            'path',
            r'$.root.children[0].type',
          ),
        ),
      );
    });

    test('GIVEN a payload that is not an object WHEN parsed THEN it throws',
        () {
      expect(
        () => SduiDocument.fromJson(<Object?>[1, 2, 3]),
        throwsA(isA<SduiParseException>()),
      );
    });

    test('GIVEN a tree at the maximum depth WHEN parsed THEN it is accepted',
        () {
      final document = SduiDocument.fromJson(<String, Object?>{
        'schemaVersion': 1,
        'root': _nested(SduiNode.maxDepth),
      });

      expect(document.root.type, 'column');
    });

    test('GIVEN a tree deeper than the maximum WHEN parsed THEN it throws', () {
      expect(
        () => SduiDocument.fromJson(<String, Object?>{
          'schemaVersion': 1,
          'root': _nested(SduiNode.maxDepth + 1),
        }),
        throwsA(isA<SduiParseException>()),
      );
    });
  });
}
