#pragma once

#include <QObject>
#include <QVariantMap>
#include <QVariantList>
#include <QUrl>
#include <QtQml/qqmlregistration.h>

class ProjectStorage : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    // один общий объект на всё приложение: в QML пишем ProjectStorage.saveProject(...),
    // создавать ProjectStorage { id: ... } на каждой странице больше не нужно
    QML_SINGLETON
    Q_PROPERTY(QString lastError READ lastError NOTIFY lastErrorChanged)
    // папка куда сохраняются все проекты
    Q_PROPERTY(QString projectsFolder READ projectsFolder NOTIFY projectsFolderChanged)

public:
    explicit ProjectStorage(QObject *parent = nullptr);

    QString lastError() const { return m_lastError; }
    QString projectsFolder() const;

    Q_INVOKABLE bool saveProject(const QUrl &fileUrl, const QVariantMap &data);
    Q_INVOKABLE QVariantMap loadProject(const QUrl &fileUrl);

    Q_INVOKABLE void setProjectsFolder(const QString &folder);
    Q_INVOKABLE QUrl newProjectFile(const QString &name);
    Q_INVOKABLE QVariantList listProjects();

    // записать текст в файл (экспорт SQL)
    Q_INVOKABLE bool saveTextFile(const QUrl &fileUrl, const QString &text);
    // file:///C:/a.png → C:/a.png (нужно для saveToFile у картинки)
    Q_INVOKABLE QString toLocalFile(const QUrl &fileUrl) const { return fileUrl.toLocalFile(); }

signals:
    void lastErrorChanged();
    void projectsFolderChanged();

private:
    void setLastError(const QString &error);

    QString m_lastError;
};
