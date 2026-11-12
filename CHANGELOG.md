# Changelog

## 0.1.0

- Versioned JSON schema: `SduiDocument`, `SduiNode`, `SduiAction`.
- Component registry with built-ins: `column`, `row`, `text`, `button`,
  `card`, `padding`, `spacer`, `divider`.
- Action registry; handlers live in the host app.
- Fail-soft rendering: unknown components, throwing builders and over-deep
  trees are skipped and reported through `SduiFailureListener`.
- Fail-closed documents: malformed payloads and newer schema versions show a
  fallback instead of crashing.
- Interactive example app.
