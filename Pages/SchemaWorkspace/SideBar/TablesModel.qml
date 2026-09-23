import QtQuick



Item {
    width: 200
    height: 35
    y: 30


   Image {
        source: "qrc:/Images/table-grid.svg"
        x: 26
        width: 14
        height: 14
    }

    Text {
        text: "users" // заглушка
        font.family: fonts.jetBrainsMB.family
        font.pointSize: 9
        x: 47
        color: "#a1a9b7"
    }

    Text {
        id: tableCount

        text: "8" // заглушка
        color: "#a1a9b7"

        font.pointSize: 9
        x: 170
    }
}

