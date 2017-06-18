import QtQuick 2.7
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.0
import QtQuick.Controls.Styles 1.4
import QtQuick.Window 2.2
import QtQuick.Controls 2.1
import QtQuick.Dialogs 1.2
import QtQuick 2.2
import QtQuick.Window 2.2
import QtGraphicalEffects 1.0


Item {
    id: db_editer
    anchors.fill: parent

    ListModel{
        id:requestListModel
    }

    Component{
        id:messaheDialogComponent
        MessageDialog {
        }
    }

    function showMessahe(title,message){
        var dialog = messaheDialogComponent.createObject(null,{title:title,text: message})
        dialog.open();
    }

    property Dialog createRequestDialog: null
    height: 600

    Component{
        id:createRequestDialogComponent
        Dialog {
            id: createRequestDialog
            width: 400
            height: 250
            title: "Create request"
            standardButtons: StandardButton.Ok | StandardButton.Cancel | StandardButton.Help
            signal onRequestCreated(string requestAlias,string requestBody)

            ColumnLayout {
                width: parent.width
                height: parent.height/2
                spacing: 7

                Text {
                    id: reauestDialogHelp
                    width: createRequestDialog
                    text:
                        "Запит може містити змінні, котрі вносятся в нього \n\
наступним чином: {var_name=default_value}. \n\
var_name - ім'я змінної, повино починатись з літери \n\
і містити лише символи латинського алфавіту та цифри. \n\
default_value - значення за умвченням.\n\
default_value пишется через знак рівності \n\
і не є обов'язковим"
                    font.pointSize: 12
                    wrapMode: Text.WordWrap
                    visible: false
                }

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
                if(clickedButton == StandardButton.Help){
                    reauestDialogHelp.visible = !reauestDialogHelp.visible
                }else if (clickedButton == StandardButton.Ok && requestName.text.length>0 && requestContent.text.length>0 )
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
                showMessahe("Error","this request have not unique name")
                return;
            }
        }
        requestListModel.append({requestAlias:reqAlias,requestBody:reqBody})
        requestListView.update()
    }

    Rectangle {
        id: componentBox
        width: 200
        color: "#009dff"
        border.color: "#00000000"
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 0
        anchors.top: parent.top
        anchors.topMargin: 0
    }

    Rectangle{
        id:wokBack
        color: "#dff2f5"
        anchors.bottom: toolBack.top
        anchors.bottomMargin: 0
        anchors.right: parent.right
        anchors.rightMargin: 0
        anchors.left: componentBox.right
        anchors.leftMargin: 0
        anchors.top: parent.top
        anchors.topMargin: 0

    }


    Rectangle{
        id:toolBack
        height: 200
        color: "#f9f6f6"
        border.color: "#000000"
        anchors.right: parent.right
        anchors.rightMargin: 0
        anchors.left: componentBox.right
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
                    id:requestListItem
                    color: "#e1e1fd"
                    border.color: "#7c8088"
                    border.width: 4
                    height: 55
                    width: requestListScroll.width

                    RowLayout {
                        anchors.margins: 7
                         anchors.verticalCenter: requestListItem.verticalCenter
                        id: rowLayout
                        width: requestListScroll.width
                        Text {
                        anchors.left: parent.left
                            anchors.leftMargin: 16
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
                            color: "#424242"
                            text: requestAlias
                            font.bold: true
                            font.pixelSize: 14
                            anchors.rightMargin: 15
                        }

                        Text {
                            id: request
                            text: requestBody
                            Layout.fillWidth: true
                            font.pixelSize: 16
                        }

                        Button {
                            anchors.right: parent.right
                            anchors.rightMargin: 16
                            anchors.verticalCenter: requestListItem.verticalCenter
                            id: deleteBtn
                            text: qsTr("Remove")
                        }
                    }
                }


            }
        }

    }

    Rectangle{
        id:workToolMove
        height: 20
        anchors.right: parent.right
        anchors.rightMargin: 0
        anchors.left: componentBox.right
        anchors.leftMargin: 0
        anchors.bottom: toolBack.top
        anchors.bottomMargin: -10

        gradient: Gradient {
            GradientStop {
                position: 0.00;
                color: "#22ffffff";
            }
            GradientStop {
                position: 0.50;
                color: "#99aaaaaa";
            }
            GradientStop {
                position: 1.00;
                color: "#22ffffff";
            }
        }
        MouseArea {
            anchors.rightMargin: 0
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

    Rectangle{
        id:horizontalSplit1
        width: 20
        color: "#00000000"
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 0
        anchors.top: parent.top
        anchors.topMargin: 0
        anchors.left: componentBox.right
        anchors.leftMargin: -10

        MouseArea {
            anchors.rightMargin: 0
            cursorShape: Qt.Horizontal
            anchors.fill: parent
            drag{ target: parent; axis: Drag.XAxis }
            drag.smoothed: true
            onMouseXChanged: {
                if(drag.active){
                    componentBox.width += mouseX
                }
            }
        }
    }

}

