import QtQuick
import QtQuick.Controls


ApplicationWindow {
    id: window
    width: 1200
    height: 800
    visible: true
    title: "Nodal"
    flags: Qt.Window | Qt.FramelessWindowHint

    StackView {
        id: stackView
        anchors.fill: parent
        // initialItem: "ProjectLauncherPage.qml" потом вернуть

        initialItem: "Pages/ProjectLauncher/ProjectLauncherPage.qml"
    }
}