/*
Copyright 2011 Martin Borho <martin@borho.net>
GPLv3 - see License.txt for details
*/
import QtQuick 1.1
import com.nokia.meego 1.0

Dialog {
    id: authDialog
    width: 380
    title: Item {
        id: titleField
        height: 60
        width: parent.width
        Text {
            font.pixelSize: 40
            color: "red"
            text: "Your Kippt.com Login"
            anchors.horizontalCenter: parent.horizontalCenter
        }
    }

    content: Item {
        id: authInput
        height:childrenRect.height+25
        width: parent.width
        anchors.horizontalCenter: parent.horizontalCenter
        TextField {
            id: authUsername
            height:50
            width: parent.width
            placeholderText: "Username"
            maximumLength: 80
        }
        TextField {
            id: authPassword
            anchors.top: authUsername.bottom
            height:50
            width: parent.width
            echoMode: TextInput.Password
            placeholderText: "Password"
            maximumLength: 80
        }        
    }

    buttons: Column {
        id:buttonColumn
        width:360
        anchors.horizontalCenter: parent.horizontalCenter
        spacing:35
        ButtonRow {
            id:loginButton
            style: ButtonStyle { }
            anchors.horizontalCenter: buttonColumn.horizontalCenter
            height:50
            Button {
                text: "Login";
                onClicked: authDialog.accept()
            }
        }
        Button {
            id: registerButton
            height:40
            width:350
            text: "No account? Register here.";
            anchors.horizontalCenter: buttonColumn.horizontalCenter
            onClicked: Qt.openUrlExternally("https://kippt.com/signup/")
        }
        Text {
            width: parent.width
            text: "Privacy Policy"
            color:"red"
            font.pixelSize: 25
            horizontalAlignment: Text.AlignHCenter
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    privacyPolicy.open();
                }
            }
        }
     }

    Dialog {
        id: privacyPolicy
        width: 380

        title: Item {
            height: 60
            width: parent.width
            Text {
                font.pixelSize: 40
                color: "red"
                text: "Privacy Policy"
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }
        content: Item {
            height:childrenRect.height+25
            width: parent.width
            anchors.horizontalCenter: parent.horizontalCenter
            Text {
                width: parent.width
                text: getPrivacyPolicy()
                color:"white"
                font.pixelSize: 20
                wrapMode: Text.WordWrap
            }
        }
        buttons: ButtonRow {
            style: ButtonStyle { }
            anchors.horizontalCenter: parent.horizontalCenter
            Button {
                text: "OK";
                onClicked: privacyPolicy.accept()
            }
       }
    }

    function accept() {
        appWindow.requestToken(authUsername.text, authPassword.text);
        close()
    }

    function getPrivacyPolicy() {
        var policy = "Klippr does only save your username and an extra authtoken, which are needed ";
        policy += "to authenticate you against kippt.com. ";
        policy += "This token is requested once with your username and password from kippt.com.\n";
        policy += " You can revoke access for this app and delete this data by clicking 'Revoke Access' in the app menu ";
        policy += "or by changing your password on kippt.com.\n";
        return policy
    }
}
