import QtQuick 1.0
import com.nokia.meego 1.0

Dialog {
   id: aboutDialog
   content:Item {
        id: name
        width: parent.width
        height: 300
        Text {
            font.pixelSize:22
            font.family: kipprFont.name
            color: "white"
            anchors.centerIn: parent
            text: parent.getAboutMsg()
            textFormat: Text.RichText
            wrapMode: Text.WordWrap
            onLinkActivated: Qt.openUrlExternally(link)
        }
        function getAboutMsg() {
             var msg = '<h1>Klippr</h1>';
             msg +=  '<h3>a client for kippt.com</h3>';
             msg += '<p>&#169; 2012, Martin Borho <a style="color:red" href="mailto:martin@borho.net">martin@borho.net</a><br/>';
             msg += 'License: GNU General Public License (GPL) Vers.3<br/>';
             msg += 'Source: <a style="color:red" href="http://github.com/mborho/klippr">http://github.com/mborho/klippr</a><br/>';
             msg += 'Header font: <a style="color:red" href="http://openfontlibrary.org/en/font/sansus-webissimo">Sansus Webissimo</a>'
             msg += '<div><b>Changelog:</b><br/>'
             msg += '<div>* 1.0.0 - Ovi store</div>';
             msg += '<div>* 0.8.0 - Reader fontsize adjustable, username in Feed</div>';
             msg += '<div>* 0.6.0 - Search added, bugfixes</div>';
             msg += '</div>';
             msg += '</p><br/>';
             msg += '<table><tr><td valign="middle">powered by </td>';
             msg += '<td valign="middle"><a style="color:red" href="http://kippt.com">Kippt.com</a></td>'; //<img src="gfx/glogo.png" height="41" width="114" /></td>';
             msg += '</tr></table>';
             return msg
        }
    }
}
