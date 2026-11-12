/*
    SPDX-FileCopyrightText: 2026 CachyOS UI contributors
    SPDX-License-Identifier: GPL-3.0-or-later

    Regression test of the internationalisation helper.

    The KF6 QML module `org.kde.ki18n` returns an empty string instead of the
    source text, which silently blanks every label. `CachyI18n` must always
    return the original text when there is no catalogue for the domain.
*/

#include <QCoreApplication>
#include <QTest>

#include <KLocalizedString>

#include "cachyi18n.h"

class TestCachyI18n : public QObject
{
    Q_OBJECT

private Q_SLOTS:
    void initTestCase();
    void testFallsBackToSourceText();
    void testContextVariant();
    void testDomainVariant();
    void testEmptyMessage();

private:
    CachyI18n m_i18n;
};

void TestCachyI18n::initTestCase()
{
    // A domain without any catalogue: the worst case for a translation helper.
    KLocalizedString::setApplicationDomain("cachyos-ui-selftest-no-catalogue");
}

void TestCachyI18n::testFallsBackToSourceText()
{
    // This is the regression: the helper must never blank a label.
    QCOMPARE(m_i18n.i18n(QStringLiteral("Undo")), QStringLiteral("Undo"));
    QCOMPARE(m_i18n.i18n(QStringLiteral("KLiveCaptions — Subtítulos en Tiempo Real")),
             QStringLiteral("KLiveCaptions — Subtítulos en Tiempo Real"));

    // A message that certainly exists in a catalogue must also come back
    // untouched when the domain has none.
    QVERIFY(!m_i18n.i18n(QStringLiteral("Save")).isEmpty());
}

void TestCachyI18n::testContextVariant()
{
    QCOMPARE(m_i18n.i18nc(QStringLiteral("Verb"), QStringLiteral("Open")),
             QStringLiteral("Open"));
    QVERIFY(!m_i18n.i18nc(QStringLiteral("Verb"), QStringLiteral("Open")).isEmpty());
}

void TestCachyI18n::testDomainVariant()
{
    QCOMPARE(m_i18n.i18d(QStringLiteral("kcmutils"), QStringLiteral("Save")),
             QStringLiteral("Save"));
    QVERIFY(!m_i18n.i18d(QStringLiteral("kcmutils"), QStringLiteral("Save")).isEmpty());
}

void TestCachyI18n::testEmptyMessage()
{
    // An empty message must not throw and must stay empty.
    QCOMPARE(m_i18n.i18n(QString()), QString());
}

QTEST_MAIN(TestCachyI18n)
#include "test_cachyi18n.moc"
