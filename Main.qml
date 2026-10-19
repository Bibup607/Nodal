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

    // временно: лаунчер -> новый проект открывает пустой workspace
    Loader {
        id: pageLoader
        anchors.fill: parent
        sourceComponent: launcherPage
    }

    Component {
        id: launcherPage

        ProjectLauncherPage {
            onCreateProjectRequested: pageLoader.sourceComponent = workspacePage
            onOpenFileRequested: console.log("open project")
            onOpenProjectRequested: (path) => console.log("open recent", path)
        }
    }

    Component {
        id: workspacePage

        SchemaWorkspacePage {}
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
