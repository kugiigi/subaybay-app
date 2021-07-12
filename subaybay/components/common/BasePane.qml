import QtQuick 2.12
import QtQuick.Controls 2.5

Pane{
    id: basePane
    
    property var actions: []
    property string inputTextValue
    property Flickable flickable
    property string label
    property string iconName
    
    padding: 0
}