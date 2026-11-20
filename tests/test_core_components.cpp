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
#include <QQuickWindow>
#include <QSignalSpy>
#include <QStandardItemModel>
#include <QTest>

#include "LayoutAuditor.h"
#include "cachysortfilterproxymodel.h"
#include "cachytheme.h"
#include "cachywindowshadow.h"

namespace {

enum TorrentRole {
    NameRole = Qt::UserRole + 1,
    CategoryRole,
    SizeMBrole,
    SizeStrRole,
};

class SampleModel : public QStandardItemModel
{
public:
    explicit SampleModel(QObject *parent = nullptr)
        : QStandardItemModel(parent)
    {
        addEntry(QStringLiteral("cachyos-desktop-linux-2603.iso"), QStringLiteral("ISO"), 2850, QStringLiteral("2.8 GB"));
        addEntry(QStringLiteral("archlinux-x86_64.iso"), QStringLiteral("ISO"), 1120, QStringLiteral("1.1 GB"));
        addEntry(QStringLiteral("kde-plasma-wallpapers.tar.zst"), QStringLiteral("Artwork"), 420, QStringLiteral("420 MB"));
        addEntry(QStringLiteral("linux-cachyos-bore-6.14.pkg.tar.zst"), QStringLiteral("Kernel"), 165, QStringLiteral("148 MB"));
    }

