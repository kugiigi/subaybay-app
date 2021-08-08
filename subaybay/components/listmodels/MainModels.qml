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
                dashboardModel.updateUserMetric()
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

        function updateUserMetric() {
            var curItem, curValue
            var valItems = []
            var msgItem
            var circleMessage
            var firstChar
            var valueText

            for (var i = 0; i < count; i++) {
                curItem = get(i)

                for (var h = 0; h < curItem.items.count; h++) {
                    curValue = curItem.items.get(h)
                    firstChar = curValue.title.charAt(0)

                    // Only add values from today
                    if (curItem.itemId !== "all" && curValue.type == "last" && firstChar >= "0" && firstChar <= "9") {
                        valItems.push({ "name": curItem.displayName, "title": curValue.title, "value": curValue.value + " " + curItem.displaySymbol })
                    }
                }
            }
            
            for (var k = 0; k < valItems.length; k++) {
                msgItem = valItems[k]
                if (settings.coloredText) {
                    valueText = ("<font color=\"#FF19b6ee\">%1</font><br>%3 <font color=\"#FF3eb34f\">%2</font>").arg(msgItem.name).arg(msgItem.value).arg(msgItem.title)
                } else {
                    valueText = ("%1:\n%3 %2 ").arg(msgItem.name).arg(msgItem.value).arg(msgItem.title)                    
                }

                

                if (circleMessage) {
                    if (settings.coloredText) {
                        circleMessage = circleMessage + "<br>" + valueText
                    } else {
                        circleMessage = circleMessage + "\n" + valueText
                    }

                    
                } else {
                    circleMessage = valueText
                }
            }

            if (circleMessage) {
                userMetric.circleMetric = circleMessage
                userMetric.increment(1)
            }
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
