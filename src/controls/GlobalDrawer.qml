/*
 *   Copyright 2015 Marco Martin <mart@kde.org>
 *
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

import QtQuick 2.6
import QtQuick.Templates 2.0 as T2
import QtQuick.Controls 2.0 as QQC2
import QtQuick.Layouts 1.2
import QtGraphicalEffects 1.0
import org.kde.kirigami 2.4

import "private"
import "templates/private"

/**
 * A drawer specialization intended for the global actions of the application
 * valid regardless of the application state (think about the menubar
 * of a desktop application).
 *
 * Example usage:
 * @code
 * import org.kde.kirigami 2.4 as Kirigami
 *
 * Kirigami.ApplicationWindow {
 *  [...]
 *     globalDrawer: Kirigami.GlobalDrawer {
 *         actions: [
 *            Kirigami.Action {
 *                text: "View"
 *                iconName: "view-list-icons"
 *                Kirigami.Action {
 *                        text: "action 1"
 *                }
 *                Kirigami.Action {
 *                        text: "action 2"
 *                }
 *                Kirigami.Action {
 *                        text: "action 3"
 *                }
 *            },
 *            Kirigami.Action {
 *                text: "Sync"
 *                iconName: "folder-sync"
 *            }
 *         ]
 *     }
 *  [...]
 * }
 * @endcode
 *
 */
