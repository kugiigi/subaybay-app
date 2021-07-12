import QtQuick 2.12
import QtQuick.Controls 2.5
import QtQuick.Layouts 1.3

ColumnLayout{
    id: delagate
    
    spacing: 3
    
    Label{
        Layout.fillWidth: true
        
        text: modelData.header
        font.pixelSize: 20
        elide: Text.ElideRight
    }
    
    Label{
        Layout.fillWidth: true
        
        text: modelData.descr
        font.pixelSize: 15
        wrapMode: Text.Wrap
    }
}
