.import QtQuick.LocalStorage 2.12 as Sql


/*open database for transactions*/
function openDB() {
    var db = null
    if (db !== null)
        return

    db = Sql.LocalStorage.openDatabaseSync("subaybay.kugiigi", "1.0",
                                           "applciation's backend data", 100000)

    return db
}

/*************Meta data functions*************/

//Create initial data
function createInitialData() {
    createMetaTables()
    initiateData()
}

//Create meta tables
function createMetaTables() {
    var db = openDB()

    db.transaction(function (tx) {
        tx.executeSql(
                    "CREATE TABLE IF NOT EXISTS `profiles` (`profile_id`	INTEGER PRIMARY KEY AUTOINCREMENT,`active` INTEGER NOT NULL CHECK (`active` IN (0, 1)), `display_name` TEXT)")
        tx.executeSql(
                    "CREATE TABLE IF NOT EXISTS `units` (`name`	TEXT PRIMARY KEY,`display_symbol` TEXT)")
        tx.executeSql(
                    "CREATE TABLE IF NOT EXISTS `monitor_items` (`item_id` TEXT PRIMARY KEY,`display_name` TEXT,`descr` TEXT, `display_format` TEXT, `unit` TEXT)")
        tx.executeSql(
                    "CREATE TABLE IF NOT EXISTS `monitor_items_dash` (`item_id` TEXT NOT NULL,`value_type` TEXT,`scope` TEXT, PRIMARY KEY(item_id, value_type, scope), FOREIGN KEY(item_id) REFERENCES monitor_items(item_id) ON DELETE CASCADE)")
        tx.executeSql(
                    "CREATE TABLE IF NOT EXISTS `monitor_items_fields` (`field_id` TEXT NOT NULL, `item_id` TEXT NOT NULL, `field_seq` INTEGER NOT NULL, `display_name` TEXT, `unit` TEXT, `precision` INTEGER, PRIMARY KEY(field_id, item_id), FOREIGN KEY(item_id) REFERENCES monitor_items(item_id) ON DELETE CASCADE)")
        tx.executeSql(
                    "CREATE TABLE IF NOT EXISTS `monitor_items_values` (`entry_date` TEXT NOT NULL, `field_id` TEXT NOT NULL, `profile_id` INTEGER NOT NULL, `item_id` TEXT NOT NULL, `value` REAL, PRIMARY KEY(entry_date, field_id, profile_id, item_id), FOREIGN KEY(item_id) REFERENCES monitor_items(item_id) ON DELETE CASCADE, FOREIGN KEY(field_id, item_id) REFERENCES monitor_items_fields(field_id, item_id) ON DELETE CASCADE, CONSTRAINT fk_profiles FOREIGN KEY(profile_id) REFERENCES profiles(profile_id) ON DELETE CASCADE)")
        tx.executeSql(
                    "CREATE TABLE IF NOT EXISTS `monitor_items_comments` (`entry_date` TEXT NOT NULL, `profile_id` INTEGER NOT NULL, `comments` TEXT, PRIMARY KEY(entry_date, profile_id), CONSTRAINT fk_profiles FOREIGN KEY(profile_id) REFERENCES profiles(profile_id) ON DELETE CASCADE)")
    })
}

function createMetaViews() {
    var db = openDB()

    db.transaction(function (tx) {
        tx.executeSql("DROP VIEW IF EXISTS expenses_today")
        tx.executeSql("DROP VIEW IF EXISTS expenses_yesterday")
        tx.executeSql("DROP VIEW IF EXISTS expenses_thisweek")
        tx.executeSql("DROP VIEW IF EXISTS expenses_thismonth")
        tx.executeSql("DROP VIEW IF EXISTS expenses_recent")
        tx.executeSql("DROP VIEW IF EXISTS expenses_lastweek")
        tx.executeSql("DROP VIEW IF EXISTS expenses_lastmonth")
        tx.executeSql("DROP VIEW IF EXISTS expenses_vw")


        tx.executeSql(
                    "CREATE VIEW IF NOT EXISTS expenses_today AS SELECT a.expense_id, a.category_name, a.name, a.descr, a.date, a.value, b.home_currency, b.travel_currency, IFNULL(b.rate, 0) as 'rate', IFNULL(b.value, 0) as 'travel_value' FROM expenses a LEFT OUTER JOIN travel_expenses b USING(expense_id) WHERE date(a.date) = date('now','localtime')")
        tx.executeSql(
                    "CREATE VIEW IF NOT EXISTS expenses_yesterday AS SELECT a.expense_id, a.category_name, a.name, a.descr, a.date, a.value, b.home_currency, b.travel_currency, IFNULL(b.rate, 0) as 'rate', IFNULL(b.value, 0) as 'travel_value' FROM expenses a LEFT OUTER JOIN travel_expenses b USING(expense_id) WHERE date(a.date) = date('now','localtime','-1 day')")
        tx.executeSql(
                    "CREATE VIEW IF NOT EXISTS expenses_thisweek AS SELECT a.expense_id, a.category_name, a.name, a.descr, a.date, a.value, b.home_currency, b.travel_currency, IFNULL(b.rate, 0) as 'rate', IFNULL(b.value, 0) as 'travel_value' FROM expenses a LEFT OUTER JOIN travel_expenses b USING(expense_id) WHERE date(a.date) BETWEEN date('now','localtime','weekday 6','-6 days') AND date('now','localtime','weekday 6')")
        tx.executeSql(
                    "CREATE VIEW IF NOT EXISTS expenses_thismonth AS SELECT a.expense_id, a.category_name, a.name, a.descr, a.date, a.value, b.home_currency, b.travel_currency, IFNULL(b.rate, 0) as 'rate', IFNULL(b.value, 0) as 'travel_value' FROM expenses a LEFT OUTER JOIN travel_expenses b USING(expense_id) WHERE date(a.date) BETWEEN date('now', 'localtime', 'start of month')  AND date('now','localtime','start of month','+1 month','-1 day')")
        tx.executeSql(
                    "CREATE VIEW IF NOT EXISTS expenses_recent AS SELECT a.expense_id, a.category_name, a.name, a.descr, a.date, a.value, b.home_currency, b.travel_currency, IFNULL(b.rate, 0) as 'rate', IFNULL(b.value, 0) as 'travel_value' FROM expenses a LEFT OUTER JOIN travel_expenses b USING(expense_id) WHERE date(a.date) BETWEEN date('now','localtime','-7 day') AND date('now','localtime')")
        tx.executeSql(
                    "CREATE VIEW IF NOT EXISTS expenses_lastweek AS SELECT a.expense_id, a.category_name, a.name, a.descr, a.date, a.value, b.home_currency, b.travel_currency, IFNULL(b.rate, 0) as 'rate', IFNULL(b.value, 0) as 'travel_value' FROM expenses a LEFT OUTER JOIN travel_expenses b USING(expense_id) WHERE date(a.date) BETWEEN date('now','localtime','weekday 6', '-13 days') AND date('now','localtime','weekday 6', '-7 days')")
        tx.executeSql(
                    "CREATE VIEW IF NOT EXISTS expenses_lastmonth AS SELECT a.expense_id, a.category_name, a.name, a.descr, a.date, a.value, b.home_currency, b.travel_currency, IFNULL(b.rate, 0) as 'rate', IFNULL(b.value, 0) as 'travel_value' FROM expenses a LEFT OUTER JOIN travel_expenses b USING(expense_id) WHERE date(a.date) BETWEEN date('now','localtime','start of month','-1 month') AND date('now','localtime','start of month','-1 day')")
        tx.executeSql(
                    "CREATE VIEW IF NOT EXISTS expenses_vw AS SELECT a.expense_id, a.category_name, a.name, a.descr, a.date, a.value, b.home_currency, b.travel_currency, IFNULL(b.rate, 0) as 'rate', IFNULL(b.value, 0) as 'travel_value' FROM expenses a LEFT OUTER JOIN travel_expenses b USING(expense_id)")
    })
}

