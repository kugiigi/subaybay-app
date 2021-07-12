import QtQuick 2.12
import QtQuick.Controls 2.5
import Ubuntu.Components 1.3 as UT
import "../components/mainpage"
import "../components/common"
import "../library/functions.js" as Functions

BasePage {
    id: mainPage

    flickable: listView
    
    // Avoid binding loop warning
    implicitWidth: parent.width

    title: mainView.profiles.currentName()

    headerRightActions: [addAction, profilesAction]

    BaseAction {
        id: profilesAction
    
        text: i18n.tr("Switch Profile")
        iconName: "account"
    
        onTrigger:{
            profilesPopup.openPopup()
        }
    }

    BaseAction{
        id: addAction
    
        text: i18n.tr("New Entry")
        iconName: "add"
    
        onTrigger:{
            newEntrySelection.openPopup()
        }
    }
    
    function refresh() {
        listView.model.refresh()
    }

    function newEntry(itemId) {
        newEntryPopup.openDialog(itemId)
    }

    Connections {
        target: mainView.settings
        onActiveProfileChanged: {
            refresh()
        }
    }

    ListView {
        id: listView

        // snapMode: ListView.SnapToItem 
        boundsBehavior: Flickable.DragOverBounds
        
        anchors{
            top: parent.top
            topMargin: spacing
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            bottomMargin: topMargin
        }
        
        spacing: 10
        model: mainModels.dashboardModel

        delegate: MonitorItemsDelegate {
            itemId: model.itemId
            displayName: model.displayName
            items: model.items
            unit: model.displaySymbol

            onClicked: {
                var today = Functions.getToday()
                stackView.push(Qt.resolvedUrl("ValuesListPage.qml"), {itemId: model.itemId, scope: "day", toDate: today, fromDate: today})
            }
        }
        ScrollBar.vertical: ScrollBar { width: 10 }
    }
}
