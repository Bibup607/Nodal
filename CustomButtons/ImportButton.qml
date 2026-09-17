import QtQuick
import QtQuick.Controls.Basic as Basic
import QtQuick.Templates as T

T.Button {
    id: control

    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                            implicitContentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                             implicitContentHeight + topPadding + bottomPadding)

    padding: 6
    horizontalPadding: padding + 2

    contentItem: Text {
        text: control.text
        font: control.font
        color: "black"
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }

    background: Rectangle {
        radius: 6
        color: control.pressed ? "#3fb98c" : "#52d6a6"

        Behavior on color {
            ColorAnimation { duration: 150 }
        }
    }

    HoverHandler {
        cursorShape: Qt.PointingHandCursor
    }
}
