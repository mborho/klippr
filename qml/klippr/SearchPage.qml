/*
Copyright 2012 Martin Borho <martin@borho.net>
GPLv3 - see License.txt for details
*/
import QtQuick 1.1
import com.nokia.meego 1.0
//import com.nokia.extras 1.1
import "components"
import "js/kippt.js" as Kippt

Page {
    id: searchPage
    tools: searchTools

    function clear() {
        searchInput.text = "";
        clipsList.clear();
        clipCountCircle.visible = false;
    }

    function setInputFocus() {
        searchInput.focus = true;
    }

    function showSpinner() {
        navBack.visible = false
        listsSpinner.running = true
        listsSpinner.visible = true
        searchSubmit.opacity = 0.5;
        searchSubmitArea.enabled = true;
    }

    function hideSpinner() {
        listsSpinner.visible = false
        listsSpinner.running = false
        navBack.visible = true
        searchSubmit.opacity = 1;
        searchSubmitArea.enabled = true;
    }

    function search() {
        if(searchInput.text !== "") {
            showSpinner();
            clipsList.clear();
            clipCountCircle.visible = false;
            searchSubmit.focus = true
            var query = searchInput.text;
            var options = {
                id: "search",
                query: query,
                path: '/api/search/clips/?q='+encodeURIComponent(query)+'&include_data=list',
            }
            appWindow.loadSearchResults(options);
        }
    }

    function render(options, links) {
        hideSpinner();
        // clipcount
        clipCount.text = links.meta.total_count;
        clipCountCircle.visible = true
        if(links.meta.total_count > 999) clipCountCircle.width = 65
        else if(links.meta.total_count > 99) clipCountCircle.width = 55
        else clipCountCircle.width = 45

        if(links.meta && links.meta.next) {
            links.meta.next = links.meta.next.replace(/\/api\/clips\//, '/api/search/clips/')
        }

        links.list = {id: "search"}
        clipsList.render(links)
    }

    function updateClipInList(clip, moved) {
        if(moved) {
            clipsList.removeClip(clip);
        } else {
            clipsList.updateClip(clip);
        }
    }

    Keys.onPressed: {
        if (event.key == Qt.Key_Return) {
           search();
        }
    }

    Rectangle {
        id: searchHeader
        height:71
        width: parent.width
        z:3
        color: "#171717"
        TextField {
            id: searchInput
            placeholderText: "Search in your clips"
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: 10
            width: parent.width-searchSubmit.width-40
         }
        Rectangle {
            id:clipCountCircle
            anchors.right: searchInput.right
            anchors.rightMargin: 5
            anchors.verticalCenter: searchInput.verticalCenter
            anchors.verticalCenterOffset: 1
            width:45
            height:45
            radius:20
            color:  "#2E3E30"
            visible: false;
            Text {
                id: clipCount
                font.pixelSize: 25
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
                text:""
                color:"white"
            }
        }
        Image {
            id: searchSubmit
            anchors.right: parent.right
            anchors.rightMargin: 15
            anchors.verticalCenter: parent.verticalCenter
            source: "gfx/search.png"
            opacity: 1
            MouseArea {
                id:searchSubmitArea
                anchors.fill: parent
                onClicked: search()
                enabled: true
            }
         }
    }

    ClipsList {
        id: clipsList
    }

    ToolBarLayout {
        id: searchTools
        visible: true
        ToolIcon {
            id: navBack
            iconId: "toolbar-back"
            onClicked: {
                pageStack.pop();
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
    }

}
