import QtQuick
import QtQuick.Templates as T


T.Button {
    id: control

    checkable: true
    hoverEnabled: true

    // ширина по тексту: слева место под иконку 10 + 13 + 6
    implicitWidth: implicitContentWidth + leftPadding + rightPadding
    implicitHeight: Math.max(implicitBackgroundHeight, implicitContentHeight + topPadding + bottomPadding)
    leftPadding: 29
    rightPadding: 10

    // background
    property color normalColorbg: "#11151c"
    property color activeColorbg: "#183c35"

    // border
    property color normalColorb: "#252c37"
    property color activeColorb: "#52d6a6"

    // text
    property color normalColort: "#a1a9b7"
    property color activeColort: "#52d6a6"

    property url imageSource
    property url imageSourceActive

    background: Rectangle {
            color: control.checked ? activeColorbg : (control.hovered ? activeColorbg : normalColorbg)
            radius: 6
            border.width: 1
            border.color: control.checked ? activeColorb : (control.hovered ? activeColorb : normalColorb)

            Behavior on color { ColorAnimation { duration: 150 } }
        }

    Image {
        width: 13
        height: 13
        source: (control.checked || control.hovered) ? control.imageSourceActive : control.imageSource

        anchors {
            left: parent.left
            leftMargin: 10
            verticalCenter: parent.verticalCenter
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