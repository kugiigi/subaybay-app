import QtQuick 2.12
import QtQuick.Controls 2.5
import QtQuick.Layouts 1.3

ColumnLayout{
    id: paneHeader
    
    visible: headerLabel.text || descrLabel.text
    spacing: 3
    
    Label{
        id: headerLabel
        
        Layout.fillWidth: true
        
        visible: text
        text: modelData.title
        font.pixelSize: 25
        color: theme.normal.backgroundText
        font.weight: Font.Medium
        elide: Text.ElideRight
    }
    
    Label{
        id: descrLabel
        
        Layout.fillWidth: true
        
        visible: text
        text: modelData.descr
        font.pixelSize: 15
        color: theme.normal.backgroundText
        wrapMode: Text.Wrap
    }
}
