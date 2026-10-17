import QtQuick
import qs.Common
import qs.Modules.Plugins
import qs.Widgets
import qs.DCommon.Widgets as DCommon

import "./layouts.js" as Layouts

PluginSettings {
    id: root
    pluginId: "kbLayoutDisplay"

    // layouts
    StyledText {
        width: parent.width
        text: "Layouts"
        font.pixelSize: Theme.fontSizeLarge
        font.weight: Font.Bold
        color: Theme.surfaceText
    }

    Rectangle {
        width: parent.width
        height: 1
        color: Theme.outline
        opacity: 0.3
    }

    ListSetting {
        id: rulesList
        settingKey: "layoutRules"
        label: "Layout labels"
        description: "Columns: layout name prefix, text in the bar, text in the popup. Prefix is matched against the name reported by the compositor, the longest match wins."
        defaultValue: Layouts.defaultRules

        function addRule() {
            const match = matchField.text.trim();
            if (match === "")
                return;

            addItem({
                match: match,
                widget: widgetField.text.trim(),
                popup: popupField.text.trim()
            });

            matchField.text = "";
            widgetField.text = "";
            popupField.text = "";
            matchField.forceActiveFocus();
        }

        inputs: [
            Flow {
                width: parent.width
                spacing: Theme.spacingS

                DCommon.DTextField {
                    id: matchField
                    width: 180
                    placeholderText: "Name starts with"
                    Keys.onReturnPressed: rulesList.addRule()
                }

                DCommon.DTextField {
                    id: widgetField
                    width: 80
                    placeholderText: "Bar"
                    Keys.onReturnPressed: rulesList.addRule()
                }

                DCommon.DTextField {
                    id: popupField
                    width: 180
                    placeholderText: "Popup"
                    Keys.onReturnPressed: rulesList.addRule()
                }

                DCommon.DButton {
                    width: 50
                    height: 36
                    text: "Add"
                    onClicked: rulesList.addRule()
                }
            }
        ]

        delegate: Component {
            StyledRect {
                required property int index
                required property var modelData

                width: parent.width
                height: 40
                radius: Theme.cornerRadius
                color: Theme.chipSurface
                border.width: 0

                Row {
                    anchors.left: parent.left
                    anchors.leftMargin: Theme.spacingM
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: Theme.spacingM

                    StyledText {
                        width: 180
                        text: modelData.match
                        color: Theme.surfaceText
                        font.pixelSize: Theme.fontSizeMedium
                        elide: Text.ElideRight
                    }

                    StyledText {
                        width: 80
                        text: modelData.widget
                        color: Theme.surfaceText
                        font.pixelSize: Theme.fontSizeMedium
                        elide: Text.ElideRight
                    }

                    StyledText {
                        width: 180
                        text: modelData.popup
                        color: Theme.surfaceText
                        font.pixelSize: Theme.fontSizeMedium
                        elide: Text.ElideRight
                    }
                }

                ListSettingRemoveButton {
                    onClicked: rulesList.removeItem(index)
                }
            }
        }
    }

    // visibility
    StyledText {
        width: parent.width
        text: "Visibility"
        font.pixelSize: Theme.fontSizeLarge
        font.weight: Font.Bold
        color: Theme.surfaceText
    }

    Rectangle {
        width: parent.width
        height: 1
        color: Theme.outline
        opacity: 0.3
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

    // widget
    StyledText {
        width: parent.width
        text: "Widget"
        font.pixelSize: Theme.fontSizeLarge
        font.weight: Font.Bold
        color: Theme.surfaceText
    }

    Rectangle {
        width: parent.width
        height: 1
        color: Theme.outline
        opacity: 0.3
    }

    SliderSetting {
        settingKey: "barWidgetFontSize"
        description: "Font size in bar widget"
        label: "Bar widget font size"
        defaultValue: 10
        minimum: 8
        maximum: 32
        unit: " px"
    }

    ColorSetting {
        settingKey: "widgetTextColor"
        label: "Widget text color"
        description: "Text color of widget"
        defaultValue: Theme.primary
    }

    // popup
    StyledText {
        width: parent.width
        text: "Popup"
        font.pixelSize: Theme.fontSizeLarge
        font.weight: Font.Bold
        color: Theme.surfaceText
    }

    Rectangle {
        width: parent.width
        height: 1
        color: Theme.outline
        opacity: 0.3
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

    ColorSetting {
        settingKey: "popupBackgroundColor"
        label: "Popup background color"
        description: "Background color of the layout notification"
        defaultValue: Theme.surface
    }

    ColorSetting {
        settingKey: "popupBorderColor"
        label: "Popup border color"
        description: "Border color of popup"
        defaultValue: "transparent"
    }

    SliderSetting {
        settingKey: "popupBorderWidth"
        label: "Popup border width"
        description: "Width of popup border"
        defaultValue: 0
        minimum: 0
        maximum: 500
        unit: " px"
    }
}
