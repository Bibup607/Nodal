import QtQuick
import QtQuick.Controls

// окно создания своего цвета квадрат насыщенность/яркость полоса оттенка
Popup {
    id: picker
    padding: 10

    property real hue: 0
    property real sat: 1
    property real val: 1
    readonly property color pickedColor: Qt.hsva(hue, sat, val, 1)

    // временный цвет чтобы разложить строку
    property color parsedColor: "#000000"

    signal colorAccepted(string color)

    function openWith(initialColor) {
        setFromColor(initialColor)
        open()
    }

    function setFromColor(c) {
        parsedColor = c
        // у серых цветов оттенка нет (-1), тогда оставляем прошлый
        if (parsedColor.hsvHue >= 0) hue = parsedColor.hsvHue
        sat = parsedColor.hsvSaturation
        val = parsedColor.hsvValue
        hexField.text = pickedColor.toString()
    }

    function clamp01(v) {
        return Math.min(Math.max(v, 0), 1)
    }

    onPickedColorChanged: {
        if (!hexField.activeFocus) hexField.text = pickedColor.toString()
    }

    background: Rectangle {
        color: "#11151c"
        border.color: "#252c37"
        border.width: 1
        radius: 8
    }

    contentItem: Column {
        spacing: 10

        // насыщенность слева направо яркост сверху вниз
        Item {
            id: svArea
            width: 160
            height: 120

            Rectangle {
                anchors.fill: parent
                radius: 4
                color: Qt.hsva(picker.hue, 1, 1, 1)

                Rectangle {
                    anchors.fill: parent
                    radius: 4
                    gradient: Gradient {
                        orientation: Gradient.Horizontal
                        GradientStop { position: 0; color: "#ffffffff" }
                        GradientStop { position: 1; color: "#00ffffff" }
                    }
                }

                Rectangle {
                    anchors.fill: parent
                    radius: 4
                    gradient: Gradient {
                        GradientStop { position: 0; color: "#00000000" }
                        GradientStop { position: 1; color: "#ff000000" }
                    }
                }
            }

            Rectangle {
                width: 12
                height: 12
                radius: 6
                x: picker.sat * svArea.width - width / 2
                y: (1 - picker.val) * svArea.height - height / 2
                color: picker.pickedColor
                border.width: 2
                border.color: "#ffffff"
            }

            MouseArea {
                anchors.fill: parent
                preventStealing: true
                cursorShape: Qt.CrossCursor

                function pick(mouse) {
                    picker.sat = picker.clamp01(mouse.x / width)
                    picker.val = 1 - picker.clamp01(mouse.y / height)
                }

                onPressed: (mouse) => pick(mouse)
                onPositionChanged: (mouse) => pick(mouse)
            }
        }

        // полоса оттенка
        Item {
            id: hueBar
            width: 160
            height: 12

            Rectangle {
                anchors.fill: parent
                radius: 6
                gradient: Gradient {
                    orientation: Gradient.Horizontal
                    GradientStop { position: 0 / 6; color: "#ff0000" }
                    GradientStop { position: 1 / 6; color: "#ffff00" }
                    GradientStop { position: 2 / 6; color: "#00ff00" }
                    GradientStop { position: 3 / 6; color: "#00ffff" }
                    GradientStop { position: 4 / 6; color: "#0000ff" }
                    GradientStop { position: 5 / 6; color: "#ff00ff" }
                    GradientStop { position: 6 / 6; color: "#ff0000" }
                }
            }

            Rectangle {
                width: 6
                height: 16
                radius: 3
                x: picker.hue * hueBar.width - width / 2
                anchors.verticalCenter: parent.verticalCenter
                color: Qt.hsva(picker.hue, 1, 1, 1)
                border.width: 2
                border.color: "#ffffff"
            }

            MouseArea {
                anchors.fill: parent
                anchors.topMargin: -4
                anchors.bottomMargin: -4
                preventStealing: true
                cursorShape: Qt.PointingHandCursor

                function pick(mouse) {
                    picker.hue = picker.clamp01(mouse.x / width)
                }

                onPressed: (mouse) => pick(mouse)
                onPositionChanged: (mouse) => pick(mouse)
            }
        }

        // превью hex и кнопка добавления
        Row {
            spacing: 6

            Rectangle {
                width: 22
                height: 22
                radius: 11
                anchors.verticalCenter: parent.verticalCenter
                color: picker.pickedColor
                border.width: 1
                border.color: "#252c37"
            }

            TextField {
                id: hexField
                width: 82
                height: 24
                anchors.verticalCenter: parent.verticalCenter
                leftPadding: 6
                rightPadding: 6
                topPadding: 0
                bottomPadding: 0
                verticalAlignment: TextInput.AlignVCenter
                maximumLength: 7
                selectByMouse: true
                color: "#ffffff"
                selectionColor: "#1f4e43"
                font.family: "Monospace"
                font.pixelSize: 10
                validator: RegularExpressionValidator { regularExpression: /#?[0-9a-fA-F]{6}/ }

                background: Rectangle {
                    radius: 4
                    color: "#0d1117"
                    border.width: 1
                    border.color: hexField.activeFocus ? "#52d6a6" : "#252c37"
                }

                // по Enter переносим введенный hex на квадрат и полосу
                onAccepted: {
                    picker.setFromColor(text.startsWith("#") ? text : "#" + text)
                    focus = false
                }
            }

            Rectangle {
                id: addBtn
                width: 44
                height: 24
                radius: 4
                anchors.verticalCenter: parent.verticalCenter
                color: addMouse.containsMouse ? "#183c35" : "#11151c"
                border.width: 1
                border.color: addMouse.containsMouse ? "#52d6a6" : "#252c37"

                Behavior on color {
                    ColorAnimation { duration: 150 }
                }

                Text {
                    anchors.centerIn: parent
                    text: qsTr("Add")
                    color: addMouse.containsMouse ? "#52d6a6" : "#a1a9b7"
                    font.family: "Monospace"
                    font.pixelSize: 10
                    font.bold: true
                }

                MouseArea {
                    id: addMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        picker.colorAccepted(picker.pickedColor.toString())
                        picker.close()
                    }
                }
            }
        }
    }
}
