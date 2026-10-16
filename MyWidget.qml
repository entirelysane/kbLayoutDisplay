import QtQuick
import qs.Common
import qs.Services
import qs.Widgets
import qs.Modules.Plugins
import Quickshell.Io
import Quickshell
import Quickshell.Wayland

import "./layouts.js" as Layouts

PluginComponent {
    id: root

    readonly property int barWidgetFontSize: pluginData.barWidgetFontSize ?? 12
    readonly property int popupTextFontSize: pluginData.popupTextFontSize ?? 20
    readonly property string popupPosition: pluginData.popupPosition ?? "bottom"
    readonly property int popupMargin: Number(pluginData.popupMargin ?? 100)

    property var layoutNames: []
    property int currentLayoutIndex: 0

    property bool popupVisible: false
    property string popupText: ""

    readonly property string layoutText: {
        if (layoutNames.length === 0)
            return "???";

        const name = layoutNames[currentLayoutIndex] || "";
        return getLayoutText(Layouts.widgetLayouts, name);
    }

    function getLayoutText(rules, layoutName) {
        const rule = rules.find(item => layoutName.startsWith(item.match));
        return rule ? rule.displayText : layoutName;
    }

    horizontalBarPill: Component {
        Row {
            spacing: Theme.spacingS

            StyledText {
                text: root.layoutText
                font.pixelSize: root.barWidgetFontSize
                color: Theme.surfaceText
                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }

    verticalBarPill: Component {
        Column {
            spacing: Theme.spacingXS

            StyledText {
                text: root.layoutText
                font.pixelSize: root.barWidgetFontSize
                color: Theme.surfaceText
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }
    }

    Timer {
        id: popupTimer
        interval: 1000
        onTriggered: root.popupVisible = false
    }

    Process {
        id: niriEvents

        command: ["niri", "msg", "--json", "event-stream"]
        running: true

        stdout: SplitParser {
            onRead: data => {
                try {
                    const event = JSON.parse(data);

                    if (event.KeyboardLayoutsChanged) {
                        const state = event.KeyboardLayoutsChanged.keyboard_layouts;
                        root.layoutNames = state.names;
                        root.currentLayoutIndex = state.current_idx;
                    } else if (event.KeyboardLayoutSwitched) {
                        root.currentLayoutIndex = event.KeyboardLayoutSwitched.idx;
                        root.popupText = root.getLayoutText(Layouts.popupLayouts, root.layoutNames[root.currentLayoutIndex] || "");

                        root.popupVisible = true;
                        popupTimer.restart();
                    }
                } catch (error) {
                    console.error("myPlugin: failed to parse Niri event:", error);
                }
            }
        }
    }

    PanelWindow {
        id: popup

        visible: root.popupVisible

        anchors {
            top: true
            bottom: true
            left: true
            right: true
        }

        color: "transparent"
        exclusiveZone: 0

        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

        Rectangle {
            id: popupBox

            width: popupLabel.implicitWidth + 64
            height: popupLabel.implicitHeight + 40

            radius: Theme.cornerRadius
            color: Theme.surface
            border.color: Theme.outline
            border.width: 1

            x: {
                switch (root.popupPosition) {
                case "left":
                    return root.popupMargin;
                case "right":
                    return parent.width - width - root.popupMargin;
                default:
                    return (parent.width - width) / 2;
                }
            }

            y: {
                switch (root.popupPosition) {
                case "top":
                    return root.popupMargin;
                case "bottom":
                    return parent.height - height - root.popupMargin;
                default:
                    return (parent.height - height) / 2;
                }
            }

            StyledText {
                id: popupLabel

                anchors.centerIn: parent

                text: root.popupText
                font.pixelSize: root.popupTextFontSize
                font.weight: Font.Bold
                color: Theme.surfaceText
            }
        }
    }
}
