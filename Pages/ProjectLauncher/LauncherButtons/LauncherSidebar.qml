import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import NodalDB

// левая панель стартового экрана
Rectangle {
    id: sidebar

    implicitWidth: 206
    color: "#11151c"

    property int recentCount: 0
    // код текущего языка ru или en
    property string language: "en"
    property url docsUrl: "https://github.com/"
    property string versionText: "Qt 6.11.1 · local workspace · v1.0.0"

    signal recentRequested()
    signal openFileRequested()
    signal createProjectRequested()
    signal languageSelected(string code)

    Fonts {
        id: fonts
    }

    // линия справа
    Rectangle {
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        width: 1
        color: "#252c37"
    }

    // активной может быть только одна кнопка та что нажата последней
    ButtonGroup {
        id: navGroup
    }

    component GroupTitle: Text {
        Layout.leftMargin: 2
        Layout.bottomMargin: 2
        color: "#a1a9b7"
        font.pixelSize: 9
        font.bold: true
        font.letterSpacing: 0.6
    }

    ColumnLayout {
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.topMargin: 16
        anchors.leftMargin: 10
        anchors.rightMargin: 10
        spacing: 4

        GroupTitle {
            text: qsTr("GET STARTED")
        }

        LauncherNavItem {
            Layout.fillWidth: true
            text: qsTr("Recent")
            ButtonGroup.group: navGroup
            imageSource: "qrc:/Images/clock.svg"
            imageSourceActive: "qrc:/Images/clock-icon-active.svg"
            badge: sidebar.recentCount
            badgeFont: fonts.jetBrainsMB.family
            onClicked: sidebar.recentRequested()
        }

        LauncherNavItem {
            Layout.fillWidth: true
            text: qsTr("Open project")
            ButtonGroup.group: navGroup
            imageSource: "qrc:/Images/folder-open.svg"
            imageSourceActive: "qrc:/Images/folder-open-icon-active.svg"
            onClicked: sidebar.openFileRequested()
        }

        LauncherNavItem {
            Layout.fillWidth: true
            text: qsTr("New project")
            ButtonGroup.group: navGroup
            imageSource: "qrc:/Images/plus-square.svg"
            imageSourceActive: "qrc:/Images/plus-square-icon-active.svg"
            onClicked: sidebar.createProjectRequested()
        }

        // разделитель между группами
        Rectangle {
            Layout.fillWidth: true
            Layout.topMargin: 6
            Layout.bottomMargin: 6
            implicitHeight: 1
            color: "#252c37"
        }

        GroupTitle {
            text: qsTr("RESOURCES")
        }

        LauncherNavItem {
            Layout.fillWidth: true
            text: qsTr("Documentation")
            ButtonGroup.group: navGroup
            imageSource: "qrc:/Images/book.svg"
            imageSourceActive: "qrc:/Images/book-icon-active.svg"
            onClicked: Qt.openUrlExternally(sidebar.docsUrl)
        }

        LauncherNavItem {
            Layout.fillWidth: true
            text: qsTr("Keyboard shortcuts")
            ButtonGroup.group: navGroup
            imageSource: "qrc:/Images/keyboard.svg"
            imageSourceActive: "qrc:/Images/keyboard-icon-active.svg"
            onClicked: hotkeysPopup.open()
        }

        LauncherNavItem {
            id: languageItem
            Layout.fillWidth: true
            text: qsTr("Language")
            ButtonGroup.group: navGroup
            imageSource: "qrc:/Images/globe.svg"
            imageSourceActive: "qrc:/Images/globe-icon-active.svg"
            badge: sidebar.language.toUpperCase()
            badgeColor: "#52d6a6"
            badgeFont: fonts.jetBrainsMB.family
            showArrow: true
            highlighted: languagePopup.visible
            arrowUp: languagePopup.visible
            onClicked: languagePopup.visible ? languagePopup.close() : languagePopup.open()

            LanguagePopup {
                id: languagePopup
                y: languageItem.height + 4
                width: languageItem.width
                currentCode: sidebar.language
                codeFont: fonts.jetBrainsMB.family
                onLanguagePicked: (code) => sidebar.languageSelected(code)
            }
        }

        // статус
        RowLayout {
            Layout.topMargin: 14
            Layout.leftMargin: 2
            spacing: 6

            Rectangle {
                implicitWidth: 6
                implicitHeight: 6
                radius: 3
                color: "#52d6a6"
            }

            Text {
                text: qsTr("Ready")
                color: "#a1a9b7"
                font.pixelSize: 10
            }
        }

        Text {
            Layout.fillWidth: true
            Layout.leftMargin: 2
            text: sidebar.versionText
            color: "#7d8796"
            font.family: fonts.jetBrainsMB.family
            font.pixelSize: 9
            elide: Text.ElideRight
        }
    }

    // окно со списком клавиш по центру окна
    Popup {
        id: hotkeysPopup
        parent: Overlay.overlay
        anchors.centerIn: parent
        width: 320
        modal: true
        padding: 16
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

        Overlay.modal: Rectangle {
            color: "#80000000"
        }

        background: Rectangle {
            color: "#161b22"
            border.color: "#252c37"
            border.width: 1
            radius: 8
        }

        contentItem: ColumnLayout {
            spacing: 10

            Text {
                text: qsTr("Keyboard shortcuts")
                color: "#e6edf3"
                font.pixelSize: 14
                font.bold: true
            }

            Repeater {
                model: [
                    { keys: "Esc", action: qsTr("Cancel relation") },
                    { keys: qsTr("Wheel"), action: qsTr("Zoom canvas") },
                    { keys: qsTr("Middle button"), action: qsTr("Pan canvas") },
                    { keys: "Enter", action: qsTr("Save field") }
                ]

                delegate: RowLayout {
                    required property var modelData
                    Layout.fillWidth: true
                    spacing: 10

                    Text {
                        Layout.fillWidth: true
                        text: modelData.action
                        color: "#cbd5e1"
                        font.pixelSize: 12
                        elide: Text.ElideRight
                    }

                    Rectangle {
                        implicitWidth: keyText.implicitWidth + 12
                        implicitHeight: 20
                        radius: 4
                        color: "#0d1117"
                        border.color: "#252c37"
                        border.width: 1

                        Text {
                            id: keyText
                            anchors.centerIn: parent
                            text: modelData.keys
                            color: "#52d6a6"
                            font.family: fonts.jetBrainsMB.family
                            font.pixelSize: 10
                        }
                    }
                }
            }
        }
    }
}
