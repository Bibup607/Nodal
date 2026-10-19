#pragma once

#include <QObject>
#include <QVariantMap>
#include <QUrl>
#include <QtQml/qqmlregistration.h>

class ProjectStorage : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    Q_PROPERTY(QString lastError READ lastError NOTIFY lastErrorChanged)

public:
    explicit ProjectStorage(QObject *parent = nullptr);

    QString lastError() const { return m_lastError; }

    Q_INVOKABLE bool saveProject(const QUrl &fileUrl, const QVariantMap &data);
    Q_INVOKABLE QVariantMap loadProject(const QUrl &fileUrl);

signals:
    void lastErrorChanged();

private:
    void setLastError(const QString &error);

    QString m_lastError;
};