/*
Copyright 2012 Martin Borho <martin@borho.net>
GPLv3 - see License.txt for details
*/
import QtQuick 1.1
import com.nokia.meego 1.0

Dialog {
    id: editListDialog
    width: parent.width-30
    property int listId: 0;

    function sendForm() {
        var title = listName.text,
//            desc = listDesc.text,
            is_private = listPrivate.checked;
        if(title != "") {
            var params = {
                title:title,
//                description: desc,
                is_private: is_private
            }
            if(listId > 0) {
                listPage.item.editList(params);
            } else {
                mainPage.createList(params);
            }
            close();
        }
    }

    function showNew(list) {
        listName.text = ""
        listId = 0;
        dialogTitle.text = "Create a new list"
        listName.text = ""
        listPrivate.checked = true;
//        listDesc.text = (list.description) ? list.description : ""
        open()
    }

    function showEdit(list) {
        listName.text = ""
        listId = list.id;
        dialogTitle.text = "Edit list";
        listName.text = list.title;
//        listDesc.text = (list.description) ? list.description : ""
        if(list.is_private) {
            listPrivate.checked = true;
        } else {
            listPublic.checked = true;
        }
        open()
    }

    title: Item {
        height: childrenRect.height
        width: parent.width
        Text {
            id:dialogTitle
            font.pixelSize: 40
            color: "white"
            text: ""
        }
    }


    content: Item {
        id: listInput
        height:childrenRect.height+20
        width: parent.width-20
        anchors.horizontalCenter: parent.horizontalCenter
//        Text {
//            id: text
//            height: 70
//            width: parent.width
//            color:"white"
//            font.pixelSize: 22
//            text: "Login with your username\n and password"
//            anchors.top: parent.top
//        }
        TextField {
            id: listName
            height:40
            width: parent.width
            anchors.top: text.bottom
            placeholderText: "Name"
            maximumLength: 80
        }
//        TextArea {
//            id: listDesc
//            anchors.top: listName.bottom
//            width: parent.width
//            placeholderText: "Description"
//        }

        Rectangle {
            anchors.top: listName.bottom
            width:280
            height:60
            color:"black"
            anchors.horizontalCenter: parent.horizontalCenter
            ButtonRow {
                anchors.top: parent.top
                anchors.topMargin: 15
                width:parent.width
                anchors.verticalCenter: parent.verticalCenter
                RadioButton {
                    id:listPublic
                    text: "public  "
                    height:30
                }
                RadioButton {
                    id:listPrivate
                    text: "private"
                    height:30
                    checked: true
                }
            }
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
