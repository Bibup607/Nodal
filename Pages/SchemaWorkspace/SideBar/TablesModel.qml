import QtQuick
import NodalDB

Item {
    width: 200
    height: 35

    Fonts {
        id: fonts
    }

    Image {
        source: "qrc:/Images/table-grid.svg"
        x: 26
        y: 10
        width: 14
        height: 14
    }

    Text {
        text: "users"
        font.family: fonts.jetBrainsMB.family
        font.pointSize: 9
        x: 47
        y: 10
        color: "#a1a9b7"
    }

    Text {
        id: tableCount
        text: "8"
        color: "#a1a9b7"
        font.pointSize: 9
        x: 170
        y: 10
    }
}