#include "tablesmodel.h"

TablesModel::TablesModel(QObject *parent)
    : QAbstractListModel(parent)
{
    // Тестовые данные для проверки работы
    m_tables.append({"users"});
    m_tables.append({"orders"});
    m_tables.append({"products"});
}

int TablesModel::rowCount(const QModelIndex &parent) const
{
    if (parent.isValid())
        return 0;
    return m_tables.count();
}

QVariant TablesModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || index.row() < 0 || index.row() >= m_tables.count())
        return QVariant();

    const TableItem &item = m_tables.at(index.row());

    if (role == TableNameRole)
        return item.name;

    return QVariant();
}

QHash<int, QByteArray> TablesModel::roleNames() const
{
    QHash<int, QByteArray> roles;
    // Это связывает C++ роль TableNameRole с переменной model.tableName в QML
    roles[TableNameRole] = "tableName";
    return roles;
}

int TablesModel::count() const
{
    return rowCount();
}

void TablesModel::addTable(const QString &name)
{
    beginInsertRows(QModelIndex(), m_tables.count(), m_tables.count());
    m_tables.append({name});
    endInsertRows();
    emit countChanged();
}