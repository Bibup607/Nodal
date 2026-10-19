import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Templates as T

import NodalDB

T.ItemDelegate {
    id: row

    required property string name
    required property string path
    required property string engine
    required property int tables
    required property int relations
    required property bool readOnly
    required property string lastOpened
    required property color accent
    required property int index

    // нажат крестик
    signal removeRequested()

    implicitHeight: 54
    leftPadding: 12
    rightPadding: 14
    hoverEnabled: true

    Fonts {
        id: fonts
    }

    background: Rectangle {
        radius: 6
        border.width: 1
        color: row.hovered ? "#171d26" : "#13181f"
        border.color: row.hovered ? "#364152" : "#252c37"
    }

    contentItem: RowLayout {
        spacing: 12

        Rectangle {
            Layout.preferredWidth: 30
            Layout.preferredHeight: 30
            radius: 6
            color: "#0d1117"
            border.color: "#252c37"

            LineIcon {
                anchors.centerIn: parent
                width: 15
                height: 15
                color: row.accent
                pathData: "M4.5 2h7a2.5 2.5 0 0 1 2.5 2.5v7a2.5 2.5 0 0 1 -2.5 2.5h-7a2.5 2.5 0 0 1 -2.5 -2.5v-7a2.5 2.5 0 0 1 2.5 -2.5z M5 5.5h2.5 M5 8h1.5 M5 10.5h2.5 M9.8 5.5a1 1 0 1 0 2 0a1 1 0 1 0 -2 0 M9.8 10.5a1 1 0 1 0 2 0a1 1 0 1 0 -2 0 M10.8 6.5v3"
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 2

            Text {
                text: row.name
                color: "#ffffff"
                font.family: fonts.jetBrainsMB.family
                font.pixelSize: 12
            }

            // длинный путь сокращается троеточием посередине
            Text {
                Layout.fillWidth: true
                Layout.rightMargin: 90
                text: row.path
                color: "#7d8796"
                font.family: fonts.jetBrainsMB.family
                font.pixelSize: 9
                elide: Text.ElideMiddle
            }

            // "PostgreSQL · 12 tables · 18 relations" или "ClickHouse · 24 tables · read-only"
            Text {
                // %n нужен для падежей в русском: 1 таблица 2 таблицы 5 таблиц
                text: row.engine + " · " + qsTr("%n table(s)", "", row.tables) + " · "
                      + (row.readOnly ? qsTr("read-only") : qsTr("%n relation(s)", "", row.relations))
                color: "#a1a9b7"
                font.pixelSize: 10
            }
        }

        // стрелка вправо
        LineIcon {
            Layout.preferredWidth: 12
            Layout.preferredHeight: 12
            color: row.hovered ? "#52d6a6" : "#7d8796"
            pathData: "M6 3.5L10.5 8L6 12.5"
        }
    }

    // дата в правом верхнем углу
    Text {
        anchors.top: parent.top
        anchors.topMargin: 10
        anchors.right: parent.right
        anchors.rightMargin: 34
        text: row.lastOpened
        color: "#7d8796"
        font.pixelSize: 9
    }

    // крестик лежит поверх строки поэтому клик по нему не открывает проект
    T.AbstractButton {
        id: removeBtn
        width: 20
        height: 20
        padding: 5
        anchors.right: parent.right
        anchors.rightMargin: 30
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 8
        hoverEnabled: true

        ToolTip.visible: hovered
        ToolTip.delay: 500
        ToolTip.text: qsTr("Remove from list")

        contentItem: LineIcon {
            viewBox: 10
            color: removeBtn.hovered ? "#f08a8a" : "#4b5563"
            pathData: "M1.5 1.5L8.5 8.5 M8.5 1.5L1.5 8.5"
        }

        onClicked: row.removeRequested()
    }

    HoverHandler {
        cursorShape: Qt.PointingHandCursor
    }
}
