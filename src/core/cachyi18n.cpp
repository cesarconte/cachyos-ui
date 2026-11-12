/*
 * SPDX-FileCopyrightText: 2026 CachyOS UI contributors
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

#include "cachyi18n.h"

#include <KLocalizedString>

namespace {

/**
 * KF6 answers an empty message with the literal marker "(I18N_EMPTY_MESSAGE)"
 * and a message with a missing argument with "(I18N_ARGUMENT_MISSING)". Those
 * markers are developer aids and must never reach the interface: the original
 * text is kept instead.
 */
QString translated(const KLocalizedString &text, const QString &fallback)
{
    if (fallback.isEmpty()) {
        return QString();
    }

    QString result = text.toString();
    result.remove(QStringLiteral("(I18N_EMPTY_MESSAGE)"));
    result.remove(QStringLiteral("(I18N_ARGUMENT_MISSING)"));
    return result;
}

/**
 * Replaces a `%1`, `%2` … placeholder of a translated message, mirroring the
 * behaviour of the KF6 `i18n()` helper.
 */
KLocalizedString substitute(KLocalizedString text, const QVariant &value)
{
    if (!value.isValid()) {
        return text;
    }

    switch (value.typeId()) {
    case QMetaType::Int:
    case QMetaType::LongLong:
        return text.subs(value.toLongLong());
    case QMetaType::UInt:
    case QMetaType::ULongLong:
        return text.subs(value.toULongLong());
    case QMetaType::Double:
    case QMetaType::Float:
        return text.subs(value.toDouble());
    default:
        return text.subs(value.toString());
    }
}

} // namespace

QString CachyI18n::i18n(const QString &message, const QVariant &arg1, const QVariant &arg2, const QVariant &arg3) const
{
    if (message.isEmpty()) {
        return QString();
    }
    const QByteArray utf8 = message.toUtf8();
    KLocalizedString text = ki18n(utf8.constData());
    text = substitute(text, arg1);
    text = substitute(text, arg2);
    text = substitute(text, arg3);
    return translated(text, message);
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
