import QtQuick 2.12
import Ubuntu.Components 1.3 as UT
import "../../library/dataUtils.js" as DataUtils

Item{
    id: mainModels
    
    property alias profilesModel: profilesModel
    property alias dashboardModel: dashboardModel
    property alias dashItemsModel: dashItemsModel
    property var valuesListModels: [firstValuesListModel, secondValuesListModel, thirdValuesListModel]
    property alias firstValuesListModel: firstValuesListModel
    property alias secondValuesListModel: secondValuesListModel
    property alias thirdValuesListModel: thirdValuesListModel
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
            case "Values_2":
                secondValuesListModel.summaryValues = messageObject.result
                secondValuesListModel.loadingStatus = "Ready"
                break;
            case "Values_3":
                thirdValuesListModel.summaryValues = messageObject.result
                thirdValuesListModel.loadingStatus = "Ready"
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

    BaseValuesModel {
        id: firstValuesListModel

        modelId: "Values_1"
    }

    BaseValuesModel {
        id: secondValuesListModel

        modelId: "Values_2"
    }

    BaseValuesModel {
        id: thirdValuesListModel

        modelId: "Values_3"
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
