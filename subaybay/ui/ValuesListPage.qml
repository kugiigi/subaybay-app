import QtQuick 2.12
import QtQuick.Controls 2.5
import QtQuick.Controls.Suru 2.2
import Ubuntu.Components 1.3 as UT
import QtQuick.Layouts 1.12
import "../components/valueslistpage"
import "../components/common"
import "../library/functions.js" as Functions

BasePage {
    id: valuesListPage

    readonly property bool isToday: Functions.isToday(dateViewPath.currentItem.fromDate)
    property string currentDate: Functions.getToday()

    property string itemId
    property string scope

    flickable: dateViewPath.currentItem.view

    title: mainView.profiles.currentName()
    
    signal refresh
    signal itemDeleted

    headerRightActions: [addAction, todayAction, sortAction, profilesAction]
    
    Connections {
        target: mainView.settings
        onActiveProfileChanged: {
            refresh()
        }
    }
    
    Connections {
        target: newEntryPopup
        onAccepted: {
            refresh()
        }
    }

    onItemDeleted: {
        refresh()
        mainModels.dashboardModel.refresh();
    }

    onCurrentDateChanged: {
        dateViewPath.scrollToBegginer()
    }

    function next() {
        dateViewPath.incrementCurrentIndex()
    }
    
    function previous() {
        dateViewPath.decrementCurrentIndex()
    }

    function newEntry() {
        if (isToday) {
            newEntrySelection.openWithInitial(itemId)
        } else {
            newEntrySelection.openWithInitial(itemId, dateViewPath.currentItem.fromDate)
        }
    }
    
    function goToday() {
        if (scope == "day") {
            currentDate = Functions.getToday()
        }
    }

    Shortcut {
        sequence: StandardKey.MoveToNextChar
        onActivated: next()
    }

    Shortcut {
        sequence: StandardKey.MoveToPreviousChar
        onActivated: previous()
    }

    BaseAction{
        id: addAction
    
        text: i18n.tr("New Entry")
        iconName: "add"
    
        onTrigger:{
            newEntry()
        }
    }

    BaseAction{
        id: todayAction
    
        text: i18n.tr("View Today")
        iconName: "calendar-today"
        enabled: !valuesListPage.isToday
    
        onTrigger:{
            goToday()
        }
    }

    BaseAction{
        id: sortAction
    
        text: i18n.tr("Sort")
        iconName: "sort-listitem"
        enabled: false
    
        onTrigger:{
            
        }
    }

    BaseAction{
        id: profilesAction
    
        text: i18n.tr("Switch Profile")
        iconName: "account"
    
        onTrigger:{
            profilesPopup.openPopup()
        }
    }
    
    BaseAction {
        id: editAction
  
        text: i18n.tr("Edit")
        iconName: "edit"
    
        onTrigger:{
            newEntryPopup.openEdit(contextMenu.itemProperties.entryDateId, contextMenu.itemProperties.itemId, contextMenu.itemProperties.comments, contextMenu.itemProperties.fields)
        }
    }
  
    BaseAction {
        id: deleteAction
  
        text: i18n.tr("Delete")
        iconName: "delete"
    
        onTrigger:{
            deleteConfirmDialog.openNormal()
        }
    }
  
    BaseAction {
        id: separatorAction
        separator: true
    }

    DeleteConfirmDialog {
        id: deleteConfirmDialog

        title: i18n.tr("Delete this value?")
        subtitle: ("%1 - %2 %3").arg(contextMenu.itemProperties.entryDate).arg(contextMenu.itemProperties.value).arg(contextMenu.itemProperties.unit)
        checkBoxTitle: i18n.tr("Delete all with the same date/time")

        onAccepted: {
            var result = mainView.values.delete(contextMenu.itemProperties.entryDateId, contextMenu.itemProperties.itemId, checked)
            var tooltipMsg

            if (result.success) {
                tooltipMsg = i18n.tr("Value deleted")
                valuesListPage.itemDeleted()
            } else {
                tooltip = i18n.tr("Error deleting")
            }
            
            tooltip.display(tooltipMsg)
        }

        onAboutToShow: {
            if (mainView.values.entryDateMultiple(contextMenu.itemProperties.entryDateId, contextMenu.itemProperties.itemId)) {
                showCheckbox = true
            } else {
                showCheckbox = false
            }
        }
    }

    ContextMenu {
        id: contextMenu

        itemProperties: { "entryDateId": "", "entryDate": "", "fields": "", "itemId": "", "value": "", "comments": "", "unit": "" }

        actions: [editAction, separatorAction, deleteAction]
        listView: dateViewPath.currentItem.view
    }
    
    CriteriaPopup {
        id: criteriaPopup

        activeItemId: valuesListPage.itemId
        dateValue: new Date(dateViewPath.currentItem.fromDate)
        onSelect: {
            valuesListPage.itemId = selectedItemId
            valuesListPage.currentDate = Functions.formatDateForDB(selectedDate)
            valuesListPage.refresh()
            dateValue = Qt.binding(function() { return new Date(dateViewPath.currentItem.fromDate) } )
        }
    }
    
    UT.LiveTimer {
        frequency: UT.LiveTimer.Hour
        onTrigger: navigationRow.labelRefresh()
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0
  
        ValuesNavigationRow {
            id: navigationRow

            function labelRefresh() {
                dateTitle = Qt.binding(function() { return Functions.relativeDate(dateViewPath.currentItem.fromDate,"ddd, MMM DD", "Basic") })
            }

            Component.onCompleted: labelRefresh()

            Layout.fillWidth: true
            Layout.maximumHeight: 90
            z: 1

            biggerDateLabel: valuesListPage.itemId === "all"
            itemTitle: valuesListPage.itemId === "all" ? i18n.tr("All") : mainView.mainModels.monitorItemsModel.getItem(valuesListPage.itemId, "itemId").displayName

            onCriteria: criteriaPopup.openPopup()
            onNext: valuesListPage.next()
            onPrevious: valuesListPage.previous()
        }
        
        ToolSeparator {
            id: separator
    
            Layout.fillWidth: true
            z: navigationRow.z
            orientation: Qt.Horizontal
            topPadding: 0
            bottomPadding: 0
        }
        
        PathViewBase {
            id: dateViewPath

            objectName: "dateViewPath"

            Layout.fillWidth: true
            Layout.fillHeight: true

            delegate: Item {                
                property alias model: listView.model
                property alias count: listView.count
                property alias view: listView
                property string fromDate: Functions.addDays(valuesListPage.currentDate, dateViewPath.loopCurrentIndex + dateViewPath.indexType(index))
                property string toDate: fromDate

                height: parent.height
                width: parent.width

                function loadData() {
                    listView.model.load(valuesListPage.itemId, valuesListPage.scope, fromDate, fromDate)
                }
                
                onFromDateChanged: {
                    loadData()
                }

                Connections {
                    target: valuesListPage
                    onRefresh: loadData()
                }

                EmptyState {
                    id: emptyState
                   
                    anchors.centerIn: parent
                    title: i18n.tr("No data")
                    loadingTitle: i18n.tr("Loading data")
                    loadingSubTitle: i18n.tr("Please wait")
                    isLoading: !listView.model.ready
                    shown: listView.model.count === 0 || !listView.model.ready
                }
            
                ListView {
                    id: listView
          
                    anchors.fill: parent
                    z: 0
                    boundsBehavior: Flickable.DragOverBounds
                    focus: true
                    currentIndex: -1
                    visible: model.ready
                    section.property: valuesListPage.itemId === "all" ? "entryDate" : ""
                    section.delegate: Rectangle {
                                        color: "transparent"
                                        height: units.gu(4)

                                        anchors {
                                            left: parent.left
                                            right: parent.right
                                        }
                                        
                                        Rectangle {
                                            id: dividerRec

                                            anchors.bottom: parent.bottom
                                            width: parent.width
                                            height: Suru.units.dp(1)
                                            color: Suru.neutralColor
                                        }

                                        RowLayout {
                                            anchors.fill: parent

                                            CustomLabel {
                                                Layout.leftMargin: Suru.units.gu(2)
                                                Suru.textLevel: Suru.HeadingThree
                                                font.pointSize: 12
                                                text: section
                                                font.italic: true
                                                role: "date"
                                            }
                                        }
                                    }
          
                    model: mainModels.valuesListModels[index]
            
                    delegate: ValueListDelegate {
                        id: valuesListDelegate
                        anchors {
                          left: parent.left
                          right: parent.right
                        }
                        values: model.values
                        entryDate: model.entryDate
                        comments: model.comments
                        unit: model.unit
                        itemName: valuesListPage.itemId === "all" ? model.itemName : ""
                        highlighted: listView.currentIndex == index

                        onShowContextMenu: {
                            var itemProperties = { entryDateId: model.entryDateId
                                    , entryDate: model.entryDate, fields: model.fields
                                    , itemId: model.itemId, value: model.values
                                    , comments: model.comments, unit: model.unit
                            }

                            listView.currentIndex = index
                            contextMenu.popupMenu(valuesListDelegate, mouseX, mouseY, itemProperties)
                        }
                    }

                    ScrollBar.vertical: ScrollBar { width: 10 }
                    ListViewPositioner{z: 5; mode: "Down"}
                    NumberAnimation on opacity {
                        running: listView.count > 0
                        from: 0
                        to: 1
                        easing: Suru.animations.EasingInOut
                        duration: Suru.animations.BriskDuration
                    }
                }
            }
        }

        SummaryValuesDelegate {
            id: summaryValues
      
            valuesModel: dateViewPath.currentItem.model.summaryValues
            visible: valuesListPage.itemId !== "all" && dateViewPath.currentItem.model.ready && dateViewPath.currentItem.model.count > 0

            Layout.fillWidth: true

            NumberAnimation on opacity {
                running: dateViewPath.currentItem.count > 0
                from: 0
                to: 1
                easing: Suru.animations.EasingInOut
                duration: Suru.animations.BriskDuration
            }

            Behavior on implicitHeight {
                NumberAnimation {
                    duration: Suru.animations.FastDuration
                    easing: Suru.animations.EasingOut
                }
            }
        }
    }
}
