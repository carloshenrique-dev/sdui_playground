import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_playground/sdui_playground.dart';

void main() {
  group('SduiProps', () {
    const props = SduiProps(<String, Object?>{
      'text': 'hello',
      'count': 3,
      'ratio': 1.5,
      'enabled': true,
    });

    test('GIVEN matching types WHEN read THEN values are returned', () {
      expect(props.string('text'), 'hello');
      expect(props.integer('count'), 3);
      expect(props.number('ratio'), 1.5);
      expect(props.boolean('enabled'), isTrue);
    });

    test('GIVEN an integer WHEN read as number THEN it becomes a double', () {
      expect(props.number('count'), 3.0);
    });

    test('GIVEN a wrong type WHEN read THEN null is returned, not an error',
        () {
      expect(props.string('count'), isNull);
      expect(props.integer('ratio'), isNull);
      expect(props.boolean('text'), isNull);
      expect(props.number('text'), isNull);
    });

    test('GIVEN a missing key WHEN read THEN null is returned', () {
      expect(props.string('missing'), isNull);
      expect(props.contains('missing'), isFalse);
      expect(props.contains('text'), isTrue);
    });
  });
}
