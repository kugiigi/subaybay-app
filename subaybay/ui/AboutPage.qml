import QtQuick 2.12
import QtQuick.Controls 2.5
import "../components/aboutpage"
import "../components/common"

BasePage {
    id: aboutPage
    
    title: i18n.tr("About") + " Subaybay"
    flickable: aboutFlickable
    
    headerRightActions: [
        BaseAction{
            text: i18n.tr("Help")
            iconName: "help"
        
            onTrigger:{
                //Navigate to About Page section in the Help Page
                // stackView.gotToHelp([3, 0])
                 stackView.gotToHelp(["aboutpage", "main"])
            }
        }
    ]
    
    Flickable {
        id: aboutFlickable
        
        anchors.fill: parent
        contentHeight: listView.height + iconComponent.height + 50
        boundsBehavior: Flickable.DragOverBounds

        ScrollIndicator.vertical: ScrollIndicator { }
        
        function externalLinkConfirmation(link){
            externalDialog.externalURL = link
            externalDialog.openNormal()
        }
        
        
        IconComponent{
            id: iconComponent
            
            anchors {
                top: parent.top
                topMargin: 20
                left: parent.left
                right: parent.right
            }
        }
        
        ListView{
            id: listView
            
            model: aboutModel
            height: contentHeight
            interactive: false
            
            anchors{
                top: iconComponent.bottom
                topMargin: 20
                left: parent.left
                right: parent.right
            }
            
            section{
                property: "section"
                delegate: SectionItem{text: section}
            }
            
            delegate: NavigationItem{
                title: model.text
                subtitle: model.subText
                iconName: model.icon
                url: model.urlText
            }
        }
        
        ListModel {
            id: aboutModel
            
            Component.onCompleted: fillData()
    
            function fillData(){
                append({"section": i18n.tr("Companion"), "text": i18n.tr("Webapp"), "subText": "For viewing of data remotely", "icon": "stock_website", "urlText": "https://subaybay.kugiverse.com"})
                append({"section": i18n.tr("Support"), "text": i18n.tr("Report a bug"), "subText": "", "icon": "mail-mark-important", "urlText": "https://github.com/kugiigi/subaybay-app/issues"})
                append({"section": i18n.tr("Support"), "text": i18n.tr("Contact Developer"), "subText": "", "icon": "stock_email", "urlText": "mailto:kugi_eusebio@protonmail.com"})
                append({"section": i18n.tr("Support"), "text": i18n.tr("View source"), "subText": "", "icon": "stock_document", "urlText": "https://github.com/kugiigi/subaybay-app"})
                append({"section": i18n.tr("Support"), "text": i18n.tr("Donate"), "subText": "", "icon": "like", "urlText": "https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=2GBQRJGLZMBCL"})
                append({"section": i18n.tr("Support"), "text": i18n.tr("View in OpenStore"), "subText": "", "icon": "ubuntu-store-symbolic", "urlText": "openstore://subaybay.kugiigi"})
                append({"section": i18n.tr("Support"), "text": i18n.tr("Other apps by the developer"), "subText": "", "icon": "stock_application", "urlText": "https://open-store.io/?search=author%3AKugi%20Eusebio"})
                append({"section": i18n.tr("Developers"), "text": "Kugi Eusebio", "subText": i18n.tr("Main developer"), "icon": "", "urlText": "https://github.com/kugiigi"})
                append({"section": i18n.tr("Powered by"), "text": "moment.js", "subText": i18n.tr("Date and Time manipulation and formatting"), "icon": "", "urlText": "http://momentjs.com/"})
                append({"section": i18n.tr("Powered by"), "text": "Nymea app components", "subText": i18n.tr("Date and time pickers"), "icon": "", "urlText": "https://github.com/nymea/nymea-app"})
            }
        }
    }
    
    ExternalDialog{
        id: externalDialog
    }
}
