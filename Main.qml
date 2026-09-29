import QtQuick
import QtQuick.Window
import "Pages/SchemaWorkspace"

Window {
    id: appWindow
    width: 1280
    height: 800
    visible: true
    title: "NodalDB"
    flags: Qt.Window | Qt.FramelessWindowHint

    SchemaWorkspacePage {
        anchors.fill: parent
    }
}