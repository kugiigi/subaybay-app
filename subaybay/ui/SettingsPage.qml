import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import "../components/common"
import "../components/listmodels"
import "../components/settingspage"

BasePage {
    id: settingsPage
    
    title: i18n.tr("Settings")
    flickable: settingsFlickable
    
    headerRightActions: [
            BaseAction{
                text: i18n.tr("Help")
                iconName: "help"
            
                onTrigger:{
                    //Navigate to Settings Page section in the Help Page
                    stackView.gotToHelp(["settingspage", "main"])
                }
            }
        ]
    
    
    Flickable {
        id: settingsFlickable
        
        anchors.fill: parent
        contentHeight: settingsColumn.implicitHeight + (settingsColumn.anchors.margins * 2)
        boundsBehavior: Flickable.DragOverBounds

        ScrollIndicator.vertical: ScrollIndicator { }
        
        function moveScroll(newY){
            contentY = newY
        }
    
        Column {
            id: settingsColumn
            
            spacing: 10
            
            anchors{
                fill: parent
                margins: 25
            }

            
            ComboBoxItem{       
                id: themeSettings
                        
                text: i18n.tr("Theme")
                model: settingsModels.themeModel
                currentIndex: model.find(settings.currentTheme, "text")
                
                onCurrentIndexChanged:{
                    settings.currentTheme = model.get(currentIndex).text
                }
            }
            
            CheckBoxItem {
                text: i18n.tr("Colored texts")
                checkState: settings.coloredText ? Qt.Checked : Qt.Unchecked
                onCheckStateChanged: {
                    switch (checkState) {
                        case Qt.Checked:
                            settings.coloredText = true
                            break;
                        case Qt.Unchecked:
                            settings.coloredText = false
                            break;
                    }
                }
            }
        }
    }
}
