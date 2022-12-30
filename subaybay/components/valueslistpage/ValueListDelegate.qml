import QtQuick 2.12
import QtQuick.Controls 2.5
import QtQuick.Controls.Suru 2.2
import Lomiri.Components 1.3 as UT
import QtQuick.Layouts 1.12
import "../common"

CustomItemDelegate {
    id: valueListDelegate
  
    property var values
    property string entryDate
    property string comments
    property string unit
    property string itemName
    
    signal showContextMenu(real mouseX, real mouseY)

    divider.visible: false

    onPressAndHold: {
        showContextMenu(valueListDelegate.pressX, valueListDelegate.pressY)
    }
    
    MouseAreaContext {
        anchors.fill: parent

        onTrigger: {
            valueListDelegate.showContextMenu(mouseX, mouseY)
        }
    }
  
    contentItem: RowLayout {
        CustomLabel {
            id: dateLabel

            Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
            visible: !valueListDelegate.itemName
            Suru.textLevel: Suru.HeadingThree
            font.pointSize: 11
            text: valueListDelegate.entryDate
            font.italic: true
            role: "date"
        }

        CustomLabel {
            id: itemLabel

            Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
            visible: valueListDelegate.itemName
            Suru.textLevel: Suru.HeadingTwo
            text: valueListDelegate.itemName
            role: "item"
        }

        ColumnLayout {
            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignRight
      
            RowLayout {
                Layout.alignment: Qt.AlignRight
          
                CustomLabel {
                    id: valueLabel
        
                    Suru.textLevel: Suru.HeadingTwo
                    text: valueListDelegate.values
                    role: "value"
                }
          
                CustomLabel {
                    id: unitLabel
          
                    Layout.alignment: Qt.AlignBottom
                    Suru.textLevel: Suru.Small
                    text: valueListDelegate.unit
                    role: "value"
                }
            }
      
            Label {
                id: commentsLabel
      
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.leftMargin: Suru.units.gu(5)
                horizontalAlignment: Text.AlignRight
                visible: valueListDelegate.comments ? true: false
                Suru.textLevel: Suru.Caption
                wrapMode: Text.WordWrap
                text: valueListDelegate.comments
            }
        }
    }
}
