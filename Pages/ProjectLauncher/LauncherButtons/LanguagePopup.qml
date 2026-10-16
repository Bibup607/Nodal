import QtQuick
import QtQuick.Controls
import QtQuick.Shapes
import QtQuick.Effects

// меню выбора языка под пунктом язык
Popup {
    id: popup

    padding: 4
    // клик по самому пункту не закрывает меню а переключает его
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent

    property string currentCode: "en"
    property string codeFont: ""

    signal languagePicked(string code)

    background: Item {
        Rectangle {
            id: bg
            anchors.fill: parent
            color: "#161b22"
            border.color: "#252c37"
            border.width: 1
            radius: 8
        }

        // мягкая тень
        MultiEffect {
            source: bg
            anchors.fill: bg
            shadowEnabled: true
            shadowColor: "#000000"
            shadowOpacity: 0.5
            shadowBlur: 0.6
            shadowVerticalOffset: 4
        }
    }

    contentItem: Column {
        spacing: 2

        Repeater {
            model: [
                { code: "ru", name: "Русский" },
                { code: "en", name: "English" }
            ]

            delegate: Rectangle {
                id: langRow
                required property var modelData
                readonly property bool selected: modelData.code === popup.currentCode

                width: parent.width
                height: 30
                radius: 5
                color: selected ? "#183c35" : (rowMouse.containsMouse ? "#1b222c" : "transparent")

                Behavior on color { ColorAnimation { duration: 150 } }

                Row {
                    anchors.left: parent.left
                    anchors.leftMargin: 10
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 10

                    Text {
                        width: 22
                        anchors.verticalCenter: parent.verticalCenter
                        text: langRow.modelData.code.toUpperCase()
                        color: "#7d8796"
                        font.family: popup.codeFont
                        font.pixelSize: 10
                    }

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: langRow.modelData.name
                        color: langRow.selected ? "#52d6a6" : "#cbd5e1"
                        font.pixelSize: 12
                    }
                }

                // галочка у выбранного
                Shape {
                    visible: langRow.selected
                    width: 12
                    height: 12
                    anchors.right: parent.right
                    anchors.rightMargin: 10
                    anchors.verticalCenter: parent.verticalCenter
                    preferredRendererType: Shape.CurveRenderer

                    ShapePath {
                        strokeColor: "#52d6a6"
                        strokeWidth: 1.5
                        fillColor: "transparent"
                        capStyle: ShapePath.RoundCap
                        joinStyle: ShapePath.RoundJoin
                        startX: 2; startY: 6.5
                        PathLine { x: 5; y: 9.5 }
                        PathLine { x: 10; y: 3 }
                    }
                }

                MouseArea {
                    id: rowMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        popup.languagePicked(langRow.modelData.code)
                        popup.close()
                    }
                }
            }
        }
    }
}
