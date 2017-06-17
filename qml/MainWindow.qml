import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.0


ApplicationWindow {
    visible: true
    width: 640
    height: 480
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
        }

        StackView {
            id: stack
            anchors.top: topBar.bottom
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.left: parent.left
//            initialItem: welcomeViewComponent.createObject(stack,{})
            initialItem: addTableViewComponent.createObject(stack,{})
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
        AddTable{
            id: addTableView
        }
    }
}

