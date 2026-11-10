/*
 * SPDX-FileCopyrightText: 2026 CachyOS UI contributors
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

#pragma once

#include <QObject>
#include <QQuickWindow>
#include <qqmlregistration.h>

class CachyWindowBlur : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_ATTACHED(CachyWindowBlur)
    Q_PROPERTY(bool enabled READ isEnabled WRITE setEnabled NOTIFY enabledChanged)

public:
    explicit CachyWindowBlur(QObject *parent = nullptr);
    ~CachyWindowBlur() override = default;

    bool isEnabled() const { return m_enabled; }
    void setEnabled(bool enabled);

    static CachyWindowBlur *qmlAttachedProperties(QObject *object);

Q_SIGNALS:
    void enabledChanged();

private:
    void applyBlur();

    bool m_enabled{true};
    QQuickWindow *m_window{nullptr};
};
