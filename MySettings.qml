import QtQuick
import qs.Common
import qs.Modules.Plugins
import qs.Widgets

PluginSettings {
    id: root
    pluginId: "myPlugin"

    SliderSetting {
        settingKey: "barWidgetFontSize"
        description: "Font size in bar widget"
        label: "Bar widget font size"
        defaultValue: 10
        minimum: 8
        maximum: 32
        unit: " px"
    }

    SliderSetting {
        settingKey: "popupTextFontSize"
        description: "Font size in popup notification"
        label: "Popup text font size"
        defaultValue: 20
        minimum: 8
        maximum: 100
        unit: " px"
    }

    Column {
        id: popupPositionSetting

        width: parent ? parent.width : 0
        spacing: Theme.spacingXS

        readonly property var positions: ["center", "top", "bottom", "left", "right"]

        function loadValue() {
            const stored = root.loadValue("popupPosition", "center")
            const index = positions.indexOf(stored)
            positionGroup.currentIndex = index >= 0 ? index : 0
        }

        Component.onCompleted: loadValue()

        StyledText {
            text: "Popup position"
            font.pixelSize: Theme.fontSizeMedium
            font.weight: Font.Medium
            color: Theme.surfaceText
        }

        StyledText {
            text: "Where the popup appears on screen"
            font.pixelSize: Theme.fontSizeSmall
            color: Theme.surfaceVariantText
            width: parent.width
            wrapMode: Text.WordWrap
        }

        DankButtonGroup {
            id: positionGroup

            model: ["Center", "Top", "Bottom", "Left", "Right"]
            checkEnabled: false

            onSelectionChanged: (index, selected) => {
                if (!selected)
                    return

                positionGroup.currentIndex = index
                root.saveValue("popupPosition", popupPositionSetting.positions[index])
            }
        }
    }

    SliderSetting {
        settingKey: "popupMargin"
        label: "Popup Margin"
        description: "Distance from screen edge in pixels"
        defaultValue: 100
        minimum: 0
        maximum: 500
        unit: " px"
    }
}

