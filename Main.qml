import QtQuick
import QtQuick.Window
import QtCore
import NodalDB
import QWindowKit   // безрамочное окно: Snap Layouts, изменение размера за края
import "Pages/SchemaWorkspace"
import "Pages/ProjectLauncher"
import "Components"

Window {
    id: appWindow
    width: 1280
    height: 800
    minimumWidth: 900
    minimumHeight: 560
    // показываем окно только после настройки QWindowKit (в Component.onCompleted), иначе мелькнёт родная рамка
    visible: false
    title: "Nodal"

    // QWindowKit сам убирает родную шапку Windows, но оставляет окну системные свойства:
    // Snap Layouts, растягивание за края, тени и анимации разворачивания
    WindowAgent {
        id: frameAgent
    }

    // true после frameAgent.setup — до этого шапку регистрировать нельзя
    property bool frameReady: false

    // говорим агенту, где шапка и кнопки у текущей страницы
    // вызывается при старте и при каждой смене страницы, потому что шапка у каждой страницы своя
    function registerTitleBar() {
        if (frameReady && pageLoader.item)
            pageLoader.item.setupTitleBar(frameAgent)
    }

    property string projectName: ""
    property string projectEngine: ""
    // путь и содержимое открытого файла пустые у нового проекта
    property url projectPath: ""
    property var projectData: null
    property bool forceClose: false


    // читаем файл до перехода чтобы при ошибке остаться в лаунчере
    function openProject(path) {
        let data = ProjectStorage.loadProject(path)
        if (!data.tables) {
            saveNotification.showError(qsTr("Could not open project"), ProjectStorage.lastError)
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
                    saveNotification.showError(qsTr("Could not create project"), ProjectStorage.lastError)
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
            onErrorOccurred: (text, details) => saveNotification.showError(text, details)
            onBackRequested: pageLoader.sourceComponent = launcherPage
            onCloseApproved: {
                appWindow.forceClose = true
                appWindow.close()
            }
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
    onClosing: (close) => {
        appSettings.language = Qt.uiLanguage
        let page = pageLoader.item
        if (!forceClose && page && page.hasUnsavedChanges) {
            close.accepted = false
            page.requestClose()
        }
    }
}
