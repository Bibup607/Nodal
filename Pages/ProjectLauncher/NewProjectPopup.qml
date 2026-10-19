import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects

// окно создания проекта по центру с затемнением фона
Popup {
    id: popup

    anchors.centerIn: Overlay.overlay
    width: 380
    padding: 20
    modal: true
    focus: true
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

    property string titleFont: ""
    property string monoFont: ""

    signal createRequested(string name, string engine)

    readonly property bool canCreate: nameField.text.trim() !== ""

    // при каждом открытии поля начинаются заново
    onOpened: {
        nameField.text = ""
        engineGroup.current = "PostgreSQL"
        nameField.forceActiveFocus()
    }

    function accept() {
        if (!canCreate) return
        close()
        createRequested(nameField.text.trim(), engineGroup.current)
    }

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
            text: qsTr("New project")
            color: "#ffffff"
            font.family: popup.titleFont
            font.pixelSize: 16
        }

        Text {
            Layout.topMargin: 6
            Layout.fillWidth: true
            text: qsTr("Name the schema and choose a database.")
            color: "#a1a9b7"
            font.pixelSize: 11
            wrapMode: Text.WordWrap
        }

        Text {
            Layout.topMargin: 18
            text: qsTr("PROJECT NAME")
            color: "#7d8796"
            font.pixelSize: 9
            font.bold: true
            font.letterSpacing: 0.6
        }

        TextField {
            id: nameField
            Layout.topMargin: 6
            Layout.fillWidth: true
            Layout.preferredHeight: 32
            leftPadding: 10
            placeholderText: "my_database"
            placeholderTextColor: "#4b5563"
            color: "#e6edf3"
            selectionColor: "#1f4e43"
            font.family: popup.monoFont
            font.pixelSize: 11
            maximumLength: 40
            selectByMouse: true

            background: Rectangle {
                color: "#0d1117"
                radius: 6
                border.width: 1
                border.color: nameField.activeFocus ? "#52d6a6" : "#252c37"
            }

            onAccepted: popup.accept()
        }

        Text {
            Layout.topMargin: 16
            text: qsTr("DATABASE")
            color: "#7d8796"
            font.pixelSize: 9
            font.bold: true
            font.letterSpacing: 0.6
        }

        // выбор движка базы одна кнопка активна
        RowLayout {
            id: engineGroup
            Layout.topMargin: 6
            Layout.fillWidth: true
            spacing: 6

            property string current: "PostgreSQL"

            Repeater {
                model: ["PostgreSQL", "MySQL", "SQLite"]

                delegate: Rectangle {
                    id: chip
                    required property string modelData
                    readonly property bool selected: engineGroup.current === modelData

                    Layout.fillWidth: true
                    Layout.preferredHeight: 30
                    radius: 6
                    color: selected ? "#183c35" : (chipMouse.containsMouse ? "#1b222c" : "#0d1117")
                    border.width: 1
                    border.color: selected ? "#52d6a6" : "#252c37"

                    Behavior on color { ColorAnimation { duration: 150 } }

                    Text {
                        anchors.centerIn: parent
                        text: chip.modelData
                        color: chip.selected ? "#52d6a6" : "#cbd5e1"
                        font.family: popup.monoFont
                        font.pixelSize: 11
                    }

                    MouseArea {
                        id: chipMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: engineGroup.current = chip.modelData
                    }
                }
            }
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
                Layout.preferredWidth: createText.implicitWidth + 28
                Layout.preferredHeight: 30
                radius: 6
                // пока нет имени кнопка тусклая и не нажимается
                opacity: popup.canCreate ? 1 : 0.4
                color: createMouse.containsMouse && popup.canCreate ? "#6ee7b7" : "#52d6a6"

                Behavior on color { ColorAnimation { duration: 150 } }

                Text {
                    id: createText
                    anchors.centerIn: parent
                    text: qsTr("Create")
                    color: "#0d1117"
                    font.pixelSize: 12
                    font.bold: true
                }

                MouseArea {
                    id: createMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: popup.canCreate ? Qt.PointingHandCursor : Qt.ArrowCursor
                    onClicked: popup.accept()
                }
            }
        }
    }
}