//Initialize data for first time use
function initiateData() {
    var db = openDB()
    db.transaction(function (tx) {
        // Create default profile
        var profiles = tx.executeSql('SELECT * FROM profiles')
        if (profiles.rows.length === 0) {
            tx.executeSql(
                        'INSERT INTO profiles ("active", "display_name") VALUES(1, ?)',[i18n.tr("Default")])
        }

        // Create standard monitor items
        var monitorItems = tx.executeSql('SELECT * FROM monitor_items')
        if (monitorItems.rows.length === 0) {
            tx.executeSql(
                        'INSERT INTO monitor_items VALUES("urine", ?, ?, "%1", "milliliters")',[i18n.tr("Urine"), i18n.tr("Volume of urine")])
            tx.executeSql(
                        'INSERT INTO monitor_items VALUES("blood_pressure", ?, ?, "%1/%2", "mmhg")',[i18n.tr("Blood Pressure"), i18n.tr("Pressure of the blood")])
            tx.executeSql(
                        'INSERT INTO monitor_items VALUES("oxygen", ?, ?, "%1", "percent")',[i18n.tr("Oxygen"), i18n.tr("Oxygen level in the blood")])
            tx.executeSql(
                        'INSERT INTO monitor_items VALUES("heart_rate", ?, ?, "%1", "bpm")',[i18n.tr("Heart Rate"), i18n.tr("Rate of heart beats")])
            tx.executeSql(
                        'INSERT INTO monitor_items VALUES("blood_sugar", ?, ?, "%1", "mgdl")',[i18n.tr("Blood Sugar"), i18n.tr("Sugar level in the blood")])
            tx.executeSql(
                        'INSERT INTO monitor_items VALUES("temperature", ?, ?, "%1", "celsius")',[i18n.tr("Temperature"), i18n.tr("Temperature of the body")])
        }

        // Add units
        var units = tx.executeSql('SELECT * FROM units')
        if (units.rows.length === 0) {
            tx.executeSql(
                        'INSERT INTO units VALUES("milliliters", "ml")')
            tx.executeSql(
                        'INSERT INTO units VALUES("mmhg", "mmHg")')
            tx.executeSql(
                        'INSERT INTO units VALUES("percent", "%")')
            tx.executeSql(
                        'INSERT INTO units VALUES("bpm", "bpm")')
            tx.executeSql(
                        'INSERT INTO units VALUES("mgdl", "mg/dL")')
            tx.executeSql(
                        'INSERT INTO units VALUES("celsius", "°C")')
        }

        // Add monitor item fields
        var fields = tx.executeSql('SELECT * FROM monitor_items_fields')
        if (fields.rows.length === 0) {
            tx.executeSql(
                        'INSERT INTO monitor_items_fields VALUES("default", "urine", 1, "", "milliliters", 0)')
            tx.executeSql(
                        'INSERT INTO monitor_items_fields VALUES("default", "oxygen", 1, "", "percent", 0)')
            tx.executeSql(
                        'INSERT INTO monitor_items_fields VALUES("default", "heart_rate", 1, "", "bpm", 0)')
            tx.executeSql(
                        'INSERT INTO monitor_items_fields VALUES("default", "blood_sugar", 1, "", "mgdl", 0)')
            tx.executeSql(
                        'INSERT INTO monitor_items_fields VALUES("default", "temperature", 1, "", "celsius", 1)')
            tx.executeSql(
                        'INSERT INTO monitor_items_fields VALUES("systolic", "blood_pressure", 1, ?, "mmhg", 0)',[i18n.tr("Systolic")])
            tx.executeSql(
                        'INSERT INTO monitor_items_fields VALUES("diastolic", "blood_pressure", 2, ?, "mmhg", 0)',[i18n.tr("Diastolic")])
        }

        // Add monitor items dash data
        var monitorItemDash = tx.executeSql('SELECT * FROM monitor_items_dash')
        if (monitorItemDash.rows.length === 0) {
            tx.executeSql(
                        'INSERT INTO monitor_items_dash VALUES("urine", "last", "all")')
            tx.executeSql(
                        'INSERT INTO monitor_items_dash VALUES("urine", "total", "today")')
            tx.executeSql(
                        'INSERT INTO monitor_items_dash VALUES("urine", "average", "recent daily")')
            tx.executeSql(
                        'INSERT INTO monitor_items_dash VALUES("blood_pressure", "last", "all")')
            tx.executeSql(
                        'INSERT INTO monitor_items_dash VALUES("oxygen", "last", "all")')
            tx.executeSql(
                        'INSERT INTO monitor_items_dash VALUES("oxygen", "average", "today")')
            tx.executeSql(
                        'INSERT INTO monitor_items_dash VALUES("heart_rate", "last", "all")')
            tx.executeSql(
                        'INSERT INTO monitor_items_dash VALUES("heart_rate", "average", "today")')
            tx.executeSql(
                        'INSERT INTO monitor_items_dash VALUES("blood_sugar", "last", "all")')
            tx.executeSql(
                        'INSERT INTO monitor_items_dash VALUES("blood_sugar", "average", "week")')
            tx.executeSql(
                        'INSERT INTO monitor_items_dash VALUES("blood_sugar", "average", "recent")')
            tx.executeSql(
                        'INSERT INTO monitor_items_dash VALUES("blood_sugar", "highest", "today")')
            tx.executeSql(
                        'INSERT INTO monitor_items_dash VALUES("temperature", "last", "all")')
            tx.executeSql(
                        'INSERT INTO monitor_items_dash VALUES("temperature", "highest", "today")')
        }
    })
}

//Checks current database user version
function checkUserVersion() {
    var db = openDB()
    var rs = null
    var currentDataBaseVersion

    db.transaction(function (tx) {
        rs = tx.executeSql('PRAGMA user_version')
        currentDataBaseVersion = rs.rows.item(0).user_version
    })

    return currentDataBaseVersion
}

//increments database user version
function upgradeUserVersion() {
    var db = openDB()
    var rs = null
    var currentDataBaseVersion
    var newDataBaseVersion

    db.transaction(function (tx) {
        rs = tx.executeSql('PRAGMA user_version')
        currentDataBaseVersion = rs.rows.item(0).user_version
        newDataBaseVersion = currentDataBaseVersion + 1
        tx.executeSql("PRAGMA user_version = " + newDataBaseVersion)
    })
}

//Execute Needed Database upgrades
function databaseUpgrade(currentVersion) {
    // if (currentVersion < 1) {
    //     executeUserVersion1()
    // }
    // if (currentVersion < 2) {
    //     executeUserVersion2()
    // }
    // if (currentVersion < 3) {
    //     executeUserVersion3()
    // }
}

//Database Changes for User Version 1
function executeUserVersion1() {
    createMetaViews()
    createReportsRecord()
    createQuickRecord()
    console.log("Database Upgraded to 1")
    upgradeUserVersion()
}

