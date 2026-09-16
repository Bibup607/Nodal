import QtQuick
import QtQuick.Controls

Button {
    id: control

    width: 100
    height: 40


    checkable: true
    hoverEnabled: false

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
        color: checked ? activeColorbg : normalColorbg

        radius: 6

        border {
            width: 1
            color: checked ? activeColorb : normalColorb
        }
    }

    Image {
        anchors {
            left: parent.left
            leftMargin: 10
            verticalCenter: parent.verticalCenter
        }
    }

    contentItem: Text {
        text: control.text
        color: checked ? activeColort : normalColort

        font.pixelSize: 12

        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }
}
