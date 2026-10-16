import QtQuick
import qs.Common
import qs.Services
import qs.Widgets
import qs.Modules.Plugins
import Quickshell.Io

PluginComponent {
    id: root
    property var layoutNames: []
    property int currentLayoutIndex: 0

    property string displayText: pluginData.displayText || "Hello"

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

            DankIcon {
                name: "widgets"
                size: Theme.iconSize
                color: Theme.primary
                anchors.verticalCenter: parent.verticalCenter
            }

            StyledText {
                text: root.layoutText
                font.pixelSize: Theme.fontSizeMedium
                color: Theme.surfaceText
                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }

    verticalBarPill: Component {
        Column {
            spacing: Theme.spacingXS

            DankIcon {
                name: "widgets"
                size: Theme.iconSize
                color: Theme.primary
                anchors.horizontalCenter: parent.horizontalCenter
            }

            StyledText {
                text: root.layoutText
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.surfaceText
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }
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
                }
            } catch (error) {
                console.error("myPlugin: failed to parse Niri event:", error)
            }
        }
    }
    }
}