function createReportsRecord(){
    var db = openDB()

    db.transaction(function (tx) {
        tx.executeSql(
                    "CREATE TABLE IF NOT EXISTS `reports` (`report_id` INTEGER PRIMARY KEY AUTOINCREMENT,`creator` TEXT DEFAULT 'user',`report_name` TEXT,`type` TEXT DEFAULT 'LINE',`date_range` TEXT DEFAULT 'This Month',`date_mode` TEXT DEFAULT 'Day',`filter` TEXT,`exceptions` TEXT,`date1` TEXT,`date2` TEXT)")
    })


}

function createQuickRecord(){
    var db = openDB()

    db.transaction(function (tx) {
        tx.executeSql(
                    "CREATE TABLE IF NOT EXISTS `quick_expenses` (`quick_id` INTEGER PRIMARY KEY AUTOINCREMENT, `category_name`	TEXT, `name` TEXT, `descr` TEXT, `value` REAL);")
    })

}

//Database Changes for User Version 2
// Version 0.70
function executeUserVersion2() {
    createCurrenciesRecord()
    createInitialCurrencies()
    console.log("Database Upgraded to 2")
    upgradeUserVersion()
}




/*************Main Data functions*************/
function getProfiles() {
    var db = openDB()
    var arrResults = []
    var rs = null

    db.transaction(function (tx) {
        rs = tx.executeSql("SELECT * FROM profiles where active = 1 order by display_name asc")
        arrResults.length = rs.rows.length

        for (var i = 0; i < rs.rows.length; i++) {
            arrResults[i] = rs.rows.item(i)
        }
    })

    return arrResults
}

function checkProfileIfExist(txtDisplayName) {
    var db = openDB()
    var rs = null
    var exists

    db.transaction(function (tx) {
        rs = tx.executeSql("SELECT * FROM profiles WHERE active = 1 and display_name = ?", [txtDisplayName])

        exists = rs.rows.length === 0 ? false : true
    })

    return exists
}

function newProfile(txtDisplayName) {
    var txtSaveStatement
    var db = openDB()
    var rs = null
    var newID

    txtSaveStatement = 'INSERT INTO profiles(active, display_name) VALUES(1, ?)'

    db.transaction(function (tx) {
        tx.executeSql(txtSaveStatement,
                      [txtDisplayName])

        rs = tx.executeSql("SELECT MAX(profile_id) as id FROM profiles")
        newID = rs.rows.item(0).id
    })


    return newID
}

function editProfile(intProfileId, txtNewDisplayName) {
    var db = openDB()

    db.transaction(function (tx) {
        tx.executeSql(
                    "UPDATE profiles SET display_name = ? WHERE profile_id = ?",
                    [txtNewDisplayName, intProfileId])
    })
}

function deleteProfile(intProfileId) {
    var txtSqlStatement
    var db = openDB()
    var success
    var errorMsg
    var result

    // FIXME: Deactivate a profile if it has data until proper archiving is implemented
    if (checkProfileData(intProfileId)) {
        txtSqlStatement = `UPDATE profiles set active = 0 WHERE profile_id = ?`
    } else {
        txtSqlStatement = 'DELETE FROM profiles WHERE profile_id = ?'
    }

    try {
        db.transaction(function (tx) {
            tx.executeSql(txtSqlStatement, [intProfileId])
        })

        success = true
    } catch (err) {
        console.log("Database error: " + err)
        errorMsg = err
        success = false
    }
    
    result = {"success": success, "error": errorMsg}
    
    return result
}

function getMonitorItems() {
    var db = openDB()
    var arrResults = []
    var rs = null

    db.transaction(function (tx) {
        rs = tx.executeSql("SELECT items.item_id, items.display_name, items.descr \
              , items.display_format, items.unit, units.display_symbol \
              FROM monitor_items items \
              LEFT OUTER JOIN units units ON items.unit = units.name \
              ORDER BY items.display_name asc")
        arrResults.length = rs.rows.length

        for (var i = 0; i < rs.rows.length; i++) {
            arrResults[i] = rs.rows.item(i)
        }
    })

    return arrResults
}

function getItemsFields() {
    var db = openDB()
    var arrResults = []
    var rs = null

    db.transaction(function (tx) {
        rs = tx.executeSql("SELECT items.item_id, items.display_name, fields.field_id \
              , fields.display_name as field_name, fields.precision, units.display_symbol \
              FROM monitor_items items, monitor_items_fields fields \
              LEFT OUTER JOIN units units ON fields.unit = units.name \
              WHERE items.item_id = fields.item_id \
              ORDER BY items.display_name asc, fields.field_seq asc")
        arrResults.length = rs.rows.length

        for (var i = 0; i < rs.rows.length; i++) {
            arrResults[i] = rs.rows.item(i)
        }
    })

    return arrResults
}

function addNewValue(txtEntryDate, txtFieldId, intProfileId, txtItemId, realValue) {
    var txtSaveStatement
    var db = openDB()
    var rs = null
    var newID
    var success
    var errorMsg
    var result

    txtSaveStatement = 'INSERT INTO monitor_items_values ("entry_date", "field_id", "profile_id", "item_id", "value") \
                        VALUES(strftime("%Y-%m-%d %H:%M:%f", ?, "utc"),?,?,?,?)'

    try {
        db.transaction(function (tx) {
            tx.executeSql(txtSaveStatement,
                          [txtEntryDate, txtFieldId, intProfileId, txtItemId, realValue])
    
        })

        success = true
    } catch (err) {
        console.log("Database error: " + err)
        errorMsg = err
        success = false
    }

    result = {"success": success, "error": errorMsg}
    
    return result
}

function updateItemValue(txtEntryDate, txtFieldId, intProfileId, txtItemId, realValue) {
    var txtSaveStatement
    var db = openDB()
    var rs = null
    var newID
    var success
    var errorMsg
    var result

    txtSaveStatement = 'UPDATE monitor_items_values SET value = ? \
                        WHERE strftime("%Y-%m-%d %H:%M:%f", entry_date, "localtime") = strftime("%Y-%m-%d %H:%M:%f", ?) \
                        AND field_id = ? AND profile_id = ? AND item_id = ?'

    try {
        db.transaction(function (tx) {
            tx.executeSql(txtSaveStatement,
                          [realValue, txtEntryDate, txtFieldId, intProfileId, txtItemId])
    
        })

        success = true
    } catch (err) {
        console.log("Database error: " + err)
        errorMsg = err
        success = false
    }

    result = {"success": success, "error": errorMsg}
    
    return result
}

function addNewComment(txtEntryDate, intProfileId, txtComments) {
    var txtSaveStatement
    var db = openDB()
    var rs = null
    var newID
    var success
    var errorMsg
    var result

    txtSaveStatement = 'INSERT INTO monitor_items_comments ("entry_date", "profile_id", "comments") \
                        VALUES(strftime("%Y-%m-%d %H:%M:%f", ?, "utc"),?,?)'

    try {
        db.transaction(function (tx) {
            tx.executeSql(txtSaveStatement,
                          [txtEntryDate, intProfileId, txtComments])
    
        })

        success = true
    } catch (err) {
        console.log("Database error: " + err)
        errorMsg = err
        success = false
    }

    result = {"success": success, "error": errorMsg}
    
    return result
}

