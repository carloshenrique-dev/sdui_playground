# Schema reference (version 1)

## Document

```json
{
  "schemaVersion": 1,
  "root": { "type": "column", "children": [] }
}
```

## Node

| Field | Type | Required | Notes |
| --- | --- | --- | --- |
| `type` | string | yes | Component identifier. |
| `id` | string | no | Stable id for analytics and debugging. |
| `props` | object | no | Component properties. |
| `actions` | object | no | Map of event name (for example `onTap`) to action. |
| `children` | array | no | Nested nodes. Maximum depth: 32. |

Unknown fields are ignored.

## Action

| Field | Type | Required | Notes |
| --- | --- | --- | --- |
| `type` | string | yes | Selects the handler registered by the app. |
| `params` | object | no | Free-form arguments for the handler. |

## Built-in components

| Type | Props | Actions |
| --- | --- | --- |
| `column`, `row` | `gap` (number), `fill` (bool), `mainAxis` (`start` / `center` / `end` / `spaceBetween` / `spaceAround` / `spaceEvenly`), `crossAxis` (`start` / `center` / `end` / `stretch`) | none |
| `text` | `text` (string), `style` (`headline` / `title` / `body` / `caption`), `align` (`start` / `center` / `end`) | none |
| `button` | `label` (string), `variant` (`filled` / `outlined` / `text`) | `onTap` (button is disabled without it) |
| `card` | `padding` (number, default 16), `gap` (number, default 8) | none |
| `padding` | `all` (number) | none |
| `spacer` | `width`, `height` (numbers) | none |
| `divider` | none | none |

Invalid or missing props fall back to the defaults above.
