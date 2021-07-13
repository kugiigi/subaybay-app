import QtQuick 2.12
import QtQuick.Controls 2.5
import QtQuick.Controls.Suru 2.2

TextField {
    id: customTextField
    
    property string role

    color: {
        if (settings.coloredText) {
            switch (role) {
                case "item":
                    Suru.activeFocusColor
                    break;
                case "value":
                    Suru.highlightColor
                    break;
                case "date":
                    Suru.secondaryForegroundColor
                    break;
                default:
                    Suru.foregroundColor
                    break;
            }
        } else {
            Suru.foregroundColor
        }
    }

    Suru.highlightType: {
        if (settings.coloredText) {
            switch (role) {
                case "item":
                    Suru.InformationHighlight
                    break;
                case "value":
                    Suru.PositiveHighlight
                    break;
                case "date":
                    Suru.WarningHighlight
                    break;
                default:
                    Suru.InformationHighlight
                    break;
            }
        } else {
            Suru.InformationHighlight
        }
    }
}