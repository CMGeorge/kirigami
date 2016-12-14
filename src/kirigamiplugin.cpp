/*
 *   Copyright 2009 by Alan Alpert <alan.alpert@nokia.com>
 *   Copyright 2010 by Ménard Alexis <menard@kde.org>
 *   Copyright 2010 by Marco Martin <mart@kde.org>

 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License as
 *   published by the Free Software Foundation; either version 2, or
 *   (at your option) any later version.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU Library General Public License for more details
 *
 *   You should have received a copy of the GNU Library General Public
 *   License along with this program; if not, write to the
 *   Free Software Foundation, Inc.,
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

#include "kirigamiplugin.h"
#include "enums.h"
#include "desktopicon.h"
#include "settings.h"

#include <QQmlEngine>
#include <QQmlContext>
#include <QQuickItem>

QString KirigamiPlugin::componentPath(const QString &fileName) const
{
    foreach (const QString &style, m_stylesFallbackChain) {
        const QString candidate = QStringLiteral("styles/") + style + QLatin1Char('/') + fileName;
        if (QFile::exists(resolveFilePath(candidate))) {
            return resolveFileUrl(candidate);
        }
    }
    return resolveFileUrl(fileName);
}


void KirigamiPlugin::registerTypes(const char *uri)
{
    Q_ASSERT(uri == QLatin1String("org.kde.kirigami"));
    const QString style = QString::fromLatin1(qgetenv("QT_QUICK_CONTROLS_STYLE"));

#if !defined(Q_OS_ANDROID) && !defined(Q_OS_IOS)
    if (style.isEmpty() && QFile::exists(resolveFilePath(QStringLiteral("/styles/Desktop")))) {
        m_stylesFallbackChain.prepend(QStringLiteral("Desktop"));
    }
#endif

    if (!style.isEmpty() && QFile::exists(resolveFilePath(QStringLiteral("/styles/") + style))) {
        m_stylesFallbackChain.prepend(style);
    }
    //At this point the fallback chain will be selected->Desktop->Fallback


    //TODO: in this plugin it will end up something similar to
    //PlasmaCore's ColorScope?

    qmlRegisterSingletonType<Settings>(uri, 2, 0, "Settings",
         [](QQmlEngine*, QJSEngine*) -> QObject* {
             return new Settings;
         }
     );

    qmlRegisterUncreatableType<ApplicationHeaderStyle>(uri, 2, 0, "ApplicationHeaderStyle", "Cannot create objects of type ApplicationHeaderStyle");

    qmlRegisterSingletonType(componentPath(QStringLiteral("Theme.qml")), uri, 2, 0, "Theme");
    qmlRegisterSingletonType(componentPath(QStringLiteral("Units.qml")), uri, 2, 0, "Units");

    qmlRegisterType(componentPath(QStringLiteral("Action.qml")), uri, 2, 0, "Action");
    qmlRegisterType(componentPath(QStringLiteral("AbstractApplicationHeader.qml")), uri, 2, 0, "AbstractApplicationHeader");
    qmlRegisterType(componentPath(QStringLiteral("AbstractApplicationWindow.qml")), uri, 2, 0, "AbstractApplicationWindow");
    qmlRegisterType(componentPath(QStringLiteral("AbstractListItem.qml")), uri, 2, 0, "AbstractListItem");
    qmlRegisterType(componentPath(QStringLiteral("ApplicationHeader.qml")), uri, 2, 0, "ApplicationHeader");
    qmlRegisterType(componentPath(QStringLiteral("ToolBarApplicationHeader.qml")), uri, 2, 0, "ToolBarApplicationHeader");
    qmlRegisterType(componentPath(QStringLiteral("ApplicationWindow.qml")), uri, 2, 0, "ApplicationWindow");
    qmlRegisterType(componentPath(QStringLiteral("BasicListItem.qml")), uri, 2, 0, "BasicListItem");
    qmlRegisterType(componentPath(QStringLiteral("OverlayDrawer.qml")), uri, 2, 0, "OverlayDrawer");
    qmlRegisterType(componentPath(QStringLiteral("ContextDrawer.qml")), uri, 2, 0, "ContextDrawer");
    qmlRegisterType(componentPath(QStringLiteral("GlobalDrawer.qml")), uri, 2, 0, "GlobalDrawer");
    qmlRegisterType(componentPath(QStringLiteral("Heading.qml")), uri, 2, 0, "Heading");
    qmlRegisterType(componentPath(QStringLiteral("Separator.qml")), uri, 2, 0, "Separator");
    qmlRegisterType(componentPath(QStringLiteral("PageRow.qml")), uri, 2, 0, "PageRow");

    //The icon is "special: we have to use a wrapper class to QIcon on desktops
#if !defined(Q_OS_ANDROID) && !defined(Q_OS_IOS)
    if (!m_stylesFallbackChain.isEmpty() && m_stylesFallbackChain.first() == QStringLiteral("Desktop")) {
        qmlRegisterType<DesktopIcon>(uri, 2, 0, "Icon");
    } else {
        qmlRegisterType(componentPath(QStringLiteral("Icon.qml")), uri, 2, 0, "Icon");
    }
#else
    qmlRegisterType(componentPath(QStringLiteral("Icon.qml")), uri, 2, 0, "Icon");
#endif

    qmlRegisterType(componentPath(QStringLiteral("Label.qml")), uri, 2, 0, "Label");
    qmlRegisterType(componentPath(QStringLiteral("OverlaySheet.qml")), uri, 2, 0, "OverlaySheet");
    qmlRegisterType(componentPath(QStringLiteral("Page.qml")), uri, 2, 0, "Page");
    qmlRegisterType(componentPath(QStringLiteral("ScrollablePage.qml")), uri, 2, 0, "ScrollablePage");
    qmlRegisterType(componentPath(QStringLiteral("SplitDrawer.qml")), uri, 2, 0, "SplitDrawer");
    qmlRegisterType(componentPath(QStringLiteral("SwipeListItem.qml")), uri, 2, 0, "SwipeListItem");
}

#include "moc_kirigamiplugin.cpp"

