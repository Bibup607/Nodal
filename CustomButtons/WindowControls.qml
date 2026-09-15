import QtQuick

Row {
    id: windowControls

    signal closeRequested()
    signal minimizeRequested()
    signal maximizeRequested()

    Rectangle {
        width: 12
        height: 12
        color: "#f0544f"
        radius: 6

        MouseArea {
            anchors.fill: parent
            onClicked: closeRequested()
        }
    }

    Rectangle {
        width: 12
        height: 12
        color: "#fabd2b"
        radius: 6

        MouseArea {
            anchors.fill: parent
            onClicked: minimizeRequested()
        }
    }

    Rectangle {
        width: 12
        height: 12
        color: "#2ec757"
        radius: 6

        MouseArea {
            anchors.fill: parent
            onClicked: maximizeRequested()
        }
    }
}
