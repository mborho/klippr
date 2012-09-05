 /*
Copyright 2011 Martin Borho <martin@borho.net>
GPLv3 - see License.txt for details
*/
import QtQuick 1.1
import com.nokia.meego 1.0
import com.nokia.extras 1.1

 Rectangle {
     id: listsOverview
     width: parent.width
     height: parent.height-71
     anchors.bottom: parent.bottom
     color: "#3B3B3B"

    function formatDate(timestamp) {
        var date = new Date(parseInt(timestamp+'000'));
        return  Qt.formatDate(date) +' '+String(Qt.formatTime(date,Qt.TextDate)).substring(0,5);
    }

    function clear() {
        listsModel.clear()
    }

    function renderOverview(lists) {

        if(lists.meta.previous) {
            listsModel.remove(listsModel.count-1)
        } else {
            listsModel.clear()
            listsModel.append({id:"feed", title:"Feed", is_private:true, path:'/api/feed/?include_data=list,user',
                                updated:false, expand:true, icon: "feed-icon.png"})
            //
            if(lists.objects[0].slug === "inbox") {
                // insert inbox
                lists.objects[0].expand = true;
                lists.objects[0].icon = "inbox-icon.png"
                listsModel.append(lists.objects[0]);
            }
            //
            listsModel.append({id:"read_later", title:"Read Later", is_private:true, icon: "read-later-icon.png",
                    path:'/api/clips/?is_read_later=true&include_data=list', updated:false, expand:true})
            listsModel.append({id:"starred", title:"Starred", is_private:true, icon: "starred-icon.png",
                    path:'/api/clips/?is_starred=true&include_data=list', updated:false, expand:true})
            listsModel.append({id:"all", title:"All Clips", is_private:true, path:'/api/clips/?include_data=list',
                                    icon: "all-clips-icon.png", updated:false, expand:true})
        }

        lists.objects.forEach(function(list) {
            if(list.slug !== "inbox") {
                list.icon = (list.is_private) ? "link-icon-private.png" : "link-icon.png"
                listsModel.append(list)
            }
        })

        if(lists.meta.next) {
            listsModel.append({title:"next", id:false, updated:false, path:lists.meta.next})
        }
    }

    function updateIndex(index, list) {
        var icon = (list.is_private) ? "link-icon-private.png" : "link-icon.png"
        listsModel.set(index, {title:list.title, is_private:list.is_private, icon:icon});
    }

    function loadNext(path) {
        appWindow.loadAllLists(path);
    }

    function listClicked(index) {
        var list = listsModel.get(index),
            options = {index:index, title:list.title, is_private:list.is_private, id:list.id}
        options.path = (isNaN(parseInt(options.id))) ? list.path : '/api/clips/?include_data=list&list='+options.id;
        appWindow.loadList(options)
    }

     ListModel {
        id: listsModel
     }

     Component {
        id: listsDelegate
        Rectangle {
            id: listContainer
            width:parent.width
            height: rowColumn.height + ((expand) ? 35 : 25)
            color: "#3B3B3B"
            Column {
                id:rowColumn
                width:parent.width
                anchors.left: parent.left
                anchors.leftMargin:10
                anchors.verticalCenter: parent.verticalCenter
                Text {
                    text: title
                    maximumLineCount:2
                    elide: Text.ElideRight
                    font.pixelSize: (expand) ? 34 : 29
                    wrapMode: Text.WordWrap
                    width:parent.width-40
                    horizontalAlignment: (id) ? Text.AlignLeft : Text.AlignHCenter
                    color:"white"
                }
            }
            MoreIndicator {
                objectName: "indicatorObject"
                anchors.verticalCenter: rowColumn.verticalCenter
                anchors.right: rowColumn.right
                anchors.rightMargin:10
                source: (id) ? "../gfx/"+icon : "";
                visible: (id) ? true :false
            }
            MouseArea {
                anchors.fill: rowColumn
                onClicked: (!id) ? loadNext(path) : listClicked(index);
                onPressed: {parent.color = "#171717"}
                onReleased: {parent.color = "#3B3B3B"}
                onCanceled: {parent.color = "#3B3B3B"}
            }
            Rectangle {
                anchors.bottom: parent.bottom
                height:1
                width:parent.width
                color: "#171717"
            }
        }
    }

    ListView {
        id: overviewListView
        anchors.fill: parent
        model: listsModel
        snapMode: ListView.SnapToItem
        width: parent.width
        delegate: listsDelegate
    }

    ScrollDecorator {
        flickableItem: overviewListView
    }
 }
