#include "tablesfilterproxymodel.h"
#include "tablesmodel.h"

TablesFilterProxyModel::TablesFilterProxyModel(QObject *parent)
    : QSortFilterProxyModel(parent)
{
    // поиск без учета регистра ('user' найдет 'Users')
    setFilterCaseSensitivity(Qt::CaseInsensitive);

    // при любом изменении списка пересчитываем count для QML
    connect(this, &QAbstractItemModel::rowsInserted, this, &TablesFilterProxyModel::countChanged);
    connect(this, &QAbstractItemModel::rowsRemoved, this, &TablesFilterProxyModel::countChanged);
    connect(this, &QAbstractItemModel::modelReset, this, &TablesFilterProxyModel::countChanged);
    connect(this, &QAbstractItemModel::layoutChanged, this, &TablesFilterProxyModel::countChanged);
    connect(this, &QAbstractItemModel::dataChanged, this, [this]() {
        beginFilterChange();
        endFilterChange();
        emit countChanged();
    });
}

QString TablesFilterProxyModel::filterPattern() const
{
    return m_filterPattern;
}

void TablesFilterProxyModel::setFilterPattern(const QString &pattern)
{
    if (m_filterPattern == pattern)
        return;

    m_filterPattern = pattern;
    emit filterPatternChanged();

    beginFilterChange();
    endFilterChange();

    emit countChanged();
}

int TablesFilterProxyModel::count() const
{
    return rowCount();
}

bool TablesFilterProxyModel::filterAcceptsRow(int sourceRow, const QModelIndex &sourceParent) const
{
    // если поисковая строка пустая показываем абсолютно все таблицы
    if (m_filterPattern.trimmed().isEmpty())
        return true;

    if (!sourceModel())
        return false;

    // достаем индекс таблицы из исходного TablesModel
    QModelIndex sourceIndex = sourceModel()->index(sourceRow, 0, sourceParent);

    const QHash<int, QByteArray> roles = sourceModel()->roleNames();
    int targetRole = -1;
    for (auto it = roles.cbegin(); it != roles.cend(); ++it) {
        if (it.value() == "tableName" || it.value() == "name") {
            targetRole = it.key();
            break;
        }
    }

    // берем название таблицы по роли TableNameRole из tablesmodel.h
    QVariant dataVal = (targetRole != -1)
                           ? sourceModel()->data(sourceIndex, targetRole)
                           : sourceModel()->data(sourceIndex, TablesModel::TableNameRole);

    QString tableName = dataVal.toString();

    // проверяем, есть ли подстрока поиска в названии
    return tableName.contains(m_filterPattern, Qt::CaseInsensitive);
}

int TablesFilterProxyModel::mapToSourceRow(int proxyRow) const
{
    QModelIndex proxyIndex = index(proxyRow, 0);
    QModelIndex sourceIndex = mapToSource(proxyIndex);
    return sourceIndex.isValid() ? sourceIndex.row() : -1;
}