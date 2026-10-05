#pragma once

#include <QAbstractItemModel>
#include <QSortFilterProxyModel>
#include <QtQml/qqmlregistration.h> // дает макрос для связи с QML

class TablesFilterProxyModel : public QSortFilterProxyModel
{
    Q_OBJECT
    QML_ELEMENT // делаем доступным в QML

    // cвойство для текста поиска, к которому привяжется TextField
    Q_PROPERTY(QString filterPattern READ filterPattern WRITE setFilterPattern NOTIFY filterPatternChanged)

    // cвойство для вывода количества найденных таблиц
    Q_PROPERTY(int count READ count NOTIFY countChanged)

public:
    //  explicit запрещает неявные приведения типов, parent управляет памятью в дереве Qt
    explicit TablesFilterProxyModel(QObject *parent = nullptr);

    // геттеры и сеттеры
    QString filterPattern() const;
    void setFilterPattern(const QString &pattern);

    int count() const;

    // переводит номер строки из поиска в реальный номер в базе
    Q_INVOKABLE int mapToSourceRow(int proxyRow) const;

// события которые c++ отправляет в qml при изменении данных
signals:
    void filterPatternChanged();
    void countChanged();

protected:
    // решает показывать или нет
    bool filterAcceptsRow(int sourceRow, const QModelIndex &sourceParent) const override;

private:
    QString m_filterPattern;
};

