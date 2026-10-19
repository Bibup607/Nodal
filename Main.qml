import QtQuick
import QtQuick.Window
import QtCore
import NodalDB
import "Pages/SchemaWorkspace"
import "Pages/ProjectLauncher"

Window {
    id: appWindow
    width: 1280
    height: 800
    visible: true
    title: "NodalDB"
    flags: Qt.Window | Qt.FramelessWindowHint

    property string projectName: ""
    property string projectEngine: ""
    // путь и содержимое открытого файла пустые у нового проекта
    property url projectPath: ""
    property var projectData: null

    ProjectStorage {
        id: projectStorage
    }

    // читаем файл до перехода чтобы при ошибке остаться в лаунчере
    function openProject(path) {
        let data = projectStorage.loadProject(path)
        if (!data.tables) {
            console.warn("open failed:", path, projectStorage.lastError)
            return
        }
        projectName = data.name || "untitled"
        projectEngine = data.engine || "PostgreSQL"
        projectPath = path
        projectData = data
        pageLoader.sourceComponent = workspacePage
    }

    // временно: лаунчер -> новый проект открывает пустой workspace
    Loader {
        id: pageLoader
        anchors.fill: parent
        sourceComponent: launcherPage
    }

    Component {
        id: launcherPage

        ProjectLauncherPage {
            onCreateProjectRequested: (name, engine) => {
                appWindow.projectName = name
                appWindow.projectEngine = engine
                appWindow.projectPath = ""
                appWindow.projectData = null
                pageLoader.sourceComponent = workspacePage
            }
            onOpenProjectRequested: (path) => appWindow.openProject(path)
        }
    }

    Component {
        id: workspacePage

        SchemaWorkspacePage {
            projectName: appWindow.projectName
            dbEngine: appWindow.projectEngine
            projectPath: appWindow.projectPath
            initialData: appWindow.projectData
        }
    }

    // язык хранится в реестре между запусками
    Settings {
        id: appSettings
        property string language: "en"
    }

    Component.onCompleted: Qt.uiLanguage = appSettings.language
    // запоминаем выбранный язык при закрытии окна
    onClosing: appSettings.language = Qt.uiLanguage
}
