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
    property string versionText: "Qt 6.11.1 · local workspace · v1.2.0"

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
        closePolicy: recordingId !== "" ? Popup.CloseOnPressOutside : Popup.CloseOnEscape | Popup.CloseOnPressOutside

        property string recordingId: ""

        onClosed: recordingId = ""

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

            Text {
                Layout.fillWidth: true
                text: qsTr("Click a shortcut to change it.")
                color: "#7d8796"
                font.pixelSize: 11
                wrapMode: Text.WordWrap
            }

            Repeater {
                model: [
                    { id: "addTable", action: qsTr("Add table") },
                    { id: "addColumn", action: qsTr("Add column") },
                    { id: "rename", action: qsTr("Rename table") },
                    { id: "comment", action: qsTr("Add comment") },
                    { id: "duplicate", action: qsTr("Duplicate table") },
                    { keys: "Ctrl+C / Ctrl+V", action: qsTr("Copy / paste table") },
                    { keys: "Ctrl+X", action: qsTr("Cut table") },
                    { id: "deleteTable", action: qsTr("Delete table") },
                    { keys: "Esc", action: qsTr("Deselect / cancel relation") },
                    { id: "search", action: qsTr("Search tables") },
                    { id: "togglePanel", action: qsTr("Toggle left panel") },
                    { id: "save", action: qsTr("Save project") },
                    { id: "selectTool", action: qsTr("Select tool") },
                    { id: "panTool", action: qsTr("Pan tool") },
                    { keys: "= / -", action: qsTr("Zoom in / out") },
                    { keys: qsTr("Wheel"), action: qsTr("Pan canvas") },
                    { keys: "Ctrl + " + qsTr("Wheel"), action: qsTr("Zoom canvas") },
                    { keys: qsTr("Middle button"), action: qsTr("Pan canvas") },
                    { keys: qsTr("Right click"), action: qsTr("Canvas menu") },
                    { keys: "Enter", action: qsTr("Save field") }
                ]

                delegate: RowLayout {
                    id: hotkeyRow
                    required property var modelData
                    readonly property bool editable: modelData.id !== undefined
                    readonly property bool recording: editable && hotkeysPopup.recordingId === modelData.id
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
                        border.color: hotkeyRow.recording ? "#52d6a6" : (keyMouse.containsMouse ? "#364152" : "#252c37")
                        border.width: 1

                        Text {
                            id: keyText
                            anchors.centerIn: parent
                            text: hotkeyRow.recording ? qsTr("Press keys…")
                                  : (hotkeyRow.editable ? (Hotkeys.keys[modelData.id] || "—") : modelData.keys)
                            color: "#52d6a6"
                            font.family: fonts.jetBrainsMB.family
                            font.pixelSize: 10
                        }

                        MouseArea {
                            id: keyMouse
                            anchors.fill: parent
                            enabled: hotkeyRow.editable
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                hotkeysPopup.recordingId = hotkeyRow.modelData.id
                                keyCatcher.forceActiveFocus()
                            }
                        }

                        Item {
                            id: keyCatcher

                            Keys.onShortcutOverride: (event) => event.accepted = hotkeyRow.recording
                            Keys.onPressed: (event) => {
                                if (!hotkeyRow.recording) return
                                event.accepted = true
                                if (event.key === Qt.Key_Escape) {
                                    hotkeysPopup.recordingId = ""
                                    return
                                }
                                if ([Qt.Key_Control, Qt.Key_Shift, Qt.Key_Alt, Qt.Key_Meta].includes(event.key)) return
                                Hotkeys.set(hotkeyRow.modelData.id, ProjectStorage.keySequence(event.key, event.modifiers))
                                hotkeysPopup.recordingId = ""
                            }
                            onActiveFocusChanged: if (!activeFocus && hotkeyRow.recording) hotkeysPopup.recordingId = ""
                        }
                    }
                }
            }

            Text {
                Layout.topMargin: 4
                text: qsTr("Reset to defaults")
                color: resetHover.hovered ? "#52d6a6" : "#7d8796"
                font.pixelSize: 11

                HoverHandler {
                    id: resetHover
                    cursorShape: Qt.PointingHandCursor
                }
                TapHandler {
                    onTapped: Hotkeys.reset()
                }
            }
        }
    }
}
