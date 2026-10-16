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
}
