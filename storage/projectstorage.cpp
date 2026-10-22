#include "projectstorage.h"

#include <QFile>
#include <QSaveFile>
#include <QJsonDocument>
#include <QJsonObject>
#include <QDir>
#include <QFileInfo>
#include <QSettings>
#include <QStandardPaths>

ProjectStorage::ProjectStorage(QObject *parent)
    : QObject(parent)
{
    // создаем папку проектов если ее еще нет
    QDir().mkpath(projectsFolder());
}

QString ProjectStorage::projectsFolder() const
{
    // папка из настроек или Документы NodalDB
    const QString defaultFolder =
        QStandardPaths::writableLocation(QStandardPaths::DocumentsLocation) + "/NodalDB";
    return QSettings().value("projectsFolder", defaultFolder).toString();
}

void ProjectStorage::setProjectsFolder(const QString &folder)
{
    // меняем папку проектов и запоминаем ее
    const QUrl url(folder);
    const QString path = url.isLocalFile() ? url.toLocalFile() : folder;

    QSettings().setValue("projectsFolder", path);
    QDir().mkpath(path);
    emit projectsFolderChanged();
}

QUrl ProjectStorage::newProjectFile(const QString &name)
{
    const QDir dir(projectsFolder());

    // свободное имя файла для нового проекта
    QString fileName = name + ".schema";
    for (int i = 2; dir.exists(fileName); ++i)
        fileName = name + "-" + QString::number(i) + ".schema";

    return QUrl::fromLocalFile(dir.filePath(fileName));
}

QVariantList ProjectStorage::listProjects()
{
    // файлы проектов новые сверху
    const QFileInfoList files = QDir(projectsFolder()).entryInfoList(
        {"*.schema"}, QDir::Files, QDir::Time);

    QVariantList result;
    for (const QFileInfo &file : files) {
        result.append(QVariantMap{
            {"name", file.fileName()},
            {"path", file.absoluteFilePath()},
            {"modified", file.lastModified()}
        });
    }
    return result;
}

bool ProjectStorage::saveProject(const QUrl &fileUrl, const QVariantMap &data)
{
    QSaveFile file(fileUrl.toLocalFile());
    if (!file.open(QIODevice::WriteOnly)) {
        setLastError(file.errorString());
        return false;
    }

    const QJsonDocument doc(QJsonObject::fromVariantMap(data));
    file.write(doc.toJson(QJsonDocument::Indented));

    if (!file.commit()) {
        setLastError(file.errorString());
        return false;
    }

    setLastError(QString());
    return true;
}

QVariantMap ProjectStorage::loadProject(const QUrl &fileUrl)
{
    QFile file(fileUrl.toLocalFile());
    if (!file.open(QIODevice::ReadOnly)) {
        setLastError(file.errorString());
        return {};
    }

    QJsonParseError parseError;
    const QJsonDocument doc = QJsonDocument::fromJson(file.readAll(), &parseError);
    if (parseError.error != QJsonParseError::NoError) {
        setLastError(parseError.errorString());
        return {};
    }
    if (!doc.isObject()) {
        setLastError(tr("Not a NodalDB project"));
        return {};
    }

    setLastError(QString());
    return doc.object().toVariantMap();
}

void ProjectStorage::setLastError(const QString &error)
{
    if (m_lastError == error) return;
    m_lastError = error;
    emit lastErrorChanged();
}