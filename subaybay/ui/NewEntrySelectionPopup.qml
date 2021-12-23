import QtQuick 2.12
import QtQuick.Controls 2.5
import QtQuick.Controls.Suru 2.2
import QtQuick.Layouts 1.12
import "../components/common"


CustomPopup {
    id: newEntrySelection

    readonly property bool allSelected: monitorItemsListView.model.count == activeItems.length
    property string customDatePlaceHolder

    property var activeItems: []
  
    standardButtons: Dialog.NoButton
    closePolicy: Popup.CloseOnEscape
    
    function openWithInitial(itemId, customDate) {
        openPopup()
        if (customDate) {
            customDatePlaceHolder = customDate
        }
        if (itemId !== "all") {
            var temp = activeItems.slice()
            temp.push(itemId)
            activeItems = temp.slice()
        }
    }
    
    function reset() {
        // Reset values
        activeItems = []
    }

    function selectAll() {
        var temp = []

        for (var i = 0; i < monitorItemsListView.model.count; i++) {
            temp.push(monitorItemsListView.model.get(i).itemId)
        }

        activeItems = temp.slice()
    }
    
    function deselectAll() {
        activeItems = []
    }

    onAboutToShow: reset()
    
    onAccepted: newEntryPopup.openDialog(activeItems, customDatePlaceHolder)
    
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

                iconName: newEntrySelection.allSelected ? "select-none" : "select"
                color: Suru.backgroundColor
                
                onClicked: {
                    if (newEntrySelection.allSelected) {
                        newEntrySelection.deselectAll()
                    } else {
                        newEntrySelection.selectAll()
                    }
                }
            }
        }
        
        SeparatorLine {
            Layout.fillWidth: true
        }

        ListView {
            id: monitorItemsListView

            Layout.fillWidth: true
            Layout.fillHeight: true

            clip: true
            currentIndex: -1
  
            model: mainView.mainModels.monitorItemsFieldsModel

            delegate: CheckDelegate {
                id: checkDelegate
    
                anchors {
                   left: parent.left
                   right: parent.right
                }
                text: model.displayName
                checked: activeItems.indexOf(model.itemId) > -1
                
                onToggled: {
                    var temp = activeItems.slice()

                    if (checked) {
                      temp.push(model.itemId)
                    } else {
                      temp.splice(temp.indexOf(model.itemId), 1)
                    }
                    activeItems = temp.slice()
                }
            }
  
            Keys.onEscapePressed: newEntrySelection.close()
        }
    }
}
