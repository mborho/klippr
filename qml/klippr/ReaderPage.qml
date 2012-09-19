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
    property int fontSize: 100;

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
        fontSize = 100;
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
            settings.defaultFontSize : 30
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
                if(newSize > 45 && newSize < 175) {
                    fontSize = newSize;
                    evaluateJavaScript("document.getElementById('body').style.fontSize = '"+fontSize+"%';");
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
            anchors.verticalCenter: parent.verticalCenter
            width: 230
            text: "open in browser"
            onClicked: {
                Qt.openUrlExternally ( url )
            }
        }
        ToolIcon {
            iconId: "toolbar-up";
            anchors.right: downIcon.left
            onClicked: {
                webView.setFontSize(+5);//bigger()
            }
        }
        ToolIcon {
            id:downIcon
            iconId: "toolbar-down";
            anchors.right: parent.right
            onClicked: {
                webView.setFontSize(-5);
            }
        }
    }
}
