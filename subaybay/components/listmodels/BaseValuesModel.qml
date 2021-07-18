import QtQuick 2.12

BaseListModel {
    id: baseValuesModel

    property var summaryValues

    worker: workerLoader

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
