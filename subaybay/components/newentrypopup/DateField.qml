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
    property bool showToggle
    readonly property bool checked: checkState == Qt.Checked

    spacing: 5
  
    RowLayout {
        Layout.fillWidth: true
        spacing: 0
        visible: dateField.showToggle

        ItemDelegate {
            Layout.fillWidth: true
            Layout.fillHeight: true
            CheckBox {
                id: dateCheckBox
                text: i18n.tr("Use current date and time")
                checkState: Qt.Checked
                anchors {
                    leftMargin: Suru.units.gu(2)
                    fill: parent
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
            onClicked: otherItemsMenu.popup(addMoreButton, 0, addMoreButton.height)

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
                text: Functions.formatDate(dateField.dateValue, "ddd, MMMM DD, YYYY")
                font.italic: true
                role: "date"
            }

            onClicked: {
                highlighted = true
                var popup = datePickerComponent.createObject(mainView.corePage, {dateTime: dateField.dateValue})
                popup.accepted.connect(function() {
                    dateField.dateValue = popup.dateTime
                })
                popup.closed.connect(function() {
                    dateButton.highlighted = false
                })
                popup.open();
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
                text: Functions.formatDate(dateField.dateValue, "hh:mm A")
                font.italic: true
                role: "date"
            }
                          
            onClicked: {
                highlighted = true
                var popup = timePickerComponent.createObject(mainView.corePage, {hour: dateField.dateValue.getHours(), minute: dateField.dateValue.getMinutes(), fullDate: dateField.dateValue})
                popup.accepted.connect(function() {
                    var date = new Date(dateField.dateValue)
                    date.setHours(popup.hour);
                    date.setMinutes(popup.minute)
                    dateField.dateValue = date;
                })
                popup.closed.connect(function() {
                    timeButton.highlighted = false
                })
                popup.open();
            }
        }
    }

    Component {
        id: datePickerComponent
        DatePickerDialog {}
    }

    Component {
        id: timePickerComponent
        TimePickerDialog{}
    }
}
