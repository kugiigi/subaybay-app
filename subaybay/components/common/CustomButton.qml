import QtQuick 2.12
import QtQuick.Controls 2.5
import QtQuick.Controls.Suru 2.2

AbstractButton {
  id: customButton
  
  property alias radius: bg.radius
  property alias color: bg._normalColor
  property alias border: bg.border
  property bool highlighted: false

  focusPolicy: Qt.TabFocus
  focus: false

  background: Rectangle {
      id: bg
      
      property color _normalColor: Suru.backgroundColor

      implicitWidth: customButton.Suru.units.gu(4)
      implicitHeight: customButton.Suru.units.gu(6)

      color: customButton.highlighted || customButton.down ? _normalColor.hslLightness > 0.1 ? Qt.darker(_normalColor, 1.2)
                                      : Qt.lighter(_normalColor, 2.0)
              : _normalColor

      Behavior on color {
          ColorAnimation {
              duration: Suru.animations.SnapDuration
              easing: Suru.animations.EasingIn
          }
      }
  }
}