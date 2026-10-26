import QtQuick
import QtQuick.Window
import QtCore
import NodalDB
import QWindowKit
import "Pages/SchemaWorkspace"
import "Pages/ProjectLauncher"
import "Components"

Window {
    id: appWindow
    width: 1280
    height: 800
    minimumWidth: 900
    minimumHeight: 560
    visible: false
    title: "Nodal"

    WindowAgent {
        id: frameAgent
    }

    property bool frameReady: false

    function registerTitleBar() {
        if (frameReady && pageLoader.item)
            pageLoader.item.setupTitleBar(frameAgent)
    }

    property string projectName: ""
    property string projectEngine: ""
    property url projectPath: ""
    property var projectData: null


    // читаем файл до перехода чтобы при ошибке остаться в лаунчере
    function openProject(path) {
        let data = ProjectStorage.loadProject(path)
        if (!data.tables) {
            console.warn("open failed:", path, ProjectStorage.lastError)
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
        onLoaded: appWindow.registerTitleBar()
    }

    Component {
        id: launcherPage

        ProjectLauncherPage {
            onCreateProjectRequested: (name, engine) => {
                // сразу создаем файл в папке проектов
                let path = ProjectStorage.newProjectFile(name)
                if (!ProjectStorage.saveProject(path, { name: name, engine: engine, tables: [] })) {
                    console.warn("create failed:", path, ProjectStorage.lastError)
                    return
                }
                appWindow.projectName = name
                appWindow.projectEngine = engine
                appWindow.projectPath = path
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
            onProjectSaved: (fileName) => saveNotification.show(fileName)
            onFileExported: (fileName, message) => saveNotification.show(fileName, message)
            onBackRequested: pageLoader.sourceComponent = launcherPage
        }
    }

    SaveNotification {
        id: saveNotification
    }

    // язык хранится в реестре между запусками
    Settings {
        id: appSettings
        property string language: "en"
    }

    Component.onCompleted: {
        Qt.uiLanguage = appSettings.language

        frameAgent.setup(appWindow)
        frameReady = true
        registerTitleBar()
        appWindow.visible = true
    }
    // запоминаем выбранный язык при закрытии окна
    onClosing: appSettings.language = Qt.uiLanguage
}
