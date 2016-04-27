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

import QtQuick 2.0
import QtQuick.Controls 1.2 as Controls
import QtQuick.Layouts 1.2
import org.kde.kirigami 1.0

ScrollablePage {
    id: page
    actions {
        main: Action {
            iconName: sheet.opened ? "dialog-cancel" : "document-edit"
            onTriggered: {
                print("Action button in buttons page clicked");
                sheet.opened = !sheet.opened
            }
        }
        contextualActions: [
            Controls.Action {
                text:"Action for checkbox page"
                onTriggered: print("Action 1 clicked")
            },
            Controls.Action {
                text:"Action 2"
            }
        ]
    }

    Layout.fillWidth: true
    title: "Checkboxes"

    ColumnLayout {
        //This OverlaySheet is put in the "wrong place", but will be automatically reparented
        // to "page"
        OverlaySheet {
            id: sheet
            Label {
                wrapMode: Text.WordWrap
                text: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nullam id risus id augue euismod accumsan. Nunc vestibulum placerat bibendum. Morbi commodo auctor varius. Donec molestie euismod ultrices. Sed facilisis augue nec eros auctor, vitae mattis quam rhoncus. Nam ut erat diam. Curabitur iaculis accumsan magna, eget fermentum massa scelerisque eu. Cras elementum erat non erat euismod accumsan. Vestibulum ac mi sed dui finibus pulvinar. Vivamus dictum, leo sed lobortis porttitor, nisl magna faucibus orci, sit amet euismod arcu elit eget est. Duis et vehicula nibh. In arcu sapien, laoreet sit amet porttitor non, rhoncus vel magna. Suspendisse imperdiet consectetur est nec ornare. Pellentesque bibendum sapien at erat efficitur vehicula. Morbi sed porta nibh. Vestibulum ut urna ut dolor sagittis mattis."
            }
        }
        Item {
            Layout.fillWidth: true
            Layout.minimumHeight: units.gridUnit * 10
            GridLayout {
                anchors.centerIn: parent
                columns: 3
                rows: 3
                rowSpacing: Units.smallSpacing

                Item {
                    width: 1
                    height: 1
                }
                Label {
                    text: "Normal"
                }
                Label {
                    text: "Disabled"
                    enabled: false
                }
                Label {
                    text: "On"
                }
                Controls.CheckBox {
                    text: "On"
                    checked: true
                }
                Controls.CheckBox {
                    text: "On"
                    checked: true
                    enabled: false
                }
                Label {
                    text: "Off"
                }
                Controls.CheckBox {
                    text: "Off"
                    checked: false
                }
                Controls.CheckBox {
                    text: "Off"
                    checked: false
                    enabled: false
                }
            }
        }
    }
}