    QHash<int, QByteArray> roleNames() const override
    {
        return {
            {NameRole, QByteArrayLiteral("name")},
            {CategoryRole, QByteArrayLiteral("category")},
            {SizeMBrole, QByteArrayLiteral("sizeMB")},
            {SizeStrRole, QByteArrayLiteral("sizeStr")},
        };
    }

private:
    void addEntry(const QString &name, const QString &category, int sizeMB, const QString &sizeStr)
    {
        auto *item = new QStandardItem(name);
        item->setData(name, NameRole);
        item->setData(category, CategoryRole);
        item->setData(sizeMB, SizeMBrole);
        item->setData(sizeStr, SizeStrRole);
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
    void testPhase2ControlsAndLayoutAudit();
    void testPhase3ControlsAndLayoutAudit();
    void testPhaseAControlsAndLayoutAudit();

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

    // Sort by human-readable string sizes (sizeStr) ascending: 148 MB < 420 MB < 1.1 GB < 2.8 GB
    proxy.sortByRole(QStringLiteral("sizeStr"), Qt::AscendingOrder);
    QCOMPARE(proxy.get(0).value(QStringLiteral("sizeStr")).toString(), QStringLiteral("148 MB"));
    QCOMPARE(proxy.get(1).value(QStringLiteral("sizeStr")).toString(), QStringLiteral("420 MB"));
    QCOMPARE(proxy.get(2).value(QStringLiteral("sizeStr")).toString(), QStringLiteral("1.1 GB"));
    QCOMPARE(proxy.get(3).value(QStringLiteral("sizeStr")).toString(), QStringLiteral("2.8 GB"));

    // Sort by human-readable string sizes (sizeStr) descending: 2.8 GB > 1.1 GB > 420 MB > 148 MB
    proxy.sortByRole(QStringLiteral("sizeStr"), Qt::DescendingOrder);
    QCOMPARE(proxy.get(0).value(QStringLiteral("sizeStr")).toString(), QStringLiteral("2.8 GB"));
    QCOMPARE(proxy.get(1).value(QStringLiteral("sizeStr")).toString(), QStringLiteral("1.1 GB"));
    QCOMPARE(proxy.get(2).value(QStringLiteral("sizeStr")).toString(), QStringLiteral("420 MB"));
    QCOMPARE(proxy.get(3).value(QStringLiteral("sizeStr")).toString(), QStringLiteral("148 MB"));

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

void TestCoreComponents::testPhase2ControlsAndLayoutAudit()
{
    QQmlEngine engine;
    engine.addImportPath(QStringLiteral(CACHYOS_BUILD_QML_DIR));

    QQmlComponent component(&engine);
    component.setData(QByteArrayLiteral(R"QML(
        import QtQuick
        import QtQuick.Layouts
        import CachyOS.UI

        CachyWindow {
            id: win
            title: "Phase 2 Controls Audit"
            width: 760
            height: 620
            contentPadded: true

            headerLeading: [
                CachyNavigationButtons {
                    anchors.verticalCenter: parent.verticalCenter
                    canGoBack: true
                    canGoForward: false
                }
            ]

            ColumnLayout {
                anchors.fill: parent
                spacing: CachyTheme.spacingSmall

                CachyBreadcrumbBar {
                    objectName: "breadcrumbBar"
                    Layout.fillWidth: true
                    Layout.minimumWidth: 0
                    path: "/home/cesar/Proyectos/cachyos-ui"
                }

                CachyTabView {
                    id: tabView
                    objectName: "tabView"
                    Layout.fillWidth: true
                    Layout.minimumWidth: 0
                    Layout.fillHeight: true
                    tabs: [
                        { title: "General", iconName: "settings" },
                        { title: "Downloads", iconName: "download" }
                    ]

                    CachyFormCard {
                        Layout.fillWidth: true

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: CachyTheme.spacingMedium

                            CachyCheckBox {
                                objectName: "checkBox"
                                text: "Enable BORE Scheduler"
                                checked: true
                            }
                            CachyRadioButton {
                                objectName: "radioButton"
                                text: "Performance"
                                checked: true
                            }
                            CachyBadge {
                                objectName: "badge"
                                text: "Active"
                                badgeType: "success"
                                iconName: "check"
                            }
                            CachyBusyIndicator {
                                objectName: "busyIndicator"
                                running: true
                                size: 18
                            }
                        }

                        CachyFormDelegateSeparator {}

                        CachyFormComboBoxDelegate {
                            objectName: "comboDelegate"
                            label: "Color Mode"
                            model: ["Auto", "Light", "Dark"]
                            currentIndex: 2
                        }

                        CachyFormDelegateSeparator {}

                        CachyFormSpinBoxDelegate {
                            objectName: "spinDelegate"
                            label: "Listening Port"
                            from: 1024
                            to: 65535
                            value: 51413
                        }

                        CachyTextArea {
                            objectName: "textArea"
                            Layout.fillWidth: true
                            Layout.minimumWidth: 0
                            placeholderText: "Release notes..."
                            text: "CachyOS.UI Phase 2 controls"
                        }
                    }

                    Item {}
                }

                CachyToast {
                    id: toast
                    objectName: "toast"
                    Layout.alignment: Qt.AlignHCenter
                    text: "Settings saved"
                    messageType: "success"
                }
            }

            CachyMenu {
                id: contextMenu
                objectName: "contextMenu"
                CachyMenuItem {
                    text: "Copy"
                    iconName: "file"
                    shortcutText: "Ctrl+C"
                }
                CachyMenuSeparator {}
                CachyMenuItem {
                    text: "Move to Trash"
                    iconName: "trash"
                    destructive: true
                }
            }
        }
    )QML"), QUrl());

    QVERIFY2(!component.isError(), qPrintable(component.errorString()));
    QScopedPointer<QObject> obj(component.create());
    auto *window = qobject_cast<QQuickWindow *>(obj.data());
    QVERIFY(window != nullptr);
    QVERIFY(QTest::qWaitForWindowExposed(window));
    QCoreApplication::processEvents();

    // Verify spinbox clamping and toast activation
    auto *spinDelegate = window->findChild<QQuickItem *>(QStringLiteral("spinDelegate"));
    QVERIFY(spinDelegate != nullptr);
    QCOMPARE(spinDelegate->property("value").toInt(), 51413);

    auto *toast = window->findChild<QQuickItem *>(QStringLiteral("toast"));
    QVERIFY(toast != nullptr);
    QMetaObject::invokeMethod(toast, "show",
                              Q_ARG(QVariant, QStringLiteral("Configuration updated")),
                              Q_ARG(QVariant, QStringLiteral("info")),
                              Q_ARG(QVariant, 0));
    QCOMPARE(toast->property("active").toBool(), true);

    const auto violations = LayoutAuditor::audit(window->contentItem());
    QStringList messages;
    for (const auto &v : violations) {
        messages.append(v.toString());
    }
    QVERIFY2(violations.isEmpty(), qPrintable(messages.join(QLatin1Char('\n'))));
}

void TestCoreComponents::testPhase3ControlsAndLayoutAudit()
{
    QQmlEngine engine;
    engine.addImportPath(QStringLiteral(CACHYOS_BUILD_QML_DIR));

    QQmlComponent component(&engine);
    component.setData(QByteArrayLiteral(R"QML(
        import QtQuick
        import QtQuick.Layouts
        import CachyOS.UI

        CachyWindow {
            id: win
            title: "Phase 3 Controls Audit"
            width: 880
            height: 640
            contentPadded: true

            ColumnLayout {
                anchors.fill: parent
                spacing: CachyTheme.spacingSmall

                CachyBreadcrumbBar {
                    objectName: "breadcrumbBar"
                    Layout.fillWidth: true
                    Layout.minimumWidth: 0
                    path: "/home/cesar/Proyectos/cachyos-ui"
                }

                CachySplitView {
                    objectName: "splitView"
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    orientation: Qt.Horizontal

                    CachyListItem {
                        objectName: "listItem"
                        width: 260
                        title: "CachyOS ISO image"
                        subtitle: "2850 MB"
                        iconName: "file"
                        iconColor: CachyTheme.accentColor
                        badgeText: "Active"
                        badgeType: "accent"
                        progressValue: 0.65
                        statusText: "Downloading"
                    }

                    CachyGridItem {
                        objectName: "gridItem"
                        width: 120
                        title: "Wallpapers"
                        subtitle: "420 MB"
                        iconName: "folder"
                        iconColor: "#007AFF"
                        selected: true
                    }
                }

                CachyTableHeader {
                    objectName: "tableHeader"
                    Layout.fillWidth: true
                    Layout.minimumWidth: 0
                    sortRole: "name"
                    columns: [
                        { role: "name", title: "Nombre", width: 240, fillWidth: true },
                        { role: "size", title: "Tamaño", width: 100 },
                        { role: "status", title: "Estado", width: 120 }
                    ]
                }

                CachyTableView {
                    objectName: "tableView"
                    Layout.fillWidth: true
                    Layout.minimumWidth: 0
                    Layout.preferredHeight: 120
                    columns: [
                        { role: "name", title: "Nombre", width: 200, fillWidth: true },
                        { role: "size", title: "Tamaño", width: 100 },
                        { role: "status", title: "Estado", width: 120, type: "badge" }
                    ]
                }

                CachyStatusBar {
                    objectName: "statusBar"
                    summaryText: "24 elementos • 142 GB disponibles"
                    secondaryText: "↓ 12.4 MB/s ↑ 1.8 MB/s"
                    leadingIcon: "info"
                }

                CachyFileDropArea {
                    objectName: "fileDropArea"
                    Layout.fillWidth: true
                    Layout.minimumWidth: 0
                    Layout.preferredHeight: 80
                    placeholderTitle: "Arrastra archivos aquí"
                    placeholderSubtitle: ".torrent, .iso"
                    acceptedExtensions: ["torrent", "iso"]
                }

                CachyPlasmoidSurface {
                    objectName: "plasmoidSurface"
                    Layout.fillWidth: true
                    Layout.minimumWidth: 0
                    Layout.preferredHeight: 120
                    title: "Quick Settings"
                    subtitle: "Phase 3 audit"
                    iconName: "settings"
                }
            }
        }
    )QML"), QUrl());

    QVERIFY2(!component.isError(), qPrintable(component.errorString()));
    QScopedPointer<QObject> obj(component.create());
    auto *window = qobject_cast<QQuickWindow *>(obj.data());
    QVERIFY(window != nullptr);
    QVERIFY(QTest::qWaitForWindowExposed(window));
    QCoreApplication::processEvents();

    const auto violations = LayoutAuditor::audit(window->contentItem());
    QStringList messages;
    for (const auto &v : violations) {
        messages.append(v.toString());
    }
    QVERIFY2(violations.isEmpty(), qPrintable(messages.join(QLatin1Char('\n'))));
}

void TestCoreComponents::testPhaseAControlsAndLayoutAudit()
{
    QQmlEngine engine;
    QQmlComponent component(&engine);
    component.setData(QByteArrayLiteral(R"QML(
        import QtQuick
        import QtQuick.Layouts
        import CachyOS.UI

        CachyWindow {
            id: win
            width: 800
            height: 900
            visible: true

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 16
                spacing: 12

                CachyTagField {
                    Layout.fillWidth: true
                    tags: ["CachyOS", "Wayland", "Vulkan", "Linux"]
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 12

                    CachyDatePicker {
                        Layout.preferredWidth: 280
                        Layout.preferredHeight: 300
                    }

                    CachyTimePicker {
                        Layout.preferredWidth: 260
                        Layout.preferredHeight: 90
                        is24Hour: false
                    }
                }

                CachyWaveformSlider {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 28
                    position: 0.45
                }

                CachyMediaBar {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 76
                    trackTitle: "La Graciosa"
                    trackArtist: "Quevedo, Elvis Crespo"
                    isPlaying: true
                    position: 0.35
                    positionSeconds: 84
                    durationSeconds: 240
                }
            }

            CachyDrawer {
                id: drawer
                edge: Qt.RightEdge
                drawerSize: 260
                title: "Detalles del Medio"
                opened: false
            }
        }
    )QML"), QUrl());

    QVERIFY2(!component.isError(), qPrintable(component.errorString()));
    QScopedPointer<QObject> obj(component.create());
    auto *window = qobject_cast<QQuickWindow *>(obj.data());
    QVERIFY(window != nullptr);
    QVERIFY(QTest::qWaitForWindowExposed(window));
    QCoreApplication::processEvents();

    const auto violations = LayoutAuditor::audit(window->contentItem());
    QStringList messages;
    for (const auto &v : violations) {
        messages.append(v.toString());
    }
    QVERIFY2(violations.isEmpty(), qPrintable(messages.join(QLatin1Char('\n'))));
}

QTEST_MAIN(TestCoreComponents)
#include "test_core_components.moc"
