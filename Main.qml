import QtQuick
import QtQuick.Window
// import "Pages/SchemaWorkspace"
import "Pages/ProjectLauncher"

Window {
    id: appWindow
    width: 1280
    height: 800
    visible: true
    title: "NodalDB"
    flags: Qt.Window | Qt.FramelessWindowHint

    ProjectLauncherPage {
        anchors.fill: parent

        onCreateProjectRequested: console.log("new project")
        onOpenFileRequested: console.log("open project")
    }
}