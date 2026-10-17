import QtQuick
import QtQuick.Layouts
import QtQuick.Templates as T

import NodalDB

// карточка действия на стартовом экране создать или открыть проект
T.AbstractButton {
    id: control

    implicitWidth: 260
    implicitHeight: 134
    padding: 16
    hoverEnabled: true

    // true зеленая главная карточка
    property bool primary: false
    property url iconSource
    // серый текст под заголовком
    property string description
    // подпись горячей клавиши внизу
    property string shortcutText

    Fonts {
        id: fonts
    }

    // при нажатии карточка чуть уменьшается
    scale: control.down ? 0.99 : 1.0
    Behavior on scale { NumberAnimation { duration: 90; easing.type: Easing.OutQuad } }

    background: Rectangle {
        radius: 8
        border.width: 1
        color: control.primary ? (control.hovered ? "#1d4a40" : "#183c35")
                               : (control.hovered ? "#171d26" : "#13181f")
        border.color: control.primary ? "#52d6a6"
                                      : (control.hovered ? "#364152" : "#252c37")

        Behavior on color { ColorAnimation { duration: 150 } }
        Behavior on border.color { ColorAnimation { duration: 150 } }
    }

    contentItem: ColumnLayout {
        spacing: 0

        // квадратик с иконкой
        Rectangle {
            Layout.preferredWidth: 30
            Layout.preferredHeight: 30
            radius: 6
            color: control.primary ? "#52d6a6" : "#0d1117"
            border.width: control.primary ? 0 : 1
            border.color: "#252c37"

            Image {
                anchors.centerIn: parent
                width: 14
                height: 14
                sourceSize: Qt.size(14, 14)
                source: control.iconSource
            }
        }

        Text {
            Layout.topMargin: 22
            Layout.fillWidth: true
            text: control.text
            color: "#ffffff"
            font.family: fonts.interBold.family
            font.pixelSize: 14
            elide: Text.ElideRight
        }

        Text {
            Layout.topMargin: 5
            Layout.fillWidth: true
            text: control.description
            color: "#a1a9b7"
            font.pixelSize: 11
            wrapMode: Text.WordWrap
        }

        // прижимает подпись клавиши к низу карточки
        Item { Layout.fillHeight: true }

        Text {
            text: control.shortcutText
            color: control.primary ? "#52d6a6" : "#7d8796"
            opacity: control.primary ? 0.8 : 1.0
            font.family: fonts.jetBrainsMB.family
            font.pixelSize: 10
        }
    }

    HoverHandler {
        cursorShape: Qt.PointingHandCursor
    }
}
