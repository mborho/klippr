/*
Copyright 2012 Martin Borho <martin@borho.net>
GPLv3 - see License.txt for details
*/
import QtQuick 1.1
import com.nokia.meego 1.0
import "components"
import "js/kippt.js" as Kippt

Page {
    id: clipPage
    tools: clipTools
    width: parent.width
    property int clipId: 0
    property bool starred: false
    property bool read_later: false
    property string article: ""
    property bool jumpToOverview: false
    property bool feedView: false
    property bool searchView: false

    states: [
        State {
            name: "BlackBack"
            when: status === PageStatus.Deactivating && pageStack.depth === 4
            PropertyChanges {
                target: clipContainer
                color: "#000000"
                restoreEntryValues: false
            }
            PropertyChanges {
                target: clipHeader
                color: "#000000"
                restoreEntryValues: false
            }
        },
        State {
            name: "DefaultBack"
            when: status === PageStatus.Active
            PropertyChanges {
                target: clipContainer
                color: "#3B3B3B"
                restoreEntryValues: false
            }
            PropertyChanges {
                target: clipHeader
                color: "#171717"
                restoreEntryValues: false
            }
        }
    ]
    transitions: Transition {
         ColorAnimation {}
    }

    function openUrl(url) {
        console.log('Opening '+url);
        Qt.openUrlExternally ( url )
    }

    function formatDate(timestamp) {
        var date = new Date(parseInt(timestamp+'000'));
        return  Qt.formatDate(date) +' '+String(Qt.formatTime(date,Qt.TextDate)).substring(0,5);
    }

    function getListTitle(clip) {
        var title = "";
        if(typeof(clip.user) === "object") {
            var appUser = Kippt.Data.getUser();
            if(appUser.username !== clip.user.username) {
                title = clip.user.username+' / ';
            }
        }
        title += clip.list.title;
        return title;
    }

    function handleFlickableInteraction() {
//        console.log(clipNotes.height+" < "+flickableNotes.height)
//        if(screen.currentOrientation === Screen.Portrait) {
        if(clipNotes.height < flickableNotes.height) {
            flickableNotes.interactive = false;
        } else {
            flickableNotes.interactive = true;
        }
    }

    function update(clip, currentList) {
        if(currentList === "read_later") {
            if(read_later === true && read_later !== clip.is_read_later) {
                jumpToOverview = true
            } else jumpToOverview = false
        } else if(currentList === "starred") {
            if(starred === true && starred !== clip.is_starred) {
                jumpToOverview = true
            } else jumpToOverview = false
        }
        clipTitle.text = clip.title;
        clipDate.text = formatDate(clip.updated);
        if(clip.notes || clipNotes.text != "") {
            clipNotes.text = clip.notes;
        }
        starred = clip.is_starred;
        read_later = clip.is_read_later;
        hideSpinner();
    }

    function updateList(list) {
        clipList.text = list.title;
        hideSpinner();
        var currentList = Kippt.Data.getList();
//        if(!isNaN(parseInt(currentList.id))) {
//            jumpToOverview = true;
//        }
    }

    function clear() {
        clipList.text = "";
        clipDomain.text = "";
        clipTitle.text = "";
        clipUrl.text = "";
        clipDate.text = "";
        clipNotes.text = "";
    }

    function render(clip) {
        clear()
        feedView = (Kippt.Data.getList().id === "feed") ? true :false;
        searchView = (Kippt.Data.getList().id === "search") ? true :false;
        clipId = clip.id
        clipList.text = getListTitle(clip);
        clipDomain.text = clip.url_domain;
        clipTitle.text = clip.title;
        clipUrl.text = clip.url;
        clipDate.text = formatDate((clip.updated !== clip.created) ? clip.updated : clip.created)
        if(clip.notes) {
            clipNotes.text = clip.notes;
        }
        starred = clip.is_starred;
        read_later = clip.is_read_later;
        article = (clip.article) ? clip.article : ""
        jumpToOverview = false
        handleFlickableInteraction()
    }

    function showSpinner() {
        clipNavBack.visible = false
        clipSpinner.running = true
        clipSpinner.visible = true
    }

    function hideSpinner() {
        clipSpinner.visible = false
        clipSpinner.running = false
        clipNavBack.visible = true
    }

    function toggleOption(data) {
        showSpinner()
        var options = {
            clipId: clipId,
            path: '/api/clips/'+clipId+'/',
            search: searchView,
            data: data
        }
        appWindow.updateClip(options)
    }

    function moveClip(clip, list) {
        showSpinner()
        var options = {
            clipId: clipId,
            list: list,
            path: '/api/clips/'+clipId+'/?include_data=list',
            search: searchView,
            data: {is_starred: starred, is_read_later:read_later, list:list.resource_uri}
        }
        appWindow.moveClip(options);
    }

    function editClip(params) {
        showSpinner()
        params.is_starred =  starred;
        params.is_read_later = read_later;
        var options = {
            path: '/api/clips/'+clipId+'/',
            data: params,
            search: searchView
        }
        appWindow.updateClip(options)
    }

    function deleteClip() {
        showSpinner()
        var options = {
            path: '/api/clips/'+clipId+'/'
        }
        appWindow.deleteClip(options);
    }

    function openReader() {
        appWindow.loadReader({id:clipId, path:article})
    }

    Rectangle {
        id: clipContainer
        width: parent.width
        height:parent.height
        anchors.fill: parent
        color: "#3B3B3B"

        Rectangle {
            id:clipHeader
            height:71
            width: parent.width
            color: "#171717"
            Row {
                id:clipMeta
                width:parent.width-30
                height: childrenRect.height
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                Text {
                    id:clipList
                    text:""
                    font.pixelSize: 25
                    font.family: kipprFont.name
                    width:parent.width-clipDate.width
                    maximumLineCount:1
                    elide: Text.ElideRight
                    wrapMode: Text.WrapAnywhere
                    color: "white"
                }
                Text {
                    id:clipDate
                    text:""
                    font.pixelSize: 25
                    font.family: kipprFont.name
                    color: "white"
                }
            }
        }

        Text {
            id:clipDomain
            text:""
            font.pixelSize: 35
            width:parent.width-30
            anchors.top: clipHeader.bottom
            anchors.topMargin: 15
            anchors.horizontalCenter: parent.horizontalCenter
            wrapMode: Text.WordWrap
            color: "white"
        }
        Text {
            id:clipTitle
            text:""
            font.pixelSize: 45
            width:parent.width-30
            wrapMode: Text.WordWrap
            anchors.top: clipDomain.bottom
            anchors.topMargin:15
            anchors.horizontalCenter: parent.horizontalCenter
            color: "white"
        }

        Flickable {
            id:flickableNotes
            width: parent.width-30
            anchors.top: clipTitle.bottom
            anchors.topMargin: 15
            anchors.bottom: clipFooter.top
            anchors.horizontalCenter: parent.horizontalCenter
            contentWidth: width
            contentHeight: clipNotes.height
            clip:true
            Text {
                id:clipNotes
                text:""
                font.pixelSize: 22
                width:parent.width
                wrapMode: Text.WordWrap
                color: "white"
            }
        }
        Rectangle {
            id:clipFooter
            width:parent.width-30
            height: clipUrl.height+20
            z:3
            color: parent.color
            anchors.bottom: parent.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            Text {
                id:clipUrl
                text:""
                font.pixelSize: 22
                width:parent.width
                maximumLineCount:3
                elide: Text.ElideRight
                wrapMode: Text.WrapAnywhere
                color: "white"
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        openUrl(parent.text)
                    }
                }
            }
        }
    }

    ToolBarLayout {
        id: clipTools
        visible: true
        ToolIcon {
            id:clipNavBack
            iconId: "toolbar-back";
            onClicked: {
                if(jumpToOverview) {
                    pageStack.pop(mainPage);
                } else {
                    pageStack.pop();
                }
                clipMenu.close()
            }
        }
        BusyIndicator {
            id: clipSpinner
            running: false
            width: clipNavBack.width
            visible: false
            platformStyle: BusyIndicatorStyle { size: "medium" }
            anchors.left: parent.left
            anchors.leftMargin: 25
            anchors.verticalCenter: parent.verticalCenter
        }
        Image {
            id: clipStarredIcon
            source: (clipPage.starred) ? "gfx/icon-m-common-favorite-mark-inverse.png" : "gfx/icon-m-common-favorite-unmark-inverse.png"
            visible: !clipPage.feedView
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    toggleOption({is_starred: !clipPage.starred, is_read_later:clipPage.read_later})
                }
            }
        }
        Image {
            id: readLaterIcon
            source: (clipPage.read_later) ? "gfx/read-later.png" : "gfx/read-not-later.png"
            visible: !clipPage.feedView
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    toggleOption({is_read_later: !clipPage.read_later, is_starred:clipPage.starred})
                }
            }
        }
        Image {
            id: linkIcon
            source: "gfx/icon-link.png"
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    openUrl(clipUrl.text);
                }
            }
        }
        Image {
            id: readerIcon
            source: "gfx/reader.png"
            visible: clipPage.article
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    openReader()
                }
            }
        }
        ToolIcon {
            platformIconId: "toolbar-view-menu"
            visible: !clipPage.feedView
            anchors.right: (parent === undefined) ? undefined : parent.right
            onClicked: ((!clipPage.feedView) ? ((clipMenu.status === DialogStatus.Closed) ? clipMenu.open() : clipMenu.close()) : false)
        }
    }


    Menu {
        id: clipMenu
        visualParent: pageStack
        MenuLayout {
            visible: !clipPage.feedView
            MenuItem {
                text: "Edit"
                onClicked: {
                    var clip = Kippt.Data.getClip();
                    editClipDialog.showEdit(clip)
                }
            }
            MenuItem {
                text: "Delete"
                onClicked: {
                    acceptDialog.ask("clip", "Delete this clip?")
                }
            }
            MenuItem {
                text: "Move to list"
                onClicked: {
                    moveToDialog.show()
                }
            }
        }
    }

    Loader {
        id:moveToDialog
        width: parent.width
        height: parent.height
        onStatusChanged: {
            if (moveToDialog.status == Loader.Ready) {
                show()
            }
        }
        function show() {
            if (moveToDialog.status == Loader.Ready) {
                moveToDialog.item.render();
                moveToDialog.item.open();
            } else {
                moveToDialog.source = "components/MoveToDialog.qml"
            }
        }
    }

}
