import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

Rectangle {
    id: root
    width: 250
    implicitHeight: mainLayout.implicitHeight + 24

    x: model.posX
    y: model.posY

    property bool isSelected: workspaceCanvas.selectedTableIndex === index

    signal removeTable()
    signal selected()
    signal requestAddColumn()
    signal nameChanged(string newName)
    signal fieldKeyChanged(int fieldIndex, string keyType)
    signal fieldTypeChanged(int fieldIndex, string newType)

    color: "#121721"
    radius: 10
    border.width: isSelected ? 2 : 1
    border.color: isSelected ? "#34d399" : "#262f3f"

    MouseArea {
        anchors.fill: parent
        onClicked: {
            workspaceCanvas.selectedTableIndex = (workspaceCanvas.selectedTableIndex === index ? -1 : index)
            root.selected()
        }
    }

    // главная вертикальная колонка
    ColumnLayout {
        id: mainLayout
        anchors.fill: parent
        anchors.margins: 12
        spacing: 10

        Item {
            Layout.fillWidth: true
            implicitHeight: 14

            Rectangle {
                width: 36
                height: 4
                radius: 2
                color: handleMouseArea.pressed ? "#34d399" : (handleMouseArea.containsMouse ? "#475569" : "#1e293b")
            }

            MouseArea {
                id: handleMouseArea
                anchors.fill: parent
                hoverEnabled: true

                cursorShape: pressed ? Qt.ClosedHandCursor : Qt.OpenHandCursor
                drag.target: root

                onPressed: {
                    root.z = 100
                    root.forceActiveFocus()
                    workspaceCanvas.selectedTableIndex = index
                    root.selected()
                }

                onReleased: {
                    root.z = 1
                    model.posX = Math.round(root.x)
                    model.posY = Math.round(root.y)
                }
            }
        }

        // шапка таблицы
        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            Text {
                text: "⊞"
                font.pixelSize: 22
                color: root.isSelected ? "#34d399" : "#60a5fa"
            }

            TextField {
                placeholderText: model.tableName
                placeholderTextColor: "#64748b"
                maximumLength: 20
                text: ""
                color: "#ffffff"
                font.bold: true
                font.pixelSize: 14
                font.family: "Monospace"
                Layout.fillWidth: true
                background: null
                selectByMouse: true

                onAccepted: {
                    focus = false
                }

                // сохраняет введённое имя при нажатии ентер или потере фокуса.
                onEditingFinished: {
                    focus = false
                    if (text.trim() !== "") {
                        globalTablesModel.setTableName(index, text.trim())
                        root.nameChanged(text.trim())
                    }
                }
            }

            Text {
                text: "•••"
                color: "#64748b"
                font.pixelSize: 10

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: menuAction.open()
                }

                Menu {
                    id: menuAction
                    width: 95

                    MenuItem {
                        id: addColumnItem
                        text: "Add Column"
                        height: 28

                        onTriggered: {
                            root.requestAddColumn()
                        }

                        background: Rectangle {
                            implicitWidth: parent.width
                            implicitHeight: 28
                            radius: 4
                            color: addColumnItem.down ? "#1f4e43" : (addColumnItem.hovered ? "#183c35" : "transparent")

                            Behavior on color {
                                ColorAnimation { duration: 120 }
                            }
                        }

                        contentItem: Text {
                            text: addColumnItem.text
                            color: addColumnItem.down ? "#ffffff" : (addColumnItem.hovered ? "#52d6a6" : "#a1a9b7")
                            font.pixelSize: 10
                            font.family: "Monospace"
                            verticalAlignment: Text.AlignVCenter
                            leftPadding: 8

                            Behavior on color {
                                ColorAnimation { duration: 120 }
                            }
                        }
                    }

                    MenuItem {
                        id: delTable
                        text: "Del Table"
                        height: 28

                        onTriggered: {
                            root.removeTable()
                        }

                        background: Rectangle {
                            implicitWidth: parent.width
                            implicitHeight: 28
                            radius: 4
                            color: delTable.down ? "#541c24" : (delTable.hovered ? "#3d141b" : "transparent")

                            Behavior on color {
                                ColorAnimation { duration: 120 }
                            }
                        }

                        contentItem: Text {
                            text: delTable.text
                            color: delTable.down ? "#ffffff" : (delTable.hovered ? "#ef4444" : "#a1a9b7")
                            font.pixelSize: 10
                            font.family: "Monospace"
                            verticalAlignment: Text.AlignVCenter
                            leftPadding: 8

                            Behavior on color {
                                ColorAnimation { duration: 120 }
                            }
                        }
                    }

                    background: Rectangle {
                        color: "#11151C"
                        border.width: 1
                        border.color: "#252c37"
                        radius: 6
                    }
                }
            }
        }

        // тонкая линия разделитель под шапкой
        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: "#1e293b"
        }

        // список колонок
        Repeater {
            model: fields

            delegate: RowLayout {
                id: rowItem
                Layout.fillWidth: true
                spacing: 8

                readonly property int fieldRowIndex: index

                // слот индикатора PK / FK / точка
                Item {
                    id: badgeSlot
                    width: 24
                    height: 16
                    Layout.alignment: Qt.AlignVCenter

                    Rectangle {
                        anchors.fill: parent
                        visible: isPk
                        color: "#064e3b"
                        radius: 4

                        Text {
                            anchors.centerIn: parent
                            text: "PK"
                            color: "#34d399"
                            font.pixelSize: 9
                            font.bold: true
                            font.family: "Monospace"
                        }
                    }

                    Rectangle {
                        anchors.fill: parent
                        visible: !isPk && isFk
                        color: "#1e3a5f"
                        radius: 4

                        Text {
                            anchors.centerIn: parent
                            text: "FK"
                            color: "#60a5fa"
                            font.pixelSize: 9
                            font.bold: true
                            font.family: "Monospace"
                        }
                    }

                    Rectangle {
                        anchors.centerIn: parent
                        visible: !isPk && !isFk
                        width: 8
                        height: 8
                        radius: 4
                        color: "#121721"
                    }

                    MouseArea {
                        id: keyMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            root.forceActiveFocus()
                            keyMenu.open()
                        }
                    }

                    Menu {
                        id: keyMenu
                        y: badgeSlot.height + 4
                        width: 170
                        padding: 4

                        background: Rectangle {
                            color: "#11151c"
                            border.color: "#252c37"
                            border.width: 1
                            radius: 8
                        }

                        delegate: MenuItem {
                            id: menuItem
                            implicitHeight: 28

                            contentItem: Text {
                                leftPadding: 6
                                text: menuItem.text
                                font.family: "Monospace"
                                font.pixelSize: 11
                                font.bold: menuItem.highlighted
                                // подсветка при наведении
                                color: menuItem.highlighted ? "#52d6a6" : "#cbd5e1"
                                verticalAlignment: Text.AlignVCenter
                            }

                            background: Rectangle {
                                radius: 4
                                // подсветка фона выбранного пункта
                                color: menuItem.highlighted ? "#1b222c" : "transparent"
                            }
                        }

                        Action {
                            text: "PK"
                            onTriggered: root.fieldKeyChanged(rowItem.fieldRowIndex, "PK")
                        }

                        Action {
                            text: "FK"
                            onTriggered: root.fieldKeyChanged(rowItem.fieldRowIndex, "FK")
                        }

                        Action {
                            text: "NONE"
                            onTriggered: root.fieldKeyChanged(rowItem.fieldRowIndex, "NONE")
                        }
                    }
                }

                // имя поля
                TextField {
                    placeholderText: "..."
                    placeholderTextColor: "#64748b"
                    maximumLength: 20
                    text: ""
                    color: "#cbd5e1"
                    font.family: "Monospace"
                    font.pixelSize: 12
                    Layout.fillWidth: true
                    background: null
                    selectByMouse: true

                    onAccepted: {
                        focus = false
                    }
                }

                Item {
                    id: typeSelector
                    implicitWidth: typeText.implicitWidth + 8
                    implicitHeight: 20
                    Layout.alignment: Qt.AlignRight

                    Rectangle {
                        anchors.fill: parent
                        radius: 4
                        color: typeMouseArea.containsMouse ? "#1e293b" : "transparent"
                    }

                    Text {
                        id: typeText
                        anchors.fill: parent
                        text: type
                        color: typeMouseArea.containsMouse ? "#c4b5fd" : "#a78bfa"
                        font.pixelSize: 12
                    }

                    MouseArea {
                        id: typeMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            root.forceActiveFocus()
                            typeMenu.open()
                        }
                    }

                    Menu {
                        id: typeMenu
                        y: typeSelector.height + 4
                        width: 130
                        padding: 4

                        background: Rectangle {
                            color: "#11151c"
                            border.color: "#252c37"
                            border.width: 1
                            radius: 8
                        }

                        delegate: MenuItem {
                            id: typeMenuItem
                            implicitHeight: 26

                            contentItem: Text {
                                leftPadding: 6
                                text: typeMenuItem.text
                                font.family: "Monospace"
                                font.pixelSize: 11
                                font.bold: typeMenuItem.highlighted
                                color: typeMenuItem.highlighted ? "#c4b5fd" : "#cbd5e1"
                                verticalAlignment: Text.AlignVCenter
                            }

                            background: Rectangle {
                                radius: 4
                                color: typeMenuItem.highlighted ? "#1b222c" : "transparent"
                            }
                        }
                        // Список основных типов PostgreSQL
                        Action { text: "uuid"; onTriggered: root.fieldTypeChanged(fieldRowIndex, "uuid") }
                        Action { text: "serial"; onTriggered: root.fieldTypeChanged(fieldRowIndex, "serial") }
                        Action { text: "bigserial"; onTriggered: root.fieldTypeChanged(fieldRowIndex, "bigserial") }

                        // Целые числа
                        Action { text: "smallint"; onTriggered: root.fieldTypeChanged(fieldRowIndex, "smallint") }
                        Action { text: "integer"; onTriggered: root.fieldTypeChanged(fieldRowIndex, "integer") }
                        Action { text: "bigint"; onTriggered: root.fieldTypeChanged(fieldRowIndex, "bigint") }

                        // Дробные и точные числа
                        Action { text: "numeric"; onTriggered: root.fieldTypeChanged(fieldRowIndex, "numeric") }
                        Action { text: "real"; onTriggered: root.fieldTypeChanged(fieldRowIndex, "real") }
                        Action { text: "double"; onTriggered: root.fieldTypeChanged(fieldRowIndex, "double") }

                        // Строки и текст
                        Action { text: "varchar"; onTriggered: root.fieldTypeChanged(fieldRowIndex, "varchar") }
                        Action { text: "char"; onTriggered: root.fieldTypeChanged(fieldRowIndex, "char") }
                        Action { text: "text"; onTriggered: root.fieldTypeChanged(fieldRowIndex, "text") }

                        // Логический
                        Action { text: "boolean"; onTriggered: root.fieldTypeChanged(fieldRowIndex, "boolean") }

                        // Дата и время
                        Action { text: "date"; onTriggered: root.fieldTypeChanged(fieldRowIndex, "date") }
                        Action { text: "time"; onTriggered: root.fieldTypeChanged(fieldRowIndex, "time") }
                        Action { text: "timestamp"; onTriggered: root.fieldTypeChanged(fieldRowIndex, "timestamp") }
                        Action { text: "timestamptz"; onTriggered: root.fieldTypeChanged(fieldRowIndex, "timestamptz") }

                        // Документы и бинарники
                        Action { text: "json"; onTriggered: root.fieldTypeChanged(fieldRowIndex, "json") }
                        Action { text: "jsonb"; onTriggered: root.fieldTypeChanged(fieldRowIndex, "jsonb") }
                        Action { text: "bytea"; onTriggered: root.fieldTypeChanged(fieldRowIndex, "bytea") }

                        // Сеть
                        Action { text: "inet"; onTriggered: root.fieldTypeChanged(fieldRowIndex, "inet") }
                    }
                }

                Rectangle {
                    id: connectorPort
                    width: 8
                    height: 8
                    radius: 4
                    Layout.alignment: Qt.AlignVCenter

                    color: portMouseArea.containsMouse ? "#52d6a6" : "#262f3f"
                    border.width: 1
                    border.color: portMouseArea.containsMouse ? "#ffffff" : "#52d6a6"

                    MouseArea {
                        id: portMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.CrossCursor

                        onPressed: (mouse) => {
                            relationMenu.open()
                        }
                    }

                    Menu {
                        id: relationMenu
                        y: connectorPort.height + 4
                        width: 80
                        padding: 4

                        background: Rectangle {
                            color: "#11151c"
                            border.color: "#252c37"
                            border.width: 1
                            radius: 8
                        }

                        delegate: MenuItem {
                            id: relMenuItem
                            implicitHeight: 28

                            contentItem: Text {
                                text: relMenuItem.text
                                font.family: "Monospace"
                                font.pixelSize: 11
                                font.bold: relMenuItem.highlighted
                                color: relMenuItem.highlighted ? "#52d6a6" : "#cbd5e1"
                                verticalAlignment: Text.AlignVCenter
                            }

                            background: Rectangle {
                                radius: 4
                                color: relMenuItem.highlighted ? "#1b222c" : "transparent"
                            }
                        }

                        Action {
                            text: "1 : 1"
                            onTriggered: console.log("Selected 1:1 for field", rowItem.fieldRowIndex)
                        }

                        Action {
                            text: "1 : M"
                            onTriggered: console.log("Selected 1:M for field", rowItem.fieldRowIndex)
                        }

                        Action {
                            text: "M : 1"
                            onTriggered: console.log("Selected M:1 for field", rowItem.fieldRowIndex)
                        }

                        Action {
                            text: "M : M"
                            onTriggered: console.log("Selected M:M for field", rowItem.fieldRowIndex)
                        }
                    }
                }
            }
        }
    }
}