#include "projectstorage.h"

#include <QFile>
#include <QSaveFile>
#include <QJsonDocument>
#include <QJsonObject>
#include <QDir>
#include <QFileInfo>
#include <QSettings>
#include <QStandardPaths>
#include <QKeySequence>

ProjectStorage::ProjectStorage(QObject *parent)
    : QObject(parent)
{
    // создаем папку проектов если ее еще нет
    QDir().mkpath(projectsFolder());
}

QString ProjectStorage::projectsFolder() const
{
    // папка из настроек или Документы/Nodal
    const QString defaultFolder =
        QStandardPaths::writableLocation(QStandardPaths::DocumentsLocation) + "/Nodal";
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
        setLastError(tr("Not a Nodal project"));
        return {};
    }

    setLastError(QString());
    return doc.object().toVariantMap();
}

bool ProjectStorage::saveTextFile(const QUrl &fileUrl, const QString &text)
{
    // QSaveFile пишет во временный файл и подменяет им настоящий только в конце,
    // поэтому при ошибке старый файл не испортится
    QSaveFile file(fileUrl.toLocalFile());
    if (!file.open(QIODevice::WriteOnly | QIODevice::Text)) {
        setLastError(file.errorString());
        return false;
    }

    file.write(text.toUtf8());

    if (!file.commit()) {
        setLastError(file.errorString());
        return false;
    }

    setLastError(QString());
    return true;
}

QString ProjectStorage::keySequence(int key, int modifiers) const
{
    return QKeySequence(QKeyCombination(Qt::KeyboardModifiers(modifiers), Qt::Key(key)))
        .toString(QKeySequence::PortableText);
}

void ProjectStorage::setLastError(const QString &error)
{
    if (m_lastError == error) return;
    m_lastError = error;
    emit lastErrorChanged();
}