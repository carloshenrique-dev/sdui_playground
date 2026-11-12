/// Sample payloads shown in the playground, keyed by a short label.
const Map<String, String> samples = <String, String>{
  'Welcome': _welcome,
  'Unknown component': _unknownComponent,
  'Newer schema': _newerSchema,
};

const String _welcome = '''
{
  "schemaVersion": 1,
  "root": {
    "type": "padding",
    "props": { "all": 16 },
    "children": [
      {
        "type": "column",
        "props": { "gap": 12 },
        "children": [
          { "type": "text", "props": { "text": "Hello, SDUI", "style": "headline" } },
          { "type": "text", "props": { "text": "This screen is described by JSON." } },
          { "type": "divider" },
          {
            "type": "card",
            "children": [
              { "type": "text", "props": { "text": "Edit the JSON on the left", "style": "title" } },
              { "type": "text", "props": { "text": "and the preview updates.", "style": "caption" } }
            ]
          },
          {
            "type": "row",
            "props": { "gap": 8 },
            "children": [
              {
                "type": "button",
                "props": { "label": "Say hi" },
                "actions": {
                  "onTap": { "type": "showMessage", "params": { "message": "Hi from an action!" } }
                }
              },
              {
                "type": "button",
                "props": { "label": "Unhandled", "variant": "outlined" },
                "actions": { "onTap": { "type": "doesNotExist" } }
              }
            ]
          }
        ]
      }
    ]
  }
}
''';

const String _unknownComponent = '''
{
  "schemaVersion": 1,
  "root": {
    "type": "column",
    "props": { "gap": 8 },
    "children": [
      { "type": "text", "props": { "text": "Before the unknown node" } },
      { "type": "hologram", "props": { "text": "This type is not registered" } },
      { "type": "text", "props": { "text": "After it: the screen still renders." } }
    ]
  }
}
''';

const String _newerSchema = '''
{
  "schemaVersion": 99,
  "root": { "type": "text", "props": { "text": "Not renderable by this engine" } }
}
''';
