import QtQuick 2.12
import QtQuick.Controls 2.5
import QtQuick.Controls.Suru 2.2


BasePickerDialog {
    id: datePickerDialog

    property alias dateTime: p.date

    DatePicker {
        id: p
        width: parent.width
        height: parent.height
    }
}
