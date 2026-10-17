import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window

import NodalDB
import "../../"
import "LauncherButtons"
import "RecentProjects"

Item {
    id: page
    anchors.fill: parent

    signal createProjectRequested()
    signal openFileRequested()
    signal openProjectRequested(string path)

    // горячие клавиши работают пока страница видна
    Shortcut { sequence: StandardKey.New;  enabled: page.visible; onActivated: page.createProjectRequested() }
    Shortcut { sequence: StandardKey.Open; enabled: page.visible; onActivated: page.openFileRequested() }
    Shortcut { sequence: StandardKey.Find; enabled: page.visible; onActivated: searchField.forceActiveFocus() }

    // недавние проекты пока демо данные
    ListModel {
        id: recentModel
        ListElement { name: "commerce.schema"; path: "~/Projects/acme-cloud/db/commerce.schema"
                      engine: "PostgreSQL"; tables: 12; relations: 18; readOnly: false
                      lastOpened: "2 min ago"; accent: "#52d6a6" }
        ListElement { name: "billing-core.schema"; path: "~/Work/nodal/billing/billing-core.schema"
                      engine: "PostgreSQL"; tables: 9; relations: 11; readOnly: false
                      lastOpened: "yesterday"; accent: "#60a5fa" }
        ListElement { name: "analytics-warehouse.schema"; path: "/Volumes/Data/schemas/analytics-warehouse.schema"
                      engine: "ClickHouse"; tables: 24; relations: 0; readOnly: true
                      lastOpened: "Sep 12"; accent: "#a78bfa" }
        ListElement { name: "identity-service.schema"; path: "~/Projects/platform/identity-service.schema"
                      engine: "MySQL"; tables: 7; relations: 6; readOnly: false
                      lastOpened: "Sep 8"; accent: "#f59e0b" }
    }

    // тот же фильтр что и поиск таблиц ищет по роли name
    TablesFilterProxyModel {
        id: filteredRecent
        sourceModel: recentModel
        filterPattern: searchField.text.trim()
    }

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
                recentCount: recentModel.count

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
                    // на большом экране колонка шире и по центру минимум 60 по краям
                    x: Math.max(60, (mainArea.availableWidth - width) / 2)
                    y: 56
                    width: Math.min(1100, mainArea.availableWidth - 120)
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
                            Layout.fillHeight: true
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
                            Layout.fillHeight: true
                            text: "Open saved project"
                            description: "Choose a .schema file on disk or in a network folder."
                            iconSource: "qrc:/Images/card-folder.svg"
                            shortcutText: "Ctrl+O"
                            onClicked: page.openFileRequested()
                        }
                    }

                    // недавние проекты
                    RowLayout {
                        Layout.topMargin: 30
                        Layout.fillWidth: true

                        Text {
                            Layout.fillWidth: true
                            text: "RECENT PROJECTS"
                            color: "#a1a9b7"
                            font.pixelSize: 9
                            font.bold: true
                            font.letterSpacing: 0.6
                        }

                        Text {
                            visible: recentModel.count > 0
                            text: "Clear list"
                            color: clearHover.hovered ? "#52d6a6" : "#7d8796"
                            font.pixelSize: 10

                            HoverHandler {
                                id: clearHover
                                cursorShape: Qt.PointingHandCursor
                            }
                            TapHandler {
                                onTapped: recentModel.clear()
                            }
                        }
                    }

                    // поиск по имени проекта
                    TextField {
                        id: searchField
                        Layout.topMargin: 10
                        Layout.fillWidth: true
                        Layout.preferredHeight: 32
                        leftPadding: 30
                        rightPadding: 60
                        placeholderText: "Search by name..."
                        placeholderTextColor: "#7d8796"
                        color: "#e6edf3"
                        font.pixelSize: 11
                        selectByMouse: true

                        // esc очищает поиск и убирает фокус
                        Keys.onEscapePressed: {
                            clear()
                            focus = false
                        }

                        background: Rectangle {
                            color: "#0d1117"
                            radius: 6
                            border.width: 1
                            border.color: searchField.activeFocus ? "#52d6a6" : "#252c37"
                        }

                        LineIcon {
                            width: 13
                            height: 13
                            anchors.left: parent.left
                            anchors.leftMargin: 10
                            anchors.verticalCenter: parent.verticalCenter
                            // лупа svg путь в квадрате 16x16 круг из двух дуг (a) и ручка линией (M L)
                            pathData: "M2.4 7a4.6 4.6 0 1 0 9.2 0a4.6 4.6 0 1 0 -9.2 0 M10.5 10.5L14 14"
                        }

                        Text {
                            anchors.right: parent.right
                            anchors.rightMargin: 10
                            anchors.verticalCenter: parent.verticalCenter
                            text: "Ctrl+F"
                            color: "#7d8796"
                            font.family: fonts.jetBrainsMB.family
                            font.pixelSize: 9
                        }
                    }

                    Column {
                        Layout.topMargin: 10
                        Layout.fillWidth: true
                        spacing: 8

                        Repeater {
                            model: filteredRecent

                            delegate: RecentProjectRow {
                                width: parent.width
                                onClicked: page.openProjectRequested(path)
                                // index тут номер в отфильтрованном списке
                                onRemoveRequested: recentModel.remove(filteredRecent.mapToSourceRow(index))
                            }
                        }
                    }

                    Text {
                        Layout.topMargin: 24
                        Layout.fillWidth: true
                        visible: filteredRecent.count === 0
                        text: recentModel.count === 0
                              ? "Projects you open will appear here."
                              : "Nothing found for \"" + searchField.text.trim() + "\""
                        color: "#7d8796"
                        font.pixelSize: 11
                        horizontalAlignment: Text.AlignHCenter
                    }
                }
            }
        }
    }
}
