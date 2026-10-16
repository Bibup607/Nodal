import QtQuick
import QtQuick.Templates as T

// пункт меню сайдбара стартового экрана
T.AbstractButton {
    id: control

    implicitHeight: 32
    leftPadding: 10
    rightPadding: 10
    // выбранный раздел checked переключается при нажатии
    checkable: true
    hoverEnabled: true
    focusPolicy: Qt.TabFocus

    // подсветка как при наведении например пока открыто меню
    property bool highlighted: false

    property url imageSource
    property url imageSourceActive

    // текст справа счетчик или код языка
    property string badge: ""
    property color badgeColor: textColor
    property string badgeFont: ""
    // стрелка вниз справа
    property bool showArrow: false
    property bool arrowUp: false

    readonly property color textColor: checked ? "#52d6a6"
                                              : ((hovered || highlighted || visualFocus) ? "#e6edf3" : "#a1a9b7")

    background: Rectangle {
        radius: 6
        color: control.checked ? "#183c35"
                              : ((control.hovered || control.highlighted || control.visualFocus) ? "#1b222c" : "transparent")

        Behavior on color { ColorAnimation { duration: 150 } }
    }

    contentItem: Item {
        Image {
            id: icon
            width: 14
            height: 14
            sourceSize: Qt.size(14, 14)
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            source: control.checked ? control.imageSourceActive : control.imageSource
        }

        // занимает все место между иконкой и правой частью
        Text {
            anchors.left: icon.right
            anchors.leftMargin: 8
            anchors.right: rightPart.left
            anchors.rightMargin: rightPart.width > 0 ? 8 : 0
            anchors.verticalCenter: parent.verticalCenter
            text: control.text
            color: control.textColor
            font.pixelSize: 12
            elide: Text.ElideRight

            Behavior on color { ColorAnimation { duration: 150 } }
        }

        Row {
            id: rightPart
            spacing: 4
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter

            Text {
                visible: control.badge !== ""
                anchors.verticalCenter: parent.verticalCenter
                text: control.badge
                color: control.badgeColor
                font.family: control.badgeFont
                font.pixelSize: 10

                Behavior on color { ColorAnimation { duration: 150 } }
            }

            Image {
                visible: control.showArrow
                width: 10
                height: 10
                sourceSize: Qt.size(10, 10)
                anchors.verticalCenter: parent.verticalCenter
                source: "qrc:/Images/chevron-down.svg"
                rotation: control.arrowUp ? 180 : 0

                Behavior on rotation { NumberAnimation { duration: 200 } }
            }
        }
    }

    HoverHandler {
        cursorShape: Qt.PointingHandCursor
    }
}
