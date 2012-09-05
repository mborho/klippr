 /*
Copyright 2012 Martin Borho <martin@borho.net>
GPLv3 - see License.txt for details
*/
import QtQuick 1.1
import com.nokia.meego 1.0
import com.nokia.extras 1.1

 Rectangle {
    id: clipsList
    width: parent.width
    height: parent.height-71
    anchors.bottom: parent.bottom
    color: "#3B3B3B"

    property bool showListName: false
    property bool feedView: false
    property int maxSubtitleLines: 3

    function formatDate(timestamp) {
        var date = new Date(parseInt(timestamp+'000'));
        return  Qt.formatDate(date) +' '+String(Qt.formatTime(date,Qt.TextDate)).substring(0,5);
    }

    function buildSubtitle(clip) {
        // no rich text allowed, because of maximumLineCount!
        var subtitle = "";
        if(clip.updated) {
            subtitle = formatDate(clip.updated);
            if(showListName) {
                subtitle += ' in '+clip.list.title+' ';
            }
            subtitle += (clip.notes) ? ((showListName) ? '\n':' / ' )+clip.notes.trim() : ''
        }
        return subtitle;
    }

    function updateClip(clip) {
        var max = clipsModel.count;
        for(var x=0; max>x;x++) {
            if(clipsModel.get(x).id === clip.id) {
                clip.subtitle = buildSubtitle(clip)
                clipsModel.set(x, clip);
                break;
            }
        }
    }

    function clear() {
        clipsModel.clear()
    }

    function render(clips) {

        // show listname in subtitle
        if(isNaN(parseInt(clips.list.id))) {
            showListName = true;
            maxSubtitleLines = 4;
        } else {
            showListName = false;
            maxSubtitleLines = 3;
        }

        feedView = (clips.list.id === "feed") ? true :false;

        if(clips.meta.previous) {
            clipsModel.remove(clipsModel.count-1)
            hideSpinner()
        } else {
            clear()
        }

        clips.objects.forEach(function(clip) {
            clip.notes = clip.notes
            clip.subtitle = buildSubtitle(clip)
            clipsModel.append(clip)
        })

        if(clips.meta.next) {
            clipsModel.append({title:"next", id:clips.meta.next, updated:false, subtitle:""})
        }
    }

    function loadNext(path) {
        showSpinner()
        appWindow.loadList({path:path})
    }

    function clipClicked(index) {
        var clip = clipsModel.get(index)
        appWindow.loadClip({index:index, path:"/api/clips/"+clip.id+"/?include_data=list"})
    }

    ListModel {
        id: clipsModel
    }

    Component {
        id: clipsDelegate
        Rectangle {
            width:parent.width
            height: rowColumn.height + ((updated) ? 15 : 5)
            color: "#3B3B3B"
            Column {
                id:rowColumn
                width:parent.width
                anchors.left: parent.left
                anchors.leftMargin:10
                anchors.verticalCenter: parent.verticalCenter
                Text {
                    width:parent.width-((feedView) ? 75 : 45)
                    text: title
                    maximumLineCount:2
                    elide: Text.ElideRight
                    font.pixelSize: 28
                    wrapMode: (title.match(/^https?:\/\//)) ? Text.WrapAnywhere : Text.WordWrap
                    horizontalAlignment: (updated) ? Text.AlignLeft : Text.AlignHCenter
                    color:"white"
                }
                Text {
                    width:parent.width-((feedView) ? 80 : 40)
                    text: subtitle
                    font.pixelSize: 20
                    maximumLineCount: maxSubtitleLines
                    elide: Text.ElideRight
                    wrapMode: Text.WordWrap
                    color: "white"
                }
            }
            MoreIndicator {
                objectName: "indicatorObject"
                anchors.verticalCenter: rowColumn.verticalCenter
                anchors.right: rowColumn.right
                anchors.rightMargin:15
                visible: false; //(updated) ? true :false
                smooth: false
                Component.onCompleted: {
                    if(feedView && user) {
                        source = user.avatar_url;
                        width = 56
                        height = 56
                        anchors.top = parent.top
                        anchors.topMargin = 15
                        fillMode = Image.PreserveAspectFit
                    }
                    visible = (updated) ? true :false;
                }
            }
            MouseArea {
                anchors.fill: rowColumn
                onClicked: (!updated) ? loadNext(id) : clipClicked(index)
                onPressed: {parent.color = "#171717"}
                onReleased: {parent.color = "#3B3B3B"}
                onCanceled: {parent.color = "#3B3B3B"}
            }
        }
    }

    ListView {
        id: clipsListView
        anchors.fill: parent
        model: clipsModel
        delegate: clipsDelegate
    }

    ScrollDecorator {
        flickableItem: clipsListView
    }

}
