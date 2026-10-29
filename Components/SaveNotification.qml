import QtQuick
import QtQuick.Layouts
import "../"

Rectangle {
    id: root

    anchors.right: parent.right
    anchors.rightMargin: 20
    anchors.bottom: parent.bottom
    anchors.bottomMargin: 20
    z: 1000

    implicitWidth: row.implicitWidth + 28
    implicitHeight: 44
    radius: 10
    color: "#13181F"
    border.width: 1
    border.color: "#252C37"

    visible: false
    opacity: 0

    property string fileName: ""
    // заголовок уведомления; пусто — «Project saved»
    property string message: ""
    property bool isError: false
    property real offset: 10

    transform: Translate { y: root.offset }

    // show("a.schema") — проект сохранён; show("a.sql", qsTr("SQL exported")) — свой заголовок
    function showError(text, details) {
        show(details, text)
        isError = true
    }

    function show(name, text) {
        isError = false
        fileName = name
        message = text || ""
        hideAnim.stop()
        if (!visible) {
            opacity = 0
            offset = 10
            visible = true
        }
        showAnim.restart()
        hideTimer.restart()
    }

    Fonts {
        id: fonts
    }

    RowLayout {
        id: row
        anchors.left: parent.left
        anchors.leftMargin: 12
        anchors.verticalCenter: parent.verticalCenter
        spacing: 10

        Rectangle {
            Layout.preferredWidth: 24
            Layout.preferredHeight: 24
            radius: 12
            color: root.isError ? "#3D141B" : "#183C35"

            LineIcon {
                anchors.centerIn: parent
                width: 12
                height: 12
                pathData: root.isError ? "M4 4L12 12M12 4L4 12" : "M3 8.5L6.2 11.5L13 4.5"
                color: root.isError ? "#EF4444" : "#52D6A6"
                lineWidth: 2.67
            }
        }

        Text {
            text: root.message !== "" ? root.message : qsTr("Project saved")
            color: "#FFFFFF"
            font.pixelSize: 12
            font.weight: Font.DemiBold
        }

        Text {
            text: root.fileName
            color: "#7D8796"
            font.family: fonts.jetBrainsMB.family
            font.pixelSize: 11
            elide: Text.ElideMiddle
            Layout.maximumWidth: 220
        }
    }

    ParallelAnimation {
        id: showAnim
        NumberAnimation { target: root; property: "opacity"; to: 1; duration: 180; easing.type: Easing.OutCubic }
        NumberAnimation { target: root; property: "offset"; to: 0; duration: 180; easing.type: Easing.OutCubic }
    }

    SequentialAnimation {
        id: hideAnim
        NumberAnimation { target: root; property: "opacity"; to: 0; duration: 150 }
        PropertyAction { target: root; property: "visible"; value: false }
    }

    Timer {
        id: hideTimer
        interval: 3000
        onTriggered: hideAnim.start()
    }
}
