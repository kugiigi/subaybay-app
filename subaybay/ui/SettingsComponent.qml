import QtQuick 2.12
import Qt.labs.settings 1.0


Item{
    id: settingsComponent
    
    //Settings page
    property alias style: settings.style
    property alias currentTheme: settings.currentTheme
    property alias coloredText:  settings.coloredText
    
    //Saved data
    property alias activeProfile: settings.activeProfile
    property alias firstRun: settings.firstRun

    Settings {
        id: settings
    
        //Settings page
        property string style: "Suru"
        property string currentTheme: "System"
        property bool coloredText: true
        
        //Saved data
        property int activeProfile: 1
        property bool firstRun: true
    }
}
