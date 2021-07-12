import QtQuick 2.12
import QtQuick.Controls 2.5
import Ubuntu.Components 1.3 as UT

Page{
    id: basePage
    
    property list<UT.Action> headerLeftActions
    property list<UT.Action> headerRightActions
    property Flickable flickable

    focus: true
}
