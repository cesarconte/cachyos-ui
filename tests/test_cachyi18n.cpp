/*
    SPDX-FileCopyrightText: 2026 CachyOS UI contributors
    SPDX-License-Identifier: GPL-3.0-or-later

    Regression test of the internationalisation helper.

    The KF6 QML module `org.kde.ki18n` returns an empty string instead of the
    source text, which silently blanks every label. `CachyI18n` must always
    return the original text when there is no catalogue for the domain.
*/

#include <QCoreApplication>
#include <QFile>
#include <QTest>
#include <QUrl>

#include <KLocalizedString>

#include "cachyi18n.h"
#include "cachytheme.h"

class TestCachyI18n : public QObject
{
    Q_OBJECT

private Q_SLOTS:
    void initTestCase();
    void testFallsBackToSourceText();
    void testContextVariant();
    void testPlaceholderArguments();
    void testDomainVariant();
    void testEmptyMessage();
    void testThemedIconResolution();

private:
    CachyI18n m_i18n;
    CachyTheme m_theme;
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

void TestCachyI18n::testPlaceholderArguments()
{
    // The placeholders must be replaced, and the KF6 marker of a missing
    // argument must never reach the interface.
    QCOMPARE(m_i18n.i18n(QStringLiteral("%1 palabras • %2 entidades"), 12, 3),
             QStringLiteral("12 palabras • 3 entidades"));

    QCOMPARE(m_i18n.i18n(QStringLiteral("%1 de %2"), QStringLiteral("uno"), QStringLiteral("dos")),
             QStringLiteral("uno de dos"));

    // Without arguments the placeholders stay untouched and nothing is broken.
    const QString untouched = m_i18n.i18n(QStringLiteral("%1 elementos"));
    QVERIFY(!untouched.isEmpty());
    QVERIFY(!untouched.contains(QStringLiteral("I18N_ARGUMENT_MISSING")));
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

void TestCachyI18n::testThemedIconResolution()
{
    // A known icon of the Plasma theme must be resolved into a file that
    // really exists on disk.
    const QString url = m_theme.iconUrl(QStringLiteral("edit-copy"));
    QVERIFY(!url.isEmpty());
    QVERIFY(url.startsWith(QStringLiteral("file://")));

    const QString path = QUrl(url).toLocalFile();
    QVERIFY(QFile::exists(path));
    QVERIFY(path.endsWith(QStringLiteral(".svg")));

    // The symbolic variant is preferred: it can be tinted with the colour of
    // the interface.
    QVERIFY(path.contains(QStringLiteral("symbolic")));

    // An unknown icon resolves to nothing instead of a broken image.
    QCOMPARE(m_theme.iconUrl(QStringLiteral("this-icon-does-not-exist")), QString());
    QCOMPARE(m_theme.iconUrl(QString()), QString());
}

QTEST_MAIN(TestCachyI18n)
#include "test_cachyi18n.moc"
