import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window

import NodalDB
import "../../"
import "Tables"
import "CustomButtons"


Item {
    id: workspaceRoot
    anchors.fill: parent

    Rectangle {
        anchors.fill: parent
        color: "#0D1117"
    }

    Fonts {
        id: fonts
    }

    TableItemsView {
        id: globalTablesModel
    }

    TablesFilterProxyModel {
        id: filteredTablesModel
        sourceModel: globalTablesModel      // говорим, откуда брать таблицы
        filterPattern: searchField.text     // привязываем к тексту из строки поиска
    }

    Component.onCompleted: {
        globalTablesModel.addNewTable(150, 150)
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // Верхняя шапка (Тулбар)
        Rectangle {
            Layout.fillWidth: true
            height: 52
            border {
                color: "#252c37"
                width: 1
            }
            color: "#11151C"

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 12
                anchors.rightMargin: 12

                // Логотип
                RowLayout {
                    spacing: 8
                    Image {
                        width: 28
                        height: 28
                        source: "qrc:/Images/logo.svg"
                    }

                    Text {
                        text: "Nodal"
                        font.family: fonts.interBold.family
                        font.pixelSize: 16
                        font.bold: true
                        color: "white"
                    }
                }

                Item { Layout.fillWidth: true }

                // Инструменты по центру
                RowLayout {
                    spacing: 4

                    ToolbarButton {
                        id: selectBtn
                        imageSource: "qrc:/Images/select.svg"
                        imageSourceActive: "qrc:/Images/select-icon-active.svg"
                        text: "Select"
                        leftPadding: 10
                        checked: true
                        Layout.preferredWidth: 70
                        Layout.preferredHeight: 35
                    }

                    ToolbarButton {
                        id: panBtn
                        imageSource: "qrc:/Images/pan.svg"
                        imageSourceActive: "qrc:/Images/pan-icon-active.svg"
                        text: "Pan"
                        leftPadding: 15
                        Layout.preferredWidth: 60
                        Layout.preferredHeight: 35
                    }

                    Rectangle {
                        id: addTableBtn
                        Layout.preferredWidth: 65
                        Layout.preferredHeight: 35
                        radius: 6

                        readonly property color normalBg: "#11151c"
                        readonly property color activeBg: "#183c35"

                        readonly property color normalBorder: "#252c37"
                        readonly property color activeBorder: "#52d6a6"

                        readonly property color normalText: "#a1a9b7"
                        readonly property color activeText: "#52d6a6"

                        color: (mouseArea.pressed || mouseArea.containsMouse) ? activeBg : normalBg
                        border.width: 1
                        border.color: (mouseArea.pressed || mouseArea.containsMouse) ? activeBorder : normalBorder

                        Behavior on color {
                            ColorAnimation { duration: 150 }
                        }

                        Behavior on border.color {
                            ColorAnimation { duration: 150 }
                        }

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 10
                            anchors.rightMargin: 8
                            spacing: 6

                            Image {
                                id: btnIcon
                                source: (mouseArea.pressed || mouseArea.containsMouse) ? "qrc:/Images/table-icon-active.svg" : "qrc:/Images/table.svg"
                                sourceSize.width: 13
                                sourceSize.height: 13
                                Layout.alignment: Qt.AlignVCenter
                            }

                            Text {
                                id: btnText
                                text: "Table"
                                color: (mouseArea.pressed || mouseArea.containsMouse) ? addTableBtn.activeText : addTableBtn.normalText
                                font.pixelSize: 12
                                font.family: "Monospace"
                                Layout.alignment: Qt.AlignVCenter

                                Behavior on color {
                                    ColorAnimation { duration: 150 }
                                }
                            }
                        }

                        MouseArea {
                            id: mouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor

                            onClicked: {
                                let spawnX = (-workspaceCanvas.panX + 200) / workspaceCanvas.zoom
                                let spawnY = (-workspaceCanvas.panY + 150) / workspaceCanvas.zoom
                                globalTablesModel.addNewTable(spawnX, spawnY)
                            }
                        }
                    }

                    ToolbarButton {
                        id: relationBtn
                        imageSource: "qrc:/Images/relation.svg"
                        imageSourceActive: "qrc:/Images/relation-icon-active.svg"
                        text: "Relation"
                        leftPadding: 15
                        Layout.preferredWidth: 80
                        Layout.preferredHeight: 35
                    }
                }

                Item { Layout.fillWidth: true }

                // Правые кнопки экспорта
                RowLayout {
                    spacing: 8

                    ImportButton {
                        text: "Save"
                        font.bold: true
                        Layout.preferredWidth: 60
                        Layout.preferredHeight: 30
                    }

                    ImportButton {
                        text: "Export SQL"
                        font.bold: true
                        Layout.preferredWidth: 90
                        Layout.preferredHeight: 30
                    }
                }

                Item { Layout.fillWidth: true }

                // Кнопки управления окном
                WindowControls {
                    onCloseRequested: {
                        if (Window.window) Window.window.close()
                    }
                    onMinimizeRequested: {
                        if (Window.window) Window.window.showMinimized()
                    }
                    onMaximizeRequested: {
                        if (!Window.window) return
                        if (Window.window.visibility === Window.Maximized) {
                            Window.window.showNormal()
                        } else {
                            Window.window.showMaximized()
                        }
                    }
                }
            }
        }

        // Рабочая зона: Сайдбар + Канвас
        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 0

            // Левый сайдбар (SCHEMA EXPLORER)
            Rectangle {
                Layout.preferredWidth: 206
                Layout.fillHeight: true
                color: "#11151c"

                // Разделительная граница справа от сайдбара
                Rectangle {
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    anchors.right: parent.right
                    width: 1
                    color: "#252c37"
                }

                ColumnLayout {
                    anchors.fill: parent
                    spacing: 8

                    Text {
                        text: "SCHEMA EXPLORER"
                        color: "#a1a9b7"
                        font.bold: true
                        Layout.alignment: Qt.AlignLeft
                        Layout.leftMargin: 14
                        Layout.topMargin: 14
                    }

                    // Поле поиска
                    TextField {
                        id: searchField

                        Image {
                            source: "qrc:/Images/search.svg"
                            width: 13
                            height: 13
                            anchors.left: parent.left
                            anchors.leftMargin: 10
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        placeholderText: "Filter tables..."
                        placeholderTextColor: "#a1a9b7"
                        color: "#a1a9b7"
                        font.pointSize: 10
                        Layout.alignment: Qt.AlignLeft
                        Layout.leftMargin: 14
                        Layout.preferredWidth: 178
                        leftPadding: 30

                        background: Rectangle {
                            color: "#0d1117"
                            border.color: "#252c37"
                            border.width: 1
                            radius: 6
                        }
                    }

                    // Область прокрутки списка
                    ScrollView {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        clip: true

                        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

                        // Скроллбар
                        ScrollBar.vertical: ScrollBar {
                            parent: parent
                            anchors.top: parent.top
                            anchors.bottom: parent.bottom
                            anchors.right: parent.right
                            anchors.rightMargin: 1
                            width: 3
                            policy: ScrollBar.AsNeeded

                            contentItem: Rectangle {
                                implicitWidth: 3
                                radius: 1.5
                                color: parent.pressed ? "#52d6a6" : (parent.hovered ? "#475569" : "#262f3f")

                                Behavior on color {
                                    ColorAnimation { duration: 150 }
                                }
                            }

                            background: Rectangle {
                                color: "transparent"
                            }
                        }

                        // База данных и список таблиц
                        Column {
                            width: 206
                            height: implicitHeight
                            spacing: 8
                            topPadding: 10
                            bottomPadding: 16

                            Item {
                                width: 178
                                height: 22
                                x: 14

                                Row {
                                    anchors.left: parent.left
                                    anchors.verticalCenter: parent.verticalCenter
                                    spacing: 8

                                    Image {
                                        id: chevronIcon
                                        rotation: 0
                                        width: 13
                                        height: 13
                                        anchors.verticalCenter: parent.verticalCenter
                                        source: "qrc:/Images/chevron-down.svg"

                                        Behavior on rotation {
                                            NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
                                        }

                                        MouseArea {
                                            anchors.fill: parent
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: chevronIcon.rotation = (chevronIcon.rotation === 0 ? 180 : 0)
                                        }
                                    }

                                    Image {
                                        source: "qrc:/Images/database.svg"
                                        width: 14
                                        height: 14
                                        anchors.verticalCenter: parent.verticalCenter
                                    }

                                    Text {
                                        text: "commerce_db"
                                        color: "white"
                                        font.family: fonts.jetBrainsMB.family
                                        font.pointSize: 9
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                }

                                Text {
                                    text: filteredTablesModel.count
                                    color: "#64748b"
                                    font.family: fonts.jetBrainsMB.family
                                    font.pointSize: 9
                                    anchors.right: parent.right
                                    anchors.rightMargin: 12
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                            }

                            // Список карточек таблиц
                            Repeater {
                                model: filteredTablesModel

                                delegate: Item {
                                    width: 178
                                    height: 30
                                    x: 14

                                    readonly property int realIndex: filteredTablesModel.mapToSourceRow(index)
                                    property bool isSelected: workspaceCanvas.selectedTableIndex === realIndex

                                    Rectangle {
                                        id: rowBg
                                        anchors.fill: parent
                                        radius: 6

                                        property color normalColorbg: "transparent"
                                        property color activeColorbg: "#183c35"
                                        property color normalColort: "#a1a9b7"
                                        property color activeColort: "#52d6a6"

                                        color: (isSelected || rowMouse.containsMouse) ? activeColorbg : normalColorbg

                                        Behavior on color {
                                            ColorAnimation { duration: 150 }
                                        }

                                        MouseArea {
                                            id: rowMouse
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: {
                                                workspaceCanvas.selectedTableIndex = (workspaceCanvas.selectedTableIndex === realIndex ? -1 : realIndex)
                                            }
                                        }

                                        Text {
                                            text: model.tableName
                                            color: (isSelected || rowMouse.containsMouse) ? rowBg.activeColort : rowBg.normalColort
                                            font.family: fonts.jetBrainsMB.family
                                            font.pointSize: 8
                                            anchors.left: parent.left
                                            anchors.leftMargin: 12
                                            anchors.verticalCenter: parent.verticalCenter

                                            Behavior on color {
                                                ColorAnimation { duration: 150 }
                                            }
                                        }

                                        Text {
                                            text: model.fields ? model.fields.count : 0
                                            font.family: fonts.jetBrainsMB.family
                                            color: (isSelected || rowMouse.containsMouse) ? rowBg.activeColort : rowBg.normalColort
                                            font.pointSize: 8
                                            anchors.right: parent.right
                                            anchors.rightMargin: 30
                                            anchors.verticalCenter: parent.verticalCenter

                                            Behavior on color {
                                                ColorAnimation { duration: 150 }
                                            }
                                        }

                                        Text {
                                            id: dotsBtn
                                            text: "⋮"
                                            color: dotsMouse.containsMouse || tableAction.visible ? "#52d6a6" : "#a1a9b7"
                                            font.pointSize: 15
                                            anchors.right: parent.right
                                            anchors.rightMargin: 9
                                            anchors.verticalCenter: parent.verticalCenter

                                            MouseArea {
                                                id: dotsMouse
                                                anchors.fill: parent
                                                hoverEnabled: true
                                                cursorShape: Qt.PointingHandCursor
                                                onClicked: tableAction.open()
                                            }

                                            Menu {
                                                id: tableAction
                                                y: dotsBtn.height + 4
                                                width: 140
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

                                                    // Проверяем, помечен ли action как деструктивный
                                                    readonly property bool isDestructive: menuItem.action && menuItem.action.isDestructive === true

                                                    contentItem: Text {
                                                        text: menuItem.text
                                                        font.family: "Monospace"
                                                        font.pixelSize: 11
                                                        font.bold: menuItem.highlighted

                                                        // Красный текст для удаления, иначе изумрудный
                                                        color: menuItem.highlighted
                                                               ? (menuItem.isDestructive ? "#ef4444" : "#52d6a6")
                                                               : "#cbd5e1"

                                                        verticalAlignment: Text.AlignVCenter
                                                        leftPadding: 8

                                                        Behavior on color {
                                                            ColorAnimation { duration: 150 }
                                                        }
                                                    }

                                                    background: Rectangle {
                                                        radius: 4

                                                        // Тёмно-красный фон при наведении на удаление, иначе тёмно-зеленый/серый
                                                        color: menuItem.highlighted
                                                               ? (menuItem.isDestructive ? "#2d1519" : "#1b222c")
                                                               : "transparent"

                                                        Behavior on color {
                                                            ColorAnimation { duration: 150 }
                                                        }
                                                    }
                                                }

                                                Action {
                                                    text: "Rename table"
                                                    onTriggered: rowDelegate.isEditing = true
                                                }

                                                Action {
                                                    text: "Add column"
                                                    onTriggered: globalTablesModel.addColumn(realIndex)
                                                }

                                                Action {
                                                    text: "Add comment"
                                                    onTriggered: globalTablesModel.addComment(realIndex)
                                                }

                                                Action {
                                                    text: "Duplicate table"
                                                    onTriggered: globalTablesModel.duplicateTable(realIndex)
                                                }

                                                Action {
                                                    text: "Delete table"
                                                    property bool isDestructive: true
                                                    onTriggered: globalTablesModel.removeTable(realIndex)
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }

            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true

                InfiniteCanvas {
                    id: workspaceCanvas
                    anchors.fill: parent
                    tablesModel: globalTablesModel

                    Rectangle {
                        id: tableCard

                        DragHandler {
                            id: cardDragHandler
                            target: tableCard
                            acceptedButtons: Qt.LeftButton
                            grabPermissions: PointerHandler.TakeOverForbidden | PointerHandler.CanTakeOverFromItems

                            xAxis.onActiveValueChanged: (delta) => {
                                tableCard.x += delta / workspaceCanvas.zoom
                            }
                            yAxis.onActiveValueChanged: (delta) => {
                                tableCard.y += delta / workspaceCanvas.zoom
                            }
                        }
                    }
                }
            }
        }
    }
}