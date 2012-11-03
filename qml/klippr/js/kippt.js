.pragma library
// Copyright 2012 Martin Borho <martin@borho.net>
// GPLv3q - see license.txt for details

var App = {
    username: "",
    apiToken: "",
}

var Data = function() {
    //
    var _user = {};
    var _lists = {};
    var _clip = {};
    var _list = {};    
    //
    this.setUser =  function(user) {
        _user = user;
    }
    //
    this.getUser =  function() {
        return _user;
    }
    //
    this.setLists = function(lists) {
        if(lists.meta.previous) {
            _lists.objects = _lists.objects.concat(lists.objects)
        } else {
            _lists = lists;
        }
    }
    //
    this.getLists = function(index) {
        return _lists.objects;
    }
    //
    this.getListByIndex = function(index) {
        return _lists.objects[index];
    }
    //
    this.setList = function(list) {
        _list = list;
    }
    //
    this.getList = function () {
        return _list;
    }
    //
    this.setClip = function(clip) {
        _clip = clip;
    }
    //
    this.getClip = function () {
        return _clip;
    }
};

Data = new Data();

var Connector = function(username, token) {

    this.username = username
    this.token = token
    this.endpoint = "https://kippt.com";
    this.xmlHttp = new XMLHttpRequest();

}

Connector.prototype.buildUrl = function(path, params) {
    return this.endpoint+path;
}

Connector.prototype.getToken = function(password, onSuccess, onError) {
    var params = {
        url: 'https://'+encodeURIComponent(this.username)+':'+encodeURIComponent(password)+'@kippt.com/api/account',
        token: this.token,
        onSuccess: onSuccess,
        onError: onError
    }
    this.doRequest(params);
}

Connector.prototype.postData = function(options, onSuccess, onError) {
    var params = {
            url: this.endpoint+options.path,
            onSuccess: onSuccess,
            onError: onError,
            data: options.data,
            method: "POST"
        }
    this.doRequest(params);
}

Connector.prototype.getData = function(path, onSuccess, onError) {
    var params = {
            url: this.endpoint+path,
            onSuccess: onSuccess,
            onError: onError
        }
    this.doRequest(params);
}

Connector.prototype.updateData = function(options, onSuccess, onError) {
    var params = {
            url: this.endpoint+options.path,
            onSuccess: onSuccess,
            onError: onError,
            data: options.data,
            method: "PUT"
        }
    this.doRequest(params);
}

Connector.prototype.deleteData = function(options, onSuccess, onError) {
    var params = {
            url: this.endpoint+options.path,
            onSuccess: onSuccess,
            onError: onError,
            method: "DELETE"
        }
    this.doRequest(params);
}

Connector.prototype.doRequest = function(options) {
    var url = options.url,
        method = (options.method) ? options.method :"GET",
        data = (options.data) ? JSON.stringify(options.data) : null,
        xmlHttp = this.xmlHttp;
//    var start = Date.now();
//    if(data) console.log(data);
    if (xmlHttp) {
        xmlHttp.open(method, url, true);
        xmlHttp.setRequestHeader("X-Kippt-Client", "Klippr for Meego");
        if(this.token) {
            xmlHttp.setRequestHeader("X-Kippt-Username", this.username);
            xmlHttp.setRequestHeader("X-Kippt-API-Token", this.token);
        }

        xmlHttp.onreadystatechange = function () {
            if (xmlHttp.readyState == 4) {
//                if(data) console.log(xmlHttp.responseText);
                if(xmlHttp.status == "200" || xmlHttp.status == "201") {
//                    console.log("end :"+(Date.now()-start))
                    var myJSON = JSON.parse(xmlHttp.responseText);
                    options.onSuccess(myJSON);
                } else if(xmlHttp.status == "401") {
                    options.onError(xmlHttp.status);
                }
            }
        };
        xmlHttp.send(data);
    }
}
