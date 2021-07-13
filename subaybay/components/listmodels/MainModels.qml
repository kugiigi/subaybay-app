import QtQuick 2.12
import Ubuntu.Components 1.3 as UT
import "../../library/dataUtils.js" as DataUtils

Item{
    id: mainModels
    
    property alias profilesModel: profilesModel
    property alias dashboardModel: dashboardModel
    property alias dashItemsModel: dashItemsModel
    property alias firstValuesListModel: firstValuesListModel
    property alias monitorItemsModel: monitorItemsModel
    property alias monitorItemsFieldsModel: monitorItemsFieldsModel
    
    /*WorkerScript for asynch loading of models*/
    WorkerScript {
        id: workerLoader
        source: "ModelWorkerScript.mjs"

        onMessage: {
            switch (messageObject.modelId) {
            case "Profiles":
                profilesModel.loadingStatus = "Ready"
                break;
            case "MonitorItemsFields":
                monitorItemsFieldsModel.loadingStatus = "Ready"
                break;
            case "MonitorItems":
                monitorItemsModel.loadingStatus = "Ready"
                break;
            case "DashItems":
                dashItemsModel.loadingStatus = "Ready"
                break;
            case "Values_1":
                firstValuesListModel.summaryValues = messageObject.result
                firstValuesListModel.loadingStatus = "Ready"
                break;
            case "Dashboard":
                dashboardModel.loadingStatus = "Ready"
                break;
            }
        }
    }

    BaseListModel {
        id: profilesModel
  
        worker: workerLoader
        modelId: "Profiles"
        Component.onCompleted: refresh()
        
        function refresh() {
            fillData(mainView.profiles.list())
        }
    }

    BaseListModel {
        id: monitorItemsModel
  
        worker: workerLoader
        modelId: "MonitorItems"
        Component.onCompleted: refresh()
        
        function refresh() {
            fillData(mainView.monitoritems.list())
        }
    }

    BaseListModel {
        id: monitorItemsFieldsModel
  
        worker: workerLoader
        modelId: "MonitorItemsFields"
        Component.onCompleted: refresh()
        
        function refresh() {
            fillData(mainView.monitoritems.fieldsList())
        }
    }

    BaseListModel {
        id: dashItemsModel
  
        worker: workerLoader
        modelId: "DashItems"
        Component.onCompleted: refresh()
        
        function refresh() {
            fillData(mainView.monitoritems.dashList())
        }
    }

    BaseListModel {
        id: firstValuesListModel
        
        property var summaryValues

        worker: workerLoader
        modelId: "Values_1"

        function getDashItems(itemId) {
            var current
            var currentItemId
            var dashItems = []
            for (var i = 0; i < dashItemsModel.count; i++) {
                current = dashItemsModel.get(i)
                currentItemId = current.itemId
                if (currentItemId == itemId) {
                    dashItems.push(current.valueType)
                }
            }
            return dashItems
        }

        function load(itemId, displayFormat, scope, dateFrom, dateTo) {
            var dashItems = getDashItems(itemId);
            properties = { displayFormat: displayFormat, dashItems: dashItems }
            fillData(mainView.values.itemValues(itemId, scope, dateFrom, dateTo))
        }
    }

    BaseListModel {
        id: dashboardModel
      
        worker: workerLoader
        modelId: "Dashboard"
        Component.onCompleted: refresh()
        
        function refresh() {
            fillData(mainView.values.dashList())
        }
    }

    Connections {
        target: mainView

        onCurrentDateChanged: {
            console.log("dashboard refreshed")
            dashboardModel.refresh()
        }
    }
}
