import QtQuick 2.7
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.0
import QtQuick.Controls.Styles 1.4
import QtQuick.Window 2.2
import QtQuick.Controls 2.1
import QtQuick.Dialogs 1.2
import QtQuick 2.2
import QtQuick.Window 2.2


Item {
    id: db_editer

    ListModel{
        id:requestListModel
    }

    Component{
        id:messaheDialogComponent
        MessageDialog {
        }
    }

    function showError(title,message){
        var dialog = messaheDialogComponent.createObject(null,{title:title,text: message})
        dialog.open();
    }

    property Dialog createRequestDialog: null
    height: 600

    Component{
        id:createRequestDialogComponent
        Dialog {
            width: 350
            height: 175
            id: createRequestDialog
            title: "Create request"
            standardButtons: StandardButton.Ok | StandardButton.Cancel
            signal onRequestCreated(string requestAlias,string requestBody)

            ColumnLayout {
                width: parent.width
                height: parent.height/2
                spacing: 7
                TextField {
                    id: requestName
                    height: 20
                    anchors.right: parent.right
                    anchors.left: parent.left
                    placeholderText: "Enter name for request var"
                }
                TextField {
                    id: requestContent
                    height: requestName.height
                    anchors.right: parent.right
                    anchors.left: parent.left
                    placeholderText: "Enter request"
                }
            }

            onButtonClicked: {
                if (clickedButton == StandardButton.Ok && requestName.text.length>0 && requestContent.text.length>0 )
                    createRequestDialog.onRequestCreated(requestName.text,requestContent.text)
            }

        }
    }

    function requestAlias(obj){ return obj.requestAlias; }

    function requestBody(obj){ return obj.requestBody; }

    function addNewRequst(reqAlias,reqBody){
        for(var i=0;i<requestListModel.count;i++){
            console.log(requestAlias(requestListModel.get(i)))
            if(requestAlias(requestListModel.get(i)) == reqAlias){
                showError("error","this request have not unique name")
                return;
            }
        }
        requestListModel.append({requestAlias:reqAlias,requestBody:reqBody})
        requestListView.update()
    }

    Rectangle{
        id:wokBack
        color: "#dff2f5"
        anchors.bottom: toolBack.top
        anchors.bottomMargin: 0
        anchors.right: parent.right
        anchors.rightMargin: 0
        anchors.left: parent.left
        anchors.leftMargin: 0
        anchors.top: parent.top
        anchors.topMargin: 0

    }


    Rectangle{
        id:toolBack
        y: 330
        height: 200
        color: "#f9f6f6"
        border.color: "#000000"
        anchors.right: parent.right
        anchors.rightMargin: 0
        anchors.left: parent.left
        anchors.leftMargin: 0
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 0

        Button {
            id: addRequestButton
            height: 24
            text: qsTr("Add new request")
            anchors.left: parent.left
            anchors.leftMargin: 24
            anchors.top: parent.top
            anchors.topMargin: 12
            onClicked: {
                if(createRequestDialog == null){
                    createRequestDialog= createRequestDialogComponent.createObject(null, {})
                    createRequestDialog.onRequestCreated.connect(addNewRequst)
                }
                createRequestDialog.open()
                //                addNewRequst("r"+requestListModel.count,"test")
            }
        }
        ScrollView{
            id:requestListScroll
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 12
            anchors.right: parent.right
            anchors.rightMargin: 24
            anchors.left: parent.left
            anchors.leftMargin: 24
            anchors.top: addRequestButton.bottom
            anchors.topMargin: 12

            ListView{
                id:requestListView
                model:requestListModel
                spacing: 7

                delegate: Rectangle {
                    color: "#f5f5f5"
                    border.color: "#00b5b5b5"
                    border.width: 3
                    height: 40
                    width: requestListScroll.width
                    RowLayout {
                        id: rowLayout
                        width: requestListScroll.width
                        Text {
                            id: text1
                            text: qsTr("#")
                            font.pixelSize: 16
                        }

                        Text {
                            id: reqNumber
                            width: 24
                            font.pixelSize: 16
                        }

                        Text {
                            id: alias
                            text: requestAlias
                            font.pixelSize: 16
                        }

                        Text {
                            id: request
                            text: requestBody
                            Layout.fillWidth: true
                            font.pixelSize: 16
                        }

                        Button {
                            id: deleteBtn
                            text: qsTr("Remove")
                        }
                    }
                }


            }
        }

    }

    Rectangle{
        id:moveLine
        width: parent.width
        height: 5
        color: "black"
        gradient: Gradient {
            GradientStop {
                position: 0.00;
                color: "#00ffffff";
            }
            GradientStop {
                position: 0.50;
                color: "#55aaaaaa";
            }
            GradientStop {
                position: 1.00;
                color: "#00ffffff";
            }
        }
        anchors.bottom: toolBack.top
        anchors.bottomMargin: 0
        MouseArea {
            cursorShape: Qt.SizeVerCursor
            anchors.fill: parent
            drag{ target: parent; axis: Drag.YAxis }
            drag.smoothed: true
            onMouseYChanged: {
                if(drag.active){
                    toolBack.y = mouseY
                    toolBack.height = toolBack.height - mouseY
                }
            }
        }
    }
}