function editComment(txtEntryDate, intProfileId, txtNewComments) {
    var db = openDB()
    var success
    var errorMsg
    var result

    try {
        db.transaction(function (tx) {
            tx.executeSql(
                        "UPDATE monitor_items_comments SET comments = ? WHERE profile_id = ? \
                        AND strftime('%Y-%m-%d %H:%M:%f', entry_date, 'localtime') = strftime('%Y-%m-%d %H:%M:%f', ?)",
                        [txtNewComments, intProfileId, txtEntryDate])
        })
        success = true
    } catch (err) {
        console.log("Database error: " + err)
        errorMsg = err
        success = false
    }
    
    result = {"success": success, "error": errorMsg}
    
    return result
}

// Check if profile has values data
function checkProfileData(intProfileId) {
    var db = openDB()
    var rs = null
    var exists

    db.transaction(function (tx) {
        rs = tx.executeSql("SELECT * FROM monitor_items_values WHERE profile_id = ?", [intProfileId])

        exists = rs.rows.length === 0 ? false : true
    })

    return exists
}

function getItemValues(intProfileId, txtItemId, txtScope, txtxDateFrom, txtDateTo) {
    var db = openDB()
    var arrResults = []
    var rs = null
    var txtSelectStatement
    // console.log (txtxDateFrom + " - " + txtDateTo)
    db.transaction(function (tx) {
        txtSelectStatement = "SELECT (strftime('%Y-%m-%d %H:%M:%f', val.entry_date, 'localtime')) as entry_date, val.item_id, val.value \
                              , com.comments, fields.field_id, fields.precision, fields.field_seq \
                              FROM monitor_items_values as val \
                              LEFT OUTER JOIN monitor_items_comments as com \
                              ON val.entry_date = com.entry_date \
                              AND val.profile_id = com.profile_id \
                              LEFT OUTER JOIN monitor_items_fields fields \
                              ON val.field_id = fields.field_id \
                              AND val.item_id = fields.item_id \
                              WHERE val.profile_id = ? \
                              AND val.item_id = ?\
                              AND date(val.entry_date, 'localtime') BETWEEN date(?) AND date(?) \
                              ORDER BY val.entry_date asc, fields.field_seq asc;"
        rs = tx.executeSql(txtSelectStatement,
                                   [intProfileId, txtItemId, txtxDateFrom, txtDateTo])
        arrResults.length = rs.rows.length

        for (var i = 0; i < rs.rows.length; i++) {
            arrResults[i] = rs.rows.item(i)
        }
    })

    return arrResults
}

function deleteValue(intProfileId, txtEntryDate, txtItemId) {
    var txtSqlStatement
    var db = openDB()
    var success
    var errorMsg
    var result

    txtSqlStatement = 'DELETE FROM monitor_items_values WHERE profile_id = ? AND strftime("%Y-%m-%d %H:%M:%f", entry_date, "localtime") = strftime("%Y-%m-%d %H:%M:%f", ?) AND item_id = ?'

    try {
        db.transaction(function (tx) {
            tx.executeSql(txtSqlStatement, [intProfileId, txtEntryDate, txtItemId])
        })

        if (!checkCommentDelete(intProfileId, txtEntryDate, txtItemId)) {
            deleteComment(intProfileId, txtEntryDate)
        }

        success = true
    } catch (err) {
        console.log("Database error: " + err)
        success = false
    }
    
    result = {"success": success, "error": errorMsg}
    
    return result
}

function deleteComment(intProfileId, txtEntryDate) {
    var txtSqlStatement
    var db = openDB()
    var success, errorMsg
    var result

    txtSqlStatement = 'DELETE FROM monitor_items_comments WHERE profile_id = ? AND strftime("%Y-%m-%d %H:%M:%f", entry_date, "localtime") = strftime("%Y-%m-%d %H:%M:%f", ?)'

    try {
        db.transaction(function (tx) {
            tx.executeSql(txtSqlStatement, [intProfileId, txtEntryDate])
        })

        success = true
    } catch (err) {
        console.log("Database error: " + err)
        success = false
    }
    
    result = {"success": success, "error": errorMsg}
    
    return result
}

// Check if comments is shared with other items
function checkCommentDelete(intProfileId, txtEntryDate, txtItemId) {
    var db = openDB()
    var rs = null
    var exists

    db.transaction(function (tx) {
        rs = tx.executeSql("SELECT * FROM monitor_items_values \
                            WHERE profile_id = ? AND strftime('%Y-%m-%d %H:%M:%f', entry_date, 'localtime') = strftime('%Y-%m-%d %H:%M:%f', ?) AND item_id <> ?", [intProfileId, txtEntryDate, txtItemId])

        exists = rs.rows.length === 0 ? false : true
    })

    return exists
}

function getDashItems() {
    var db = openDB()
    var arrResults = []
    var rs = null

    db.transaction(function (tx) {
        rs = tx.executeSql("SELECT dash.item_id, items.display_name, items.display_format \
              , items.unit, units.display_symbol, dash.value_type, dash.scope \
              FROM monitor_items_dash dash, monitor_items items \
              LEFT OUTER JOIN units units ON items.unit = units.name \
              WHERE dash.item_id = items.item_id")
        arrResults.length = rs.rows.length

        for (var i = 0; i < rs.rows.length; i++) {
            arrResults[i] = rs.rows.item(i)
        }
    })

    return arrResults
}

function getTotalFromValues(intProfileId, txtItemId, txtxDateFrom, txtDateTo, txtGrouping) {
    var db = openDB()
    var arrResults = []
    var rs = null
    var txtSelectStatement

    db.transaction(function (tx) {
        txtSelectStatement = "SELECT strftime('%Y-%m-%d %H:%M:%f', val.entry_date, 'localtime') as entry_date, ROUND(TOTAL(val.value), fields.precision) as value \
                              FROM monitor_items_values as val \
                              LEFT OUTER JOIN monitor_items_fields fields \
                              ON val.field_id = fields.field_id \
                              AND val.item_id = fields.item_id \
                              WHERE val.profile_id = ? \
                              AND val.item_id = ? \
                              AND datetime(val.entry_date, 'localtime') BETWEEN datetime(?) AND datetime(?) \
                              GROUP BY fields.field_id \
                              ORDER BY val.entry_date asc, fields.field_seq asc;"
        rs = tx.executeSql(txtSelectStatement,
                                   [intProfileId, txtItemId, txtxDateFrom, txtDateTo])
        arrResults.length = rs.rows.length

        for (var i = 0; i < rs.rows.length; i++) {
            arrResults[i] = rs.rows.item(i)
        }
    })

    return arrResults
}

