#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QIcon>
#include <QQuickStyle>


int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    QQuickStyle::setStyle("Basic");

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
