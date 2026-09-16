import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "CustomButtons"

Item {
    // Rectangle {
    //     anchors.fill: parent
    //     color: "#0D1117"
    // }

    FontLoader {
          id: interBold
          source: "qrc:/fonts/Inter_18pt-Bold.ttf"
    }

    Rectangle {   // фон всей шапки
        width: parent.width
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

            RowLayout { // левая зона: лого + breadcrumb

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

            RowLayout { // центр: инструменты
                ToolbarButton {
                        text: "Select"
                        Layout.preferredWidth: 90
                        Layout.preferredHeight: 35
                }
                ToolbarButton {
                        text: "Pan"
                        Layout.preferredWidth: 90
                        Layout.preferredHeight: 35
                }
                ToolbarButton {
                        text: "Table"
                        Layout.preferredWidth: 90
                        Layout.preferredHeight: 35
                }
                ToolbarButton {
                        text: "Relation"
                        Layout.preferredWidth: 90
                        Layout.preferredHeight: 35
                }
            }

            Item { Layout.fillWidth: true }

            RowLayout { // правая зона

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
                    onMaximizeRequested: Window.window.showMaximized()
                    // Window.window — ссылка на реальное окно, доступна из любого Item
            }
        }


    }
}
