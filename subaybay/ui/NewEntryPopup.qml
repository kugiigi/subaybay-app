import QtQuick 2.12
import QtQuick.Controls 2.5
import QtQuick.Controls.Suru 2.2
import Lomiri.Components 1.3 as UT
import QtQuick.Layouts 1.12
import "../components/newentrypopup"
import "../components/common"
import "../library/functions.js" as Functions

CustomPopup {
    id: newEntryPopup

    property alias activeItems: activeListModel
    property bool editMode: false
  
    standardButtons: Dialog.NoButton
    closePolicy: Popup.CloseOnEscape
    
    onOpened: {
        fieldsModel.itemAt(0).focusFirstField()
    }

    function openDialog(itemId, customDate) {
        editMode = false
        reset()
        
        if (Array.isArray(itemId)) {
            for (var i = 0; i < itemId.length; i++) {
                priv.addItem(otherItemsMenu.model.getItem(itemId[i], "itemId"))
            }
        } else {
            priv.addItem(otherItemsMenu.model.getItem(itemId, "itemId"))
        }

        if (customDate) {
            dateField.dateValue = Functions.convertDBToDate(customDate)
            dateField.checkState = Qt.Unchecked
        } else {
            dateField.dateValue = new Date()
            dateField.checkState = Qt.Checked
        }
        
        openPopup()
    }
    
    function openEdit(entryDate, itemId, comments, fields) {
        var value
        var currentItem, currentField
        
        editMode = true
        reset()

        // Set date/time fields to current values
        dateField.dateValue = Functions.convertDBToDate(entryDate)
        dateField.checkState = Qt.Unchecked

        priv.addItem(otherItemsMenu.model.getItem(itemId, "itemId"))
        priv.editEntryDate = entryDate
        priv.editItemId = itemId
        currentItem = fieldsModel.itemAt(0)

        for (var i = 0; i < fields.count; i++) {
            currentField = currentItem.fieldsRepeater.itemAt(i)
            value = fields.get(i).value
            
            currentField.valueField.text = value
            
            if (i == 0) {
                currentField.valueField.focus
            }
        }

        priv.origComments = comments
        commentTextArea.text = comments

        openPopup()
    }
    
    function reset() {
        // Reset values
        activeItems.clear()
        dateField.checkState = Qt.Checked
        commentTextArea.text = ""
    }
    
    QtObject {
        id: priv
        
        property string editEntryDate
        property bool entryMultiple: mainView.values.entryDateMultiple(editEntryDate, editItemId)
        property date entryDate
        property string editItemId
        property string origComments

        function submitData() {
            keyboard.target.commit()

            var entryDate
            var comments = commentTextArea.text
            var fieldId, itemId, value
            var currentItem, currentField
            var valuesToSave = []


            if (newEntryPopup.editMode) {
                if (dateField.dateModified) {
                    entryDate = Functions.formatDateForDB(dateField.dateValue)
                } else {
                    entryDate = priv.editEntryDate
                }
            } else {
                entryDate = dateField.checked ? new Date() : dateField.dateValue
                entryDate = Functions.formatDateForDB(entryDate)
            }

            for (var i = 0; i < fieldsModel.count; i++) {
                currentItem = fieldsModel.itemAt(i)
                itemId = currentItem.itemId

                for (var h = 0; h < currentItem.fieldsRepeater.count; h++) {
                    currentField = currentItem.fieldsRepeater.itemAt(h)
                    fieldId = currentField.fieldId
                    value = currentField.value

                    if (value) {
                        valuesToSave.push({fieldId: fieldId, itemId: itemId, value: value})
                    } else {
                        currentField.valueField.focus = true
                        return "empty"
                    }
                }
            }
            
            for (var k = 0; k < valuesToSave.length; k++) {
                if (newEntryPopup.editMode) {
                    if (mainView.values.edit(priv.editEntryDate, valuesToSave[k].fieldId, valuesToSave[k].itemId, valuesToSave[k].value).success == false) {
                        return "database"
                    }
                } else {
                    if (mainView.values.add(entryDate, valuesToSave[k].fieldId, valuesToSave[k].itemId, valuesToSave[k].value).success == false) {
                        return "database"
                    }
                }
            }

            // Updates entry date when modified by the user
            if (dateField.dateModified) {
                if (mainView.values.editEntryDate(priv.editEntryDate, entryDate).success == false) {
                    return "database"
                }
            }

            if (comments) {
                if (newEntryPopup.editMode) {
                    return mainView.values.editComment(entryDate, comments).success
                } else {
                    return mainView.values.addComment(entryDate, comments).success
                }
            } else {
                if (origComments) {
                    return mainView.values.deleteComment(entryDate).success
                }
                return true
            }
        }

        function addItem(item) {
            newEntryPopup.activeItems.append(item)
        }
    }

    header: DateField {
        id: dateField

        readonly property bool dateModified: priv.editEntryDate != Functions.formatDateForDB(dateField.dateValue)

        showToggle: !newEntryPopup.editMode
    }

    footer: DialogButtonBox {
        CustomDialogButton {
            id: saveButton

            text: i18n.tr("Save")
            
            onClicked: {
                var result = priv.submitData()
                var tooltipMsg

                if (result == true) {
                    accept()
                    tooltipMsg = i18n.tr("Value saved")
                } else {
                    switch(result) {
                        case "database":
                            tooltipMsg = i18n.tr("Error saving data")
                            break;
                        case "empty":
                            tooltipMsg = i18n.tr("Fill up all required fields")
                            break;
                        default:
                            tooltipMsg = i18n.tr("Error")
                            break;
                    }
                }

                tooltip.display(tooltipMsg)
            }
        }

        CustomDialogButton {
            id: cancelButton

            text: i18n.tr("Cancel")

            onClicked: newEntryPopup.reject()
        }
    }

    ListModel {
        id: activeListModel

        function find(item) {
        		var i = 0
        
        		for (i = 0; i <= count - 1; i++) {
          			if (item.itemId == get(i).itemId) {
          				  return i
          			}
        		}
        	
        		return -1
      	}
    }
    
    Flickable {
        id: flickable
    
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }
        topMargin: 20
        clip: true
        contentHeight: columnLayout.height
  
        ColumnLayout {
            id: columnLayout
      
            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
            }
      
            spacing: 20

            Label {
                id: warningLabel

                visible: newEntryPopup.editMode && priv.entryMultiple && dateField.dateModified
                Layout.fillWidth: true
                Layout.leftMargin: Suru.units.gu(3)
                Layout.rightMargin: Suru.units.gu(3)
                text: i18n.tr("All entries with the same date/time will be updated")
                Suru.textLevel: Suru.Caption
            }

            Repeater {
                id: fieldsModel

                model: newEntryPopup.activeItems

                delegate: NewEntryItem {
                    Layout.fillWidth: true
                    Layout.leftMargin: 20
                    Layout.rightMargin: 20

                    itemIndex: model.index
                    itemId: model.itemId
                    title: model.displayName + " *"
                    fields: model.fields
                    removable: fieldsModel.model.count > 1

                    onRemove: {
                        activeItems.remove(index, 1)
                    }
                }
            }
            
            ColumnLayout {
                id: commentColumn

                Layout.fillWidth: true
                Layout.leftMargin: 20
                Layout.rightMargin: 20

                Label {
                    id: commentLabel

                    Layout.fillWidth: true
                    text: i18n.tr("Comments/Observations")
                    Suru.textLevel: Suru.HeadingThree
                }

                TextArea {
                    id: commentTextArea

                    function focusPrevious() {
                        var prevItem = commentTextArea.nextItemInFocusChain(false)
                        prevItem.focus = true
                    }

                    Layout.fillWidth: true
                    font.pixelSize: 15
                    Keys.onPressed: {
                        if (event.key == Qt.Key_Backspace && commentTextArea.text == "") {
                            focusPrevious()
                        }
                    }
                    Keys.onUpPressed: focusPrevious()
                    onFocusChanged: {
                        if (focus) {
                            Functions.scrollToView(this, flickable, commentLabel.height + commentColumn.spacing, 0)
                        }
                    }
                }
            }
        }
    }
    
    Menu {
        id: otherItemsMenu
        
        property alias model: menuItemRepeater.model
        
        Repeater {
            id: menuItemRepeater

            model: mainView.mainModels.monitorItemsFieldsModel
            
            delegate: MenuItem {
                text: model.displayName
                height: visible ? 60 : 0
                visible: newEntryPopup.activeItems.find(menuItemRepeater.model.get(index)) == -1
                onTriggered: {
                    priv.addItem(menuItemRepeater.model.get(index))
                }
            }
        }
    }
}
