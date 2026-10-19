import QtQuick
import QtQuick.Window
import QtCore
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
                pageLoader.sourceComponent = workspacePage
            }
            onOpenFileRequested: console.log("open project")
            onOpenProjectRequested: (path) => console.log("open recent", path)
        }
    }

    Component {
        id: workspacePage

        SchemaWorkspacePage {
            projectName: appWindow.projectName
            dbEngine: appWindow.projectEngine
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
