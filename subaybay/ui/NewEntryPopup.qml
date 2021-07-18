import QtQuick 2.12
import QtQuick.Controls 2.5
import QtQuick.Controls.Suru 2.2
import Ubuntu.Components 1.3 as UT
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

    function openDialog(itemId) {
        editMode = false
        reset()
        
        if (Array.isArray(itemId)) {
            for (var i = 0; i < itemId.length; i++) {
                priv.addItem(otherItemsMenu.model.getItem(itemId[i], "itemId"))
            }
        } else {
            priv.addItem(otherItemsMenu.model.getItem(itemId, "itemId"))
        }
        
        openPopup()
    }
    
    function openEdit(entryDate, itemId, comments, fields) {
        var value
        var currentItem, currentField
        
        editMode = true
        reset()

        priv.addItem(otherItemsMenu.model.getItem(itemId, "itemId"))
        priv.editEntryDate = entryDate
        currentItem = fieldsModel.itemAt(0)
        for (var i = 0; i < fields.count; i++) {
            currentField = currentItem.fieldsRepeater.itemAt(i)
            value = fields.get(i).value
            
            currentField.valueField.text = value
            
            if (i == 0) {
                currentField.valueField.focus
            }
        }
        
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

        function submitData() {
            keyboard.target.commit()

            var entryDate
            var comments = commentTextArea.text
            var fieldId, itemId, value
            var currentItem, currentField
            var valuesToSave = []


            if (newEntryPopup.editMode) {
                entryDate = priv.editEntryDate
            } else {
                entryDate = dateField.checked ? new Date() : dateField.dateValue
            }

            entryDate = Functions.formatDateForDB(entryDate)

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
                    if (mainView.values.edit(entryDate, valuesToSave[k].fieldId, valuesToSave[k].itemId, valuesToSave[k].value).success == false) {
                        return "database"
                    }
                } else {
                    if (mainView.values.add(entryDate, valuesToSave[k].fieldId, valuesToSave[k].itemId, valuesToSave[k].value).success == false) {
                        return "database"
                    }
                }
            }

            if (comments) {
                if (newEntryPopup.editMode) {
                    return mainView.values.editComment(entryDate, comments).success
                } else {
                    return mainView.values.addComment(entryDate, comments).success
                }
            } else {
                return true
            }
        }

        function addItem(item) {
            newEntryPopup.activeItems.append(item)
        }
    }

    header: DateField {
        id: dateField

        visible: !newEntryPopup.editMode
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
      
            Repeater {
                id: fieldsModel

                model: newEntryPopup.activeItems

                delegate: NewEntryItem {
                    Layout.fillWidth: true
                    Layout.leftMargin: 20
                    Layout.rightMargin: 20

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
                Layout.fillWidth: true
                Layout.leftMargin: 20
                Layout.rightMargin: 20

                Label {
                    Layout.fillWidth: true
                    text: i18n.tr("Comments/Observations")
                    Suru.textLevel: Suru.HeadingThree
                }

                TextArea {
                    id: commentTextArea
            
                    Layout.fillWidth: true
                    font.pixelSize: 15
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
