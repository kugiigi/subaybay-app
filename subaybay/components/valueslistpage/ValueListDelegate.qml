import QtQuick 2.12
import QtQuick.Controls 2.5
import QtQuick.Controls.Suru 2.2
import Ubuntu.Components 1.3 as UT
import QtQuick.Layouts 1.12
import "../common"

ItemDelegate {
    id: valueListDelegate
  
    property var values
    property string entryDate
    property string comments
    property string unit
    
    signal showContextMenu(real mouseX, real mouseY)

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
        ColumnLayout {
            Layout.fillHeight: true
      
            CustomLabel {
                id: dateLabel
      
                Layout.fillWidth: true
                Suru.textLevel: Suru.HeadingThree
                font.pointSize: 11
                font.italic: true
                text: valueListDelegate.entryDate
                role: "date"
            }
        }
  
        ColumnLayout {
            Layout.fillHeight: true
            Layout.fillWidth: true
      
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