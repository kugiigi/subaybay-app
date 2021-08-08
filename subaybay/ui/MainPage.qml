import QtQuick 2.12
import QtQuick.Controls 2.5
import QtQuick.Controls.Suru 2.2
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

    EmptyState {
        id: emptyState
       
        anchors.centerIn: parent
        loadingTitle: i18n.tr("Updating data")
        loadingSubTitle: i18n.tr("Please wait")
        isLoading: !listView.model.ready
        shown: listView.model.count === 0 || !listView.model.ready
    }

    ListView {
        id: listView

        boundsBehavior: Flickable.DragOverBounds
        
        anchors{
            top: parent.top
            topMargin: spacing
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            bottomMargin: topMargin
        }
        opacity: model.ready? 1 : 0.7
        
        spacing: 10
        model: mainModels.dashboardModel

        delegate: MonitorItemsDelegate {
            itemId: model.itemId
            displayName: model.displayName
            items: model.items
            unit: model.displaySymbol

            onClicked: {
                var today = Functions.getToday()
                stackView.push(Qt.resolvedUrl("ValuesListPage.qml"), {itemId: model.itemId, scope: "day", currentDate: today})
            }
        }
        ScrollBar.vertical: ScrollBar { width: 10 }
        
        NumberAnimation on opacity {
            running: listView.model.ready
            from: 0
            to: 1
            easing: Suru.animations.EasingInOut
            duration: Suru.animations.SlowDuration
        }
    }
}
