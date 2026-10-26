import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects

// окно подтверждения: заголовок, пояснение и две кнопки
// текст задаёт тот, кто открывает окно; по «да» приходит сигнал confirmed
Popup {
    id: popup

    anchors.centerIn: Overlay.overlay
    width: 400
    padding: 20
    modal: true
    focus: true
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

    property string titleFont: ""
    property string titleText: ""
    property string message: ""
    property string confirmText: qsTr("Continue")

    signal confirmed()

    Overlay.modal: Rectangle {
        color: "#99000000"
    }

    background: Item {
        Rectangle {
            id: bg
            anchors.fill: parent
            color: "#161b22"
            border.color: "#252c37"
            border.width: 1
            radius: 10
        }

        // мягкая тень
        MultiEffect {
            source: bg
            anchors.fill: bg
            shadowEnabled: true
            shadowColor: "#000000"
            shadowOpacity: 0.5
            shadowBlur: 0.8
            shadowVerticalOffset: 6
        }
    }

    contentItem: ColumnLayout {
        spacing: 0

        Text {
            text: popup.titleText
            color: "#ffffff"
            font.family: popup.titleFont
            font.pixelSize: 16
        }

        Text {
            Layout.topMargin: 8
            Layout.fillWidth: true
            text: popup.message
            color: "#a1a9b7"
            font.pixelSize: 12
            lineHeight: 1.3
            wrapMode: Text.WordWrap
        }

        // кнопки справа внизу
        RowLayout {
            Layout.topMargin: 22
            Layout.fillWidth: true
            spacing: 8

            Item { Layout.fillWidth: true }

            Rectangle {
                Layout.preferredWidth: cancelText.implicitWidth + 28
                Layout.preferredHeight: 30
                radius: 6
                color: cancelMouse.containsMouse ? "#1b222c" : "transparent"
                border.width: 1
                border.color: "#252c37"

                Text {
                    id: cancelText
                    anchors.centerIn: parent
                    text: qsTr("Cancel")
                    color: "#cbd5e1"
                    font.pixelSize: 12
                }

                MouseArea {
                    id: cancelMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: popup.close()
                }
            }

            Rectangle {
                Layout.preferredWidth: confirmLabel.implicitWidth + 28
                Layout.preferredHeight: 30
                radius: 6
                color: confirmMouse.containsMouse ? "#6ee7b7" : "#52d6a6"

                Behavior on color { ColorAnimation { duration: 150 } }

                Text {
                    id: confirmLabel
                    anchors.centerIn: parent
                    text: popup.confirmText
                    color: "#0d1117"
                    font.pixelSize: 12
                    font.bold: true
                }

                MouseArea {
                    id: confirmMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        popup.close()
                        popup.confirmed()
                    }
                }
            }
        }
    }
}
