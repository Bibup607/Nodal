import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects

// окно импорта: вставляем SQL-код с CREATE TABLE
// само ничего не разбирает — отдаёт текст странице через сигнал importRequested
Popup {
    id: popup

    anchors.centerIn: Overlay.overlay
    width: 520
    padding: 20
    modal: true
    focus: true
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

    property string titleFont: ""
    property string monoFont: ""
    // текст ошибки под полем; страница пишет сюда, если импортировать нечего
    property string errorText: ""

    signal importRequested(string sql)

    readonly property bool canImport: sqlArea.text.trim() !== ""

    // при каждом открытии начинаем с пустого поля
    onOpened: {
        sqlArea.text = ""
        errorText = ""
        sqlArea.forceActiveFocus()
    }

    function accept() {
        if (!canImport) return
        errorText = ""
        importRequested(sqlArea.text)   // закроет окно страница, если всё получилось
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
            text: qsTr("Import SQL")
            color: "#ffffff"
            font.family: popup.titleFont
            font.pixelSize: 16
        }

        Text {
            Layout.topMargin: 6
            Layout.fillWidth: true
            text: qsTr("Paste CREATE TABLE statements. Tables will be added to this schema.")
            color: "#a1a9b7"
            font.pixelSize: 11
            wrapMode: Text.WordWrap
        }

        // поле для кода с прокруткой
        ScrollView {
            id: sqlScroll
            Layout.topMargin: 16
            Layout.fillWidth: true
            Layout.preferredHeight: 260

            background: Rectangle {
                color: "#0d1117"
                radius: 6
                border.width: 1
                border.color: sqlArea.activeFocus ? "#52d6a6" : "#252c37"
            }

            TextArea {
                id: sqlArea
                padding: 10
                color: "#e6edf3"
                selectionColor: "#1f4e43"
                font.family: popup.monoFont
                font.pixelSize: 11
                wrapMode: TextEdit.NoWrap
                selectByMouse: true
                placeholderText: "CREATE TABLE users (\n    id SERIAL PRIMARY KEY,\n    email VARCHAR(255) NOT NULL\n);"
                placeholderTextColor: "#4b5563"
                background: null   // рамку рисует ScrollView

                // Ctrl+Enter — импорт, не отрывая рук от клавиатуры
                Keys.onPressed: (event) => {
                    if ((event.modifiers & Qt.ControlModifier)
                            && (event.key === Qt.Key_Return || event.key === Qt.Key_Enter)) {
                        popup.accept()
                        event.accepted = true
                    }
                }
            }
        }

        Text {
            Layout.topMargin: 8
            Layout.fillWidth: true
            visible: popup.errorText !== ""
            text: popup.errorText
            color: "#f87171"
            font.pixelSize: 11
            wrapMode: Text.WordWrap
        }

        // кнопки справа внизу
        RowLayout {
            Layout.topMargin: 18
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
                Layout.preferredWidth: importText.implicitWidth + 28
                Layout.preferredHeight: 30
                radius: 6
                // пока поле пустое кнопка тусклая и не нажимается
                opacity: popup.canImport ? 1 : 0.4
                color: importMouse.containsMouse && popup.canImport ? "#6ee7b7" : "#52d6a6"

                Behavior on color { ColorAnimation { duration: 150 } }

                Text {
                    id: importText
                    anchors.centerIn: parent
                    text: qsTr("Import")
                    color: "#0d1117"
                    font.pixelSize: 12
                    font.bold: true
                }

                MouseArea {
                    id: importMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: popup.canImport ? Qt.PointingHandCursor : Qt.ArrowCursor
                    onClicked: popup.accept()
                }
            }
        }
    }
}
