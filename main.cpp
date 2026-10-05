#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QIcon>
#include <QQuickStyle>
#include "models/tablesfilterproxymodel.h"


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
    qmlRegisterType<TablesFilterProxyModel>("NodalDB", 1, 0, "TablesFilterProxyModel");
    engine.loadFromModule("NodalDB", "Main");

    return QGuiApplication::exec();
}
