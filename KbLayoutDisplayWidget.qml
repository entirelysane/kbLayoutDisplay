import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.I3
import qs.Common
import qs.Services
import qs.Widgets
import qs.Modules.Plugins
import Quickshell.Wayland

import "./layouts.js" as Layouts

PluginComponent {
    id: root

    readonly property int barWidgetFontSize: pluginData.barWidgetFontSize ?? 12
    readonly property bool isWidgetVisible: pluginData.isWidgetVisible ?? true
    readonly property color widgetTextColor: pluginData.widgetTextColor ?? Theme.primary

    readonly property int popupTextFontSize: pluginData.popupTextFontSize ?? 20
    readonly property string popupPosition: pluginData.popupPosition ?? "bottom"
    readonly property color popupBackgroundColor: pluginData.popupBackgroundColor ?? Theme.surface
    readonly property color popupBorderColor: pluginData.popupBorderColor ?? "transparent"
    readonly property int popupMargin: Number(pluginData.popupMargin ?? 100)
    readonly property bool isPopupVisible: pluginData.isPopupVisible ?? true
    readonly property int popupBorderWidth: pluginData.popupBorderWidth ?? 0

    property bool popupVisible: false
    property string popupText: ""

    property string polledLayout: ""
    property string lastLayout: ""

    visible: root.isWidgetVisible

    readonly property string currentLayout: {
        if (CompositorService.isAqueous)
            return AqueousService.keyboardLayout;

        if (CompositorService.isNiri)
            return NiriService.getCurrentKeyboardLayoutName();

        if (CompositorService.isMango)
            return MangoService.currentKeyboardLayout;

        if (CompositorService.isHyprland || CompositorService.isSway)
            return root.polledLayout;

        return "";
    }

    readonly property string layoutText: {
        if (!currentLayout)
            return "???";

        return getLayoutText(Layouts.widgetLayouts, currentLayout);
    }

    function getLayoutText(rules, layoutName) {
        const rule = rules.find(item => layoutName.startsWith(item.match));
        return rule ? rule.displayText : layoutName;
    }

    onCurrentLayoutChanged: {
        const name = root.currentLayout;
        const hadKnownLayout = root.lastLayout !== "" && root.lastLayout !== "Unknown";

        root.lastLayout = name;

        if (!name || name === "Unknown" || !hadKnownLayout)
            return;

        root.popupText = root.getLayoutText(Layouts.popupLayouts, name);
        root.popupVisible = true;
        popupTimer.restart();
    }

    QtObject {
        Component.onCompleted: {
            root.lastLayout = root.currentLayout;

            if (CompositorService.isHyprland || CompositorService.isSway)
                root.updateLayout();
        }
    }

    function updateLayout() {
        if (CompositorService.isSway) {
            Proc.runCommand(null, ["swaymsg", "-t", "get_inputs", "-r"], (output, exitCode) => {
                if (exitCode !== 0) {
                    console.warn("KbLayoutDisplay: swaymsg failed");
                    root.polledLayout = "Unknown";
                    return;
                }

                try {
                    const inputs = JSON.parse(output);
                    const keyboard = inputs.find(item => item.type === "keyboard" && item.xkb_active_layout_name);

                    root.polledLayout = keyboard ? keyboard.xkb_active_layout_name : "Unknown";
                } catch (error) {
                    console.warn("KbLayoutDisplay: failed to parse Sway inputs:", error);
                    root.polledLayout = "Unknown";
                }
            });

            return;
        }

        if (CompositorService.isHyprland) {
            Proc.runCommand(null, ["hyprctl", "-j", "devices"], (output, exitCode) => {
                if (exitCode !== 0) {
                    console.warn("KbLayoutDisplay: hyprctl failed");
                    root.polledLayout = "Unknown";
                    return;
                }

                try {
                    const devices = JSON.parse(output);
                    const keyboard = devices.keyboards?.find(item => item.main === true);

                    if (!keyboard) {
                        root.polledLayout = "Unknown";
                        return;
                    }

                    if (keyboard.active_keymap) {
                        root.polledLayout = keyboard.active_keymap;
                        return;
                    }

                    const layouts = keyboard.layout ? keyboard.layout.split(",") : [];
                    const variants = (keyboard.variant ?? "").split(",");
                    const index = keyboard.active_layout_index;

                    if (Number.isInteger(index) && index >= 0 && index < layouts.length) {
                        const layout = layouts[index];
                        const variant = variants[index] ?? "";

                        root.polledLayout = variant ? `${layout}-${variant}` : layout;
                    } else {
                        root.polledLayout = "Unknown";
                    }
                } catch (error) {
                    console.warn("KbLayoutDisplay: failed to parse Hyprland devices:", error);
                    root.polledLayout = "Unknown";
                }
            });
        }
    }

    Connections {
        target: CompositorService

        function onCompositorChanged() {
            root.updateLayout();
        }
    }

    Connections {
        target: CompositorService.isHyprland ? Hyprland : null
        enabled: CompositorService.isHyprland

        function onRawEvent(event) {
            if (event.name === "activelayout")
                root.updateLayout();
        }
    }

    Loader {
        active: CompositorService.isSway

        sourceComponent: I3IpcListener {
            subscriptions: ["input"]

            onIpcEvent: event => {
                if (event.type !== "input")
                    return;

                try {
                    const payload = JSON.parse(event.data);
                    if (payload.change !== "xkb_layout")
                        return;

                    const name = payload.input?.xkb_active_layout_name;
                    if (name)
                        root.polledLayout = name;
                } catch (error) {
                    console.warn("KbLayoutDisplay: failed to parse Sway input event:", error);
                }
            }
        }
    }

    horizontalBarPill: Component {
        Row {
            spacing: Theme.spacingS

            StyledText {
                text: root.layoutText
                font.pixelSize: root.barWidgetFontSize
                color: root.widgetTextColor
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
                color: root.widgetTextColor
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }
    }

    Timer {
        id: popupTimer
        interval: 1000
        onTriggered: root.popupVisible = false
    }

    PanelWindow {
        id: popup
        visible: root.popupVisible && root.isPopupVisible

        anchors {
            top: true
            bottom: true
            left: true
            right: true
        }

        color: "transparent"
        exclusiveZone: 0

        mask: Region {
            item: popupBox
        }

        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

        Rectangle {
            id: popupBox

            width: popupLabel.implicitWidth + 64
            height: popupLabel.implicitHeight + 40

            radius: Theme.cornerRadius
            color: root.popupBackgroundColor
            border.color: root.popupBorderColor
            border.width: root.popupBorderWidth

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
