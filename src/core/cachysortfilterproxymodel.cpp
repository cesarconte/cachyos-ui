/*
 * SPDX-FileCopyrightText: 2026 CachyOS UI contributors
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

#include "cachysortfilterproxymodel.h"

CachySortFilterProxyModel::CachySortFilterProxyModel(QObject *parent)
    : QSortFilterProxyModel(parent)
{
    setDynamicSortFilter(true);
    setFilterCaseSensitivity(Qt::CaseInsensitive);
    setSortCaseSensitivity(Qt::CaseInsensitive);

    connect(this, &QAbstractItemModel::rowsInserted, this, &CachySortFilterProxyModel::countChanged);
    connect(this, &QAbstractItemModel::rowsRemoved, this, &CachySortFilterProxyModel::countChanged);
    connect(this, &QAbstractItemModel::modelReset, this, &CachySortFilterProxyModel::countChanged);
    connect(this, &QAbstractItemModel::layoutChanged, this, &CachySortFilterProxyModel::countChanged);
}

void CachySortFilterProxyModel::setSource(QAbstractItemModel *source)
{
    if (sourceModel() == source) {
        return;
    }
    setSourceModel(source);
    if (source) {
        connect(source, &QAbstractItemModel::modelReset, this, &CachySortFilterProxyModel::updateRolesAndSort, Qt::UniqueConnection);
    }
    updateRolesAndSort();
    Q_EMIT sourceChanged();
    Q_EMIT countChanged();
}

void CachySortFilterProxyModel::setFilterText(const QString &text)
{
    if (m_filterText == text) {
        return;
    }
#if QT_VERSION >= QT_VERSION_CHECK(6, 10, 0)
    beginFilterChange();
    m_filterText = text;
    endFilterChange();
#else
    m_filterText = text;
    invalidateFilter();
#endif
    Q_EMIT filterTextChanged();
    Q_EMIT countChanged();
}

void CachySortFilterProxyModel::setFilterRoleName(const QString &roleName)
{
    if (m_filterRoleName == roleName) {
        return;
    }
#if QT_VERSION >= QT_VERSION_CHECK(6, 10, 0)
    beginFilterChange();
    m_filterRoleName = roleName;
    updateRolesAndSort();
    endFilterChange();
#else
    m_filterRoleName = roleName;
    updateRolesAndSort();
    invalidateFilter();
#endif
    Q_EMIT filterRoleNameChanged();
    Q_EMIT countChanged();
}

void CachySortFilterProxyModel::setSortRoleName(const QString &roleName)
{
    if (m_sortRoleName == roleName) {
        return;
    }
    m_sortRoleName = roleName;
    updateRolesAndSort();
    Q_EMIT sortRoleNameChanged();
}

void CachySortFilterProxyModel::setSortOrder(Qt::SortOrder order)
{
    if (m_sortOrder == order) {
        return;
    }
    m_sortOrder = order;
    updateRolesAndSort();
    Q_EMIT sortOrderChanged();
}

QVariantMap CachySortFilterProxyModel::get(int row) const
{
    QVariantMap map;
    if (row < 0 || row >= rowCount()) {
        return map;
    }

    const QModelIndex proxyIdx = index(row, 0);
    const QHash<int, QByteArray> roles = roleNames();
    for (auto it = roles.constBegin(); it != roles.constEnd(); ++it) {
        map.insert(QString::fromUtf8(it.value()), data(proxyIdx, it.key()));
    }
    return map;
}

int CachySortFilterProxyModel::mapToSourceRow(int row) const
{
    if (row < 0 || row >= rowCount()) {
        return -1;
    }
    return mapToSource(index(row, 0)).row();
}

void CachySortFilterProxyModel::sortByRole(const QString &roleName, Qt::SortOrder order)
{
    const bool roleChanged = (m_sortRoleName != roleName);
    const bool orderChanged = (m_sortOrder != order);
    m_sortRoleName = roleName;
    m_sortOrder = order;
    updateRolesAndSort();
    if (roleChanged) {
        Q_EMIT sortRoleNameChanged();
    }
    if (orderChanged) {
        Q_EMIT sortOrderChanged();
    }
}

bool CachySortFilterProxyModel::filterAcceptsRow(int sourceRow, const QModelIndex &sourceParent) const
{
    if (m_filterText.isEmpty()) {
        return true;
    }

    const QAbstractItemModel *src = sourceModel();
    if (!src) {
        return true;
    }

    const QModelIndex srcIdx = src->index(sourceRow, 0, sourceParent);
    if (!srcIdx.isValid()) {
        return false;
    }

    // If a specific filterRoleName is set, check that role; otherwise search across all roles.
    if (!m_filterRoleName.isEmpty()) {
        const int role = resolveRole(m_filterRoleName);
        if (role >= 0) {
            const QString val = src->data(srcIdx, role).toString();
            return val.contains(m_filterText, filterCaseSensitivity());
        }
    }

    const QHash<int, QByteArray> roles = src->roleNames();
    for (auto it = roles.constBegin(); it != roles.constEnd(); ++it) {
        const QString val = src->data(srcIdx, it.key()).toString();
        if (val.contains(m_filterText, filterCaseSensitivity())) {
            return true;
        }
    }
    return false;
}

int CachySortFilterProxyModel::resolveRole(const QString &roleName) const
{
    if (roleName.isEmpty() || !sourceModel()) {
        return -1;
    }
    const QByteArray target = roleName.toUtf8();
    const QHash<int, QByteArray> roles = sourceModel()->roleNames();
    for (auto it = roles.constBegin(); it != roles.constEnd(); ++it) {
        if (it.value() == target) {
            return it.key();
        }
    }
    return Qt::DisplayRole;
}

void CachySortFilterProxyModel::updateRolesAndSort()
{
    if (!sourceModel()) {
        return;
    }

    if (!m_filterRoleName.isEmpty()) {
        const int fRole = resolveRole(m_filterRoleName);
        if (fRole >= 0) {
            setFilterRole(fRole);
        }
    }

    if (!m_sortRoleName.isEmpty()) {
        const int sRole = resolveRole(m_sortRoleName);
        if (sRole >= 0) {
            setSortRole(sRole);
            sort(0, m_sortOrder);
        }
    }
}
