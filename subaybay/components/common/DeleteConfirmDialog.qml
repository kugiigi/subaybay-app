import QtQuick 2.12
import QtQuick.Controls 2.5
import QtQuick.Controls.Suru 2.2
import QtQuick.Layouts 1.12
import "../common"

BaseDialog {
    id: deleteConfirmDialog

    property alias subtitle: subtitleLabel.text

    parent: mainView.corePage
    height: Suru.units.gu(20)
    standardButtons: Dialog.Ok | Dialog.Cancel

    Label {
        id: subtitleLabel

        wrapMode: Text.Wrap
        anchors {
            top: parent.top
            topMargin: Suru.units.gu(2)
            left: parent.left
            right: parent.right
        }
    }
}