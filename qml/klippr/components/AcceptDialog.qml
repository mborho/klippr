/*
Copyright 2012 Martin Borho <martin@borho.net>
GPLv3 - see License.txt for details
*/
import QtQuick 1.1
import com.nokia.meego 1.0

Dialog {
    id: acceptDialog
    width: parent.width*0.7
    property string ressourceType: ""
    property string clipId: ""

    function ask(type, msg, id) {
        askText.text = msg
        ressourceType = type
        clipId = (id) ? id : "";
        open()
    }

    function accepted() {
        if(ressourceType == "listclip" && clipId !== "") {
            listPage.item.deleteClip(clipId)
        } else if(ressourceType == "clip") {
            clipPage.item.deleteClip()
        } else if(ressourceType == "list") {
            listPage.item.deleteList()
        }
    }

    title: Item {
        id: titleField
        height: childrenRect.height
        width: parent.width
        Text {
            id:askText
            font.pixelSize: 40
            color: "red"
            text: "Your Login"
        }
    }

    buttons: ButtonRow {
        style: ButtonStyle { }
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.topMargin: 20
        height:50
        Button {
            id:acceptedButton
            text: "OK";
            onClicked: accept()
        }
        Button {
            text: "Cancel";
            onClicked: acceptDialog.close()
        }
     }
}
