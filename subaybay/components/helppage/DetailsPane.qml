import QtQuick 2.12
import QtQuick.Controls 2.5
import QtQuick.Layouts 1.3
import "detailspane"
import "../common"

BasePane {
    id: detailsPane
    
    property alias contentModel: contentRepeater.model
    property alias currentIndex: view.currentIndex
    property string title
    
    flickable: view.currentItem
    
    function setIndex(curIndex) {
        view.setCurrentIndex(curIndex)
    }
    
    ColumnLayout {
        anchors.fill: parent
        
        SwipeView {
            id: view
        
            Layout.fillHeight: true
            Layout.fillWidth: true
            
            Repeater {
                id: contentRepeater
                
                ContentDelegate {
                }
            }
        }
        
        PaneFooter {
            id: paneFooter
            
            visible: view.count > 1
        }
    }
    
}
