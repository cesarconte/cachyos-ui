/*
 * SPDX-FileCopyrightText: 2026 CachyOS UI contributors
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

#pragma once

#include <QSortFilterProxyModel>
#include <QVariantMap>
#include <qqmlregistration.h>

/**
 * High-performance C++ reactive sort & filter proxy model for QML views.
 *
 * Inspired by FishUI's QQmlSortFilterProxyModel: enables instant (< 1 ms)
 * search filtering and column sorting in any ListView, GridView or TableView
 * without writing application-specific C++ boilerplate.
 */
class CachySortFilterProxyModel : public QSortFilterProxyModel
{
    Q_OBJECT
    QML_ELEMENT

    Q_PROPERTY(QAbstractItemModel *source READ sourceModel WRITE setSource NOTIFY sourceChanged)
    Q_PROPERTY(QString filterText READ filterText WRITE setFilterText NOTIFY filterTextChanged)
    Q_PROPERTY(QString filterRoleName READ filterRoleName WRITE setFilterRoleName NOTIFY filterRoleNameChanged)
    Q_PROPERTY(QString sortRoleName READ sortRoleName WRITE setSortRoleName NOTIFY sortRoleNameChanged)
    Q_PROPERTY(Qt::SortOrder sortOrder READ sortOrder WRITE setSortOrder NOTIFY sortOrderChanged)
    Q_PROPERTY(Qt::CaseSensitivity filterCaseSensitivity READ filterCaseSensitivity WRITE setFilterCaseSensitivity NOTIFY filterCaseSensitivityChanged)
    Q_PROPERTY(int count READ count NOTIFY countChanged)

public:
    explicit CachySortFilterProxyModel(QObject *parent = nullptr);
    ~CachySortFilterProxyModel() override = default;

    void setSource(QAbstractItemModel *source);

    QString filterText() const { return m_filterText; }
    void setFilterText(const QString &text);

    QString filterRoleName() const { return m_filterRoleName; }
    void setFilterRoleName(const QString &roleName);

    QString sortRoleName() const { return m_sortRoleName; }
    void setSortRoleName(const QString &roleName);

    Qt::SortOrder sortOrder() const { return m_sortOrder; }
    void setSortOrder(Qt::SortOrder order);

    int count() const { return rowCount(); }

    /// Returns all role key-value pairs for the proxy @p row so QML delegates
    /// and imperative handlers can inspect an item directly.
    Q_INVOKABLE QVariantMap get(int row) const;

    /// Maps a proxy @p row index back to its index in the source model.
    Q_INVOKABLE int mapToSourceRow(int row) const;

    /// Toggles or sets sorting on @p roleName (handy for table headers).
    Q_INVOKABLE void sortByRole(const QString &roleName, Qt::SortOrder order = Qt::AscendingOrder);

Q_SIGNALS:
    void sourceChanged();
    void filterTextChanged();
    void filterRoleNameChanged();
    void sortRoleNameChanged();
    void sortOrderChanged();
    void filterCaseSensitivityChanged();
    void countChanged();

protected:
    bool filterAcceptsRow(int sourceRow, const QModelIndex &sourceParent) const override;

private:
    int resolveRole(const QString &roleName) const;
    void updateRolesAndSort();

    QString m_filterText;
    QString m_filterRoleName;
    QString m_sortRoleName;
    Qt::SortOrder m_sortOrder{Qt::AscendingOrder};
};
