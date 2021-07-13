import QtQuick 2.12
import QtQuick.Controls 2.5
import QtQuick.Controls.Suru 2.2
import QtQuick.Layouts 1.12
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
  
    ColumnLayout {
        anchors.fill: parent

        RowLayout {
            id: header

            Layout.fillWidth: true
            Layout.preferredHeight: Suru.units.gu(6)
            Layout.leftMargin: Suru.units.gu(2)
            Layout.rightMargin: Suru.units.gu(1)

            Label {
                Layout.fillWidth: true

                Suru.textLevel: Suru.HeadingTwo
                text: i18n.tr("New Entry")
            }
            
            ActionButton {
                Layout.preferredWidth: Suru.units.gu(5)

                iconName: "add"
                color: Suru.backgroundColor
                
                onClicked: {
                    profileDialog.openNew()
                }
            }
        }

        SeparatorLine {
            Layout.fillWidth: true
        }

        ButtonGroup {
            id: profilesGroup
        }
  
        ListView {
            id: profilesListView

            Layout.fillWidth: true
            Layout.fillHeight: true

            clip: true
            currentIndex: -1
  
            model: mainModels.profilesModel
  
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