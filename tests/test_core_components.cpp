/*
 * SPDX-FileCopyrightText: 2026 CachyOS UI contributors
 * SPDX-License-Identifier: GPL-3.0-or-later
 *
 * Phase 1 unit tests for CachyOS.UI core components:
 * - CachySortFilterProxyModel (filtering, sorting, role mapping)
 * - Embedded structural vector icons in CachyTheme::iconUrl()
 * - Offscreen QML instantiation of CachyIcon and CachyWindowShadow
 */

#include <QFile>
#include <QGuiApplication>
#include <QQmlComponent>
#include <QQmlEngine>
#include <QQuickItem>
#include <QSignalSpy>
#include <QStandardItemModel>
#include <QTest>

#include "cachysortfilterproxymodel.h"
#include "cachytheme.h"
#include "cachywindowshadow.h"

namespace {

enum TorrentRole {
    NameRole = Qt::UserRole + 1,
    CategoryRole,
    SizeMBrole,
};

class SampleModel : public QStandardItemModel
{
public:
    explicit SampleModel(QObject *parent = nullptr)
        : QStandardItemModel(parent)
    {
        addEntry(QStringLiteral("cachyos-desktop-linux-2603.iso"), QStringLiteral("ISO"), 2850);
        addEntry(QStringLiteral("archlinux-x86_64.iso"), QStringLiteral("ISO"), 1120);
        addEntry(QStringLiteral("kde-plasma-wallpapers.tar.zst"), QStringLiteral("Artwork"), 420);
        addEntry(QStringLiteral("linux-cachyos-bore-6.14.pkg.tar.zst"), QStringLiteral("Kernel"), 165);
    }

    QHash<int, QByteArray> roleNames() const override
    {
        return {
            {NameRole, QByteArrayLiteral("name")},
            {CategoryRole, QByteArrayLiteral("category")},
            {SizeMBrole, QByteArrayLiteral("sizeMB")},
        };
    }

private:
    void addEntry(const QString &name, const QString &category, int sizeMB)
    {
        auto *item = new QStandardItem(name);
        item->setData(name, NameRole);
        item->setData(category, CategoryRole);
        item->setData(sizeMB, SizeMBrole);
        appendRow(item);
    }
};

} // namespace

class TestCoreComponents : public QObject
{
    Q_OBJECT

private Q_SLOTS:
    void testSortFilterProxyModelFiltering();
    void testSortFilterProxyModelSortingAndMapping();
    void testBuiltinVectorIconsResolution();
    void testCachyIconAndShadowQmlInstantiation();

private:
    CachyTheme m_theme;
};

void TestCoreComponents::testSortFilterProxyModelFiltering()
{
    SampleModel source;
    CachySortFilterProxyModel proxy;
    QSignalSpy countSpy(&proxy, &CachySortFilterProxyModel::countChanged);

    proxy.setSource(&source);
    QCOMPARE(proxy.count(), 4);
    QVERIFY(countSpy.count() >= 1);

    // Case-insensitive search across all roles
    proxy.setFilterText(QStringLiteral("CACHYOS"));
    QCOMPARE(proxy.count(), 2);

    // Filter restricted to a specific role
    proxy.setFilterRoleName(QStringLiteral("category"));
    proxy.setFilterText(QStringLiteral("iso"));
    QCOMPARE(proxy.count(), 2);

    proxy.setFilterText(QStringLiteral("kernel"));
    QCOMPARE(proxy.count(), 1);
    const QVariantMap row0 = proxy.get(0);
    QCOMPARE(row0.value(QStringLiteral("name")).toString(),
             QStringLiteral("linux-cachyos-bore-6.14.pkg.tar.zst"));
    QCOMPARE(row0.value(QStringLiteral("sizeMB")).toInt(), 165);

    // Reset filter
    proxy.setFilterText(QString());
    QCOMPARE(proxy.count(), 4);
}

