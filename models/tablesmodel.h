#pragma once

#include <QAbstractItemModel>
#include <QAbstractListModel>
#include <QtQml/qqmlregistration.h>

// структура для хранения данных одной таблицы
struct TableItem {
    QString name;
    // сюда позже можно добавлять поля таблицы, типы и т.д.
};

class TablesModel : public QAbstractListModel
{
    Q_OBJECT
    QML_ELEMENT // автоматическая регистрация типа в модуле NodalDB

    // свойство count для чтения количества таблиц в QML
    Q_PROPERTY(int count READ count NOTIFY countChanged)

public:
    // роли по которым QML запрашивает конкретные поля таблицы (model.tableName)
    enum TableRoles {
        TableNameRole = Qt::UserRole + 1
    };
    Q_ENUM(TableRoles)

    explicit TablesModel(QObject *parent = nullptr);

    // обязательные методы QAbstractListModel для чтения данных
    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;

    int count() const;

    // метод для добавления таблицы (можно вызывать и из C++ и из QML)
    Q_INVOKABLE void addTable(const QString &name);

signals:
    void countChanged();

private:
    QVector<TableItem> m_tables; // список таблиц в памяти
};