OverlayDrawer {
    id: root
    edge: Qt.application.layoutDirection == Qt.RightToLeft ? Qt.RightEdge : Qt.LeftEdge

    /**
     * title: string
     * A title to be displayed on top of the drawer
     */
    property alias title: bannerImage.title

    /**
     * icon: var
     * An icon to be displayed alongside the title.
     * It can be a QIcon, a fdo-compatible icon name, or any url understood by Image
     */
    property alias titleIcon: bannerImage.titleIcon

    /**
     * bannerImageSource: string
     * An image to be used as background for the title and icon for
     * a decorative purpose.
     * It accepts any url format supported by Image
     */
    property alias bannerImageSource: bannerImage.source

    /**
     * actions: list<Action>
     * The list of actions can be nested having a tree structure.
     * A tree depth bigger than 2 is discouraged.
     *
     * Example usage:
     * @code
     * import org.kde.kirigami 2.4 as Kirigami
     *
     * Kirigami.ApplicationWindow {
     *  [...]
     *     globalDrawer: Kirigami.GlobalDrawer {
     *         actions: [
     *            Kirigami.Action {
     *                text: "View"
     *                iconName: "view-list-icons"
     *                Kirigami.Action {
     *                        text: "action 1"
     *                }
     *                Kirigami.Action {
     *                        text: "action 2"
     *                }
     *                Kirigami.Action {
     *                        text: "action 3"
     *                }
     *            },
     *            Kirigami.Action {
     *                text: "Sync"
     *                iconName: "folder-sync"
     *            }
     *         ]
     *     }
     *  [...]
     * }
     * @endcode
     */
    property list<QtObject> actions


    /**
     * content: list<Item> default property
     * Any random Item can be instantiated inside the drawer and
     * will be displayed underneath the actions list.
     *
     * Example usage:
     * @code
     * import org.kde.kirigami 2.4 as Kirigami
     *
     * Kirigami.ApplicationWindow {
     *  [...]
     *     globalDrawer: Kirigami.GlobalDrawer {
     *         actions: [...]
     *         Button {
     *             text: "Button"
     *             onClicked: //do stuff
     *         }
     *     }
     *  [...]
     * }
     * @endcode
     */
    default property alias content: mainContent.data

    /**
     * topContent: list<Item> default property
     * Items that will be instantiated inside the drawer and
     * will be displayed on top of the actions list.
     *
     * Example usage:
     * @code
     * import org.kde.kirigami 2.4 as Kirigami
     *
     * Kirigami.ApplicationWindow {
     *  [...]
     *     globalDrawer: Kirigami.GlobalDrawer {
     *         actions: [...]
     *         topContent: [Button {
     *             text: "Button"
     *             onClicked: //do stuff
     *         }]
     *     }
     *  [...]
     * }
     * @endcode
     */
    property alias topContent: topContent.data

    /**
     * resetMenuOnTriggered: bool
     *
     * On the actions menu, whenever a leaf action is triggered, the menu
     * will reset to its parent.
     */
    property bool resetMenuOnTriggered: true

    /**
     * currentSubMenu: Action
     *
     * Points to the action acting as a submenu
     */
    readonly property Action currentSubMenu: stackView.currentItem ? stackView.currentItem.current: null

    //TODO cable those with modal
    property bool collapsible: false
    property bool collapsed: false

    /**
     * Notifies that the banner has been clicked
     */
    signal bannerClicked()

    /**
     * Reverts the menu back to its initial state
     */
    function resetMenu() {
        stackView.pop(stackView.get(0, T2.StackView.DontLoad));
        if (root.modal) {
            root.drawerOpen = false;
        }
    }

    rightPadding: !Settings.isMobile && mainFlickable.contentHeight > mainFlickable.height ? Units.gridUnit : Units.smallSpacing

    contentItem: ScrollView {
        id: scrollView
        //ensure the attached property exists
        Theme.inherit: true
        anchors.fill: parent
        implicitWidth: root.collapsed ? Units.iconSizes.smallMedium + Units.largeSpacing * 2 : Math.min (Units.gridUnit * 20, root.parent.width * 0.8)
        horizontalScrollBarPolicy: Qt.ScrollBarAlwaysOff
        Behavior on implicitWidth {
            NumberAnimation {
                duration: Units.longDuration
                easing.type: Easing.InOutQuad
            }
        }
        Flickable {
            id: mainFlickable
            contentWidth: width
            contentHeight: mainColumn.Layout.minimumHeight
            ColumnLayout {
                id: mainColumn
                width: mainFlickable.width
                spacing: 0
                height: Math.max(root.height, Layout.minimumHeight)

                //TODO: cable visible of bannerimage
                Item {
                    implicitHeight: root.collapsible ? Math.max(collapseButton.height + Units.smallSpacing, bannerImage.Layout.preferredHeight) : bannerImage.Layout.preferredHeight

                    Layout.fillWidth: true

                    BannerImage {
                        id: bannerImage
                        anchors.fill: parent
                        opacity: !root.collapsed
                        fillMode: Image.PreserveAspectCrop

                        Behavior on opacity {
                            OpacityAnimator {
                                duration: Units.longDuration
                                easing.type: Easing.InOutQuad
                            }
                        }
                        leftPadding: root.collapsible ? collapseButton.width + Units.smallSpacing*2 : topPadding
                        MouseArea {
                            anchors.fill: parent
                            onClicked: root.bannerClicked()
                        }
                        EdgeShadow {
                            edge: Qt.BottomEdge
                            visible: bannerImageSource != ""
                            anchors {
                                left: parent.left
                                right: parent.right
                                bottom: parent.top
                            }
                        }
                    }
                    PrivateActionToolButton {
                        id: collapseButton
                        y: Units.smallSpacing

                        visible: root.collapsible
                        kirigamiAction: Action {
                            icon.name: "application-menu"
                            checkable: true
                            checked: !root.collapsed
                            onCheckedChanged: root.collapsed = !checked
                        }
                    }
                }

                ColumnLayout {
                    id: topContent
                    spacing: 0
                    Layout.alignment: Qt.AlignHCenter
                    Layout.leftMargin: root.leftPadding
                    Layout.rightMargin: root.rightPadding
                    Layout.bottomMargin: Units.smallSpacing
                    Layout.topMargin: root.topPadding
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    //NOTE: why this? just Layout.fillWidth: true doesn't seem sufficient
                    //as items are added only after this column creation
                    Layout.minimumWidth: parent.width - root.leftPadding - root.rightPadding
                    visible: children.length > 0 && childrenRect.height > 0
                }

                T2.StackView {
                    id: stackView
                    Layout.fillWidth: true
                    Layout.minimumHeight: currentItem ? currentItem.implicitHeight : 0
                    Layout.maximumHeight: Layout.minimumHeight
                    initialItem: menuComponent
                    //NOTE: it's important those are NumberAnimation and not XAnimators
                    // as while the animation is running the drawer may close, and
                    //the animator would stop when not drawing see BUG 381576
                    popEnter: Transition {
                        NumberAnimation { property: "x"; from: (stackView.mirrored ? -1 : 1) * -stackView.width; to: 0; duration: 400; easing.type: Easing.OutCubic }
                    }

                    popExit: Transition {
                        NumberAnimation { property: "x"; from: 0; to: (stackView.mirrored ? -1 : 1) * stackView.width; duration: 400; easing.type: Easing.OutCubic }
                    }

                    pushEnter: Transition {
                        NumberAnimation { property: "x"; from: (stackView.mirrored ? -1 : 1) * stackView.width; to: 0; duration: 400; easing.type: Easing.OutCubic }
                    }

                    pushExit: Transition {
                        NumberAnimation { property: "x"; from: 0; to: (stackView.mirrored ? -1 : 1) * -stackView.width; duration: 400; easing.type: Easing.OutCubic }
                    }

                    replaceEnter: Transition {
                        NumberAnimation { property: "x"; from: (stackView.mirrored ? -1 : 1) * stackView.width; to: 0; duration: 400; easing.type: Easing.OutCubic }
                    }

                    replaceExit: Transition {
                        NumberAnimation { property: "x"; from: 0; to: (stackView.mirrored ? -1 : 1) * -stackView.width; duration: 400; easing.type: Easing.OutCubic }
                    }
                }
                Item {
                    Layout.fillWidth: true
                    Layout.fillHeight: root.actions.length>0
                    Layout.minimumHeight: Units.smallSpacing
                }

                ColumnLayout {
                    id: mainContent
                    Layout.alignment: Qt.AlignHCenter
                    Layout.leftMargin: root.leftPadding
                    Layout.rightMargin: root.rightPadding
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    //NOTE: why this? just Layout.fillWidth: true doesn't seem sufficient
                    //as items are added only after this column creation
                    Layout.minimumWidth: parent.width - root.leftPadding - root.rightPadding
                    visible: children.length > 0
                    opacity: !root.collapsed
                    Behavior on opacity {
                        OpacityAnimator {
                            duration: Units.longDuration
                            easing.type: Easing.InOutQuad
                        }
                    }
                }
                Item {
                    Layout.minimumWidth: Units.smallSpacing
                    Layout.minimumHeight: root.bottomPadding
                }

                Component {
                    id: menuComponent
                    ColumnLayout {
                        spacing: 0
                        property alias model: actionsRepeater.model
                        property Action current

                        property int level: 0
                        Layout.maximumHeight: Layout.minimumHeight


                        BasicListItem {
                            id: backItem
                            visible: level > 0
                            supportsMouseEvents: true
                            icon: (LayoutMirroring.enabled ? "go-previous-symbolic-rtl" : "go-previous-symbolic")

                            label: MnemonicData.richTextLabel
                            MnemonicData.enabled: backItem.enabled && backItem.visible
                            MnemonicData.controlType: MnemonicData.MenuItem
                            MnemonicData.label: qsTr("Back")

                            separatorVisible: false
                            onClicked: stackView.pop()
                        }
                        Shortcut {
                            sequence: backItem.MnemonicData.sequence
                            onActivated: backItem.clicked()
                        }

                        Repeater {
                            id: actionsRepeater
                            model: actions
                            delegate:
                            BasicListItem {
                                id: listItem
                                supportsMouseEvents: true
                                readonly property bool wideMode: width > height * 2
                                checked: modelData.checked || (actionsMenu && actionsMenu.visible)
                                width: parent.width

                                icon: modelData.iconName

                                label: width > height * 2 ? MnemonicData.richTextLabel : ""
                                MnemonicData.enabled: listItem.enabled && listItem.visible
                                MnemonicData.controlType: MnemonicData.MenuItem
                                MnemonicData.label: modelData.text
                                property ActionsMenu actionsMenu: ActionsMenu {
                                    x: Qt.application.layoutDirection == Qt.RightToLeft ? -width : listItem.width
                                    actions: modelData.children
                                    submenuComponent: Component {
                                        ActionsMenu {}
                                    }
                                }

                                separatorVisible: false
                                visible: model ? model.visible || model.visible===undefined : modelData.visible
                                enabled: (model && model.enabled != undefined) ? model.enabled : modelData.enabled
                                opacity: enabled ? 1.0 : 0.3
                                Icon {
                                    Shortcut {
                                        sequence: listItem.MnemonicData.sequence
                                        onActivated: listItem.clicked()
                                    }
                                    isMask: true
                                    Layout.alignment: Qt.AlignVCenter
                                    Layout.rightMargin: !Settings.isMobile && mainFlickable.contentHeight > mainFlickable.height ? Units.gridUnit : 0
                                    Layout.leftMargin: !root.collapsed ? 0 : parent.width - listItem.width
                                    Layout.preferredHeight: !root.collapsed ? Units.iconSizes.smallMedium : Units.iconSizes.small/2
                                    selected: listItem.checked || listItem.pressed
                                    Layout.preferredWidth: Layout.preferredHeight
                                    source: (LayoutMirroring.enabled ? "go-next-symbolic-rtl" : "go-next-symbolic")
                                    visible: modelData.children!==undefined && modelData.children.length > 0
                                }
                                data: [
                                    QQC2.ToolTip {
                                        visible: (modelData.tooltip.length || root.collapsed) && (!actionsMenu || !actionsMenu.visible) &&  listItem.hovered && text.length > 0
                                        text: modelData.tooltip.length ? modelData.tooltip : modelData.text
                                        delay: 1000
                                        timeout: 5000
                                        y: listItem.height/2 - height/2
                                        x: Qt.application.layoutDirection == Qt.RightToLeft ? -width : listItem.width
                                    }
                                ]

                                onClicked: {
                                    modelData.trigger();
                                    if (modelData.children!==undefined && modelData.children.length > 0) {
                                        if (root.collapsed) {
                                            //fallbacks needed for Qt 5.9
                                            if ((!listItem.actionsMenu.hasOwnProperty("count") || listItem.actionsMenu.count>0) && !listItem.actionsMenu.visible) {
                                                if (listItem.actionsMenu.hasOwnProperty("popup")) {
                                                    listItem.actionsMenu.popup(control, 0, control.height)
                                                } else {
                                                    listItem.actionsMenu.visible = true;
                                                }
                                            }
                                        } else {
                                            stackView.push(menuComponent, {model: modelData.children, level: level + 1, current: modelData });
                                        }
                                    } else if (root.resetMenuOnTriggered) {
                                        root.resetMenu();
                                    }
                                    checked = Qt.binding(function() { return modelData.checked || (actionsMenu && actionsMenu.visible) });
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

