# KbLayoutDisplay

![](./assets/kblayoutdisplay-preview.webp)

DankMaterialShell widget for displaying current keyboard layout in the bar and showing popup notification when keyboard layout changes.

## Why KbLayoutDisplay?

DankMaterialShell already includes a built-in keyboard layout indicator. This plugin extends that functionality with additional customization options:

- **Custom layout mappings:** independently customize labels displayed in the bar and popup notifications.
- **Popup notifications:** show the current layout whenever it changes.
- **More customization:** control widget and popup visibility, text sizes, colors, popup position, margin, and border.

## Features

- displays keyboard layout in the bar widget
- shows a popup notification when keyboard layout changes
- configurable widget and popup font sizes
- configurable widget text color, popup background and border
- configurable popup position and margin
- independent widget and popup visibility controls
- configurable layout labels through plugin settings

## Requirements

- DankMaterialShell development version with `KeyboardLayoutService` support.
- A compatible Wayland compositor.

> **Note:** This plugin uses `KeyboardLayoutService`, which is available in the latest development version of DankMaterialShell. Older stable releases, including v1.6.3, are not supported.

Tested with DankMaterialShell `v1.6.0-568-gae361e37f` on niri `v26.04`.

## Installation

- clone repository in `~/.config/DankMaterialShell/plugins/KbLayoutDisplay`
- run `dms ipc call plugin-scan scan`
- then run `dms ipc call plugins enable kbLayoutDisplay`

## Configuration

### Widget

| Option               | Default         | Range  | Description                  |
| -------------------- | --------------- | ------ | ---------------------------- |
| Bar widget font size | 10px            | 8-32px | Text size in the bar         |
| Widget text color    | `Theme.primary` | color  | Text color of the bar widget |

### Popup

| Option                 | Default         | Range                                      | Description                   |
| ---------------------- | --------------- | ------------------------------------------ | ----------------------------- |
| Popup text font size   | 20px            | 8-100px                                    | Text size in the popup        |
| Popup position         | `Bottom`        | `Center`, `Top`, `Bottom`, `Left`, `Right` | Popup placement on screen     |
| Popup margin           | 100px           | 0-500px                                    | Distance from the screen edge |
| Popup background color | `Theme.surface` | color                                      | Background color of the popup |
| Popup border color     | `transparent`   | color                                      | Border color of the popup     |
| Popup border width     | 0px             | 0-500px                                    | Width of the popup border     |

### Visibility

| Option            | Default | Range      | Description       |
| ----------------- | ------- | ---------- | ----------------- |
| Widget visibility | `on`    | `on`/`off` | Is widget visible |
| Popup visibility  | `on`    | `on`/`off` | Is popup visible  |

## Custom layout labels

Layout labels can be configured directly in the plugin settings.

Each rule contains three fields:

- `match` identifies a layout by matching the beginning of its system name
- `widget` defines the label displayed in the bar
- `popup` defines the label displayed in popup notifications

If multiple rules match, the rule with the longest matching prefix is used. If no rule matches, the original layout name is displayed.

Default rules:

| Match     | Widget | Popup          |
| --------- | ------ | -------------- |
| `English` | `EN`   | `English (US)` |
| `Russian` | `RU`   | `Русский`      |

## Project structure

- `plugin.json` - plugin metadata
- `KbLayoutDisplayWidget.qml` - bar widget, layout handling (via DMS) and popup notifcation.
- `KbLayoutDisplaySettings.qml` - plugin settings UI.
- `layouts.js` - keyboard layout matching rules and display labels.