function getAverageFromValues(intProfileId, txtItemId, txtxDateFrom, txtDateTo, txtGrouping) {
    var db = openDB()
    var arrResults = []
    var rs = null
    var txtSelectStatement, txtGroupBy, txtOrderBy, txtGroupSelect, txtMainSelect,txtFromWhere

    txtMainSelect = "SELECT strftime('%Y-%m-%d %H:%M:%f', val.entry_date, 'localtime') as entry_date, ROUND(AVG(val.value), fields.precision) as value, fields.precision"
    txtFromWhere = "FROM monitor_items_values as val \
                    LEFT OUTER JOIN monitor_items_fields fields \
                    ON val.field_id = fields.field_id \
                    AND val.item_id = fields.item_id \
                    WHERE val.profile_id = ? \
                    AND val.item_id = ? \
                    AND datetime(val.entry_date, 'localtime') BETWEEN datetime(?) AND datetime(?)"
    txtGroupBy = "GROUP BY fields.field_id"
    txtOrderBy = "ORDER BY val.entry_date asc, fields.field_seq asc"

    switch (txtGrouping) {
        case "day":
            txtGroupSelect = "SELECT entry_date, ROUND(AVG(value), precision) as value FROM ("
            txtMainSelect = "SELECT strftime('%Y-%m-%d %H:%M:%f', val.entry_date, 'localtime') as entry_date, ROUND(TOTAL(val.value), fields.precision) as value, fields.precision"
            txtGroupBy = txtGroupBy + ", date(val.entry_date, 'localtime')"
            break;
    }

    txtSelectStatement = (txtGroupSelect ? txtGroupSelect + " " : "") + txtMainSelect + " " + txtFromWhere + " " + txtGroupBy + " " + txtOrderBy + (txtGroupSelect ? ")" : "")

    db.transaction(function (tx) {
        
        rs = tx.executeSql(txtSelectStatement,
                                   [intProfileId, txtItemId, txtxDateFrom, txtDateTo])
        arrResults.length = rs.rows.length

        for (var i = 0; i < rs.rows.length; i++) {
            arrResults[i] = rs.rows.item(i)
        }
    })

    return arrResults
}

function getLastValue(intProfileId, txtItemId, txtxDateFrom, txtDateTo, txtGrouping) {
    var db = openDB()
    var arrResults = []
    var rs = null
    var txtSelectStatement

    db.transaction(function (tx) {
        txtSelectStatement = "SELECT strftime('%Y-%m-%d %H:%M:%f', valu.entry_date, 'localtime') as entry_date, valu.value \
                            FROM monitor_items_values valu \
                            , (SELECT val.profile_id, val.item_id, MAX(val.entry_date) as entry_date, val.value \
                            FROM monitor_items_values as val \
                            LEFT OUTER JOIN monitor_items_fields fields \
                            ON val.field_id = fields.field_id \
                            AND val.item_id = fields.item_id \
                            WHERE val.profile_id = ? \
                            AND val.item_id = ? \
                            AND fields.field_seq = 1 \
                            AND datetime(val.entry_date, 'localtime') BETWEEN datetime(?) AND datetime(?) \
                            GROUP BY fields.field_id) max \
							LEFT OUTER JOIN monitor_items_fields fd \
                            ON valu.field_id = fd.field_id \
                            AND valu.item_id = fd.item_id \
                            WHERE max.profile_id = valu.profile_id \
                            AND max.entry_date = valu.entry_date \
                            AND max.item_id = valu.item_id \
                            ORDER BY fd.field_seq asc;"
        rs = tx.executeSql(txtSelectStatement,
                                   [intProfileId, txtItemId, txtxDateFrom, txtDateTo])
        arrResults.length = rs.rows.length

        for (var i = 0; i < rs.rows.length; i++) {
            arrResults[i] = rs.rows.item(i)
        }
    })

    return arrResults
}

function getHighestValue(intProfileId, txtItemId, txtxDateFrom, txtDateTo, txtGrouping) {
    var db = openDB()
    var arrResults = []
    var rs = null
    var txtSelectStatement

    db.transaction(function (tx) {
        txtSelectStatement = "SELECT strftime('%Y-%m-%d %H:%M:%f', valu.entry_date, 'localtime') as entry_date, valu.value \
                            FROM monitor_items_values valu \
                            , (SELECT val.profile_id, val.item_id, val.entry_date, MAX(val.value) as maxValue \
                            FROM monitor_items_values as val \
                            LEFT OUTER JOIN monitor_items_fields fields \
                            ON val.field_id = fields.field_id \
                            AND val.item_id = fields.item_id \
                            WHERE val.profile_id = ? \
                            AND val.item_id = ? \
                            AND fields.field_seq = 1 \
                            AND datetime(val.entry_date, 'localtime') BETWEEN datetime(?) AND datetime(?) \
                            GROUP BY fields.field_id) max \
							LEFT OUTER JOIN monitor_items_fields fd \
                            ON valu.field_id = fd.field_id \
                            AND valu.item_id = fd.item_id \
                            WHERE max.profile_id = valu.profile_id \
                            AND max.entry_date = valu.entry_date \
                            AND max.item_id = valu.item_id \
                            ORDER BY fd.field_seq asc;"
        rs = tx.executeSql(txtSelectStatement,
                                   [intProfileId, txtItemId, txtxDateFrom, txtDateTo])
        arrResults.length = rs.rows.length

        for (var i = 0; i < rs.rows.length; i++) {
            arrResults[i] = rs.rows.item(i)
        }
    })

    return arrResults
}

function getExpenses(mode, sort, dateFilter1, dateFilter2) {
    var db = openDB()
    var arrResults = []
    var rs = null
    var txtSelectStatement = ""
    var txtWhereStatement = ""
    var txtOrderStatement = ""
    var txtSelectView = "expenses_vw"

    switch (mode) {
    case "Today":
        txtSelectView = "expenses_today"
        break
    case "Yesterday":
        txtSelectView = "expenses_yesterday"
        break
    case "This Week":
        txtSelectView = "expenses_thisweek"
        break
    case "This Month":
        txtSelectView = "expenses_thismonth"
        break
    case "Recent":
        txtSelectView = "expenses_recent"
        break
    case "Last Week":
        txtSelectView = "expenses_lastweek"
        break
    case "Last Month":
        txtSelectView = "expenses_lastmonth"
        break
    case "Calendar (By Day)":
        txtWhereStatement = " WHERE date(date) = date(?,'localtime')"
        break
    case "Calendar (By Week)":
        txtWhereStatement = " WHERE date(date) BETWEEN date(?,'localtime') AND date(?, 'localtime')"
        break
    case "Calendar (By Month)":
        txtWhereStatement = " WHERE date(date) BETWEEN date(?, 'localtime') AND date(?,'localtime')"
        break
    case "Calendar (Custom)":
        txtWhereStatement = " WHERE date(date) BETWEEN date(?, 'localtime') AND date(?,'localtime')"
        break
    default:
        txtWhereStatement = ""
        break
    }

    switch (sort) {
    case "Category":
        txtOrderStatement = " ORDER BY category_name, date desc, name"
        break
    default:
        txtOrderStatement = " ORDER BY date desc, category_name, name"
        break
    }

    txtSelectStatement = 'SELECT expense_id, category_name, name, descr, date, value, home_currency, travel_currency, rate, travel_value FROM '
    txtSelectStatement = txtSelectStatement + txtSelectView + txtWhereStatement + txtOrderStatement

//    console.log(txtSelectStatement)
    db.transaction(function (tx) {
        if (mode.search("Calendar") === -1) {
            rs = tx.executeSql(txtSelectStatement)
        } else {
            //            console.log(mode + txtSelectStatement + dateFilter1 + dateFilter2)
            if (mode.search("Day") === -1) {
                rs = tx.executeSql(txtSelectStatement,
                                   [dateFilter1, dateFilter2])
            } else {
                rs = tx.executeSql(txtSelectStatement, dateFilter1)
            }
        }

        arrResults.length = rs.rows.length

        for (var i = 0; i < rs.rows.length; i++) {
            arrResults[i] = rs.rows.item(i)
        }
    })

    return arrResults
}



