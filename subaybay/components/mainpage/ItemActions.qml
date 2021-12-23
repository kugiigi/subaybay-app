import QtQuick 2.12
import QtQuick.Layouts 1.12
import "../common"

Rectangle {
	id: itemActions
	
	readonly property real buttonsMargin: 10
	
	radius: 10
	
	color: theme.normal.foreground
	width: 50 //positiveColumn.width
	
	//This will make the radius shown only on the right side
	Rectangle { color: parent.color; anchors.fill: parent; anchors.rightMargin: parent.radius }
	ColumnLayout {
        spacing: 0
        anchors {
            top: parent.top
            topMargin: buttonsMargin
            bottom: parent.bottom
            bottomMargin: buttonsMargin
            left: parent.left
            right: parent.right
        }

        ColumnLayout {
            id: negativeColumn

          Layout.fillWidth: true
            Layout.fillHeight: true
        }
        
        ColumnLayout {
            id: positiveColumn

            Layout.fillWidth: true
            Layout.fillHeight: true
            
            spacing: 7
            
            ActionButton {
                Layout.fillHeight: true
                Layout.fillWidth: true

                iconName: "add"
                onClicked: {
                    if (monitorItemsDelegate.itemId === "all") {
                        newEntrySelection.openWithInitial("all")
                    } else {
                        mainPage.newEntry(monitorItemsDelegate.itemId)
                    }
                }
            }
        }
    }
}
