/*
Copyright 2012 Martin Borho <martin@borho.net>
GPLv3 - see License.txt for details
*/
import QtQuick 1.1
import com.nokia.meego 1.0
import "components"
import "js/storage.js" as Storage
import "js/kippt.js" as Kippt

PageStackWindow {
    id: appWindow
    initialPage: mainPage
    Component.onCompleted: onStartup()
    property bool forceFullScreen: false
    property string _username: ""
    property string _apiToken: ""
    showStatusBar: (screen.currentOrientation === Screen.Portrait && !forceFullScreen) ? true : false

    FontLoader { id: kipprFont; source: "fonts/sansus-webissimo-Italic.ttf" }

    Connections {
         target: KipptConnector
         onClipDeleted: {
            if(pageStack.depth === 2) {
                // clip deleted from context menu
                listPage.item.hideSpinner()
            } else {
                clipPage.item.hideSpinner();
            }
            if(statusCode === 204) {                
                var clip = Kippt.Data.getClip();
                if(Kippt.Data.getList().id !== "search") {
                    listPage.item.updateClipInList(clip, true);
                    if(pageStack.depth > 2) { // deleted from clip page
                        pageStack.pop();
                    }
                } else if(Kippt.Data.getList().id === "search") {
                    searchPage.item.updateClipInList(clip, true);
                    if(pageStack.depth > 2) { // deleted from clip page
                        pageStack.pop();
                    }
                } else {
                    pageStack.pop(mainPage);
                }
            }
         }
         onListDeleted: {
            listPage.item.hideSpinner()
            if(statusCode === 204) {
                mainPage.clear()
                loadAllLists();
                pageStack.pop();
            }
         }
     }

    function onStartup() {
        theme.inverted = true;
        var defaults = {
            apiToken: "",
            username: ""
        }
        Storage.loadSettings(defaults, settingsLoaded);
    }

    function settingsLoaded(dbSettings) {
        _username = dbSettings.username
        _apiToken = dbSettings.apiToken;
        // handle token
        if(!_apiToken || !_username) {
            authDialog.open()
        } else {
            Kippt.Data.setUser({username:_username});
            loadAllLists();
        }
    }

    function setFullScreen(active) {
        forceFullScreen = active
    }

    function getConnector() {
        return new Kippt.Connector(_username, _apiToken);
    }

    function onApiError(status) {
        if(status === 401) {
            authDialog.open()
        }
        mainPage.stopSpinner();
    }

    function gotToken(json) {
        appWindow._apiToken = json.api_token;
        appWindow._username = json.username;
        Storage.insertSetting("apiToken", appWindow._apiToken);
        Storage.insertSetting("username", appWindow._username);
        loadAllLists();
    }

    function requestToken(username, password) {
        _username = username;
        getConnector().getToken(password, gotToken, onApiError);
    }

    function revokeAccess() {
        appWindow._apiToken = "";
        appWindow._username = "";
        Storage.insertSetting("apiToken", "");
        Storage.insertSetting("username", "");
        mainPage.clear()
        onStartup()
    }

    function loadAllLists(path) {
        var apiPath = (path !== undefined) ?  path : '/api/lists/?limit=50';
        mainPage.startSpinner();
        getConnector().getData(apiPath, function(lists) {
            Kippt.Data.setLists(lists);
            mainPage.start(lists)
        }, onApiError);
    }

    function loadList(options) {
        mainPage.startSpinner();
        getConnector().getData(options.path, function(links) {
            Kippt.Data.setList(options);
            listPage.show(options, links);
            mainPage.stopSpinner();
        });
    }

    function loadSearchResults(options) {
        getConnector().getData(options.path, function(links) {
            Kippt.Data.setList(options);
            searchPage.item.render(options, links);
        });
    }

    function loadClip(options) {
        if(options.search) searchPage.item.showSpinner()
        else listPage.item.showSpinner()
        getConnector().getData(options.path, function(clip) {
            Kippt.Data.setClip(clip)
            clipPage.show(clip)
            if(options.search) searchPage.item.hideSpinner()
            else listPage.item.hideSpinner()
        });
    }

   function loadReader(options) {
        clipPage.item.showSpinner()
        getConnector().getData(options.path, function(clip) {
            readerPage.show(clip)
            clipPage.item.hideSpinner()
        });
    }

    function createList(options) {
        mainPage.startSpinner();
        getConnector().postData(options, function(clip) {
            mainPage.stopSpinner();
            mainPage.clear();
            loadAllLists('/api/lists/');
        }, onApiError);
    }

    function updateList(options) {
        getConnector().updateData(options, function(list) {
            Kippt.Data.setList(list)
            if(options.index) {
                mainPage.updateList(options.index, list);
                listPage.item.setTitle(list.title);
            }
            listPage.item.setPrivate(list.is_private, true);
        }, onApiError);
    }

    function deleteList(options) {
        KipptConnector.deleteCall('list', 'https://kippt.com'+options.path, appWindow._username, appWindow._apiToken)
    }

    function createClip(options) {
        mainPage.startSpinner();
        getConnector().postData(options, function(clip) {
            mainPage.stopSpinner();
        }, onApiError);
    }

    function updateClip(options) {
        getConnector().updateData(options, function(clip) {
            Kippt.Data.setClip(clip)            
            if(!options.search) {
                var listId = listPage.item.listId
                listPage.item.updateClipInList(clip)
            } else {
                var listId;
                searchPage.item.updateClipInList(clip)
            }
            // remove clip from list
            if((listId === "read_later" && options.data.is_read_later === false) ||
                (listId === "starred" && options.data.is_starred === false)) {
                    listPage.item.updateClipInList(clip, true);
            }
            clipPage.item.update(clip, listId);
        }, onApiError);
    }

    function moveClip(options) {
        getConnector().updateData(options, function(clip) {
            if(!options.search) {
                var listId = listPage.item.listId;
                listPage.item.updateClipInList(clip, true);
            } else {
                var listId;
                searchPage.item.updateClipInList(clip)
            }
            clipPage.item.updateList(options.list);
        }, onApiError);
    }

    function deleteClip(options) {
        KipptConnector.deleteCall('clip', 'https://kippt.com'+options.path, appWindow._username, appWindow._apiToken)
    }

    AuthDialog {
        id: authDialog
    }

    MainPage {
        id: mainPage
    }

    Loader {
        id:listPage
        onStatusChanged: {
            if (listPage.status == Loader.Ready) {
                show();
            }
        }
        function show(data, links) {
            if (listPage.status == Loader.Ready) {
                if(pageStack.depth === 1) {
                    pageStack.push(listPage.item);
                }
            } else {
                listPage.source = "ListPage.qml"
            }
            if(data) {
                listPage.item.setData(data);
            }
            if(links) {
                listPage.item.render(links);
            }
        }
    }

    Loader {
        id:searchPage
        onStatusChanged: {
            if (searchPage.status == Loader.Ready) {
                show();
            }
        }
        function show() {
            if (searchPage.status == Loader.Ready) {
                if(pageStack.depth === 1) {
                    searchPage.item.clear();
                    pageStack.push(searchPage.item);
                    searchPage.item.setInputFocus();
                }
            } else {
                searchPage.source = "SearchPage.qml"
            }
        }
    }

    Loader {
        id:clipPage
        onStatusChanged: {
            if (clipPage.status == Loader.Ready) {
                show();
            }
        }
        function show(clip) {
            if (clipPage.status == Loader.Ready) {
                if(pageStack.depth === 2) {
                    pageStack.push(clipPage.item);
                }
            } else {
                clipPage.source = "ClipPage.qml"
            }
            if(clip) {
                clipPage.item.render(clip);
            }
        }
    }

    Loader {
        id:readerPage
        onStatusChanged: {
            if (readerPage.status == Loader.Ready) {
                show();
            }
        }
        function show(clip) {
            if (readerPage.status == Loader.Ready) {
                if(pageStack.depth === 3) {
                    pageStack.push(readerPage.item);
                }
            } else {
                readerPage.source = "ReaderPage.qml"
            }
            if(clip) {
                readerPage.item.render(clip);
            }
        }
    }

    AcceptDialog {
        id: acceptDialog
    }

    EditListDialog {
        id: editListDialog
    }

    EditClipDialog {
        id: editClipDialog
    }

    Loader {
        id: aboutLoader
        anchors.fill: parent
    }

}
