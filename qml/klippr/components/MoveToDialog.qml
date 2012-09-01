/*
Copyright 2011 Martin Borho <martin@borho.net>
GPLv3 - see License.txt for details
*/
import QtQuick 1.1
import com.nokia.meego 1.0
import "../js/kippt.js" as Kippt

SelectionDialog {
    id: moveToDialog
    titleText: 'Move clip to folder:'
    selectedIndex: -1

    function render() {        
        var lists = Kippt.Data.getLists();
        var clip = Kippt.Data.getClip();
        var max = lists.length;
        listsModel.clear()
        for(var x=0; max > x;x++) {
            if(clip.list.id === lists[x].id) {
                selectedIndex = x;
            }
            listsModel.append({name: lists[x].title});
        }
    }

    function accept() {
        var list = Kippt.Data.getListByIndex(selectedIndex);
        var clip = Kippt.Data.getClip();
        if(clip.list.id !== list.id) {
            clipPage.moveClip(clip, list);
            close();
        }
    }

    ListModel {
        id:listsModel;
    }

    model: listsModel

}
