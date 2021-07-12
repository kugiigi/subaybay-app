import QtQuick 2.12
import QtQuick.Controls 2.5
import QtQuick.Controls.Suru 2.2
import Ubuntu.Components 1.3 as UT
import QtQuick.Layouts 1.12
import "../common"

CustomButton {
    id: monitorItemsDelegate

    property string itemId
    property string displayName
    property string unit
    property alias items: dataRepeater.model

    color: theme.normal.background
    radius: 10
    height: contentItem.childrenRect.height + (contentItem.anchors.topMargin * 2)
    anchors {
        left: parent.left
        leftMargin: 10
        right: parent.right
        rightMargin: 10
    }

    border {
        width: 3
        color: theme.normal.foreground
    }
    
    Item {
        id: contentItem

        anchors {
            top: parent.top
            topMargin: 15
            left: parent.left
            leftMargin: 20
            right: itemActions.left
            rightMargin: 20
        }
        
        ColumnLayout {
            spacing: 10
            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
            }
            
            CustomLabel {
                id: titleLabel
            
                Layout.alignment: Qt.AlignHCenter
                Suru.textLevel: Suru.HeadingOne
                text: monitorItemsDelegate.displayName
                role: "item"
            }
            
            Flow {
                id: contentFlow
                
                Layout.fillHeight: true
                Layout.fillWidth: true
                spacing: 10
                
                Repeater {
                    id: dataRepeater
                    
                    delegate: MonitorItemDelegate {
                        width: contentFlow.width > 250 ? (contentFlow.width - contentFlow.spacing) / 2 : contentFlow.width 
                        value: model.value
                        title: model.title
                        unit: monitorItemsDelegate.unit
                        visible: model.value !== ""
                    }
                }
            }
        }
    }
        
    ItemActions {
        id: itemActions
        
        anchors {
            right: parent.right
            top: parent.top
            bottom: parent.bottom
        }
    }
}
