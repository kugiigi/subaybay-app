import QtQuick 2.12
import QtQuick.Controls 2.5
import QtQuick.Controls.Suru 2.2
import Ubuntu.Components 1.3 as UT
import "../components/profilespopup"
import "../components/common"


CustomPopup {
    id: profilesPopup
  
    standardButtons: Dialog.Ok
  
    ProfileDialog {
      id: profileDialog
    }
    
    DeleteConfirmDialog {
        id: deleteConfirmDialog

        title: i18n.tr("Delete the profile: %1?").arg(contextMenu.displayName)
        subtitle: i18n.tr("All associated data will be deleted.")
        onAccepted: {
            var result = mainView.profiles.delete(contextMenu.profileId)
            var tooltipMsg

            if (result.success) {
                tooltipMsg = i18n.tr("Profile deleted")
            } else {
                tooltip = i18n.tr("Error deleting")
            }
            
            tooltip.display(tooltipMsg)
        }
    }
    
    BaseAction {
        id: editAction
  
        text: i18n.tr("Edit")
        iconName: "edit"
    
        onTrigger:{
            profileDialog.openEdit(contextMenu.profileId, contextMenu.displayName)
        }
    }
  
    BaseAction {
        id: deleteAction
  
        text: i18n.tr("Delete")
        iconName: "delete"
    
        onTrigger:{
            deleteConfirmDialog.openNormal()
        }
    }
  
    BaseAction {
        id: separatorAction
        separator: true
    }
    
    ContextMenu {
        id: contextMenu
    
        property int profileId
        property string displayName
    
        actions: contextMenu.profileId !== settings.activeProfile ? [editAction, separatorAction, deleteAction]
                        : [editAction]
        listView: profilesListView
    }
  
    Item {
        anchors.fill: parent
  
        UT.PageHeader {
            id: header
  
            title: i18n.tr("Profiles")
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
  
            leadingActionBar.actions: [
                UT.Action {
                    iconName: "close"
                    text: i18n.tr("Close")
                    onTriggered: profilesPopup.close()
                }
            ]
  
            trailingActionBar {
                actions: [
                    UT.Action {
                        iconName: "add"
                        text: i18n.tr("New Profile")
  
                        onTriggered: {
                            profileDialog.openNew()
                        }
                    }
               ]
            }
        }
  
        ButtonGroup {
            id: profilesGroup
        }
  
        ListView {
            id: profilesListView
            
            clip: true
            currentIndex: -1
  
            model: mainModels.profilesModel
            anchors {
                top: header.bottom
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
                checked: model.profileId == mainView.settings.activeProfile
                ButtonGroup.group: profilesGroup
                highlighted: profilesListView.currentIndex == index
                
                onToggled: {
                  if (checked) {
                      mainView.settings.activeProfile = model.profileId
                  }
                }
                
                onPressAndHold: {
                    showContextMenu(radioDelegate.pressX, radioDelegate.pressY)
                }
                
                function showContextMenu(mouseX, mouseY) {
                    contextMenu.profileId = model.profileId
                    contextMenu.displayName = model.displayName
                    profilesListView.currentIndex = index
                    contextMenu.popup(radioDelegate, mouseX, mouseY)
                }
      
                MouseAreaContext {
                    anchors.fill: parent

                    onTrigger: {
                        radioDelegate.showContextMenu(mouseX, mouseY)
                    }
                }
            }
  
            Keys.onEscapePressed: profilesPopup.close()
        }
    }
}