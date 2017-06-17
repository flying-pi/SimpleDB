import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.0

import SimpleDB 1.0


Item {
    id: item1

    WelcomeInfo{
        id: welcomeInfo
    }

    visible: true
    anchors.fill: parent

    ListView {
        id:db_view
        anchors.right: parent.right
        anchors.left: parent.left
        model: welcomeInfo.exist_bd
        delegate: Button {
        anchors.horizontalCenter: parent.horizontalCenter
            text:name
        }
        onCountChanged: {
            var root = db_view.visibleChildren[0]
            var listViewHeight = 0
            var listViewWidth = 0

            for (var i = 0; i < root.visibleChildren.length; i++) {
                listViewHeight += root.visibleChildren[i].height
            }

            db_view.height = listViewHeight
            db_view.width = listViewWidth
        }

    }


    Button {
        anchors.horizontalCenter: parent.horizontalCenter
        id: button
        text: qsTr("Button")
        anchors.top: db_view.bottom
        anchors.topMargin: 0
        onClicked: {
            stack.push(addTableViewComponent.createObject(stack,{}))
        }
    }

}

