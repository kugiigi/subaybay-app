import QtQuick 2.12
import QtQuick.Controls 2.5
import QtQuick.Controls.Suru 2.2
import Ubuntu.Components 1.3 as UT
import "../components/common"


CustomPopup {
    id: newEntrySelection

    property var activeItems: []
  
    standardButtons: Dialog.NoButton
    closePolicy: Popup.CloseOnEscape
    
    function reset() {
        // Reset values
        activeItems = []
    }
    
    onAboutToShow: reset()
    
    onAccepted: newEntryPopup.openDialog(activeItems)
    
    footer: DialogButtonBox {
        CustomDialogButton {
            id: okButton

            text: i18n.tr("Ok")
            enabled: newEntrySelection.activeItems.length > 0
            
            onClicked: {
                accept()
            }
        }

        CustomDialogButton {
            id: cancelButton

            text: i18n.tr("Cancel")

            onClicked: newEntrySelection.reject()
        }
    }

    Item {
        anchors.fill: parent
  
        UT.PageHeader {
            id: header
  
            title: i18n.tr("New Entry")
            theme.name: switch(mainView.suruTheme) {
              case Suru.Light:
                "Ubuntu.Components.Themes.Ambiance"
                break
              case Suru.Dark:
                "Ubuntu.Components.Themes.SuruDark"
                break
              case undefined:
                undefined
                break
            }
            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
            }
        }

        ListView {
            id: monitorItemsListView
            
            clip: true
            currentIndex: -1
  
            model: mainView.mainModels.monitorItemsFieldsModel
            anchors {
                top: header.bottom
                left: parent.left
                right: parent.right
                bottom: parent.bottom
            }
  
            delegate: CheckDelegate {
                id: checkDelegate
    
                anchors {
                   left: parent.left
                   right: parent.right
                }
                text: model.displayName
                checked: activeItems.indexOf(model.itemId) > -1 // ? Qt.Checked: Qt.Unchecked
                
                onToggled: {
                    var temp = activeItems.slice()
                    if (checkState == Qt.Checked) {
                      temp.push(model.itemId)
                    } else {
                      temp.splice(activeItems.indexOf(model.itemId))
                    }
                    activeItems = temp.slice()
                }
            }
  
            Keys.onEscapePressed: newEntrySelection.close()
        }
    }
}