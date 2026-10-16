import QtQuick

//  базовые свои цвета пользователя и кнопка + для создания нового
Grid {
    id: palette
    columns: 4
    spacing: 6

    property var colorStore: null
    property string currentColor: ""

    signal colorSelected(string color)
    signal addRequested()

    readonly property var baseColors: colorStore ? colorStore.baseColors : []
    readonly property var allColors: colorStore ? colorStore.baseColors.concat(colorStore.colors) : []

    Repeater {
        model: palette.allColors

        delegate: Rectangle {
            required property string modelData
            required property int index

            // свои цвета идут после базовых, их можно удалить правым кликом
            readonly property bool isCustom: index >= palette.baseColors.length

            width: 18
            height: 18
            radius: 9
            color: modelData
            // обводка при наведении и у текущего цвета
            border.width: swatchMouse.containsMouse
                          || (palette.currentColor !== "" && Qt.colorEqual(modelData, palette.currentColor)) ? 2 : 0
            border.color: "#ffffff"

            MouseArea {
                id: swatchMouse
                anchors.fill: parent
                hoverEnabled: true
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                cursorShape: Qt.PointingHandCursor
                onClicked: (mouse) => {
                    if (mouse.button === Qt.RightButton) {
                        if (parent.isCustom)
                            palette.colorStore.remove(parent.index - palette.baseColors.length)
                    } else {
                        palette.colorSelected(parent.modelData)
                    }
                }
            }
        }
    }

    Rectangle {
        width: 18
        height: 18
        radius: 9
        color: "transparent"
        border.width: 1
        border.color: plusMouse.containsMouse ? "#52d6a6" : "#475569"

        Text {
            anchors.centerIn: parent
            text: "+"
            color: plusMouse.containsMouse ? "#52d6a6" : "#a1a9b7"
            font.family: "Monospace"
            font.pixelSize: 12
            font.bold: true
        }

        MouseArea {
            id: plusMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: palette.addRequested()
        }
    }
}
