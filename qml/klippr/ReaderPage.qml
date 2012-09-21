/*
Copyright 2012 Martin Borho <martin@borho.net>
GPLv3 - see License.txt for details
*/
import QtQuick 1.1
import com.nokia.meego 1.0
import QtWebKit 1.0
import "components"

Page {
    id: readerPage
    tools: readerTools
    property string url: ""
    property int fontSize: 30;

    function clear() {
        url = ""
        webView.html = ""
    }

    function buildHtml(clip) {
        var html = '<html><style>html {background:#000;} body {color:#fff;font-size:30px;} a {color:#FFF;font-weight:bold;} ';
        html += 'a:hover {color:#8B8B8B;} img {max-width:100%} pre {white-space:pre-wrap;}</style><body id="body">';
        html += '<script>document.onclick= function(e){if(e.target.href) {window.qml.openUrl(e.target.href);};return false;}</script>';
        html += '<h2 id="title">'+clip.title+'</h2>'
        html += clip.html
        html += '</body></html>'
        return html
    }

    function render(clip) {
        clear()
        url = clip.url
        webView.html = buildHtml(clip)
        fontSize = 30;
    }

    Flickable {
        id: flickable
        width: parent.width
        height:  parent.height
        contentWidth: webView.width
        contentHeight: webView.height
        interactive: true
        clip: true
        flickableDirection: Flickable.VerticalFlick

        WebView {
            id: webView
            html:""
            preferredWidth: flickable.width
            preferredHeight: flickable.height
            scale: 1
            settings.javascriptEnabled: true
            javaScriptWindowObjects: QtObject {
                WebView.windowObjectName: "qml"
                function consoleLog(msg){
                    console.log(msg)
                }
                function openUrl(url) {
                    Qt.openUrlExternally ( url )
                }
            }

            function setFontSize(diff) {
                var newSize = fontSize+diff;
                if(newSize > 8 && newSize < 60) {
                    fontSize = newSize;
                    evaluateJavaScript("document.getElementById('body').style.fontSize = '"+fontSize+"px';");
                }
            }
        }
    }

    ScrollDecorator {
        flickableItem: flickable
    }

    ToolBarLayout {
        id: readerTools
        ToolIcon {
            id: backIcon
            iconId: "toolbar-back";
            onClicked: {
                pageStack.pop();
            }
        }
        ToolButton {
            id: readerOpenUrl
            anchors.left: backIcon.right
            anchors.leftMargin: 10
            anchors.verticalCenter: parent.verticalCenter
            width: 230
            text: "open in browser"
            onClicked: {
                Qt.openUrlExternally ( url )
            }
        }
        Rectangle {
            width:80
            height:parent.height
            color: "transparent"
            anchors.right: downIconBox.left
            Image {
                id: upIcon
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                source: "gfx/fontsize_up.png"
                Behavior on opacity {
                    NumberAnimation { duration: 500 }
                }
            }
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    webView.setFontSize(+2);
                }
                onPressed: {upIcon.opacity = 0.1}
                onReleased: {upIcon.opacity = 1}
                onCanceled: {upIcon.opacity = 1}
            }
        }
        Rectangle {
            id: downIconBox
            width:80
            height:parent.height
            anchors.right: parent.right
            color: "transparent"
            Image {
                id: downIcon
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                source: "gfx/fontsize_down.png"
                Behavior on opacity {
                    NumberAnimation { duration: 500 }
                }
            }
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    webView.setFontSize(-2);
                }
                onPressed: {downIcon.opacity = 0.1}
                onReleased: {downIcon.opacity = 1}
                onCanceled: {downIcon.opacity = 1}
            }
        }
    }
}