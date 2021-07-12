function getHelpData() {
    var helpData = {
      "help": {
        "pages": [
          {
            "id": "navpage",
            "title": i18n.tr("Navigation"),
            "icon": "navigation-menu",
            "qml": "NavigationPane.qml",
            "panes": [
              {
                "id": "main",
                "title": i18n.tr("Basics"),
                "descr": i18n.tr("These are the basic actions that are commonly available when navigating within the app."),
                "content": [
                  {
                    "header": i18n.tr("Header"),
                    "descr": i18n.tr("The header is consisted of the left action, title and the right action.\nLeft action is reserved for the \"Menu\" button and the Back button.\nThe title displays the appropriate text that best describe the current page.\nRight action is a dynamic list of context-based actions that you can perform in the current page.")
                  },
                  {
                    "header": i18n.tr("Drawer"),
                    "descr": i18n.tr("The left action in the header contains the \"Menu\" button which you can use to open the Drawer. The Drawer can be used to navigate between other pages within the app which includes pages such as Setttings, About and the Help page.")
                  },
                  {
                    "header": i18n.tr("Content"),
                    "descr": i18n.tr("The Content is reserved to display the actual content of the current page which you can consume. Contents could be read-only or interactive.\n\nWhenever the footer is available, you can swipe horizontally to navigate between tabs.")
                  },
                  {
                    "header": i18n.tr("Footer"),
                    "descr": i18n.tr("The footer contains the available tabs in the current page if there's any.")
                  }
                ]
              },
              {
                "id": "bottomedge",
                "title": i18n.tr("Bottom Edge"),
                "descr": i18n.tr("This app supports bottom edge gestures to help you navigate with one hand with ease. Just swipe from either side of the bottom edge and you'll trigger the corresponding actions.\nOther elements in the app also adjust their position if you trigger/open them from the bottom edge. See for yourself!"),
                "content": [
                  {
                    "header": i18n.tr("Left Bottom Edge"),
                    "descr": i18n.tr("The left bottom edge is reserved to trigger the action(s) in the left side of the header. Currently, this can be the \"Menu\" button or the \"Back\" button.\nThe Drawer adjusts its layout depending on how you opened it - normally or via the bottom edge.")
                  },
                  {
                    "header": i18n.tr("Right Bototm Edge"),
                    "descr": i18n.tr("The right bottom edge is reserved to trigger the action(s) in the right side of the header. This can directly trigger the right action, if there's only one available, or it can show you a menu of available context-based actions that are present in the right side of the header.\nTooltips and dialogs adjust their position depending on how you opened them - normally or via the bottom edge.")
                  },
                  {
                    "header": i18n.tr("TRY THEM NOW!"),
                    "descr": i18n.tr("Swipe from the left bottom edge to go back.\nSwipe from the right bottom edge to see all the available Help pages.")
                  }
                ]
              },
              {
                "id": "oneui",
                "title": i18n.tr("Reachability"),
                "descr": i18n.tr("This is totally not like Samsung's One UI 😂 "),
                "content": [
                  {
                    "header": i18n.tr("List Views / Flickables"),
                    "descr": i18n.tr("List Views / Flickables (scrollable contents) can be dragged down further when already at the top to increase the height of the header and make the upper controls reachable with ease.\n\nThe header will return to normal when you move the list upwards.")
                  },
                  {
                    "header": i18n.tr("TRY IT NOW!"),
                    "descr": i18n.tr("Drag this page down until you see the header cover almost half of the page and reach the button at the top.")
                  }
                ]
              }
            ]
          },
        //   {
        //     "title": "Main Page",
        //     "icon": "stock_application",
        //     "qml": "DetailsPane.qml",
        //     "panes": [
        //       {
        //         "title": "Basics",
        //         "descr": "The main page contains all the most important Palitan functionalities.",
        //         "content": [
        //           {
        //             "header": "Input Box",
        //             "descr": "The Input Box is at the very bottom of the page that is available across all tabs in the main page. You input here the amount that you want to see the conversion to other currencies."
        //           },
        //           {
        //             "header": "Tabs",
        //             "descr": "There are currently 3 tabs: Favorites, Convert and Full view). You can navigate between them by using the tab buttons at the bottom or simply by swiping horizontally."
        //           }
        //         ]
        //       },
        //       {
        //         "title": "Convert Page",
        //         "descr": "This page is the most important page in Palitan. You mainly do the currency conversions in this page. This is the first page shown when you open Palitan.",
        //         "content": [
        //           {
        //             "header": "Data Details",
        //             "descr": "You can see the exchange rate details at the very top of the page. It includes the last update date and the current source fo the data."
        //           },
        //           {
        //             "header": "Results",
        //             "descr": "The results of the conversion can be seen at the middle of the page. It includes the actual resulting value and the corresponding rate between the selected currencies."
        //           },
        //           {
        //             "header": "Currency Tumblers",
        //             "descr": "Two currency tumblers are available at the bottom of the page that can be used to select the \"Base\" and the \"Destination\" currencies.\nA swap button is available between the currency tumblers to swap the \"Base\" and the \"Destination\" currencies.\nA find button is also available in each tumbler to easily search for a currency."
        //           },
        //           {
        //             "header": "Actions",
        //             "descr": "The following are the actions available:\n\nAdd to favorites: Add the currently selected currencies to your favorites.\nSwap: Swap the \"Base\" and the \"Destination\" currencies\nRefresh data: Update exchange rate data from the source. This needs a working internet connection."
        //           }
        //         ]
        //       },
        //       {
        //         "title": "Favorites",
        //         "descr": "This page contains the list of your favorites",
        //         "content": [
        //           {
        //             "header": "Item actions",
        //             "descr": "The following are the available actions for each favorite positioned as icons at the right side:\n\nUnfavorite: Deletes the current item from your favorites list.\nSwap: Swaps the \"Base\" and the \"Destination\" currencies of the current item\nConvert this: Sets the currencies in the Convert tab to the currencies of the current item and automatically navigate to the Convert tab."
        //           },
        //           {
        //             "header": "Actions",
        //             "descr": "The following are the actions available:\n\nAdd: Display the add dialog for adding new favorites.\nSort: Changes the current sorting rule of your favorites list\nRefresh data: Update exchange rate data from the source. This needs a working internet connection."
        //           }
        //         ]
        //       },
        //       {
        //         "title": "Full View",
        //         "descr": "This page contains all the available currencies with the conversion rate for each calculated from the \"Base\" currency in the Convert tab and current value in the Input Box.",
        //         "content": [
        //           {
        //             "header": "Item actions",
        //             "descr": "The following are the available actions for each favorite positioned as icons at the right side:\n\nSwap: Swaps the \"Base\" and the \"Destination\" currencies of the current item"
        //           },
        //           {
        //             "header": "Actions",
        //             "descr": "The following are the actions available:\n\nAdd: Display the add dialog for adding new favorites.\nSwap: Swaps the \"Base\" and the \"Destination\" currencies for all the items.\nSort: Displays the Sort dialog for changing the sorting rule of the currencies list.\nRefresh data: Update exchange rate data from the source. This needs a working internet connection."
        //           }
        //         ]
        //       }
        //     ]
        //   },
          {
            "id": "settingspage",
            "title": i18n.tr("Settings Page"),
            "icon": "settings",
            "qml": "DetailsPane.qml",
            "panes": [
              {
                "id": "main",
                "title": "",
                "descr": "",
                "content": [
                  {
                    "header": i18n.tr("Theme"),
                    "descr": i18n.tr("Changes the theme of the app.\nAvailable themes: System, Ambiance and SuruDark System follows the current system theme")
                  },
                  {
                    "header": i18n.tr("Colored text"),
                    "descr": i18n.tr("Option to enable or disable colored texts for values, dates, etc.")
                  }
                ]
              }
            ]
          },
          {
            "id": "aboutpage",
            "title": i18n.tr("About Page"),
            "icon": "info",
            "qml": "DetailsPane.qml",
            "panes": [
              {
                "id": "main",
                "title": "",
                "descr": i18n.tr("This page contains all the details about the app and their corresponding links if applicable."),
                "content": [
                  {
                    "header": i18n.tr("Support"),
                    "descr": i18n.tr("In this section, you can get links to report a bug, contact the developer, view the app's source, DONATE to the develeoper, view the app in OpenStore, and view the developer's other apps.")
                  },
                  {
                    "header": i18n.tr("Developers"),
                    "descr": i18n.tr("All involved developers, contributors and maintainers are listed here and the link to contact them.")
                  },
                  {
                    "header": i18n.tr("Powered by"),
                    "descr": i18n.tr("All 3rd party libraries that are used within the app is listed here.")
                  }
                ]
              }
            ]
          }
        ]
      }
    }

    return helpData.help.pages
}
