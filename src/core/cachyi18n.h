/*
 * SPDX-FileCopyrightText: 2026 CachyOS UI contributors
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

#pragma once

#include <QObject>
#include <QString>
#include <QVariant>
#include <qqmlregistration.h>

/**
 * Internationalisation helpers of the CachyOS.UI design system.
 *
 * The KF6 QML module `org.kde.ki18n` returns an **empty string** instead of
 * falling back to the source text in some installations (verified against
 * KF6 6.31: `KI18n.i18n("Hello World")` yields "" even when the domain has a
 * catalogue). Wrapping the labels in it therefore silently blanks the whole
 * interface, including the window title.
 *
 * This singleton calls `KLocalizedString` directly, so it always returns the
 * original text when there is no catalogue, and the translated one when there
 * is. It is the entry point used by the applications of the ecosystem:
 *
 *     import CachyOS.UI
 *     Text { text: CachyI18n.i18n("Undo") }
 *
 * The application domain is taken from `KLocalizedString::setApplicationDomain()`,
 * which every application sets at startup.
 */
class CachyI18n : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON

public:
    explicit CachyI18n(QObject *parent = nullptr)
        : QObject(parent)
    {
    }

    /// Translates @p message using the application domain.
    ///
    /// The optional arguments replace the `%1`, `%2` … placeholders of the
    /// message, exactly like the KF6 `i18n()` helper does.
    Q_INVOKABLE QString i18n(const QString &message,
                              const QVariant &arg1 = QVariant(),
                              const QVariant &arg2 = QVariant(),
                              const QVariant &arg3 = QVariant()) const;

    /// Translates @p message disambiguated by @p context.
    Q_INVOKABLE QString i18nc(const QString &context, const QString &message) const;

    /// Translates @p message using an explicit @p domain.
    Q_INVOKABLE QString i18d(const QString &domain, const QString &message) const;
};
