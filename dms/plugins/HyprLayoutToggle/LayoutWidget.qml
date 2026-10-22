import QtQuick
import qs.Common
import qs.Services
import qs.Widgets
import qs.Modules.Plugins

PluginComponent {
    id: root
    property string currentLayout: "master"

    function refreshLayout() {
        Proc.runCommand("hyprLayoutToggle.poll",
            ["hyprctl", "activeworkspace", "-j"],
            (stdout, exitCode) => {
                if (exitCode !== 0) return
                try {
                    var data = JSON.parse(stdout)
                    if (data && data.tiledLayout)
                        root.currentLayout = data.tiledLayout
                } catch (e) {
                    console.warn("hyprLayoutToggle: bad JSON from hyprctl", e)
                }
            }, 100, undefined, root)
    }

    function toggleLayout() {
        var next = root.currentLayout === "monocle" ? "master" : "monocle"
        Proc.runCommand("hyprLayoutToggle.set",
            ["sh", "-c",
             "hyprctl eval \"hl.workspace_rule({ workspace = tostring(hl.get_active_workspace().id), layout = '" + next + "' })\""],
            (stdout, exitCode) => {
                if (exitCode === 0) {
                    ToastService.showInfo(next === "monocle" ? "Monocle" : "Master")
                    root.refreshLayout()
                }
            }, 50, undefined, root)
    }

    Timer { interval: 200; running: true; repeat: true; onTriggered: root.refreshLayout() }
    Component.onCompleted: root.refreshLayout()

    horizontalBarPill: Component {
        Item {
            implicitWidth: row.implicitWidth
            implicitHeight: row.implicitHeight
            Row {
                id: row
                spacing: Theme.spacingS
                DankIcon {
                    name: root.currentLayout === "monocle" ? "fullscreen" : "grid_view"
                    size: root.iconSize
                    color: Theme.primary
                    anchors.verticalCenter: parent.verticalCenter
                }
                StyledText {
                    text: root.currentLayout
                    font.pixelSize: Theme.fontSizeSmall
                    color: Theme.surfaceText
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: root.toggleLayout()
            }
        }
    }

    verticalBarPill: Component {
        Column {
            spacing: Theme.spacingXS
            DankIcon {
                name: root.currentLayout === "monocle" ? "fullscreen" : "grid_view"
                size: root.iconSize
                color: Theme.primary
                anchors.horizontalCenter: parent.horizontalCenter
            }
            MouseArea { anchors.fill: parent; onClicked: root.toggleLayout() }
        }
    }
}
