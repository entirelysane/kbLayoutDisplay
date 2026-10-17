import QtQuick
import qs.Common
import qs.Modules.Plugins
import qs.Widgets

PluginSettings {
    id: root
    pluginId: "kbLayoutDisplay"

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

    SelectionSetting {
        settingKey: "popupPosition"
        label: "Popup position"
        description: "Where the popup appears on screen"
        defaultValue: "bottom"
        options: [
            {
                value: "center",
                label: "Center"
            },
            {
                value: "top",
                label: "Top"
            },
            {
                value: "bottom",
                label: "Bottom"
            },
            {
                value: "left",
                label: "Left"
            },
            {
                value: "right",
                label: "Right"
            }
        ]
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

    ToggleSetting {
        settingKey: "isWidgetVisible"
        label: "Widget visibility"
        description: "Is widget visible?"
        defaultValue: true
    }

    ToggleSetting {
        settingKey: "isPopupVisible"
        label: "Popup visibility"
        description: "Is popup visible?"
        defaultValue: true
    }
}
