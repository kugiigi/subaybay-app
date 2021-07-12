import QtQuick 2.12
import QtQuick.Controls 2.5
import QtQuick.Controls.Suru 2.2
import "../common"


CustomPopup {
    id: criteriaPopup
  
    property string activeItemId
    
    signal select(string selectedItemId)
    
    standardButtons: Dialog.Ok

    Item {
        anchors.fill: parent

        ButtonGroup {
            id: criteriaGroup
        }
  
        ListView {
            id: profilesListView
            
            clip: true
  
            model: mainView.mainModels.monitorItemsModel
            anchors {
                top: parent.top
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
                        select(model.itemId)
                    }
                }

            }
  
            Keys.onEscapePressed: criteriaPopup.close()
        }
    }
}