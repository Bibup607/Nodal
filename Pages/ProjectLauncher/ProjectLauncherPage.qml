import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window

import NodalDB
import "../../"
import "LauncherButtons"

Item {
    id: page
    anchors.fill: parent

    signal createProjectRequested()
    signal openFileRequested()

    // горячие клавиши работают пока страница видна
    Shortcut { sequence: StandardKey.New;  enabled: page.visible; onActivated: page.createProjectRequested() }
    Shortcut { sequence: StandardKey.Open; enabled: page.visible; onActivated: page.openFileRequested() }

    Fonts {
        id: fonts
    }

    Rectangle {
        anchors.fill: parent
        color: "#0D1117"
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // Верхняя шапка (Тулбар)
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 52
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

        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 0


            LauncherSidebar {
                Layout.preferredWidth: 206
                Layout.fillHeight: true
                recentCount: 4

                // поле поиска проектов еще не сделано
                onRecentRequested: console.log("recent")
                onOpenFileRequested: page.openFileRequested()
                onCreateProjectRequested: page.createProjectRequested()
                onLanguageSelected: (code) => language = code
            }

            ScrollView {
                id: mainArea
                Layout.fillWidth: true
                Layout.fillHeight: true
                contentWidth: availableWidth
                contentHeight: content.y + content.implicitHeight + 56
                clip: true

                ColumnLayout {
                    id: content
                    x: 60
                    y: 56
                    // не шире 835 и по 60 свободного места слева и справа
                    width: Math.min(835, mainArea.availableWidth - 120)
                    spacing: 0

                    Text {
                        text: "WORKSPACE"
                        color: "#52d6a6"
                        font.family: fonts.jetBrainsMB.family
                        font.pixelSize: 9
                        font.letterSpacing: 1
                    }

                    Text {
                        Layout.topMargin: 10
                        Layout.fillWidth: true
                        text: "Open a schema or start a new one"
                        color: "#ffffff"
                        font.family: fonts.interBold.family
                        font.pixelSize: 26
                        wrapMode: Text.WordWrap
                    }

                    Text {
                        Layout.topMargin: 10
                        Layout.preferredWidth: Math.min(520, content.width)
                        text: "Continue working on a saved database project or create a clean schema for a new service."
                        color: "#a1a9b7"
                        font.pixelSize: 12
                        wrapMode: Text.WordWrap
                        lineHeight: 1.3
                    }

                    // две карточки делят ширину поровну
                    RowLayout {
                        Layout.topMargin: 26
                        Layout.fillWidth: true
                        spacing: 14

                        ActionCard {
                            Layout.fillWidth: true
                            Layout.preferredWidth: 1
                            Layout.preferredHeight: 134
                            primary: true
                            text: "Create new project"
                            description: "Empty schema, connection settings and a save file."
                            iconSource: "qrc:/Images/card-plus.svg"
                            shortcutText: "Ctrl+N"
                            onClicked: page.createProjectRequested()
                        }

                        ActionCard {
                            Layout.fillWidth: true
                            Layout.preferredWidth: 1
                            Layout.preferredHeight: 134
                            text: "Open saved project"
                            description: "Choose a .schema file on disk or in a network folder."
                            iconSource: "qrc:/Images/card-folder.svg"
                            shortcutText: "Ctrl+O"
                            onClicked: page.openFileRequested()
                        }
                    }
                }
            }
        }
    }
}
