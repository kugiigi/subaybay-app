import QtQuick 2.12
import QtQuick.Controls 2.5
import QtQuick.Controls.Suru 2.2
import Lomiri.Components 1.3 as UT
import QtQuick.Layouts 1.12
import "../common"
import "../../library/functions.js" as Functions

CustomButton {
    id: summaryValues

    property alias valuesModel: valuesRepeater.model
    property bool expanded: false
    
    readonly property bool multipleValues: valuesModel && valuesModel.length > 1 ? true : false

    implicitHeight: content.height + content.anchors.leftMargin

    onClicked: {
        if (multipleValues) {
            expanded = !expanded
        }
    }
    
    onMultipleValuesChanged: {
        if (!multipleValues) {
            expanded = false
        }
    }

    // Formats the values
    function getFormattedValues(data) {
        var formattedText = ""
        var value = data.value
        var unit = data.unit
        
        if (value) {
            switch(data.value_type) {
                case "total":
                case "average":
                    formattedText = i18n.tr("%1 %2").arg(value).arg(unit)
                    break;
                case "last":
                case "highest":
                    formattedText = i18n.tr("%1 - %2 %3").arg(value.entryDate).arg(value.value).arg(unit)
                    break;
                default:
                    formattedText = "%1 %2".arg(value).arg(unit)
                    break;
            }
        }
        
        return formattedText
    }
    
    function getValueTypeLabel(valueType) {
        var formattedText = ""
        
        if (valueType) {
            switch(valueType) {
                case "total":
                    formattedText = i18n.tr("Total")
                    break;
                case "average":
                    formattedText = i18n.tr("Average")
                    break;
                case "last":
                    formattedText = i18n.tr("Most recent")
                    break;
                case "highest":
                    formattedText = i18n.tr("Highest")
                    break;
                default:
                    formattedText = ""
                    break;
            }
        }
        
        return formattedText
    }

    ColumnLayout {
        id: content

        spacing: Suru.units.gu(1)

        anchors {
            top: parent.top
            topMargin: expandIcon.visible ? 0 : content.spacing
            left: parent.left
            leftMargin: Suru.units.gu(2)
            right: parent.right
            rightMargin: anchors.leftMargin
        }

        UT.Icon {
            id: expandIcon

            Layout.alignment: Qt.AlignCenter
            name: summaryValues.expanded ? "go-down" : "go-up"
            implicitWidth: Suru.units.gu(3)
            implicitHeight: implicitWidth
            visible: multipleValues
        }

        Repeater {
            id: valuesRepeater

            delegate: ColumnLayout {
                visible: index == 0 || summaryValues.expanded

                CustomLabel {
                    Layout.fillWidth: true
            
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    
                    Suru.textLevel: Suru.HeadingThree
                    wrapMode: Text.WordWrap
                    text: getValueTypeLabel(modelData.value_type)
                }

                CustomLabel {
                    Layout.fillWidth: true
            
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    Suru.textLevel: Suru.HeadingOne
                    wrapMode: Text.WordWrap
                    text: getFormattedValues(modelData)
                    role: "value"
                }
            }
        }
    }
}
