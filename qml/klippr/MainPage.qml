/*
Copyright 2012 Martin Borho <martin@borho.net>
GPLv3 - see License.txt for details
*/
import QtQuick 1.1
import com.nokia.meego 1.0
import "components"
import "js/kippt.js" as Kippt


Page {
    id: mainPage
    tools: commonTools

    function start(lists) {
        stopSpinner();
        listsOverview.renderOverview(lists)
    }

    function clear() {
        listsOverview.clear()
    }

    function updateList(index, list) {
        listsOverview.updateIndex(index, list);
    }

    function createList(params) {
        var options = {
            path: '/api/lists/',
            data: params
        }
        appWindow.createList(options)
    }

    function createClip(params) {
        var options = {
            path: '/api/clips/',
            data: params
        }
        appWindow.createClip(options)
    }

    function startSpinner() {
        loadingSpinner.visible = true;
        loadingSpinner.running = true;
        refreshIcon.visible = false;
    }

    function stopSpinner() {
        loadingSpinner.visible = false;
        loadingSpinner.running = false;
        refreshIcon.visible = true;
    }

    Rectangle {
        id: header
        height:71
        width: parent.width
        z:3
        color: "#171717"

        Text {
            id: labelSelected
            width: parent.width-20
            text: "Klippr"
            maximumLineCount:1
            elide: Text.ElideRight
            font.pixelSize: 50
            font.family: kipprFont.name
            color:"white"
            wrapMode: Text.WrapAnywhere
            horizontalAlignment: Text.AlignLeft
            anchors.verticalCenter: header.verticalCenter
            anchors.left:parent.left
            anchors.leftMargin:10
        }
    }

    ListsOverview {
        id: listsOverview
    }

    ToolBarLayout {
        id: commonTools
        visible: true
        ToolIcon {
            id: refreshIcon
            platformIconId: "toolbar-refresh";
            visible: true
            onClicked: {
                mainPage.clear()
                loadAllLists();
            }
        }
        BusyIndicator {
            id: loadingSpinner
            running: false
            visible: false
            platformStyle: BusyIndicatorStyle { size: "medium" }
            anchors.left: parent.left
            anchors.leftMargin: 25
            anchors.verticalCenter: parent.verticalCenter
        }
       ToolIcon {
            id: addClipIcon
            platformIconId: "toolbar-add";
            visible: true
            anchors.horizontalCenter: parent.horizontalCenter
            onClicked: {
                editClipDialog.showNew()
            }
        }
        ToolIcon {
            platformIconId: "toolbar-view-menu"
            anchors.right: /*(parent === undefined) ? undefined : */parent.right
            onClicked: (mainMenu.status === DialogStatus.Closed) ? mainMenu.open() : mainMenu.close()
        }
    }

    Menu {
        id: mainMenu
        visualParent: pageStack
        MenuLayout {
            MenuItem {
                id:aboutButton
                text: 'About'
                onClicked: {
                    aboutLoader.source = "components/AboutDialog.qml";
                    aboutLoader.item.open();
                }
            }
            MenuItem {
                text: "Revoke Access"
                onClicked: appWindow.revokeAccess()
            }
            MenuItem {
                text: "Create new list"
                onClicked: {
                    editListDialog.showNew()
                }
            }
        }
    }

}
