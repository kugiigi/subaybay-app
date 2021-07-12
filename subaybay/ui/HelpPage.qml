import QtQuick 2.9
import QtQuick.Controls 2.2
import "../components/common"
import "../components/JSONListModel"
import "../components/helppage"
import "../data/help.js" as Help

BasePage {
    id: helpPage
    
    readonly property string qmlPath: "../components/helppage/"
    
    property var initialNavigation: [] 
    property var model: Help.getHelpData()
    readonly property int modelCount: model.length
    property int rightActionToTrigger
    property int swipeViewIndex
    
    onModelCountChanged: {
        if (initialNavigation.length == 0) {
            var initialItem = model[0]
            helpStackView.push(Qt.resolvedUrl(qmlPath + initialItem.qml), {title: initialItem.title, contentModel: initialItem.panes})
        } else {
            deepLink(initialNavigation)
        }
    }
    
    title: helpStackView.currentItem ? i18n.tr("Help") + " - " + helpStackView.currentItem.title : ""
    flickable: helpStackView.currentItem ? helpStackView.currentItem.flickable : null
    
    function deepLink(navigation){
        var currentId, currentPaneId
        var currentPanes
        var obj

        for (var i = 0; i < model.length; i++) {
            currentId = model[i].id

            if (navigation[0] == currentId) {
                currentPanes = model[i].panes
                rightActionToTrigger = i

                for (var k = 0; k < currentPanes.length; k++) {
                    currentPaneId = currentPanes[k].id
                    if (currentPaneId == navigation[1]) {
                        swipeViewIndex = k
                        break
                    }
                }
                break
            }
        }
    }

    
    Instantiator {
        id: helpPagesRepeater
        
        model: helpPage.model
        
        BaseAction{
            text: modelData.title
            iconName: modelData.icon
        
            onTrigger:{
                helpStackView.replace(Qt.resolvedUrl(qmlPath + modelData.qml), {title: modelData.title,contentModel: modelData.panes})
            }
        }
        
        onObjectAdded:{
            if (index == rightActionToTrigger) {
                object.trigger("")
            }
            headerRightActions.push(object)
        }
    }
        
    StackView {
        id: helpStackView
        
        anchors.fill: parent
        
        onCurrentItemChanged: {
            currentItem.setIndex(helpPage.swipeViewIndex)
        }
    }
}
