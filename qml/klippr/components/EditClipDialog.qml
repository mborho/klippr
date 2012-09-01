/*
Copyright 2012 Martin Borho <martin@borho.net>
GPLv3 - see License.txt for details
*/
import QtQuick 1.1
import com.nokia.meego 1.0

Dialog {
    id: editClipDialog
    width:parent.width-30
    property int clipId: 0;

    function sendForm() {
        var title = clipName.text,
            notes = clipNotes.text,
            url = clipUrl.text,
            params = {};
        if(title !== "" && clipId > 0) {
            params = {
                title:title,
                notes: notes,
            }
            clipPage.item.editClip(params);
            close();
        } else if(url!== "" && clipId === 0) {
            params = {
                url:url,
                notes: notes,
            }
            mainPage.createClip(params);
            close();
        }

    }

    function showNew() {
        clipId = 0;
        clipTitle.text = "Add a new clip"
        clipUrl.text = "";
        clipUrl.visible = true;
        clipName.text = ""
        clipName.visible = false;
        clipNotes.text = ""
        open()
    }

    function showEdit(clip) {
        clipName.text = ""
        clipId = clip.id;
        clipTitle.text = "Edit clip";
        clipUrl.text = "";
        clipUrl.visible = false;
        clipName.text = clip.title;
        clipName.visible = true;
        clipNotes.text = (clip.notes) ? clip.notes : ""
        open()
    }

    title: Item {
        height: childrenRect.height
        width: parent.width
        Text {
            id:clipTitle
            font.pixelSize: 40
            color: "white"
            text: ""
        }
    }


    content: Item {
        id: clipInput
        height:childrenRect.height+20
        width: parent.width
        anchors.horizontalCenter: parent.horizontalCenter
        TextField {
            id: clipUrl
            height:40
            width: parent.width
            anchors.top: text.bottom
            placeholderText: "URL"
            maximumLength: 80
        }
        TextField {
            id: clipName
            height:40
            width: parent.width
            placeholderText: "Title"
            maximumLength: 80
        }
        TextArea {
            id: clipNotes
            anchors.top: clipName.bottom
            width: parent.width
            placeholderText: "Notes"
        }
    }

    buttons: ButtonRow {
        style: ButtonStyle { }
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.topMargin: 20
        height:50
        Button {
            text: "OK";
            onClicked: sendForm()
        }
        Button {
            text: "Cancel";
            onClicked: close()
        }
     }
}
