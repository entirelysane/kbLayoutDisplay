import QtQuick
import Quickshell
import qs.Common
import qs.Services
import qs.Widgets
import qs.Modules.Plugins
import Quickshell.Wayland

import "./layouts.js" as Layouts

PluginComponent {
    id: root

    readonly property int barWidgetFontSize: pluginData.barWidgetFontSize ?? Theme.fontSizeMedium

    readonly property bool isWidgetVisible: pluginData.isWidgetVisible ?? true
    readonly property color widgetTextColor: pluginData.widgetTextColor ?? Theme.primary

    readonly property int popupTextFontSize: pluginData.popupTextFontSize ?? Theme.fontSizeLarge
    readonly property string popupPosition: pluginData.popupPosition ?? "bottom"
    readonly property color popupBackgroundColor: pluginData.popupBackgroundColor ?? Theme.surface
    readonly property color popupBorderColor: pluginData.popupBorderColor ?? "transparent"
    readonly property int popupMargin: Number(pluginData.popupMargin ?? 100)
    readonly property bool isPopupVisible: pluginData.isPopupVisible ?? true
    readonly property int popupBorderWidth: pluginData.popupBorderWidth ?? 0

    property bool popupVisible: false
    property string popupText: ""

    property string lastLayout: ""

    visible: root.isWidgetVisible

    readonly property string currentLayout: KeyboardLayoutService.currentLayout

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
            KeyboardLayoutService.consumers++;
            root.lastLayout = root.currentLayout;
        }
        Component.onDestruction: KeyboardLayoutService.consumers--
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
        screen: root.parentScreen
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

            width: popupLabel.implicitWidth + Theme.spacingXL * 2
            height: popupLabel.implicitHeight + Theme.spacingXL * 2

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
