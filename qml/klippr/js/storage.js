// Copyright 2012 Martin Borho <martin@borho.net>
// GPLv3 - see license.txt for details

function getConnection() {
    return openDatabaseSync("Klippr", "1.0", "KeyValueStorage", 10);
}

function executeSql(sql, params) {
    db = getConnection()
    var res = false;
    if(!params) params = [];
    db.transaction(function(tx) {
        res = tx.executeSql(sql,params);
    });
    return res;
}

function initStorage() {
    console.log('initialise storage');
    db = getConnection()
    executeSql('CREATE TABLE IF NOT EXISTS settings(key TEXT UNIQUE, value TEXT)');
//    executeSql('DELETE FROM settings WHERE 1');
}

var db = initStorage();


function loadSettings(settings, callBack) {
    var rs = executeSql('SELECT * FROM settings','');
    for(var i = 0; i < rs.rows.length; i++) {
        if(rs.rows.item(i).value !== '') {
            settings[rs.rows.item(i).key] = rs.rows.item(i).value
        }
//        console.log('key: '+rs.rows.item(i).key + ", value: " + rs.rows.item(i).value);
    }
    callBack(settings);
}

function insertSetting(key, value) {
    executeSql('INSERT OR REPLACE INTO settings VALUES(?, ?)', [key, value]);
}
