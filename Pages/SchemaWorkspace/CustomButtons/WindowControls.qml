import QtQuick
import QtQuick.Window

Row {
    id: windowControls
    spacing: 2

    signal closeRequested()
    signal minimizeRequested()
    signal maximizeRequested()

    readonly property bool isMaximized: Window.window ? Window.window.visibility === Window.Maximized : false

    component WinButton: Rectangle {
        id: btn

        property bool isDestructive: false
        readonly property bool hovered: btnMouse.containsMouse
        readonly property color iconColor: hovered ? (isDestructive ? "#ef4444" : "#52d6a6") : "#a1a9b7"

        signal clicked()

        width: 40
        height: 30
        radius: 6
        color: btnMouse.pressed
               ? (isDestructive ? "#3d141b" : "#183c35")
               : (hovered ? (isDestructive ? "#2d1519" : "#1b222c") : "transparent")

        Behavior on color { ColorAnimation { duration: 150 } }

        MouseArea {
            id: btnMouse
            anchors.fill: parent
            hoverEnabled: true
            onClicked: btn.clicked()
        }
    }

    // свернуть
    WinButton {
        onClicked: windowControls.minimizeRequested()

        Rectangle {
            anchors.centerIn: parent
            width: 10
            height: 1
            color: parent.iconColor
        }
    }

    // развернуть / восстановить
    WinButton {
        id: maxBtn
        onClicked: windowControls.maximizeRequested()

        Rectangle {
            visible: !windowControls.isMaximized
            anchors.centerIn: parent
            width: 10
            height: 10
            radius: 1
            color: "transparent"
            border.width: 1
            border.color: maxBtn.iconColor
        }

        Item {
            visible: windowControls.isMaximized
            anchors.centerIn: parent
            width: 10
            height: 10

            Rectangle {
                x: 2
                y: 0
                width: 8
                height: 8
                radius: 1
                color: "transparent"
                border.width: 1
                border.color: maxBtn.iconColor
            }

            Rectangle {
                x: 0
                y: 2
                width: 8
                height: 8
                radius: 1
                color: Qt.tint("#11151C", maxBtn.color)
                border.width: 1
                border.color: maxBtn.iconColor
            }
        }
    }

    // закрыть
    WinButton {
        id: closeBtn
        isDestructive: true // при наведении кнопка красная а не зеленая
        onClicked: windowControls.closeRequested()

        Rectangle {
            anchors.centerIn: parent
            width: 13
            height: 1
            antialiasing: true // сглаживание краев чтобы повернутая линия не была лесенкой
            rotation: 45
            color: closeBtn.iconColor
        }

        Rectangle {
            anchors.centerIn: parent
            width: 13
            height: 1
            antialiasing: true
            rotation: -45
            color: closeBtn.iconColor
        }
    }
}
