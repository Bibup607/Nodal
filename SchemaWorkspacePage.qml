import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "CustomButtons"

Item {
    Rectangle {
        anchors.fill: parent
        color: "#0D1117"
    }

    FontLoader {
          id: interBold
          source: "qrc:/fonts/Inter_18pt-Bold.ttf"
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        Rectangle {   // фон всей шапки
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

                RowLayout { // левая зона лого

                    Image {
                            width: 28
                            height: 28
                            source: "qrc:/Images/logo.svg"
                    }

                    Text {
                            text: "Nodal"
                            font.family: interBold.font.family
                            font.pixelSize: 16
                            font.bold: true
                            color: "white"
                    }
                }

                Item { Layout.fillWidth: true }

                RowLayout { // центр инструменты
                    ToolbarButton {

                        imageSource: "qrc:/Images/select-icon-active.svg"
                            // source: control.checked ? "qrc:/Images/select-icon-active.svg" : "qrc:/Images/select.svg"

                        text: "Select"
                        Layout.preferredWidth: 90
                        Layout.preferredHeight: 35
                    }
                    ToolbarButton {

                        Image {
                            source: ""
                        }
                            text: "Pan"
                            Layout.preferredWidth: 90
                            Layout.preferredHeight: 35
                    }
                    ToolbarButton {

                        Image {
                            source: ""
                        }
                            text: "Table"
                            Layout.preferredWidth: 90
                            Layout.preferredHeight: 35
                    }
                    ToolbarButton {

                        Image {
                            source: ""
                        }
                            text: "Relation"
                            Layout.preferredWidth: 90
                            Layout.preferredHeight: 35
                    }
                }

                Item { Layout.fillWidth: true }

                RowLayout { // правая зона

                    ImportButton {
                                text: "Save"
                                font.bold: true
                                Layout.preferredWidth: 90
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

                WindowControls {
                        onCloseRequested: Window.window.close()
                        onMinimizeRequested: Window.window.showMinimized()
                        onMaximizeRequested: {
                            if (Window.window.visibility === Window.Maximized) {
                                        Window.window.showNormal()
                            }
                            else {
                                        Window.window.showMaximized()
                            }
                        }
                }
            }
        }

        // тело страницы сайдбар + будущий канвас
        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 0

            Rectangle {
                Layout.preferredWidth: 206
                Layout.fillHeight: true
                color: "#11151c"

            Rectangle {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.bottomMargin: Window.window.visibility === Window.Maximized ? 885 : 660
                height: 1
                color: "#252c37"
            }

            Rectangle {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 45
                height: 1
                color: "#252c37"
            }

            Rectangle {
                // барьер справа
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

                        TextField {

                            Image {
                                source: "qrc:/Images/search.svg"
                                width: 13
                                height: 13

                                anchors {
                                    left: parent.left
                                    leftMargin: 10
                                    verticalCenter: parent.verticalCenter
                                }
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

                        Item { Layout.fillHeight: true }
                    }
            }

            // Место под будущий канвас
            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true
            }
        }
    }
}