import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

Rectangle {
    id: root
    width: 250
    implicitHeight: mainLayout.implicitHeight + 24

    x: model.posX
    y: model.posY

    property bool isSelected: false

    signal selected()
    signal requestAddColumn()
    signal nameChanged(string newName)
    signal fieldKeyChanged(int fieldIndex, string keyType)

    color: "#121721"
    radius: 10
    border.width: isSelected ? 2 : 1
    border.color: isSelected ? "#34d399" : "#262f3f"

    MouseArea {
        anchors.fill: parent
        onClicked: {
            root.isSelected = true
            root.selected()
        }
    }

    // главная вертикальная колонка
    ColumnLayout {
        id: mainLayout
        anchors.fill: parent
        anchors.margins: 12
        spacing: 10

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
                    onClicked: root.requestAddColumn()
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

                // Имя поля
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

                // Тип данных поля
                Text {
                    text: type
                    color: "#a78bfa"
                    font.family: "Monospace"
                    font.pixelSize: 12
                    Layout.alignment: Qt.AlignRight
                }
            }
        }
    }
}