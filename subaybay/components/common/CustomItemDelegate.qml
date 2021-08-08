import QtQuick 2.12
import QtQuick.Controls 2.5
import QtQuick.Controls.Suru 2.2

ItemDelegate {
    id: control
    
    property alias divider: dividerRec

    implicitWidth: Math.max(background ? background.implicitWidth : 0,
                            contentItem.implicitWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(background ? background.implicitHeight : 0,
                             Math.max(contentItem.implicitHeight,
                                      indicator ? indicator.implicitHeight : 0) + topPadding + bottomPadding)
    baselineOffset: contentItem.y + contentItem.baselineOffset

    topPadding: control.Suru.units.gu(2)
    bottomPadding: control.Suru.units.gu(2)
    leftPadding: control.Suru.units.gu(2)
    rightPadding: control.Suru.units.gu(2)

    spacing: control.Suru.units.gu(1.5)

    opacity: control.enabled ? 1.0 : 0.5

    contentItem: Text {
        leftPadding: !control.mirrored ? 0 : (control.indicator ? control.indicator.width : 0) + control.spacing
        rightPadding: control.mirrored ? 0 : (control.indicator ? control.indicator.width : 0) + control.spacing

        text: control.text
        font: control.font
        color: control.Suru.foregroundColor

        elide: Text.ElideRight
        visible: control.text
        horizontalAlignment: Text.AlignLeft
        verticalAlignment: Text.AlignVCenter
    }

    background: Rectangle {
        implicitHeight: control.Suru.units.gu(7)
        color: control.Suru.backgroundColor

        Item {
            width: parent.width
            height: parent.height

            Rectangle {
                id: highlightRect
                width: parent.width
                height: parent.height

                visible: control.down || control.highlighted

                opacity: control.highlighted ? 0.5 : 1.0
                color: {
                    if (control.highlighted)
                        return control.Suru.highlightColor

                    return control.down ? Qt.darker(control.Suru.secondaryBackgroundColor, 1.1) : control.Suru.secondaryBackgroundColor
                }

                Behavior on color {
                    ColorAnimation {
                        duration: control.Suru.animations.FastDuration
                        easing: control.Suru.animations.EasingIn
                    }
                }

                Behavior on opacity {
                    NumberAnimation {
                        duration: control.Suru.animations.FastDuration
                        easing: control.Suru.animations.EasingIn
                    }
                }
            }

            Rectangle {
                width: parent.width
                height: parent.height

                visible: control.visualFocus
                color: "transparent"
                border {
                    width: control.Suru.units.dp(2)
                    color: control.Suru.activeFocusColor
                }
            }
        }

        Rectangle {
            id: dividerRec

            anchors.bottom: parent.bottom
            width: parent.width
            height: control.Suru.units.dp(1)
            color: control.Suru.neutralColor
        }
    }
}
