#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QIcon>
#include <QImageReader>
#include <QPixmap>
#include <QQuickStyle>
#include <QQuickWindow>
#include <QSettings>
#include <QStandardPaths>
#include <QDir>

#include <QWKQuick/qwkquickglobal.h>



static void migrateOldSettings()
{
    QSettings settings;                    // новое место: Nodal/Nodal
    if (!settings.allKeys().isEmpty())
        return;                            // уже переносили или настройки уже есть

    QSettings old("NodalDB", "NodalDB");
    for (const QString &key : old.allKeys())
        settings.setValue(key, old.value(key));

    // папка проектов по умолчанию тоже была Документы/NodalDB: если она есть, продолжаем работать в ней
    const QString oldFolder =
        QStandardPaths::writableLocation(QStandardPaths::DocumentsLocation) + "/NodalDB";
    if (!settings.contains("projectsFolder") && QDir(oldFolder).exists())
        settings.setValue("projectsFolder", oldFolder);
}

int main(int argc, char *argv[])
{
    // QWindowKit просит прозрачный буфер окна: на Windows через него рисуются системные эффекты рамки
    QQuickWindow::setDefaultAlphaBuffer(true);

    QGuiApplication app(argc, argv);
    QQuickStyle::setStyle("Basic");

    // имя раздела в реестре куда Settings из QML сохраняет настройки
    app.setOrganizationName("Nodal");
    app.setApplicationName("Nodal");
    migrateOldSettings();

    // иконка окна в панели задач и альт+таб свг рендерим в нескольких размерах чтобы не было мыла
    QIcon appIcon;
    for (int size : {16, 24, 32, 48, 64, 128, 256}) {
        QImageReader reader(":/Images/logo.svg");
        reader.setScaledSize(QSize(size, size));
        appIcon.addPixmap(QPixmap::fromImage(reader.read()));
    }
    app.setWindowIcon(appIcon);

    QQmlApplicationEngine engine;
    QWK::registerTypes(&engine);   // после этого в QML работает import QWindowKit
    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreationFailed,
        &app,
        []() { QCoreApplication::exit(-1); },
        Qt::QueuedConnection);
    engine.loadFromModule("NodalDB", "Main");

    return QGuiApplication::exec();
}
