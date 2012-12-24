/*
Copyright 2012 Martin Borho <martin@borho.net>
GPLv3 - see License.txt for details
*/
import QtQuick 1.1
import com.nokia.meego 1.0
import com.nokia.extras 1.1
import "components"
import "js/kippt.js" as Kippt

// TODO description

Page {
    id: listPage
    tools: listTools
    property variant listId: 0
    property int modelIndex: 0
    property bool locked: false
    property bool extraList: false

    function setData(data) {
        //
        extraList = (isNaN(parseInt(data.id))  || data.title === "Inbox" ) ? true : false;
        //
        if(data.id !== undefined) {

            if(extraList) {//isNaN(parseInt(data.id))) {
                listLockedIcon.visible = false
            } else {
                listLockedIcon.visible = true
            }
            listId = data.id
        }

        //
        if(data.title !== undefined) {
            setTitle(data.title);
            if(data.title === "Inbox") {
                listLockedIcon.visible = false;
            }
        }
        //
        if(data.is_private !== undefined) {
            setPrivate(data.is_private);
        }
        //
        if(data.index !== undefined) {
            modelIndex = data.index;
        }
    }

    function setTitle(title) {
        labelSelected.text = title;
    }

    function setPrivate(locked, updated) {
        if(updated) hideSpinner()
        listPage.locked = locked
        listLockedIcon.source = (locked) ? "gfx/icon-m-common-locked-inverse.png" : "gfx/icon-m-common-unlocked-inverse.png";
    }

    function render(links) {
        // clipcount
        clipCount.text = links.meta.total_count;
        if(links.meta.total_count > 999) clipCountCircle.width = 65
        else if(links.meta.total_count > 99) clipCountCircle.width = 55
        else clipCountCircle.width = 45

        links.list = {id: listId}
        clipsList.render(links)
    }

    function clear() {
        listId = false;
        clipsList.clear();
        modelIndex = 0;
    }

    function showSpinner() {
        navBack.visible = false
        listsSpinner.running = true
        listsSpinner.visible = true
    }

    function hideSpinner() {
        listsSpinner.visible = false
        listsSpinner.running = false
        navBack.visible = true
    }

    function togglePrivate() {
        if(!extraList) {
            showSpinner()
            var options = {
                path: '/api/lists/'+listId+'/',
                index: modelIndex,
                data: {is_private: !listPage.locked}
            }
            appWindow.updateList(options)
        }
    }

    function editList(params) {
        showSpinner()
        var options = {
            path: '/api/lists/'+listId+'/',
            index: modelIndex,
            data: params
        }
        appWindow.updateList(options)
    }

    function deleteList() {
        showSpinner()
        var options = {
            path: '/api/lists/'+listId+'/'
        }
        appWindow.deleteList(options);
    }

    function deleteClip(clipId) {
        showSpinner()
        var options = {
            path: '/api/clips/'+clipId+'/'
        }
        appWindow.deleteClip(options);
    }

    function updateClipInList(clip, moved) {
        if(moved) {
            clipsList.removeClip(clip);
        } else {
            clipsList.updateClip(clip);
        }
    }

    Rectangle {
        id: listHeader
        height:71
        width: parent.width
        z:3
        color: "#171717"
        Text {
            id: labelSelected
            text: ""
            maximumLineCount:1
            elide: Text.ElideRight
            font.pixelSize: 40
            font.family: kipprFont.name
            color:"white"
            width:parent.width-75
            wrapMode: Text.WrapAnywhere
            horizontalAlignment: Text.AlignLeft
            anchors.verticalCenter: listHeader.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: 5
        }
        Rectangle {
            id:clipCountCircle
            anchors.right: listHeader.right
            anchors.rightMargin: 10
            anchors.verticalCenter: listHeader.verticalCenter
            width:45
            height:45
            radius:20
            color:  "#2E3E30"
            Text {
                id: clipCount
                font.pixelSize: 25
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
                text:""
                color:"white"
            }
        }

    }

    ClipsList {
        id: clipsList
    }

    ToolBarLayout {
        id: listTools
        visible: true
        ToolIcon {
            id: navBack
            iconId: "toolbar-back"
            onClicked: {
                pageStack.pop();
                listMenu.close()
            }
        }
        BusyIndicator {
            id: listsSpinner
            running: false
            visible: false
            platformStyle: BusyIndicatorStyle { size: "medium" }
            anchors.left: parent.left
            anchors.leftMargin: 25
            anchors.verticalCenter: parent.verticalCenter
        }
        Image {
            id:listLockedIcon
            source: "gfx/icon-m-common-unlocked-inverse.png"
            anchors.horizontalCenter: parent.horizontalCenter
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    togglePrivate()
                }
            }
        }
        ToolIcon {
            platformIconId: "toolbar-view-menu"
            anchors.right: (parent === undefined) ? undefined : parent.right
            visible: !extraList
            onClicked: ((extraList) ? false : (listMenu.status === DialogStatus.Closed) ? listMenu.open() : listMenu.close())
        }
    }

    Menu {
        id: listMenu
        visualParent: pageStack
        MenuLayout {
            visible: !extraList
            MenuItem {
                text: "Edit"
                height:80
                onClicked: {
                    var list = Kippt.Data.getList();
                    editListDialog.showEdit(list)
                }
            }
            MenuItem {
                text: "Delete"
                onClicked: {
                    acceptDialog.ask("list", "Delete this clip\nand all clips within?")
                }
            }
        }
    }
}
