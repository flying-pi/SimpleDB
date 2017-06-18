import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.0


ApplicationWindow {
    id:mainWindow
    visible: true
    width: 900
    height: 650
    title: qsTr("Welcome")
    Column{
        id: column
        anchors.fill: parent

        spacing: 10
        Row{
            id: topBar
            height:50
            anchors.right: parent.right
            anchors.left: parent.left
            Rectangle{
                color: "#6f88e4"
                width: parent.width
                height: parent.height
            }

            Button {
                id: back_btn
                text: qsTr("Back")
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 10
                anchors.top: parent.top
                anchors.topMargin: 10
                anchors.left: parent.left
                anchors.leftMargin: 10
                onClicked: {
                    stack.pop()
                }
            }
        }

        StackView {
            id: stack
            anchors.top: topBar.bottom
            anchors.bottom: parent.bottom
            width: mainWindow.width
            //            initialItem: welcomeViewComponent.createObject(stack,{rootWindow:mainWindow})
            initialItem: createFormComponent.createObject(stack,{rootWindow:mainWindow})
            //            initialItem: addTableViewComponent.createObject(stack,{})
        }

        Component{
            id: welcomeViewComponent
            Welcome{
            }
        }

        Component{
            id: addTableViewComponent
            AddTable{
            }
        }

        Component{
            id: createFormComponent
            CreateForm{
            }
        }
    }
}

