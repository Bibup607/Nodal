import QtQuick
import QtQuick.Window

Row {
    id: windowControls
    spacing: 8

    signal closeRequested()
    signal minimizeRequested()
    signal maximizeRequested()



    Rectangle {
        width: 12
        height: 12
        radius: 6

        color: mouseArea.containsMouse ? "#c23b37" : "#f0544f"
        Behavior on color { ColorAnimation { duration: 150 } }

        MouseArea {
            id: mouseArea
            hoverEnabled: true
            anchors.fill: parent
            onClicked: closeRequested()

            HoverHandler {
                cursorShape: Qt.PointingHandCursor
            }
        }
    }

    Rectangle {
        width: 12
        height: 12
        radius: 6

        color: mouseArea2.containsMouse ? "#c99418" : "#fabd2b"
        Behavior on color { ColorAnimation { duration: 150 } }

        MouseArea {
            id: mouseArea2
            hoverEnabled: true
            anchors.fill: parent
            onClicked: minimizeRequested()

            HoverHandler {
                cursorShape: Qt.PointingHandCursor
            }
        }
    }

    Rectangle {
        width: 12
        height: 12
        radius: 6

        color: mouseArea3.containsMouse ? "#22a041" : "#2ec757"
        Behavior on color { ColorAnimation { duration: 150 } }

        MouseArea {
            id: mouseArea3
            hoverEnabled: true
            anchors.fill: parent
            onClicked: maximizeRequested()



            HoverHandler {
                cursorShape: Qt.PointingHandCursor
            }
        }
    }
}
