import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import NodalDB   // для SqlTypes

Rectangle {
    id: root
    width: 250
    implicitHeight: mainLayout.implicitHeight + 24

    x: model.posX
    y: model.posY

    property bool isSelected: workspaceCanvas.selectedTableIndex === index
    readonly property int tableIndex: index
    property string dbEngine: "PostgreSQL"   // от неё зависит список типов в меню
    readonly property color tableColor: model.tableColor // чтобы связи брали цвет таблицы

    signal removeTable()
    signal selected()
    signal requestAddColumn()
    signal nameChanged(string newName)
    signal fieldKeyChanged(int fieldIndex, string keyType)
    signal fieldTypeChanged(int fieldIndex, string newType)
    signal fieldRenamed(int fieldIndex, string newName)
    signal relationStarted(int fieldIndex, string relType)
    signal portClicked(int fieldIndex)

    function portPoint(fieldIndex, rightSide) {
        let row = fieldsRepeater.count > fieldIndex ? fieldsRepeater.itemAt(fieldIndex) : null
        let rowCenterY = row ? mainLayout.y + row.y + row.height / 2 : height / 2
        return Qt.point(rightSide ? x + width : x, y + rowCenterY)
    }

    color: "#121721"
    radius: 10
    border.width: isSelected ? 2 : 1
    border.color: isSelected ? "#34d399" : "#262f3f"

    MouseArea {
        anchors.fill: parent
        onClicked: {
            // фокус на карточку чтобы Delete и Ctrl+C работали с таблицей а не с полем ввода
            root.forceActiveFocus()
            workspaceCanvas.selectedTableIndex = (workspaceCanvas.selectedTableIndex === index ? -1 : index)
            root.selected()
        }
    }

    // цветная полоска сверху карточки
    Rectangle {
        anchors.top: parent.top
        anchors.topMargin: root.border.width
        anchors.left: parent.left
        anchors.leftMargin: 12
        anchors.right: parent.right
        anchors.rightMargin: 12
        height: 3
        radius: 1.5
        color: model.tableColor

        Behavior on color {
            ColorAnimation { duration: 150 }
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
                color: model.tableColor
            }

            TextField {
                placeholderText: model.tableName
                placeholderTextColor: "#64748b"
                maximumLength: 64
                text: model.tableName
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
                    let newName = text.trim()
                    if (newName !== "" && newName !== model.tableName)
                        root.nameChanged(newName)
                    text = Qt.binding(() => model.tableName)
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

                FontMetrics {
                    id: menuActionFont
                    font.family: "Monospace"
                    font.pixelSize: 10
                }

                Menu {
                    id: menuAction

                    // ширина по самому длинному пункту вместе с подсказкой клавиш чтобы перевод не вылезал
                    width: {
                        let rowWidth = 0
                        for (let i = 0; i < count; ++i) {
                            let item = itemAt(i)
                            let w = menuActionFont.advanceWidth(item.text)
                            if (item.hint) w += 16 + menuActionFont.advanceWidth(item.hint)
                            rowWidth = Math.max(rowWidth, w)
                        }
                        return Math.max(95, Math.ceil(rowWidth) + 24 + leftPadding + rightPadding)
                    }

                    MenuItem {
                        id: addColumnItem
                        text: qsTr("Add Column")
                        height: 28
                        // подсказка клавиш справа
                        property string hint: "Ctrl+Enter"

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

                            Text {
                                anchors.right: parent.right
                                anchors.verticalCenter: parent.verticalCenter
                                rightPadding: 4
                                text: addColumnItem.hint
                                color: "#64748b"
                                font.pixelSize: 10
                                font.family: "Monospace"
                            }

                            Behavior on color {
                                ColorAnimation { duration: 120 }
                            }
                        }
                    }

                    MenuItem {
                        id: delTable
                        text: qsTr("Del Table")
                        height: 28
                        property string hint: "Del"

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

                            Text {
                                anchors.right: parent.right
                                anchors.verticalCenter: parent.verticalCenter
                                rightPadding: 4
                                text: delTable.hint
                                color: "#64748b"
                                font.pixelSize: 10
                                font.family: "Monospace"
                            }

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
            id: fieldsRepeater
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
                    maximumLength: 64
                    text: name
                    color: "#cbd5e1"
                    font.family: "Monospace"
                    font.pixelSize: 12
                    Layout.fillWidth: true
                    background: null
                    selectByMouse: true

                    onEditingFinished: {
                        let newName = text.trim()
                        if (newName !== "" && newName !== name)
                            root.fieldRenamed(rowItem.fieldRowIndex, newName)
                        text = Qt.binding(() => name)
                    }

                    onAccepted: focus = false
                    Keys.onEscapePressed: {
                        text = Qt.binding(() => name)
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

                    // создаёт по одному Action на каждый тип выбранной базы и кладёт их в typeMenu;
                    // сменилась база — список пересоздаётся сам
                    Instantiator {
                        model: SqlTypes.typesFor(root.dbEngine)
                        delegate: Action {
                            required property string modelData   // строка из списка, например "varchar"
                            text: modelData
                            onTriggered: root.fieldTypeChanged(rowItem.fieldRowIndex, modelData)
                        }
                        onObjectAdded: (index, object) => typeMenu.insertAction(index, object)
                        onObjectRemoved: (index, object) => typeMenu.removeAction(object)
                    }

                    Menu {
                        id: typeMenu
                        y: typeSelector.height + 4
                        width: 160   // шире для "double precision"
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
                        // пункты меню создаются из списка типов выбранной базы (см. Instantiator выше)
                    }
                }

                Rectangle {
                    id: connectorPort
                    width: 8
                    height: 8
                    radius: 4
                    Layout.alignment: Qt.AlignVCenter

                    readonly property bool isPending: workspaceCanvas.isConnecting
                                                      && workspaceCanvas.pendingTable === root.tableIndex
                                                      && workspaceCanvas.pendingField === rowItem.fieldRowIndex
                    readonly property bool isLit: portMouseArea.containsMouse || isPending

                    color: isLit ? "#52d6a6" : "#262f3f"
                    border.width: 1
                    border.color: isLit ? "#ffffff" : "#52d6a6"

                    MouseArea {
                        id: portMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.CrossCursor

                        onPressed: (mouse) => {
                            if (workspaceCanvas.isConnecting)
                                root.portClicked(rowItem.fieldRowIndex)
                            else
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
                            onTriggered: root.relationStarted(rowItem.fieldRowIndex, "1:1")
                        }

                        Action {
                            text: "1 : M"
                            onTriggered: root.relationStarted(rowItem.fieldRowIndex, "1:M")
                        }

                        Action {
                            text: "M : 1"
                            onTriggered: root.relationStarted(rowItem.fieldRowIndex, "M:1")
                        }
                    }
                }
            }
        }
    }
}