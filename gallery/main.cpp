/*
 * SPDX-FileCopyrightText: 2026 CachyOS UI contributors
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQuickWindow>
#include <QtPlugin>

Q_IMPORT_PLUGIN(CachyOS_UIPlugin)

int main(int argc, char *argv[])
{
    // Force Wayland backend on CachyOS
    qputenv("QT_QPA_PLATFORM", "wayland;xcb");

    QGuiApplication app(argc, argv);
    app.setApplicationName(QStringLiteral("cachyos-ui-gallery"));
    app.setOrganizationName(QStringLiteral("CachyOS"));

    QQmlApplicationEngine engine;
    engine.addImportPath(QStringLiteral(":/"));
    engine.addImportPath(QStringLiteral("qrc:/"));

    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreationFailed,
        &app,
        []() { QCoreApplication::exit(-1); },
        Qt::QueuedConnection);

    engine.load(QUrl(QStringLiteral("qrc:/CachyOS/UI/Gallery/GalleryWindow.qml")));

    return app.exec();
}
