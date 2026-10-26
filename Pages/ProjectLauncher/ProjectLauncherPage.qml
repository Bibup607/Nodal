import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window
import QtQuick.Dialogs

import NodalDB
import "../../"
import "LauncherButtons"
import "RecentProjects"

Item {
    id: page
    anchors.fill: parent

    signal createProjectRequested(string name, string engine)
    signal openProjectRequested(string path)

    // горячие клавиши работают пока страница видна
    Shortcut { sequence: StandardKey.New;  enabled: page.visible; onActivated: newProjectPopup.open() }
    Shortcut { sequence: StandardKey.Open; enabled: page.visible; onActivated: openDialog.open() }

    FileDialog {
        id: openDialog
        title: qsTr("Open project")
        fileMode: FileDialog.OpenFile
        nameFilters: [qsTr("NodalDB schema (*.schema)")]
        onAccepted: page.openProjectRequested(selectedFile)
    }
    Shortcut { sequence: StandardKey.Find; enabled: page.visible; onActivated: searchField.forceActiveFocus() }

    // недавние проекты из папки проектов
    ProjectStorage {
        id: projectStorage
    }

    ListModel {
        id: recentModel
    }

    function reloadProjects() {
        recentModel.clear()
        for (let p of projectStorage.listProjects()) {
            recentModel.append({
                name: p.name,
                path: p.path,
                engine: "",
                tables: 0,
                relations: 0,
                readOnly: false,
                lastOpened: Qt.formatDateTime(p.modified, "MMM d yyyy, hh:mm"),
                accent: "#52d6a6"
            })
        }
    }

    Component.onCompleted: reloadProjects()

    // выбор другой папки проектов
    FolderDialog {
        id: folderDialog
        title: qsTr("Choose projects folder")
        currentFolder: "file:///" + projectStorage.projectsFolder
        onAccepted: {
            projectStorage.setProjectsFolder(selectedFolder)
            page.reloadProjects()
        }
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

    // проект создается только после подтверждения в окне
    NewProjectPopup {
        id: newProjectPopup
        titleFont: fonts.interBold.family
        monoFont: fonts.jetBrainsMB.family
        onCreateRequested: (name, engine) => page.createProjectRequested(name, engine)
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

            Item {
                id: titleDragArea
                anchors.fill: parent

                DragHandler {
                    target: null
                    onActiveChanged: if (active) titleDragArea.Window.window.startSystemMove()
                }

                TapHandler {
                    onDoubleTapped: {
                        let win = titleDragArea.Window.window
                        if (win.visibility === Window.Maximized)
                            win.showNormal()
                        else
                            win.showMaximized()
                    }
                }
            }

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
                language: Qt.uiLanguage

                Layout.preferredWidth: 206
                Layout.fillHeight: true
                recentCount: recentModel.count

                // поле поиска проектов еще не сделано
                onRecentRequested: console.log("recent")
                onOpenFileRequested: openDialog.open()
                onCreateProjectRequested: newProjectPopup.open()
                onLanguageSelected: (code) => Qt.uiLanguage = code
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
                        text: qsTr("WORKSPACE")
                        color: "#52d6a6"
                        font.family: fonts.jetBrainsMB.family
                        font.pixelSize: 9
                        font.letterSpacing: 1
                    }

                    Text {
                        Layout.topMargin: 10
                        Layout.fillWidth: true
                        text: qsTr("Open a schema or start a new one")
                        color: "#ffffff"
                        font.family: fonts.interBold.family
                        font.pixelSize: 26
                        wrapMode: Text.WordWrap
                    }

                    Text {
                        Layout.topMargin: 10
                        Layout.preferredWidth: Math.min(520, content.width)
                        text: qsTr("Continue working on a saved database project or create a clean schema for a new service.")
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
                            text: qsTr("Create new project")
                            description: qsTr("Empty schema, connection settings and a save file.")
                            iconSource: "qrc:/Images/card-plus.svg"
                            shortcutText: "Ctrl+N"
                            onClicked: newProjectPopup.open()
                        }

                        ActionCard {
                            Layout.fillWidth: true
                            Layout.preferredWidth: 1
                            Layout.fillHeight: true
                            text: qsTr("Open saved project")
                            description: qsTr("Choose a .schema file on disk or in a network folder.")
                            iconSource: "qrc:/Images/card-folder.svg"
                            shortcutText: "Ctrl+O"
                            onClicked: openDialog.open()
                        }
                    }

                    // недавние проекты
                    RowLayout {
                        Layout.topMargin: 30
                        Layout.fillWidth: true

                        Text {
                            Layout.fillWidth: true
                            text: qsTr("RECENT PROJECTS")
                            color: "#a1a9b7"
                            font.pixelSize: 9
                            font.bold: true
                            font.letterSpacing: 0.6
                        }

                        Text {
                            visible: recentModel.count > 0
                            text: qsTr("Clear list")
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
                        placeholderText: qsTr("Search by name...")
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
                                onClicked: page.openProjectRequested("file:///" + path)
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
                              ? qsTr("Projects you open will appear here.")
                              : qsTr("Nothing found for \"%1\"").arg(searchField.text.trim())
                        color: "#7d8796"
                        font.pixelSize: 11
                        horizontalAlignment: Text.AlignHCenter
                    }
                }
            }
        }

        // подвал путь к папке проектов и кнопка смены
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 28
            color: "#11151C"
            border.color: "#252c37"

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 12
                anchors.rightMargin: 12
                spacing: 8

                Text {
                    Layout.fillWidth: true
                    text: qsTr("Projects folder: %1").arg(projectStorage.projectsFolder)
                    color: "#7d8796"
                    font.family: fonts.jetBrainsMB.family
                    font.pixelSize: 9
                    elide: Text.ElideMiddle
                }

                Text {
                    text: qsTr("Change")
                    color: changeHover.hovered ? "#52d6a6" : "#a1a9b7"
                    font.pixelSize: 10

                    HoverHandler {
                        id: changeHover
                        cursorShape: Qt.PointingHandCursor
                    }
                    TapHandler {
                        onTapped: folderDialog.open()
                    }
                }
            }
        }
    }
}
