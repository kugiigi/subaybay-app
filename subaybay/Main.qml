import QtQuick 2.12
import Ubuntu.Components 1.3
import QtQuick.Controls.Suru 2.2
import Ubuntu.Components.Themes.Ambiance 1.3 as Ambiance
import Ubuntu.Components.Themes.SuruDark 1.3 as SuruDark
import QtQuick.Controls 2.5
import QtQuick.Layouts 1.3
import UserMetrics 0.1
import Ubuntu.Components 1.3 as UT
import "library/database.js" as Data
import "library/dataUtils.js" as DataUtils
import "library/functions.js" as Functions
import "components/listmodels"
import "components/common"
import "components"
import "ui"

ApplicationWindow {
    id: mainView

    readonly property QtObject drawer: drawerLoader.item
    readonly property string current_version: "1.6"
    readonly property var suruTheme: switch(settings.currentTheme) {
            case "System":
                if (Theme.name == "Ubuntu.Components.Themes.SuruDark") {
                    Suru.Dark
                } else {
                    Suru.Light
                }
                break
            case "Ambiance":
                Suru.Light
                break
            case "SuruDark":
                Suru.Dark
                break
        }
    
    property string displayMode: "Phone" //"Desktop" //"Phone" //"Tablet"
    property QtObject theme: Suru.theme === 1 ? suruDarkTheme : ambianceTheme
    property var dataUtils: DataUtils.dataUtils
    property var profiles: dataUtils.profiles
    property var monitoritems: dataUtils.monitoritems
    property var values: dataUtils.values(settings.activeProfile)
    property string currentDate: Functions.getToday()
    
    property alias settings: settingsLoader.item
    property alias mainModels: listModelsLoader.item
    property alias mainPage: mainPageLoader.item
    property alias corePage: corePage

    // objectName for functional testing purposes (autopilot-qt5)
    objectName: "mainView"

    title: "Subaybay"
    visible: false
    minimumWidth: 300
    
    Suru.theme: suruTheme //Suru.Light //Suru.Dark

    width: switch (displayMode) {
           case "Phone":
               units.gu(50)
               break
           case "Tablet":
               units.gu(100)
               break
           case "Desktop":
               units.gu(120)
               break
           default:
               units.gu(120)
               break
           }
    height: switch (displayMode) {
            case "Phone":
                units.gu(89)
                break
            case "Tablet":
                units.gu(56)
                break
            case "Desktop":
                units.gu(68)
                break
            default:
                units.gu(68)
                break
            }

    Component.onCompleted: {
        /*Meta data processing*/
        var currentDataBaseVersion = Data.checkUserVersion()

        if (currentDataBaseVersion === 0) {
            Data.createInitialData()
        }

        Data.databaseUpgrade(currentDataBaseVersion)
        settingsLoader.active = true
    }

    Ambiance.Palette{id: ambianceTheme}
    SuruDark.Palette{id: suruDarkTheme}
    
    function checkIfDayChanged() {
        if (!Functions.isToday(currentDate)) {
            currentDate = Functions.getToday()
        }
    }

    Metric {
        id: userMetric
        
        property string circleMetric

        name: "lastValues"
        format: circleMetric
        emptyFormat: i18n.tr("No monitoring data for today")
        domain: "subaybay.kugiigi"
    }
    
    MainView {
        //Only for making translation work
        id: dummyMainView
        applicationName: "subaybay.kugiigi"
        visible: false
    }

    Connections {
        target: Qt.application

        onStateChanged: {
            if (state == Qt.ApplicationActive) {
                checkIfDayChanged()
            }
        }
    }

    UT.LiveTimer {
        frequency: UT.LiveTimer.Hour
        onTrigger: {
            checkIfDayChanged()
        }
    }

    GlobalTooltip{
        id: tooltip
    }

    Loader {
        id: settingsLoader

        active: false
        asynchronous: true
        sourceComponent: SettingsComponent {}

        onLoaded: {
            listModelsLoader.active = true
        }
    }

    Connections {
        id: keyboard
        target: Qt.inputMethod
    }
    
    Loader {
        id: listModelsLoader

        active: false
        asynchronous: true
        sourceComponent: MainModels {}

        onLoaded: {
            mainPageLoader.active = true
        }
    }

    SettingsModels {
        id: settingsModels
    }

    ProfilesPopup {
      id: profilesPopup
    }

    NewEntryPopup {
        id: newEntryPopup
        
        onAccepted: mainModels.dashboardModel.refresh()
    }
    
    NewEntrySelectionPopup {
        id: newEntrySelection
    }

    Loader {
        id: drawerLoader
        
        active: true
        asynchronous: true
        sourceComponent: MenuDrawer{
                id: drawer
                 
                 model:  [
                    { title: i18n.tr("Settings"), source: Qt.resolvedUrl("ui/SettingsPage.qml"), iconName: "settings" }
                    ,{ title: i18n.tr("About"), source: Qt.resolvedUrl("ui/AboutPage.qml"), iconName: "info" }
                    ,{ title: i18n.tr("Help"), source: Qt.resolvedUrl("ui/HelpPage.qml"), iconName: "help" }
                ]
            }

        visible: status == Loader.Ready
    }
    
    Page {
      id: corePage

      anchors {
          left: parent.left
          right: parent.right
          top: parent.top
          bottom: keyboardRec.top
          bottomMargin: keyboard.target.visible ? Suru.units.gu(2) : 0
      }
      
      header: ApplicationHeader{
          id: applicationHeader

          expandable: mainView.height >= Suru.units.gu(60)
          flickable: mainPage && stackView.currentItem.flickable ? stackView.currentItem.flickable : null
          leftActions: BaseAction{
              visible: drawerLoader.visible
              text: i18n.tr("Menu")
              iconName: stackView.depth > 1 ? "back" : "navigation-menu"
              
              onTrigger:{
                  if (stackView.depth > 1) {
                          stackView.pop()
                          drawer.resetListIndex()
                      } else {
                          if(isBottom){
                              drawer.openBottom()
                          }else{
                              drawer.openTop()
                          }
                      }
                  }
              }
              
          rightActions: mainPage && stackView.currentItem.headerRightActions ? stackView.currentItem.headerRightActions : []
      }
    
      StackView {
          id: stackView
          
          function gotToHelp(navigation){
              push(Qt.resolvedUrl("ui/HelpPage.qml"), {initialNavigation: navigation})
          }
          
          initialItem: Rectangle{color: theme.normal.background}
          
          anchors.fill: parent
      }
    }

    KeyboardRectangle{
        id: keyboardRec
    }
    
    Loader {
        id: mainPageLoader
        
        active: false
        asynchronous: true
        source: "ui/MainPage.qml"

        visible: status == Loader.Ready

        onLoaded: {
            mainView.visible = true
            stackView.replace(item)
        }
    }
    
    Loader {
        id: rightSwipeAreaLoader

        z: 20
        active: true
        asynchronous: true
        visible: status == Loader.Ready
        sourceComponent: BottomSwipeArea{
            onTriggered: applicationHeader.triggerRight(true)
        }
        
        anchors{
            right: parent.right
            left: parent.horizontalCenter
            bottom: parent.bottom
        }
    }  
    
    Loader {
        id: leftSwipeAreaLoader

        z: 20
        active: true
        asynchronous: true
        visible: status == Loader.Ready
        sourceComponent: BottomSwipeArea{
            onTriggered: applicationHeader.triggerLeft(true)
        }
        
        anchors{
            left: parent.left
            right: parent.horizontalCenter
            bottom: parent.bottom
        }
    }

    Loader {
        id: bottomEdgeHintLoader
        
        z: 10
        active: settings.firstRun
        asynchronous: true
        visible: status == Loader.Ready
        sourceComponent: BottomEdgeHint{}
        
        anchors{
            fill: parent
        }
    }
}
