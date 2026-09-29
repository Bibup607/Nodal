import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window

import NodalDB
import "CustomButtons"
import "SideBar"

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

                    ToolbarButton {
                        imageSource: "qrc:/Images/table.svg"
                        imageSourceActive: "qrc:/Images/table-icon-active.svg"
                        text: "Table"
                        leftPadding: 12
                        Layout.preferredWidth: 65
                        Layout.preferredHeight: 35
                    }

                    ToolbarButton {
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

                    // База данных и список таблиц
                    ColumnLayout {
                        Layout.fillWidth: true
                        Layout.leftMargin: 10
                        Layout.topMargin: 10
                        spacing: 8

                        Row {
                            spacing: 8

                            Image {
                                id: chevronIcon
                                rotation: 0
                                width: 13
                                height: 13
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
                            }

                            Text {
                                text: "commerce_db"
                                color: "white"
                                font.family: fonts.jetBrainsMB.family
                                font.pointSize: 9
                            }
                        }

                        TablesModel {
                            Layout.fillWidth: true
                        }
                    }

                    Item { Layout.fillHeight: true }
                }
            }

            // Центральная зона (Рабочий канвас)
            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true

                Text {
                    anchors.centerIn: parent
                    text: "Рабочая область готова под бесконечный канвас"
                    color: "#30363d"
                    font.pointSize: 14
                }
            }
        }
    }
}