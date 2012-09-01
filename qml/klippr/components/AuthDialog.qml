/*
Copyright 2011 Martin Borho <martin@borho.net>
GPLv3 - see License.txt for details
*/
import QtQuick 1.1
import com.nokia.meego 1.0

Dialog {
    id: authDialog
    width: parent.width-30
    title: Item {
        id: titleField
        height: 60
        width: parent.width
        Text {
            font.pixelSize: 40
            color: "red"
            text: "Your Kippt.com Login"
        }
    }

    content: Item {
        id: authInput
        height:childrenRect.height+20
        width: parent.width
//        anchors.top: titleField.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        Text {
            id: text
            height: 70
            width: parent.width
            color:"white"
            font.pixelSize: 22
            text: "Login with your username\n and password"
            anchors.top: parent.top
        }
        TextField {
            id: authUsername
            height:40
            width: parent.width
            anchors.top: text.bottom
            placeholderText: "Username"
            maximumLength: 80
        }
        TextField {
            id: authPassword
            anchors.top: authUsername.bottom
            height:40
            width: parent.width
            echoMode: TextInput.Password
            placeholderText: "Password"
            maximumLength: 80
        }
    }

    buttons: ButtonRow {
        style: ButtonStyle { }
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.topMargin: 20
        height:50
        Button {
            text: "OK";
            onClicked: authDialog.accept()
        }
     }

    function accept() {
        appWindow.requestToken(authUsername.text, authPassword.text);
        close()
    }
}
