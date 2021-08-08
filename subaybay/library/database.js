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
    var txtInsertStatement, txtUpdateStatement
    
    txtInsertStatement = 'INSERT INTO monitor_items_comments ("entry_date", "profile_id", "comments") \
                        VALUES(strftime("%Y-%m-%d %H:%M:%f", ?, "utc"),?,?)'
    txtUpdateStatement = "UPDATE monitor_items_comments SET comments = ? WHERE profile_id = ? \
                        AND strftime('%Y-%m-%d %H:%M:%f', entry_date, 'localtime') = strftime('%Y-%m-%d %H:%M:%f', ?)"

    try {
        db.transaction(function (tx) {
            if (checkCommentIfExist(txtEntryDate)) {
                tx.executeSql(
                            txtUpdateStatement,
                            [txtNewComments, intProfileId, txtEntryDate])
            } else {
                tx.executeSql(
                    txtInsertStatement,
                    [txtEntryDate, intProfileId, txtNewComments])
            }
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

function checkCommentIfExist(txtEntryDate) {
    var db = openDB()
    var rs = null
    var exists

    db.transaction(function (tx) {
        rs = tx.executeSql("SELECT * FROM monitor_items_comments WHERE strftime('%Y-%m-%d %H:%M:%f', entry_date, 'localtime') = strftime('%Y-%m-%d %H:%M:%f', ?)", [txtEntryDate])

        exists = rs.rows.length === 0 ? false : true
    })

    return exists
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
    var txtWhereStatement
    var txtOrderStatement
    var txtFullStatement
    var arrArgs = []
    //~ console.log (txtxDateFrom + " - " + txtDateTo)
    db.transaction(function (tx) {
        txtSelectStatement = "SELECT (strftime('%Y-%m-%d %H:%M:%f', val.entry_date, 'localtime')) as entry_date, items.display_name, val.item_id, val.value \
                              , com.comments, fields.field_id, fields.precision, fields.field_seq, units.display_symbol, items.display_format \
                              FROM monitor_items_values as val \
                              LEFT OUTER JOIN monitor_items_comments as com \
                              ON val.entry_date = com.entry_date \
                              AND val.profile_id = com.profile_id \
                              LEFT OUTER JOIN monitor_items_fields fields \
                              ON val.field_id = fields.field_id \
                              AND val.item_id = fields.item_id \
                              LEFT OUTER JOIN monitor_items items \
							  ON val.item_id = items.item_id \
                              LEFT OUTER JOIN units units \
							  ON fields.unit = units.name"
        txtWhereStatement = "WHERE val.profile_id = ? \
                              AND date(val.entry_date, 'localtime') BETWEEN date(?) AND date(?)"
        if (txtItemId !== "all") {
            txtWhereStatement = txtWhereStatement + " AND val.item_id = ?"
            arrArgs = [intProfileId, txtxDateFrom, txtDateTo, txtItemId]
        } else {
            arrArgs = [intProfileId, txtxDateFrom, txtDateTo]
        }
        txtOrderStatement = "ORDER BY val.entry_date asc, val.item_id asc, fields.field_seq asc;"

        txtFullStatement = txtSelectStatement + " " + txtWhereStatement + " " + txtOrderStatement
        rs = tx.executeSql(txtFullStatement,arrArgs)
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
