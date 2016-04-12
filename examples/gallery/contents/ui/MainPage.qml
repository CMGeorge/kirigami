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

import QtQuick 2.1
import QtQuick.Controls 1.4 as Controls
import QtQuick.Layouts 1.2
import org.kde.kirigami 1.0 as Kirigami

Kirigami.ScrollablePage {
    id: pageRoot

    anchors.fill:parent
    background: Rectangle {
        color: Kirigami.Theme.viewBackgroundColor
    }

    title: "Gallery"

    supportsRefreshing: true
    onRefreshingChanged: {
        if (refreshing) {
            refreshRequestTimer.running = true;
        }
    }

    //flickable: mainListView
    contextualActions: [
        Kirigami.Action {
            text:"Action 1"
            iconName: "document-decrypt"
            onTriggered: print("Action 1 clicked")
        },
        Kirigami.Action {
            id: shareAction
            visible: checkableAction.checked
            text:"Action 2"
            iconName: "document-share"
        },
        Kirigami.Action {
            id: checkableAction
            text:"Checkabke"
            checkable: true
            iconName: "dashboard-show"
        }
    ]



    ListView {
        id: mainListView
        Timer {
            id: refreshRequestTimer
            interval: 3000
            onTriggered: pageRoot.refreshing = false
        }
        model: ListModel {
            ListElement {
                text: "Button"
                component: "Button"
            }
            ListElement {
                text: "CheckBox"
                component: "CheckBox"
            }
            ListElement {
                text: "Radio Button"
                component: "RadioButton"
            }
            ListElement {
                text: "Progress Bar"
                component: "ProgressBar"
            }
            ListElement {
                text: "Slider"
                component: "Slider"
            }
            ListElement {
                text: "Switch"
                component: "Switch"
            }
            ListElement {
                text: "Text Field"
                component: "TextField"
            }
            ListElement {
                text: "Non Scrollable Page"
                component: "NonScrollable"
            }
        }
        delegate: Kirigami.SwipeListItem {
            Row {
                Kirigami.Label {
                    text: model.text
                }
            }
            property Item ownPage
            onClicked: {
                if (!model.component) {
                    return;
                }
                root.pageStack.pop(pageRoot);
                ownPage = root.pageStack.push(Qt.resolvedUrl("gallery/" + model.component + "Gallery.qml"));
            }
            checked: ownPage && root.pageStack.lastItem == ownPage
            actions: [
                Kirigami.Action {
                    iconName: "document-decrypt"
                    onTriggered: print("Action 1 clicked")
                },
                Kirigami.Action {
                    iconName: "mail-reply-sender"
                }]
        }
    }
}

