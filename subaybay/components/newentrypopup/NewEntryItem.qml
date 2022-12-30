import QtQuick 2.12
import QtQuick.Controls 2.5
import QtQuick.Controls.Suru 2.2
import Ubuntu.Components 1.3 as UT
import QtQuick.Layouts 1.12
import "../common"
import "../../library/functions.js" as Functions

ColumnLayout {
    id: newEntryItem

    property int itemIndex
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

    function focusPrevious(item) {
        var prevItem = item.nextItemInFocusChain(false)

        prevItem.focus = true
    }

    function focusNext(item) {
        var nextItem = item.nextItemInFocusChain(true)

        nextItem.focus = true
    }

    RowLayout {
        id: labelRow

        Layout.fillWidth: true

        CustomLabel {
            id: titleLabel
            
            Layout.fillWidth: true
            Suru.textLevel: Suru.HeadingThree
            role: "item"
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

            function focusPrevious() {
                if (!(newEntryItem.itemIndex == 0 && model.index == 0)) {
                    newEntryItem.focusPrevious(this)
                }
            }

            CustomTextField {
                id: valueTextField
                
                
        
                Layout.fillWidth: true
                placeholderText: model.title
                inputMethodHints: Qt.ImhDigitsOnly
                role: "value"
                validator: DoubleValidator{
                    decimals: model.precision
                }
                font.pixelSize: 20
                horizontalAlignment: TextInput.AlignHCenter
                Keys.onReturnPressed: newEntryItem.focusNext(this)
                Keys.onPressed: {
                    if (event.key == Qt.Key_Backspace && valueTextField.text == "") {
                        focusPrevious()
                    }
                }
                Keys.onUpPressed: focusPrevious()
                Keys.onDownPressed: newEntryItem.focusNext(this)
                onFocusChanged: {
                    if (focus) {
                        var labelY = labelRow.mapToItem(flickable.contentItem, 0, 0).y
                        var itemY = mapToItem(flickable.contentItem, 0, 0).y
                        Functions.scrollToView(this, flickable, itemY - labelY, 0)
                    }
                }
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
