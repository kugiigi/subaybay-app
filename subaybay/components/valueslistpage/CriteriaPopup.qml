import QtQuick 2.12
import QtQuick.Controls 2.5
import QtQuick.Controls.Suru 2.2
import "../common"
import "../../library/functions.js" as Functions

CustomPopup {
    id: criteriaPopup
  
    property string activeItemId
    property date dateValue
    
    signal select(string selectedItemId, date selectedDate)
    
    standardButtons: Dialog.Ok | Dialog.Cancel
    
    onAccepted: select(activeItemId, dateValue)
    
    header: CustomButton {
        id: dateButton

        focusPolicy: Qt.StrongFocus

        contentItem: CustomLabel {
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            text: Functions.formatDate(criteriaPopup.dateValue, "ddd, MMMM DD, YYYY")
            font.italic: true
            font.pointSize: Suru.units.gu(2)
            role: "date"
        }

        onClicked: {
            highlighted = true
            var popup = datePickerComponent.createObject(mainView.corePage, {dateTime: criteriaPopup.dateValue})
            popup.accepted.connect(function() {
                criteriaPopup.dateValue = popup.dateTime
            })
            popup.closed.connect(function() {
                dateButton.highlighted = false
            })
            popup.open();
        }
    }

    Component {
        id: datePickerComponent
        DatePickerDialog {}
    }

    Item {
        anchors.fill: parent

        ButtonGroup {
            id: criteriaGroup
        }
        
        RadioDelegate {
            id: allRadioItem

            anchors {
               left: parent.left
               right: parent.right
            }
            text: i18n.tr("All")
            checked: criteriaPopup.activeItemId == "all"
            ButtonGroup.group: criteriaGroup
            
            onToggled: {
                if (checked) {
                    criteriaPopup.activeItemId = "all"
                }
            }

        }
  
        ListView {
            id: profilesListView
            
            clip: true
  
            model: mainView.mainModels.monitorItemsModel
            anchors {
                top: allRadioItem.bottom
                left: parent.left
                right: parent.right
                bottom: parent.bottom
            }
  
            delegate: RadioDelegate {
                id: radioDelegate
    
                anchors {
                   left: parent.left
                   right: parent.right
                }
                text: model.displayName
                checked: criteriaPopup.activeItemId == model.itemId
                ButtonGroup.group: criteriaGroup
                
                onToggled: {
                    if (checked) {
                        criteriaPopup.activeItemId = model.itemId
                    }
                }

            }
  
            Keys.onEscapePressed: criteriaPopup.close()
        }
    }
}
