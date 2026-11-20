/*
 * SPDX-FileCopyrightText: 2026 CachyOS UI contributors
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

#include "cachysortfilterproxymodel.h"

#include <QCollator>
#include <QDateTime>
#include <QRegularExpression>
#include <optional>

static std::optional<double> parseByteSize(const QString &str)
{
    // Matches expressions like "148 MB", "2.8 GB", "24 MB", "420 MB", "512 KB", "10 B", "1.5 GiB"
    static const QRegularExpression regex(QStringLiteral(R"(^\s*([\d]+(?:[\.,][\d]+)?)\s*([KMGTPE]?I?B?)\s*$)"), QRegularExpression::CaseInsensitiveOption);
    const QRegularExpressionMatch match = regex.match(str);
    if (!match.hasMatch()) {
        return std::nullopt;
    }

    const QString unit = match.captured(2).trimmed().toUpper();
    if (unit.isEmpty()) {
        return std::nullopt;
    }

    QString numStr = match.captured(1);
    numStr.replace(QLatin1Char(','), QLatin1Char('.'));
    bool ok = false;
    double val = numStr.toDouble(&ok);
    if (!ok) {
        return std::nullopt;
    }

    if (unit.startsWith(QLatin1Char('P'))) {
        val *= 1024.0 * 1024.0 * 1024.0 * 1024.0 * 1024.0;
    } else if (unit.startsWith(QLatin1Char('T'))) {
        val *= 1024.0 * 1024.0 * 1024.0 * 1024.0;
    } else if (unit.startsWith(QLatin1Char('G'))) {
        val *= 1024.0 * 1024.0 * 1024.0;
    } else if (unit.startsWith(QLatin1Char('M'))) {
        val *= 1024.0 * 1024.0;
    } else if (unit.startsWith(QLatin1Char('K'))) {
        val *= 1024.0;
    }
    return val;
}

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

bool CachySortFilterProxyModel::lessThan(const QModelIndex &source_left, const QModelIndex &source_right) const
{
    if (!sourceModel()) {
        return false;
    }

    const int role = sortRole();
    const QVariant leftData = sourceModel()->data(source_left, role);
    const QVariant rightData = sourceModel()->data(source_right, role);

    // 1. Direct Numeric comparison (int, double, float, qint64)
    if (leftData.metaType().id() == QMetaType::Double || leftData.metaType().id() == QMetaType::Float) {
        return leftData.toDouble() < rightData.toDouble();
    }
    if (leftData.metaType().id() == QMetaType::Int || leftData.metaType().id() == QMetaType::LongLong || leftData.metaType().id() == QMetaType::UInt || leftData.metaType().id() == QMetaType::ULongLong) {
        return leftData.toLongLong() < rightData.toLongLong();
    }

    // 2. Date/Time comparison
    if (leftData.metaType().id() == QMetaType::QDateTime) {
        return leftData.toDateTime() < rightData.toDateTime();
    }
    if (leftData.metaType().id() == QMetaType::QDate) {
        return leftData.toDate() < rightData.toDate();
    }

    // 3. String comparison: Check if string represents a human-readable file size (e.g. "24 MB", "2.8 GB")
    const QString leftStr = leftData.toString();
    const QString rightStr = rightData.toString();

    const auto leftSize = parseByteSize(leftStr);
    const auto rightSize = parseByteSize(rightStr);
    if (leftSize.has_value() && rightSize.has_value()) {
        return leftSize.value() < rightSize.value();
    }

    // 4. Natural Alphanumeric Sort (e.g. "item 2" < "item 10", case-insensitive)
    QCollator collator;
    collator.setCaseSensitivity(sortCaseSensitivity());
    collator.setNumericMode(true);
    return collator.compare(leftStr, rightStr) < 0;
}
