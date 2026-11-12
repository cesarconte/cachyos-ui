/*
 * SPDX-FileCopyrightText: 2026 CachyOS UI contributors
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

#include "cachyi18n.h"

#include <KLocalizedString>

namespace {

/**
 * KF6 answers an empty message with the literal marker "(I18N_EMPTY_MESSAGE)".
 * A label whose text is empty must stay empty, otherwise the marker would be
 * rendered in the interface.
 */
QString translated(const KLocalizedString &text, const QString &fallback)
{
    if (fallback.isEmpty()) {
        return QString();
    }
    return text.toString();
}

} // namespace

QString CachyI18n::i18n(const QString &message) const
{
    if (message.isEmpty()) {
        return QString();
    }
    const QByteArray utf8 = message.toUtf8();
    return translated(ki18n(utf8.constData()), message);
}

QString CachyI18n::i18nc(const QString &context, const QString &message) const
{
    if (message.isEmpty()) {
        return QString();
    }
    const QByteArray utf8Context = context.toUtf8();
    const QByteArray utf8Message = message.toUtf8();
    return translated(ki18nc(utf8Context.constData(), utf8Message.constData()), message);
}

QString CachyI18n::i18d(const QString &domain, const QString &message) const
{
    if (message.isEmpty()) {
        return QString();
    }
    const QByteArray utf8Domain = domain.toUtf8();
    const QByteArray utf8Message = message.toUtf8();
    return translated(ki18nd(utf8Domain.constData(), utf8Message.constData()), message);
}
