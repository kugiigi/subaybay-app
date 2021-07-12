import QtQuick 2.12
import QtQuick.Controls 2.5
import QtQuick.Controls.Suru 2.2
import QtQuick.Layouts 1.12
import "../common"

BaseDialog {
    id: profileDialog

    property bool editMode: false

    standardButtons: Dialog.NoButton

    parent: mainView.corePage
    height: Suru.units.gu(20)
    focus: true
    closePolicy: Popup.CloseOnEscape

    QtObject{
        id: priv
        
        property string currentDisplayName
        property int profileId
        
        function submitData() {
            keyboard.target.commit()
            if (!mainView.profiles.exists(displayNameField.text)) {
                accept()
            } else {
                tooltip.display(i18n.tr("Name already exists"))
                displayNameField.focus = true
            }
        }
    }

    onAccepted: {
        keyboard.target.commit()
        var newDisplayName = displayNameField.text

        if (editMode) {
            mainView.profiles.edit(priv.profileId, newDisplayName)
        } else {
            mainView.profiles.new(displayNameField.text)
        }
    }

    onActiveFocusChanged: {
      if (editMode && activeFocus) {
          displayNameField.selectAll()
      }
    }
    
    onOpened: displayNameField.focus = true

    onClosed: {
        priv.currentDisplayName = ""
    }

    function openNew() {
        editMode = false
        displayNameField.text = ""
        openNormal()
    }

    function openEdit(profileId, oldDisplayName) {
        editMode = true
        priv.currentDisplayName = oldDisplayName
        priv.profileId = profileId
        displayNameField.text = priv.currentDisplayName
        openNormal()
    }


    footer: DialogButtonBox {
        CustomDialogButton {
            text: profileDialog.editMode ? i18n.tr("Save") : i18n.tr("Ok")
            enabled: displayNameField.text !== ""

            onClicked: {
                priv.submitData()
            }
        }

        CustomDialogButton {
            text: i18n.tr("Cancel")

            onClicked: {
                reject()
            }
        }
    }

    ColumnLayout {
        spacing: Suru.units.gu(2)
  
        anchors {
            left: parent.left
            right: parent.right
            verticalCenter: parent.verticalCenter
        }

        Label {
            id: titleLabel
    
            Layout.fillWidth: true
            Suru.textLevel: Suru.HeadingThree
            text: profileDialog.editMode ? i18n.tr('Editing "%1"').arg(priv.currentDisplayName) : i18n.tr("New Profile")
        }
  
        TextField {
            id: displayNameField
        
            Layout.fillWidth: true
            persistentSelection: true
            placeholderText: i18n.tr("Display name")
            font.pixelSize: Suru.units.gu(3)
            // inputMethodHints: Qt.ImhNoPredictiveText
            Keys.onReturnPressed: {
                if (text !== "") {
                    priv.submitData()
                }
            }
        }
    }
}