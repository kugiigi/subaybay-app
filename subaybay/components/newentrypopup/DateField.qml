import QtQuick 2.12
import QtQuick.Controls 2.5
import QtQuick.Controls.Suru 2.2
import Ubuntu.Components 1.3 as UT
import Ubuntu.Components.Pickers 1.3
import QtQuick.Layouts 1.12
import "../common"
import "../../library/functions.js" as Functions


ColumnLayout {
    id: dateField
  
    property alias checkState: dateCheckBox.checkState
    property date dateValue: new Date()
    readonly property bool checked: checkState == Qt.Checked

    spacing: 5
  
    RowLayout {
        Layout.fillWidth: true
        spacing: 0

        CheckDelegate {
            id: dateCheckBox
        
            Layout.fillWidth: true
            Layout.fillHeight: true
            text: i18n.tr("Use current date and time")
            checkState: Qt.Checked
            onCheckStateChanged: {
                if (checkState !== Qt.Checked) {
                    dateField.dateValue = new Date()
                }
            }
        }
        
        ActionButton {
            id: addMoreButton

            Layout.preferredWidth: Suru.units.gu(5)
            Layout.fillHeight: true

            iconName: "add"
            color: Suru.backgroundColor
            visible: otherItemsMenu.model.count !== fieldsModel.model.count && !newEntryPopup.editMode
            onClicked: otherItemsMenu.popup(addMoreButton)

            SeparatorLine {
                anchors.bottom: parent.bottom
                width: parent.width
            }
        }
    }
  
    RowLayout {
        Layout.fillWidth: true
        Layout.leftMargin: 20
        Layout.rightMargin: 20

        spacing: 10
        visible: dateCheckBox.checkState == Qt.Unchecked
  
        CustomButton {
            id: dateButton
      
            Layout.fillWidth: true
            
            focusPolicy: Qt.StrongFocus
      
            contentItem: CustomLabel {
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                text: Qt.formatDateTime(dateField.dateValue, "dddd, MMMM d, yyyy")
                font.italic: true
                role: "date"
            }
            onClicked: {
                highlighted = true
                dateTimeDialog.openDialog(dateButton, "Months|Days|Years", dateField.dateValue)
            }
        }
      
        CustomButton {
            id: timeButton
      
            property date currentDate: new Date()
            
            focusPolicy: Qt.StrongFocus
      
            Layout.fillWidth: true
            contentItem: CustomLabel {
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                text: Qt.formatDateTime(dateField.dateValue, "hh:mm ap")
                font.italic: true
                role: "date"
            }
                          
            onClicked: {
                highlighted = true
                dateTimeDialog.openDialog(timeButton, "Hours|Minutes", dateField.dateValue)
            }
        }
    }
    
    Dialog {
        id: dateTimeDialog
      
        property var caller

        parent: mainView.corePage
      
        standardButtons: Dialog.Ok | Dialog.Cancel
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
        width: parent.width
        height: 250
        y: parent.height - height

        onAccepted: dateField.dateValue = dateTimePicker.date
        onClosed: caller.highlighted = false

        function openDialog(caller, mode, date) {
            dateTimePicker.mode = mode
            dateTimePicker.date = date
            dateTimeDialog.caller = caller
            open()
        }

        DatePicker {
            id: dateTimePicker
        
            anchors.centerIn: parent
        }
    }
}