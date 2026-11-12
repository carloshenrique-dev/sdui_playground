import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../registry/sdui_build_context.dart';
import '../registry/sdui_component_registry.dart';
import '../schema/sdui_node.dart';
import '../schema/sdui_props.dart';

/// Registers the generic built-in components on [registry].
///
/// Components: `column`, `row`, `text`, `button`, `card`, `padding`, `spacer`
/// and `divider`. Their props are documented in `docs/schema.md`.
void registerBuiltInComponents(SduiComponentRegistry registry) {
  registry
    ..register('column', _flex(Axis.vertical))
    ..register('row', _flex(Axis.horizontal))
    ..register('text', _text)
    ..register('button', _button)
    ..register('card', _card)
    ..register('padding', _padding)
    ..register('spacer', _spacer)
    ..register('divider', _divider);
}

double _nonNegative(double? value, double fallback) =>
    math.max(0.0, value ?? fallback);

MainAxisAlignment _mainAxis(String? value) => switch (value) {
      'center' => MainAxisAlignment.center,
      'end' => MainAxisAlignment.end,
      'spaceBetween' => MainAxisAlignment.spaceBetween,
      'spaceAround' => MainAxisAlignment.spaceAround,
      'spaceEvenly' => MainAxisAlignment.spaceEvenly,
      _ => MainAxisAlignment.start,
    };

CrossAxisAlignment _crossAxis(String? value) => switch (value) {
      'center' => CrossAxisAlignment.center,
      'end' => CrossAxisAlignment.end,
      'stretch' => CrossAxisAlignment.stretch,
      _ => CrossAxisAlignment.start,
    };

TextAlign _textAlign(String? value) => switch (value) {
      'center' => TextAlign.center,
      'end' => TextAlign.end,
      _ => TextAlign.start,
    };

List<Widget> _withGaps(List<Widget> children, Axis axis, double gap) {
  if (gap <= 0 || children.length < 2) {
    return children;
  }
  final spaced = <Widget>[];
  for (var i = 0; i < children.length; i++) {
    if (i > 0) {
      spaced.add(
        axis == Axis.vertical ? SizedBox(height: gap) : SizedBox(width: gap),
      );
    }
    spaced.add(children[i]);
  }
  return spaced;
}

SduiComponentBuilder _flex(Axis axis) {
  return (buildContext, node, children) {
    final props = SduiProps(node.props);
    final gap = _nonNegative(props.number('gap'), 0);
    return Flex(
      direction: axis,
      mainAxisSize: (props.boolean('fill') ?? false)
          ? MainAxisSize.max
          : MainAxisSize.min,
      mainAxisAlignment: _mainAxis(props.string('mainAxis')),
      crossAxisAlignment: _crossAxis(props.string('crossAxis')),
      children: _withGaps(children, axis, gap),
    );
  };
}

Widget _text(
  SduiBuildContext buildContext,
  SduiNode node,
  List<Widget> children,
) {
  final props = SduiProps(node.props);
  final textTheme = Theme.of(buildContext.context).textTheme;
  final style = switch (props.string('style')) {
    'headline' => textTheme.headlineSmall,
    'title' => textTheme.titleMedium,
    'caption' => textTheme.bodySmall,
    _ => textTheme.bodyMedium,
  };
  return Text(
    props.string('text') ?? '',
    style: style,
    textAlign: _textAlign(props.string('align')),
  );
}

Widget _button(
  SduiBuildContext buildContext,
  SduiNode node,
  List<Widget> children,
) {
  final props = SduiProps(node.props);
  final action = node.actions['onTap'];
  final VoidCallback? onPressed =
      action == null ? null : () => buildContext.dispatch(action);
  final label = Text(props.string('label') ?? '');
  return switch (props.string('variant')) {
    'outlined' => OutlinedButton(onPressed: onPressed, child: label),
    'text' => TextButton(onPressed: onPressed, child: label),
    _ => FilledButton(onPressed: onPressed, child: label),
  };
}

Widget _card(
  SduiBuildContext buildContext,
  SduiNode node,
  List<Widget> children,
) {
  final props = SduiProps(node.props);
  final padding = _nonNegative(props.number('padding'), 16);
  final gap = _nonNegative(props.number('gap'), 8);
  return Card(
    child: Padding(
      padding: EdgeInsets.all(padding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: _withGaps(children, Axis.vertical, gap),
      ),
    ),
  );
}

Widget _padding(
  SduiBuildContext buildContext,
  SduiNode node,
  List<Widget> children,
) {
  final props = SduiProps(node.props);
  return Padding(
    padding: EdgeInsets.all(_nonNegative(props.number('all'), 0)),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: children,
    ),
  );
}

Widget _spacer(
  SduiBuildContext buildContext,
  SduiNode node,
  List<Widget> children,
) {
  final props = SduiProps(node.props);
  return SizedBox(
    width: _nonNegative(props.number('width'), 0),
    height: _nonNegative(props.number('height'), 8),
  );
}

Widget _divider(
  SduiBuildContext buildContext,
  SduiNode node,
  List<Widget> children,
) {
  return const Divider();
}
