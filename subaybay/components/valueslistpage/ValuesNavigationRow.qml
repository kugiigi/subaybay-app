import QtQuick 2.12
import QtQuick.Controls 2.5
import QtQuick.Controls.Suru 2.2
import QtQuick.Layouts 1.12
import "../common"


RowLayout {
    id: navigationRow
    
    property alias itemTitle: itemLabel.text
    property alias dateTitle: dateLabel.text
    property alias scopeTItle: scopeLabel.text
    property bool biggerDateLabel: true
    
    signal criteria
    signal next
    signal previous

    spacing: 0

    CustomButton {
        id: detailsButton

        Layout.fillWidth: true
        Layout.fillHeight: true

        onClicked: {
            navigationRow.criteria()
        }

        ColumnLayout {
            anchors {
                top: parent.top
                topMargin: 10
                left: parent.left
                leftMargin: 15
                right: parent.right
                rightMargin: anchors.leftMargin
            }

            spacing: 10

            CustomLabel {
                id: itemLabel
    
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.alignment: Qt.AlignBaseline
                Suru.textLevel: navigationRow.biggerDateLabel ? Suru.HeadingThree : Suru.HeadingOne
                role: "item"
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 10
    
                CustomLabel {
                    id: dateLabel
      
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignBaseline
                    Suru.textLevel: Suru.HeadingTwo
                    fontSizeMode: Text.HorizontalFit
                    font.pointSize: navigationRow.biggerDateLabel ? Suru.units.gu(2.5) : Suru.units.gu(2)
                    minimumPointSize: navigationRow.biggerDateLabel ? Suru.units.gu(1.5) : Suru.units.gu(1)
                    font.italic: true
                    role: "date"
                }
              
                CustomLabel {
                    id: scopeLabel

                    Layout.alignment: Qt.AlignBottom
                    Suru.textLevel: Suru.HeadingThree
                    text: valuesListPage.scope
                    visible: false
                }
            }

        }
    }
    
    ActionButton {
        id: prevButton

        Layout.preferredWidth: 45
        Layout.fillHeight: true
        iconName: "previous"
        color: theme.normal.background
        onClicked: navigationRow.previous()
    }

    ActionButton {
        id: nextButton

        Layout.preferredWidth: 45
        Layout.fillHeight: true
        iconName: "next"
        color: theme.normal.background
        onClicked: navigationRow.next()
    }
}
