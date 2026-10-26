#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QIcon>
#include <QImageReader>
#include <QPixmap>
#include <QQuickStyle>


int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    QQuickStyle::setStyle("Basic");

    // имя раздела в реестре куда Settings из QML сохраняет настройки
    app.setOrganizationName("Nodal");
    app.setApplicationName("Nodal");

    // иконка окна в панели задач и альт+таб свг рендерим в нескольких размерах чтобы не было мыла
    QIcon appIcon;
    for (int size : {16, 24, 32, 48, 64, 128, 256}) {
        QImageReader reader(":/Images/logo.svg");
        reader.setScaledSize(QSize(size, size));
        appIcon.addPixmap(QPixmap::fromImage(reader.read()));
    }
    app.setWindowIcon(appIcon);

    QQmlApplicationEngine engine;
    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreationFailed,
        &app,
        []() { QCoreApplication::exit(-1); },
        Qt::QueuedConnection);
    engine.loadFromModule("NodalDB", "Main");

    return QGuiApplication::exec();
}