void TestCoreComponents::testSortFilterProxyModelSortingAndMapping()
{
    SampleModel source;
    CachySortFilterProxyModel proxy;
    proxy.setSource(&source);

    // Sort by numeric sizeMB ascending
    proxy.sortByRole(QStringLiteral("sizeMB"), Qt::AscendingOrder);
    QCOMPARE(proxy.get(0).value(QStringLiteral("sizeMB")).toInt(), 165);
    QCOMPARE(proxy.get(3).value(QStringLiteral("sizeMB")).toInt(), 2850);
    QCOMPARE(proxy.mapToSourceRow(0), 3);
    QCOMPARE(proxy.mapToSourceRow(3), 0);

    // Sort by numeric sizeMB descending
    proxy.sortByRole(QStringLiteral("sizeMB"), Qt::DescendingOrder);
    QCOMPARE(proxy.get(0).value(QStringLiteral("sizeMB")).toInt(), 2850);
    QCOMPARE(proxy.get(3).value(QStringLiteral("sizeMB")).toInt(), 165);

    // Out-of-bounds safety
    QVERIFY(proxy.get(-1).isEmpty());
    QVERIFY(proxy.get(99).isEmpty());
    QCOMPARE(proxy.mapToSourceRow(-1), -1);
}

void TestCoreComponents::testBuiltinVectorIconsResolution()
{
    const QStringList builtinIcons = {
        QStringLiteral("chevron-left"),
        QStringLiteral("chevron-right"),
        QStringLiteral("chevron-up"),
        QStringLiteral("chevron-down"),
        QStringLiteral("close"),
        QStringLiteral("search"),
        QStringLiteral("clear"),
        QStringLiteral("check"),
        QStringLiteral("add"),
        QStringLiteral("remove"),
        QStringLiteral("refresh"),
        QStringLiteral("folder"),
        QStringLiteral("file"),
        QStringLiteral("grid"),
        QStringLiteral("list"),
        QStringLiteral("info"),
        QStringLiteral("warning"),
        QStringLiteral("error"),
        QStringLiteral("success"),
        QStringLiteral("settings"),
        QStringLiteral("pin"),
        QStringLiteral("filter"),
        QStringLiteral("sort-asc"),
        QStringLiteral("sort-desc"),
        QStringLiteral("more-horizontal"),
        QStringLiteral("external-link"),
        QStringLiteral("trash"),
        QStringLiteral("download"),
        QStringLiteral("upload"),
        QStringLiteral("pause"),
        QStringLiteral("play"),
    };

    for (const QString &iconName : builtinIcons) {
        const QString url = m_theme.iconUrl(iconName);
        QVERIFY2(url.startsWith(QStringLiteral("qrc:/CachyOS/UI/icons/")),
                 qPrintable(QStringLiteral("Expected embedded qrc icon for ") + iconName + QStringLiteral(", got: ") + url));
        const QString qrcPath = url.mid(3); // strip "qrc" -> ":/CachyOS/UI/icons/..."
        QVERIFY2(QFile::exists(qrcPath), qPrintable(qrcPath));
    }

    // Fallback resolution when primary icon does not exist
    const QString fallbackUrl = m_theme.iconUrl(QStringLiteral("non-existent-icon-999"), QStringLiteral("search"));
    QCOMPARE(fallbackUrl, QStringLiteral("qrc:/CachyOS/UI/icons/search.svg"));
}

void TestCoreComponents::testCachyIconAndShadowQmlInstantiation()
{
    QQmlEngine engine;
    engine.addImportPath(QStringLiteral(CACHYOS_BUILD_QML_DIR));

    QQmlComponent component(&engine);
    component.setData(QByteArrayLiteral(R"QML(
        import QtQuick
        import CachyOS.UI

        Item {
            width: 120
            height: 60
            CachyWindowShadow.enabled: true
            CachyWindowShadow.radius: 20

            CachyIcon {
                objectName: "searchIcon"
                name: "search"
                size: 20
                color: CachyTheme.accentColor
            }
        }
    )QML"), QUrl());

    QVERIFY2(!component.isError(), qPrintable(component.errorString()));
    QScopedPointer<QObject> root(component.create());
    QVERIFY(root != nullptr);

    auto *icon = root->findChild<QQuickItem *>(QStringLiteral("searchIcon"));
    QVERIFY(icon != nullptr);
    QCOMPARE(icon->width(), 20.0);
    QCOMPARE(icon->height(), 20.0);
    QCOMPARE(icon->property("valid").toBool(), true);
}

QTEST_MAIN(TestCoreComponents)
#include "test_core_components.moc"
