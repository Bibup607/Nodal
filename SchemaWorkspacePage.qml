import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "CustomButtons"

Item {
    id: window
    width: 1200
    height: 800
    visible: true

    // Rectangle {
    //     anchors.fill: parent
    //     color: "#0D1117"
    // }

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

                }
                Text { text: "Nodal" }
            }

            Item { Layout.fillWidth: true }

            RowLayout { // центр: инструменты
                Button { text: "Select" }
                Button { text: "Pan" }
                Button { text: "Table" }
                Button { text: "Relation" }
            }

            Item { Layout.fillWidth: true }

            RowLayout { // правая зона
                Button { text: "Export SQL" }
            }

            Item { Layout.fillWidth: true }

            WindowControls {
                    onCloseRequested: window.close()
                    onMinimizeRequested: window.showMinimized()
                    onMaximizeRequested: window.showMaximized()
            }
        }


    }
}