function getExpenseAutoComplete(txtString) {
    var db = openDB()
    var arrResults = []
    var rs = null
    var txtSelectStatement = ""
    var txtWhereStatement = ""
    var txtOrderStatement = ""
    var txtGroupStatement = ""
    var txtContainString = ""

    txtContainString = "%" + txtString + "%"

    txtSelectStatement = 'SELECT name, value, count(*) as total FROM expenses '
    txtWhereStatement = " where name LIKE ?"
    txtOrderStatement = " ORDER BY total desc limit 4"
    txtGroupStatement = " GROUP BY name,value"

    txtSelectStatement = txtSelectStatement + txtWhereStatement
            + txtGroupStatement + txtOrderStatement

    //console.log(txtSelectStatement)
    db.transaction(function (tx) {
        rs = tx.executeSql(txtSelectStatement, [txtContainString])

        arrResults.length = rs.rows.length

        //console.log("statement: " + txtSelectStatement + " - " +  txtContainString + ": results: " + arrResults.length)
        for (var i = 0; i < rs.rows.length; i++) {
            arrResults[i] = rs.rows.item(i)
        }
    })
    return arrResults
}


function getExpenseTrend(range, mode, category, exception, dateFilter1, dateFilter2) {
    var db = openDB()
    var arrResults = []
    var rs = null
    var txtLabelDateFormat
    var txtSelectStatement = ""
    var txtSelectLabel = ""
    var txtWhereStatement = ""
    var txtGroupByStatement = ""
    var txtOrderStatement = ""

    txtSelectLabel = "strftime(?, date)"

    switch (range) {
    case "This Week":
        txtWhereStatement = " WHERE date(date) BETWEEN date('now','localtime','weekday 6','-6 days') AND date('now','localtime','weekday 6')"
        break
    case "This Month":
        txtWhereStatement = " WHERE date(date) BETWEEN date('now', 'localtime', 'start of month')  AND date('now','start of month','+1 month','-1 day')"
        break
    case "This Year":
        txtWhereStatement = " WHERE date(date) BETWEEN date('now', 'localtime', 'start of year') AND date('now','start of year','+1 year','-1 day')"
        break
    case "Recent":
        txtWhereStatement = " WHERE date(date) BETWEEN date('now','-6 day','localtime') AND date('now','localtime')"
        break
    case "Last Week":
        txtWhereStatement = " WHERE date(date) BETWEEN date('now','localtime','weekday 6', '-13 days') AND date('now','localtime','weekday 6', '-7 days')"
        break
    case "Last Month":
        txtWhereStatement = " WHERE date(date) BETWEEN date('now', '-1 month','localtime','start of month') AND date('now','localtime','start of month','-1 day')"
        break
    case "Last Year":
        txtWhereStatement = " WHERE date(date) BETWEEN date('now', '-1 year','localtime','start of year') AND date('now','localtime','start of year','-1 day')"
        break
    case "Calendar (By Week)":
        txtWhereStatement = " WHERE date(date) BETWEEN date(?,'localtime') AND date(?, 'localtime')"
        break
    case "Calendar (By Month)":
        txtWhereStatement = " WHERE date(date) BETWEEN date(?, 'localtime') AND date(?,'localtime')"
        break
    case "Calendar (By Year)":
        txtWhereStatement = " WHERE date(date) BETWEEN date(?, 'localtime') AND date(?,'localtime')"
        break
    case "Calendar (Custom)":
        txtWhereStatement = " WHERE date(date) BETWEEN date(?, 'localtime') AND date(?,'localtime')"
        break
    default:
        txtWhereStatement = ""
        break
    }

    switch (mode) {
    case "Day":
//        txtLabelDateFormat = "%d"
        txtSelectLabel = 'date'
        break
    case "Week":
        txtLabelDateFormat = "%W"
        break
    case "Month":
        txtLabelDateFormat = "%m"
        break
    default:
        txtLabelDateFormat = "%d"
        break
    }

    txtSelectStatement = 'SELECT ' + txtSelectLabel + ' as label, TOTAL(value) as  total from expenses'
    txtGroupByStatement = " GROUP BY label"
    txtOrderStatement = " ORDER BY label ASC"

    txtSelectStatement = txtSelectStatement + txtWhereStatement + txtGroupByStatement + txtOrderStatement

//    console.log(txtSelectStatement)
    db.transaction(function (tx) {
        if (range.search("Calendar") === -1) {
            if(mode === "Day"){
                rs = tx.executeSql(txtSelectStatement)
            }else{
                rs = tx.executeSql(txtSelectStatement,txtLabelDateFormat)
            }
        } else {
            if(mode === "Day"){
                rs = tx.executeSql(txtSelectStatement,
                                   [dateFilter1, dateFilter2])
            }else{
                rs = tx.executeSql(txtSelectStatement,
                                   [txtLabelDateFormat, dateFilter1, dateFilter2])
            }
        }

        arrResults.length = rs.rows.length

        for (var i = 0; i < rs.rows.length; i++) {
            arrResults[i] = rs.rows.item(i)
        }
    })

    return arrResults
}


function getExpenseBreakdown(range, category, exception, dateFilter1, dateFilter2) {
    var db = openDB()
    var arrResults = []
    var rs = null
    var txtLabelDateFormat
    var txtSelectStatement = ""
    var txtWhereStatement = ""
    var txtWhereAndStatement = ""
    var txtGroupByStatement = ""
    var txtOrderStatement = ""


    switch (range) {
    case "Today":
        txtWhereStatement = " WHERE date(date) = date('now','localtime')"
        break
    case "Yesterday":
        txtWhereStatement = " WHERE date(date) = date('now','-1 day','localtime') "
        break
    case "This Week":
        txtWhereStatement = " WHERE date(date) BETWEEN date('now','localtime','weekday 6','-6 days') AND date('now','localtime','weekday 6')"
        break
    case "This Month":
        txtWhereStatement = " WHERE date(date) BETWEEN date('now', 'localtime', 'start of month')  AND date('now','start of month','+1 month','-1 day')"
        break
    case "This Year":
        txtWhereStatement = " WHERE date(date) BETWEEN date('now', 'localtime', 'start of year') AND date('now','start of year','+1 year','-1 day')"
        break
    case "Recent":
        txtWhereStatement = " WHERE date(date) BETWEEN date('now','-6 day','localtime') AND date('now','localtime')"
        break
    case "Last Week":
        txtWhereStatement = " WHERE date(date) BETWEEN date('now','localtime','weekday 6', '-13 days') AND date('now','localtime','weekday 6', '-7 days')"
        break
    case "Last Month":
        txtWhereStatement = " WHERE date(date) BETWEEN date('now', '-1 month','localtime','start of month') AND date('now','localtime','start of month','-1 day')"
        break
    case "Last Year":
        txtWhereStatement = " WHERE date(date) BETWEEN date('now', '-1 year','localtime','start of year') AND date('now','localtime','start of year','-1 day')"
        break
    case "Calendar (By Week)":
        txtWhereStatement = " WHERE date(date) BETWEEN date(?,'localtime') AND date(?, 'localtime')"
        break
    case "Calendar (By Month)":
        txtWhereStatement = " WHERE date(date) BETWEEN date(?, 'localtime') AND date(?,'localtime')"
        break
    case "Calendar (By Year)":
        txtWhereStatement = " WHERE date(date) BETWEEN date(?, 'localtime') AND date(?,'localtime')"
        break
    case "Calendar (Custom)":
        txtWhereStatement = " WHERE date(date) BETWEEN date(?, 'localtime') AND date(?,'localtime')"
        break
    default:
        txtWhereStatement = ""
        break
    }

    txtSelectStatement = 'SELECT exp.category_name as category, cat.color as color, TOTAL(exp.value) as value FROM expenses exp, categories cat'
    txtWhereAndStatement = " AND exp.category_name = cat.category_name"
    txtGroupByStatement = " GROUP BY cat.category_name"
    txtOrderStatement = " ORDER BY cat.category_name ASC"

    txtSelectStatement = txtSelectStatement + txtWhereStatement + txtWhereAndStatement + txtGroupByStatement + txtOrderStatement

//    console.log(txtSelectStatement)
    db.transaction(function (tx) {

        if (range.search("Calendar") === -1) {
           rs = tx.executeSql(txtSelectStatement)
        } else {
            if(mode.search("Day") === -1){
                rs = tx.executeSql(txtSelectStatement, [dateFilter1,dateFilter2])
            }else{
                rs = tx.executeSql(txtSelectStatement, dateFilter1)
            }
        }

        arrResults.length = rs.rows.length

        for (var i = 0; i < rs.rows.length; i++) {
            arrResults[i] = rs.rows.item(i)
        }
    })

    return arrResults
}

