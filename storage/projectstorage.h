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

signals:
    void lastErrorChanged();
    void projectsFolderChanged();

private:
    void setLastError(const QString &error);

    QString m_lastError;
};
