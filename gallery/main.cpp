/*
 * SPDX-FileCopyrightText: 2026 CachyOS UI contributors
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

#include <QCommandLineOption>
#include <QCommandLineParser>
#include <QDir>
#include <QGuiApplication>
#include <QIcon>
#include <QQmlApplicationEngine>
#include <QQuickItem>
#include <QQuickWindow>
#include <QTest>
#include <iostream>

#include "LayoutAuditor.h"

int main(int argc, char *argv[])
{
    // Force Wayland backend on CachyOS unless offscreen is needed
    bool hasAudit = false;
    for (int i = 1; i < argc; ++i) {
        if (qstrcmp(argv[i], "--audit") == 0) {
            hasAudit = true;
            break;
        }
    }

    if (hasAudit && qgetenv("QT_QPA_PLATFORM").isEmpty()) {
        qputenv("QT_QPA_PLATFORM", "offscreen");
    } else if (qgetenv("QT_QPA_PLATFORM").isEmpty()) {
        qputenv("QT_QPA_PLATFORM", "wayland;xcb");
    }

    QQuickWindow::setDefaultAlphaBuffer(true);

    QGuiApplication app(argc, argv);
    app.setApplicationName(QStringLiteral("cachyos-ui-gallery"));
    app.setApplicationVersion(QStringLiteral("1.0.0"));
    app.setOrganizationName(QStringLiteral("CachyOS"));
    app.setDesktopFileName(QStringLiteral("org.cesar.cachyos-ui-gallery"));
    app.setWindowIcon(QIcon::fromTheme(QStringLiteral("preferences-desktop-plasma-theme"), QIcon::fromTheme(QStringLiteral("preferences-system"))));

    QCommandLineParser parser;
    parser.setApplicationDescription(QStringLiteral("CachyOS.UI Golden Gate Component Showcase"));
    parser.addHelpOption();
    parser.addVersionOption();

    QCommandLineOption auditOption(QStringLiteral("audit"), QStringLiteral("Run automated LayoutAuditor check on all categories without UI."));
    parser.addOption(auditOption);

    QCommandLineOption captureOption(QStringLiteral("capture"), QStringLiteral("Directory to save screenshots of gallery sections during audit."), QStringLiteral("directory"));
    parser.addOption(captureOption);

    parser.process(app);

    QQmlApplicationEngine engine;
    engine.addImportPath(QStringLiteral("/home/cesar/Proyectos/cachyos-ui/build/src"));
    engine.addImportPath(QStringLiteral(":/"));
    engine.addImportPath(QStringLiteral("qrc:/"));
    engine.addImportPath(QStringLiteral("/home/cesar/.local/lib/qt6/qml"));

    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreationFailed,
        &app,
        []() { QCoreApplication::exit(-1); },
        Qt::QueuedConnection);

    engine.load(QUrl(QStringLiteral("qrc:/CachyOS/UI/Gallery/GalleryWindow.qml")));

    const auto rootObjects = engine.rootObjects();
    if (rootObjects.isEmpty()) {
        std::cerr << "Failed to load GalleryWindow.qml" << std::endl;
        return 1;
    }

    auto *window = qobject_cast<QQuickWindow *>(rootObjects.first());
    if (!window) {
        std::cerr << "Root object is not a QQuickWindow" << std::endl;
        return 1;
    }

    // Automated Layout Auditor & Screenshot capture mode
    if (parser.isSet(auditOption)) {
        window->show();
        (void)QTest::qWaitForWindowExposed(window, 500);
        QCoreApplication::processEvents();

        const QString captureDir = parser.value(captureOption);
        if (!captureDir.isEmpty()) {
            QDir().mkpath(captureDir);
        }

        const struct Resolution {
            int width;
            int height;
            const char *label;
        } resolutions[] = {
            {760, 540, "minimum"},
            {880, 640, "default"},
            {1200, 800, "wide"}
        };

        const int totalSections = 7;
        int totalViolations = 0;

        for (const auto &res : resolutions) {
            window->setWidth(res.width);
            window->setHeight(res.height);
            QCoreApplication::processEvents();

            for (int sec = 0; sec < totalSections; ++sec) {
                window->setProperty("activeNavIndex", sec);
                QCoreApplication::processEvents();

                const auto violations = LayoutAuditor::audit(window->contentItem());
                if (!violations.isEmpty()) {
                    totalViolations += violations.size();
                    std::cerr << "[AUDIT FAIL] Res: " << res.label << " (" << res.width << "x" << res.height
                              << ") Section: " << sec << std::endl;
                    for (const auto &v : violations) {
                        std::cerr << "  - " << v.toString().toStdString() << std::endl;
                    }
                }

                if (!captureDir.isEmpty()) {
                    const QImage img = window->grabWindow();
                    const QString fileName = QStringLiteral("%1/gallery_sec%2_%3.png")
                                                 .arg(captureDir)
                                                 .arg(sec)
                                                 .arg(QLatin1String(res.label));
                    img.save(fileName);
                }
            }
        }

        if (totalViolations > 0) {
            std::cerr << "\nAudit failed with " << totalViolations << " layout violation(s)!" << std::endl;
            return 1;
        }

        std::cout << "\n✓ CachyOS.UI Gallery Layout Auditor passed (0 violations across all " << totalSections << " sections and 3 resolutions)." << std::endl;
        return 0;
    }

    return app.exec();
}
