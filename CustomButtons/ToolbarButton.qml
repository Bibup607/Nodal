import QtQuick
import QtQuick.Templates as T


T.Button {
    id: control

    width: 100
    height: 40


    checkable: true
    hoverEnabled: true


    // property url imageSource

    // background
    property color normalColorbg: "#11151c"
    property color activeColorbg: "#183c35"

    // botder
    property color normalColorb: "#252c37"
    property color activeColorb: "#52d6a6"

    // text
    property color normalColort: "#a1a9b7"
    property color activeColort: "#52d6a6"

    // image
    property color normalColori: "#a1a9b7"
    property color activeColori: "#52d6a6"

    background: Rectangle {
            color: control.checked ? activeColorbg : (control.hovered ? activeColorbg : normalColorbg)
            radius: 6
            border.width: 1
            border.color: control.checked ? activeColorb : (control.hovered ? activeColorb : normalColorb)

            Behavior on color { ColorAnimation { duration: 150 } }
        }

    Image {
        anchors {
            left: parent.left
            leftMargin: 10
            verticalCenter: parent.verticalCenter

            width: 13
            height: 13

            source: control.imageSource
        }
    }

    contentItem: Text {
            text: control.text
            color: control.checked ? activeColort : (control.hovered ? activeColort : normalColort)
            font.pixelSize: 12
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }

        HoverHandler {
            cursorShape: Qt.PointingHandCursor
        }
}
