/*
 * SPDX-FileCopyrightText: 2026 CachyOS UI contributors
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQuickWindow>

int main(int argc, char *argv[])
{
    // Force Wayland backend on CachyOS
    qputenv("QT_QPA_PLATFORM", "wayland;xcb");

    QGuiApplication app(argc, argv);
    app.setApplicationName(QStringLiteral("cachyos-ui-gallery"));
    app.setOrganizationName(QStringLiteral("CachyOS"));

    QQmlApplicationEngine engine;
    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreationFailed,
        &app,
        []() { QCoreApplication::exit(-1); },
        Qt::QueuedConnection);

    engine.loadFromModule("CachyOS.UI.Gallery", "GalleryWindow");

    return app.exec();
}
