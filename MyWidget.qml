import QtQuick
import qs.Common
import qs.Services
import qs.Widgets
import qs.Modules.Plugins
import Quickshell.Io
import Quickshell
import Quickshell.Wayland

PluginComponent {
    id: root
  
    readonly property int barWidgetFontSize: pluginData.barWidgetFontSize ?? 12

    property var layoutNames: []
    property int currentLayoutIndex: 0

    property string displayText: pluginData.displayText || "Hello"
    
    property bool popupVisible: false
    property string popupText: ""

    property string layoutText: {
      if (layoutNames.length === 0)
        return "???"

      const name = layoutNames[currentLayoutIndex] || ""
      return name.startsWith("Russian") ? "RU"
        : name.startsWith("English") ? "EN"
        : name
    }

    Component.onCompleted: {
      console.error("My plugin: component loaded")
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
                 const event = JSON.parse(data)

                 if (event.KeyboardLayoutsChanged) {
                     const state = event.KeyboardLayoutsChanged.keyboard_layouts
                     root.layoutNames = state.names
                     root.currentLayoutIndex = state.current_idx
                 } else if (event.KeyboardLayoutSwitched) {
                   root.currentLayoutIndex = event.KeyboardLayoutSwitched.idx
                   root.popupText = root.layoutText
                   root.popupVisible = true
                   popupTimer.restart()
                 }
             } catch (error) {
                 console.error("myPlugin: failed to parse Niri event:", error)
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
          anchors.centerIn: parent

          width: popupLabel.implicitWidth + 64
          height: popupLabel.implicitHeight + 40
          radius: Theme.cornerRadius
          color: Theme.surface
          border.color: Theme.outline
          border.width: 1

          StyledText {
              id: popupLabel

              anchors.centerIn: parent

              text: root.popupText
              font.pixelSize: 32
              font.weight: Font.Bold
             color: Theme.surfaceText
          }
      }
  }
}
