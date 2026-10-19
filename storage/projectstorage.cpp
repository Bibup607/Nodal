#include "projectstorage.h"

#include <QFile>
#include <QSaveFile>
#include <QJsonDocument>
#include <QJsonObject>

ProjectStorage::ProjectStorage(QObject *parent)
    : QObject(parent)
{
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