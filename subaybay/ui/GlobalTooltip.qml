import QtQuick.Controls 2.5

ToolTip {
    id: tooltip

    property int defaultTimeout: 3000

    parent: mainView.corePage
    delay: 200

    function display(customText, position, customTimeout) {
        switch(position) {
            case "TOP":
                y = Qt.binding(function() { return applicationHeader.height + 10 } );
                break;
            case "BOTTOM":
            default:
                y = Qt.binding(function() {return parent.height - 100} );
            break;
        }
        
        if (customTimeout) {
            timeout = customTimeout
        } else {
            timeout = defaultTimeout
        }
        
        text = customText
        
        visible = true
    }
    
    timeout: defaultTimeout
}
