/*
 *   Copyright 2015 Marco Martin <mart@kde.org>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License as
 *   published by the Free Software Foundation; either version 2 or
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

import QtQuick 2.5
import QtQuick.Controls 1.3 as Controls
import QtQuick.Layouts 1.2
import QtQuick.Controls.Private 1.0
import "private"
import org.kde.kirigami 1.0


/**
 * 
 */
ApplicationHeader {
    id: header

    preferredHeight: 38
    maximumHeight: preferredHeight

    //FIXME: needs a property difinition to have its own type in qml
    property string _internal: ""

    pageDelegate: Item {
        id: delegateItem
        readonly property Page page: applicationWindow().pageStack.get(modelData)
        property ListView view: ListView.view
        readonly property bool current: __appWindow.pageStack.currentIndex == index
        property Row layout

        width: {
            //more columns shown?
            if (__appWindow.wideScreen) {
                if (modelData == 0 && view.x > 0) {
                    return page.width - view.x;
                } else {
                    return page.width;
                }
            } else {
                return Math.min(view.width, delegateRoot.implicitWidth + Units.smallSpacing);
            }
        }
        height: view.height

        Component.onCompleted: {
            layout = toolbarComponent.createObject(delegateItem)
        }
        Component {
            id: toolbarComponent
            Row {
                id: layout
                anchors.verticalCenter: parent.verticalCenter
                x: __appWindow.wideScreen ? (Math.min(delegateItem.width - width, Math.max(0, delegateItem.view.contentX - delegateItem.x))) : 0
                spacing: 2

                Rectangle {
                    anchors.verticalCenter: parent.verticalCenter
                    color: Theme.textColor
                    opacity: 0.3
                    width: Units.devicePixelRatio
                    height: parent.height * 0.6
                }
                PrivateActionToolButton {
                    anchors.verticalCenter: parent.verticalCenter
                    action: page && page.actions ? page.actions.left : null
                    showText: false
                }
                PrivateActionToolButton {
                    anchors.verticalCenter: parent.verticalCenter
                    action: page && page.actions ? page.actions.main : null
                    showText: false
                }
                PrivateActionToolButton {
                    anchors.verticalCenter: parent.verticalCenter
                    action: page && page.actions ? page.actions.right : null
                    showText: false
                }
                Rectangle {
                    anchors.verticalCenter: parent.verticalCenter
                    color: Theme.textColor
                    opacity: 0.3
                    width: Units.devicePixelRatio
                    height: parent.height * 0.6
                }
                Repeater {
                    id: repeater
                    model: page && page.actions.contextualActions ? page.actions.contextualActions : null
                    delegate: PrivateActionToolButton {
                        anchors.verticalCenter: parent.verticalCenter
                        action: modelData
                        visible: modelData.visible && x+layout.x+width*2 < delegateItem.width
                    }
                }
            }
        }
        Heading {
            x: __appWindow.wideScreen ? (Math.min(delegateItem.width - width, Math.max(0, delegateItem.view.contentX - delegateItem.x))) : 0
            anchors.verticalCenter: parent.verticalCenter
            visible: layout.width <= 0
            opacity: delegateItem.current ? 1 : 0.4
            color: Theme.textColor
            elide: Text.ElideRight
            text: page ? page.title : ""
            font.pixelSize: parent.height / 1.6
        }
        Controls.ToolButton {
            id: moreButton
            anchors {
                right: parent.right
                verticalCenter: parent.verticalCenter
            }

            //TODO: we need a kebab icon
            iconName: "application-menu"
            visible: menu.visibleChildren > 0
            onClicked: page.actions.main

            menu: Controls.Menu {
                id: menu

                property int visibleChildren: 0
                Instantiator {
                    model: page && page.actions.contextualActions ? page.actions.contextualActions : null
                    delegate: Controls.MenuItem {
                        text: modelData ? modelData.text : ""
                        iconName: modelData.iconName
                        shortcut: modelData.shortcut
                        onTriggered: modelData.trigger();
                        //skip the 3 buttons and 2 separators
                        visible: !layout.children[index+5].visible && modelData.visible
                        enabled: modelData.enabled
                        onVisibleChanged: {
                            if (visible) {
                                menu.visibleChildren++;
                            } else {
                                menu.visibleChildren = Math.max(0, menu.visibleChildren-1);
                            }
                        }
                    }
                    onObjectAdded: {
                        menu.insertItem(index, object);
                        if (object.visible) {
                            menu.visibleChildren++;
                        }
                    }
                    onObjectRemoved: {
                        menu.removeItem(object);
                        if (object.visible) {
                            menu.visibleChildren = Math.max(0, menu.visibleChildren-1);
                        }
                    }
                }
            }
        }
    }
}
