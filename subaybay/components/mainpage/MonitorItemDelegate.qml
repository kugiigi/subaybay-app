import QtQuick 2.12
import QtQuick.Controls 2.5
import QtQuick.Controls.Suru 2.2
import QtQuick.Layouts 1.12
import "../common"

ColumnLayout {
    id: monitorItemDelegate
    
    property alias title: titleLabel.text
    property alias value: valueLabel.text
    property alias unit: unitLabel.text
    
    
    CustomLabel {
        id: titleLabel
        
        Layout.fillWidth: true
        Suru.textLevel: Suru.HeadingThree
        font.pointSize: 11
        font.italic: true
        wrapMode: Text.WordWrap
        role: "date"
    }
    
    RowLayout {
        id: valueRow
        
        Layout.fillWidth: true
        
        CustomLabel {
            id: valueLabel
            
            Suru.textLevel: Suru.HeadingTwo
            role: "value"
        }
        
        CustomLabel {
            id: unitLabel
            
            Layout.alignment: Qt.AlignBottom
            Suru.textLevel: Suru.Small
            role: "value"
        }
    }
}