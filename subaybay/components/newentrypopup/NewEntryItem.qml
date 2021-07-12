import QtQuick 2.12
import QtQuick.Controls 2.5
import QtQuick.Controls.Suru 2.2
import Ubuntu.Components 1.3 as UT
import QtQuick.Layouts 1.12
import "../common"

ColumnLayout {
    id: newEntryItem

    property string itemId
    property alias title: titleLabel.text
    property alias fields: fieldsRepeater.model
    property alias fieldsRepeater: fieldsRepeater
    property bool removable: true

    signal remove

    spacing: 10
    
    function focusFirstField() {
        fieldsRepeater.itemAt(0).valueField.focus = true
    }
    
    function focusNext(item) {
        var nextItem = item.nextItemInFocusChain(true)
        var mappedY
        var itemHeightY
        var currentViewport
        var intendedContentY
        var maxContentY

        nextItem.focus = true

        mappedY = nextItem.mapToItem(flickable.contentItem, 0, 0).y
        itemHeightY = mappedY + item.height
        currentViewport = flickable.contentY - flickable.originY + flickable.height

        if (itemHeightY > currentViewport) {
            maxContentY = flickable.contentHeight - flickable.height
            // intendedContentY = flickable.contentY + itemHeightY - currentViewport - flickable.originY
            intendedContentY = itemHeightY - flickable.height + commentTextArea.height

            if (intendedContentY > maxContentY) {
                flickable.contentY = maxContentY
            } else {
                flickable.contentY = intendedContentY
            }
        }

    }

    RowLayout {
        Layout.fillWidth: true

        Label {
            id: titleLabel
            
            Layout.fillWidth: true
            Suru.textLevel: Suru.HeadingThree
        }
        
        ActionButton {
            id: removeButton

            Layout.alignment: Qt.AlignRight
            visible: newEntryItem.removable
            color: theme.normal.background
            iconName: "close"
            onClicked: remove()
        }
    }
  
    Repeater {
        id: fieldsRepeater
    
        delegate: RowLayout {
        
            property string fieldId: model.fieldId
            property alias valueField: valueTextField
            property alias value: valueTextField.text
            
            Layout.fillWidth: true
            spacing: 10

            TextField {
                id: valueTextField
                
                
        
                Layout.fillWidth: true
                placeholderText: model.title
                inputMethodHints: Qt.ImhDigitsOnly
                validator: DoubleValidator{
                    decimals: model.precision
                }
                font.pixelSize: 20
                horizontalAlignment: TextInput.AlignHCenter
                Keys.onReturnPressed: newEntryItem.focusNext(this)
            }
      
            Label {
                id: unitLabel
          
                Layout.alignment: Qt.AlignBottom
                Suru.textLevel: Suru.HeadingThree
                text: model.unit
            }
        }
    }
}