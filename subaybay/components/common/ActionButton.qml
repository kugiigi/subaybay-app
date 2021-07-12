import QtQuick.Controls 2.5
import Ubuntu.Components 1.3 as UT
import QtQuick.Layouts 1.12
import "../common"

CustomButton {
	id: actionButton

	property alias iconName: icon.name

  color: theme.normal.foreground
  focusPolicy: Qt.NoFocus
    
	UT.Icon {
		id: icon
		
		implicitWidth: actionButton.width * 0.6
		implicitHeight: implicitWidth
		anchors.centerIn: parent
		color: theme.normal.foregroundText
	}
}