function saveExpense(txtCategory, txtName, txtDescr, txtDate, realValue, travelData) {
    var txtSaveStatement
    var db = openDB()
    var rs = null
    var newID
    var newChecklist

    txtSaveStatement = 'INSERT INTO expenses(category_name,name,descr,date,value) VALUES(?,?,?,?,?)'

    db.transaction(function (tx) {
        tx.executeSql(txtSaveStatement,
                      [txtCategory, txtName, txtDescr, txtDate, realValue])

        rs = tx.executeSql("SELECT MAX(expense_id) as id FROM expenses")
        newID = rs.rows.item(0).id
        //Save Travel Data
        if(travelData){
            saveTravelExpense(newID, travelData.homeCur, travelData.travelCur, travelData.rate, travelData.value)
        }
        newChecklist = {
            expense_id: newID,
            category_name: txtCategory,
            name: txtName,
            descr: txtDescr,
            date: txtDate,
            value: realValue,
            travel: travelData
        }
    })


    return newChecklist
}

function updateExpense(id, category, name, descr, date, value, travelData) {
    var db = openDB()

    db.transaction(function (tx) {
        tx.executeSql(
                    "UPDATE expenses SET category_name = ?, name = ?, descr = ?, date = ?, value = ? WHERE expense_id = ?",
                    [category, name, descr, date, value, id])
    })

    //Update Travel Data
    if(travelData){
        updateTravelExpense(id, travelData.homeCur, travelData.travelCur, travelData.rate, travelData.value)
    }
}

function deleteExpense(id) {
    var txtDeleteStatement
    var db = openDB()

    txtDeleteStatement = 'DELETE FROM expenses WHERE expense_id = ?'

    db.transaction(function (tx) {
        tx.executeSql(txtDeleteStatement, [id])
    })

    //Delete Travel Data
    deleteTravelExpense(id)
}


//Travel Data
function getTravelData(id) {
    var db = openDB()
    var arrResults = []
    var rs = null

    db.transaction(function (tx) {
        rs = tx.executeSql("SELECT * FROM travel_expenses WHERE expense_id = ?", [id])
        arrResults.length = rs.rows.length

        for (var i = 0; i < rs.rows.length; i++) {
            //add new row in the array
            arrResults[i] = []

            //assign values to the array
            arrResults[i] = rs.rows.item(i)
        }
    })

    return arrResults[0]
}

function saveTravelExpense(id, homeCurrency, travelCurrency, rate, value ) {
    var txtSaveStatement
    var db = openDB()
    var rs = null
    var newID
    var newChecklist

    txtSaveStatement = 'INSERT INTO travel_expenses(expense_id,home_currency,travel_currency,rate,value) VALUES(?,?,?,?,?)'

    db.transaction(function (tx) {
        tx.executeSql(txtSaveStatement,
                      [id, homeCurrency, travelCurrency, rate, value])
    })
}

function updateTravelExpense(id, homeCurrency, travelCurrency, rate, value) {
    var db = openDB()

    db.transaction(function (tx) {
        tx.executeSql(
                    "UPDATE travel_expenses SET home_currency = ?, travel_currency = ?, rate = ?, value = ? WHERE expense_id = ?",
                    [homeCurrency, travelCurrency, rate, value, id])
    })
}

function deleteTravelExpense(id) {
    var txtDeleteStatement
    var db = openDB()

    txtDeleteStatement = 'DELETE FROM travel_expenses WHERE expense_id = ?'

    db.transaction(function (tx) {
        tx.executeSql(txtDeleteStatement, [id])
    })
}

function getCategories() {
    var db = openDB()
    var arrResults = []
    var rs = null
    var txtSelectStatement = ""

    txtSelectStatement = "SELECT category_name, descr, icon, color FROM categories"

    db.transaction(function (tx) {
        rs = tx.executeSql(txtSelectStatement)

        arrResults.length = rs.rows.length

        for (var i = 0; i < rs.rows.length; i++) {
            arrResults[i] = rs.rows.item(i)
        }
    })
    return arrResults
}

function saveCategory(txtName, txtDescr, txtIcon, txtColor) {
    var txtSaveStatement
    var db = openDB()
    txtSaveStatement = 'INSERT INTO categories(category_name,descr,icon,color) VALUES(?,?,?,?)'

    db.transaction(function (tx) {
        tx.executeSql(txtSaveStatement, [txtName, txtDescr, txtIcon, txtColor])
    })
}

function categoryExist(category) {
    var db = openDB()
    var rs = null
    var exists

    db.transaction(function (tx) {
        rs = tx.executeSql("SELECT * FROM categories WHERE category_name = ?", [category])

        exists = rs.rows.length === 0 ? false : true
    })

    return exists
}

function deleteCategory(txtCategory) {
    var txtDeleteStatement, txtUpdateExpensesStatement
    var txtNewCategory = "Uncategorized"
    var db = openDB()

    txtDeleteStatement = 'DELETE FROM categories WHERE category_name = ?'
    txtUpdateExpensesStatement = 'UPDATE expenses SET category_name = ? WHERE category_name = ?'

    db.transaction(function (tx) {
        tx.executeSql(txtUpdateExpensesStatement,
                      [txtNewCategory, txtCategory])
        tx.executeSql(txtDeleteStatement, [txtCategory])
    })
}

function updateCategory(txtName, txtNewName, txtDescr, txtIcon, txtColor) {
    var db = openDB()

    db.transaction(function (tx) {
        tx.executeSql("UPDATE expenses SET category_name = ? WHERE category_name = ?",
                      [txtNewName, txtName])
        tx.executeSql(
                    "UPDATE categories SET category_name = ?, descr = ?, icon = ?, color= ? WHERE category_name = ?",
                    [txtNewName, txtDescr, txtIcon, txtColor, txtName])
    })
}


function getReports() {
    var db = openDB()
    var arrResults = []
    var rs = null
    var txtSelectStatement = ""

    txtSelectStatement = "SELECT * FROM reports"

    db.transaction(function (tx) {
        rs = tx.executeSql(txtSelectStatement)

        arrResults.length = rs.rows.length

        for (var i = 0; i < rs.rows.length; i++) {
            arrResults[i] = rs.rows.item(i)
        }
    })
    return arrResults
}

function saveReport(txtName, txtDescr, txtIcon, txtColor) {
    var txtSaveStatement
    var db = openDB()
    txtSaveStatement = 'INSERT INTO categories(category_name,descr,icon,color) VALUES(?,?,?,?)'

    db.transaction(function (tx) {
        tx.executeSql(txtSaveStatement, [txtName, txtDescr, txtIcon, txtColor])
    })
}

