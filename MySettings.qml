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

    StyledText {
        width: parent.width
        text: "My Plugin Settings"
        font.pixelSize: Theme.fontSizeLarge
        font.weight: Font.Bold
        color: Theme.surfaceText
    }

    StyledText {
        width: parent.width
        text: "Configure your plugin here"
        font.pixelSize: Theme.fontSizeSmall
        color: Theme.surfaceVariantText
        wrapMode: Text.WordWrap
    }

    StringSetting {
        settingKey: "displayText"
        label: "Display Text"
        description: "Text shown in the bar"
        placeholder: "Enter text"
        defaultValue: "Hello"
    }
}
