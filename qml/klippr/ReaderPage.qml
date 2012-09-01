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

    function clear() {
        url = ""
        webView.html = ""
    }

    function buildHtml(clip) {
        var html = '<html><style>html {background:#000;color:#fff} a {color:#FFF;font-weight:bold;} ';
        html += 'a:hover {color:#8B8B8B;} img {max-width:100%}</style><body>';
        html += '<script>document.onclick= function(e){if(e.target.href) {window.qml.openUrl(e.target.href);};return false;};</script>'
        html += '<h2>'+clip.title+'</h2>'
        html += clip.html
        html += '</body></html>'
        return html
    }

    function render(clip) {
        clear()
        url = clip.url
        webView.html = buildHtml(clip)
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
            javaScriptWindowObjects: QtObject {
                WebView.windowObjectName: "qml"
                function consoleLog(msg){
                    console.log(msg)
                }
                function openUrl(url) {
                    Qt.openUrlExternally ( url )
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
            iconId: "toolbar-back";
            onClicked: {
                pageStack.pop();
            }
        }
        ToolButton {
            id: readerOpenUrl
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter
            width: 250
            text: "open in browser"
            onClicked: {
                Qt.openUrlExternally ( url )
            }
        }
    }
}
