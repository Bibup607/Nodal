import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects

// окно с готовым SQL-кодом: можно скопировать или сохранить в файл .sql
// код готовит страница (SqlExporter.generate), окно только показывает его
Popup {
    id: popup

    anchors.centerIn: Overlay.overlay
    width: 620
    padding: 20
    modal: true
    focus: true
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

    property string titleFont: ""
    property string monoFont: ""
    property string engine: ""
    property string sqlText: ""

    // сохранить в файл: диалог выбора файла открывает страница
    signal saveRequested()

    // кнопка внизу окна: primary — зелёная главная, иначе с рамкой
    component DialogButton: Rectangle {
        id: btn

        property string text
        property bool primary: false
        signal clicked()

        implicitWidth: btnText.implicitWidth + 28
        implicitHeight: 30
        radius: 6
        color: primary ? (btnMouse.containsMouse ? "#6ee7b7" : "#52d6a6")
                       : (btnMouse.containsMouse ? "#1b222c" : "transparent")
        border.width: primary ? 0 : 1
        border.color: "#252c37"

        Behavior on color { ColorAnimation { duration: 150 } }

        Text {
            id: btnText
            anchors.centerIn: parent
            text: btn.text
            color: btn.primary ? "#0d1117" : "#cbd5e1"
            font.pixelSize: 12
            font.bold: btn.primary
        }

        MouseArea {
            id: btnMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: btn.clicked()
        }
    }

    onOpened: copyButton.copied = false

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
            text: qsTr("Export SQL — %1").arg(popup.engine)
            color: "#ffffff"
            font.family: popup.titleFont
            font.pixelSize: 16
        }

        Text {
            Layout.topMargin: 6
            Layout.fillWidth: true
            text: qsTr("CREATE TABLE statements for every table and relation on the schema.")
            color: "#a1a9b7"
            font.pixelSize: 11
            wrapMode: Text.WordWrap
        }

        // код только для чтения, с прокруткой в обе стороны
        ScrollView {
            Layout.topMargin: 16
            Layout.fillWidth: true
            Layout.preferredHeight: 340

            background: Rectangle {
                color: "#0d1117"
                radius: 6
                border.width: 1
                border.color: "#252c37"
            }

            TextArea {
                id: sqlArea
                readOnly: true
                padding: 10
                text: popup.sqlText
                color: "#e6edf3"
                selectionColor: "#1f4e43"
                selectedTextColor: "#ffffff"
                font.family: popup.monoFont
                font.pixelSize: 11
                wrapMode: TextEdit.NoWrap
                selectByMouse: true
                background: null   // рамку рисует ScrollView
            }
        }

        // кнопки справа внизу
        RowLayout {
            Layout.topMargin: 18
            Layout.fillWidth: true
            spacing: 8

            Item { Layout.fillWidth: true }

            DialogButton {
                text: qsTr("Close")
                onClicked: popup.close()
            }

            DialogButton {
                id: copyButton
                // после копирования на секунду пишем «Copied», чтобы было видно, что сработало
                property bool copied: false
                text: copied ? qsTr("Copied") : qsTr("Copy")
                onClicked: {
                    // у TextArea есть свой буфер обмена: выделяем всё, копируем, снимаем выделение
                    sqlArea.selectAll()
                    sqlArea.copy()
                    sqlArea.deselect()
                    copied = true
                    copiedTimer.restart()
                }

                Timer {
                    id: copiedTimer
                    interval: 1200
                    onTriggered: copyButton.copied = false
                }
            }

            DialogButton {
                primary: true
                text: qsTr("Save .sql…")
                onClicked: popup.saveRequested()
            }
        }
    }
}