function reportExist(category) {
    var db = openDB()
    var rs = null
    var exists

    db.transaction(function (tx) {
        rs = tx.executeSql("SELECT * FROM categories WHERE category_name = ?", [category])

        exists = rs.rows.length === 0 ? false : true
    })

    return exists
}

function deleteReport(intReportID) {
    var txtDeleteStatement
    var db = openDB()

    txtDeleteStatement = 'DELETE FROM reports WHERE report_id = ?'

    db.transaction(function (tx) {
        tx.executeSql(txtDeleteStatement, [intReportID])
    })
}

function updateReport(txtName, txtNewName, txtDescr, txtIcon, txtColor) {
    var db = openDB()

    db.transaction(function (tx) {
        tx.executeSql("UPDATE expenses SET category_name = ? WHERE category_name = ?",
                      [txtNewName, txtName])
        tx.executeSql(
                    "UPDATE categories SET category_name = ?, descr = ?, icon = ?, color= ? WHERE category_name = ?",
                    [txtNewName, txtDescr, txtIcon, txtColor, txtName])
    })
}

function getQuickExpenses(searchText) {
    var db = openDB()
    var arrResults = []
    var rs = null
    var txtSelectStatement = ""
    var txtWhereStatement = ""
    var txtOrderStatement = ""

    txtOrderStatement = " ORDER BY name asc"

    txtSelectStatement = 'SELECT quick_id, category_name, name, descr, value FROM quick_expenses'
    if(searchText){
        txtWhereStatement = " WHERE category_name LIKE ? OR name LIKE ? OR descr LIKE ?"
    }

    txtSelectStatement = txtSelectStatement + txtWhereStatement + txtOrderStatement
//    console.log(txtSelectStatement)
    db.transaction(function (tx) {
        if(searchText){
            var wildcard = "%" + searchText + "%"
            rs = tx.executeSql(txtSelectStatement,[wildcard,wildcard,wildcard])
        }else{
            rs = tx.executeSql(txtSelectStatement)
        }

        arrResults.length = rs.rows.length

        for (var i = 0; i < rs.rows.length; i++) {
            arrResults[i] = rs.rows.item(i)
        }
    })

    return arrResults
}

function saveQuickExpense(txtCategory, txtName, txtDescr, realValue) {
    var txtSaveStatement
    var db = openDB()
    var rs = null
    var newID
    var newQuickExpense

    txtSaveStatement = 'INSERT INTO quick_expenses(category_name,name,descr,value) VALUES(?,?,?,?)'

    db.transaction(function (tx) {
        tx.executeSql(txtSaveStatement,
                      [txtCategory, txtName, txtDescr, realValue])
        rs = tx.executeSql("SELECT MAX(quick_id) as id FROM quick_expenses")
        newID = rs.rows.item(0).id
        newQuickExpense = {
            quick_id: newID,
            category_name: txtCategory,
            quickname: txtName,
            descr: txtDescr,
            quickvalue: realValue
        }
    })

    return newQuickExpense
}

function updateQuickExpense(id, category, name, descr, value) {
    var db = openDB()
    var updatedQuickExpense

    db.transaction(function (tx) {
        tx.executeSql(
                    "UPDATE quick_expenses SET category_name = ?, name = ?, descr = ?, value = ? WHERE quick_id = ?",
                    [category, name, descr, value, id])
    })

    updatedQuickExpense = {
        quick_id: id,
        category_name: category,
        quickname: name,
        descr: descr,
        quickvalue: value
    }

    return updatedQuickExpense
}

function deleteQuickExpense(id) {
    var txtDeleteStatement
    var db = openDB()

    txtDeleteStatement = 'DELETE FROM quick_expenses WHERE quick_id = ?'

    db.transaction(function (tx) {
        tx.executeSql(txtDeleteStatement, [id])
    })
}

function getRecentExpenses(searchText) {
    var db = openDB()
    var arrResults = []
    var rs = null
    var txtSelectStatement = ""
    var txtWhereStatement = ""
    var txtOrderStatement = ""
    var txtLimitStatement = ""
    var intTop

    txtOrderStatement = " ORDER BY a.date desc, a.expense_id desc"

    txtSelectStatement = "SELECT a.expense_id, a.category_name, a.name, a.descr, a.date, a.value, b.home_currency, b.travel_currency, IFNULL(b.rate, 0) as 'rate', IFNULL(b.value, 0) as 'travel_value' FROM expenses a LEFT OUTER JOIN travel_expenses b USING(expense_id)"
    txtLimitStatement = " LIMIT ?"

    if(searchText){
        intTop = 20
        txtWhereStatement = " WHERE a.category_name LIKE ? OR a.name LIKE ? OR a.descr LIKE ?"
        txtSelectStatement = txtSelectStatement + txtWhereStatement + txtOrderStatement + txtLimitStatement
    }else{
        intTop = 10
        txtSelectStatement = txtSelectStatement + txtOrderStatement + txtLimitStatement
    }

    //console.log(txtSelectStatement)
    db.transaction(function (tx) {

        if(searchText){
            var wildcard = "%" + searchText + "%"
            rs = tx.executeSql(txtSelectStatement,[wildcard,wildcard,wildcard,intTop])
        }else{
            rs = tx.executeSql(txtSelectStatement,[intTop])
        }

        arrResults.length = rs.rows.length

        for (var i = 0; i < rs.rows.length; i++) {
            arrResults[i] = rs.rows.item(i)
        }
    })


    return arrResults
}

function getTopExpenses() {
    var db = openDB()
    var arrResults = []
    var rs = null
    var txtSelectStatement = ""
    var txtWhereStatement = ""
    var txtOrderStatement = ""
    var txtGroupStatement = ""
    var txtLimitStatement = ""
    var intTop = 10

    txtOrderStatement = " ORDER BY count desc"
    txtGroupStatement = " GROUP BY a.name, a.category_name, a.value, b.home_currency, b.travel_currency, IFNULL(b.rate, 0), IFNULL(b.value, 0)"
    txtSelectStatement = "SELECT a.name, a.category_name, a.value, b.home_currency, b.travel_currency, IFNULL(b.rate, 0) as 'rate', IFNULL(b.value, 0) as 'travel_value', COUNT(*) as count FROM expenses a LEFT OUTER JOIN travel_expenses b USING(expense_id)"
    txtLimitStatement = " LIMIT " + intTop
    txtSelectStatement = txtSelectStatement + txtWhereStatement + txtGroupStatement + txtOrderStatement + txtLimitStatement
    //console.log(txtSelectStatement)
    db.transaction(function (tx) {
        rs = tx.executeSql(txtSelectStatement)

        arrResults.length = rs.rows.length

        for (var i = 0; i < rs.rows.length; i++) {
            arrResults[i] = rs.rows.item(i)
        }
    })

    return arrResults
}


function getCurrencies() {
    var db = openDB()
    var arrResults = []
    var rs = null
    var txtSelectStatement = ""

    txtSelectStatement = "SELECT * FROM currencies"

    db.transaction(function (tx) {
        rs = tx.executeSql(txtSelectStatement)

        arrResults.length = rs.rows.length

        for (var i = 0; i < rs.rows.length; i++) {
            arrResults[i] = rs.rows.item(i)
        }
    })
    return arrResults
}