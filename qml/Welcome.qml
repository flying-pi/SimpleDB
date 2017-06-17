import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.0
import QtQuick.Dialogs 1.2
import QtQuick.Window 2.2

import SimpleDB 1.0


Item {
    id: welcomeForm
    anchors.fill: parent

    property Window rootWindow: null

    ListModel {
        id: tables
    }

    WelcomeInfo{
        id: welcomeInfo
    }

    Component{
        id:messaheDialogComponent
        MessageDialog {
            property string itemText: "error"
            id:messaheDialog
            title: "Error"
            Component.onCompleted: {
                messaheDialog.text = itemText
            }
        }
    }

    Component.onCompleted: {
        var loadedData =  welcomeInfo.exist_bd
        for(var i =0;i<loadedData.length;i++)
            tables.append({name:loadedData[i]})
        welcomeInfo.addTable.connect(insertNewDBTable)
        welcomeInfo.showError.connect(showError)
        rootWindow.title = "All tables list"
    }

    function insertNewDBTable(showError){
        tables.append({name:tableName})
    }

    function showError(msg){
        var dialog = messaheDialogComponent.createObject(null,{itemText: msg})
        dialog.open()
    }

    Component{
        id:createTableDialogComponent
        Dialog {
            id: createTableDialog
            title: "Chose name for table"
            standardButtons: StandardButton.Ok | StandardButton.Cancel
            signal onTableNameSelect(string name)

            Column {
                anchors.fill: parent
                padding: 12
                TextField {
                    id: tableName
                    anchors.right: parent.right
                    anchors.left: parent.left
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    placeholderText: "enter table name"
                }
            }

            onButtonClicked: {
                if (clickedButton==StandardButton.Ok && tableName.text.length>0)
                    createTableDialog.onTableNameSelect(tableName.text)
            }

            Component.onCompleted: {
                createTableDialog.forceActiveFocus()
                tableName.forceActiveFocus()
            }
            
        }
    }

    GridView {
        id:db_view
        anchors.top: parent.top
        anchors.bottom: button.top
        anchors.bottomMargin: 7
        anchors.right: parent.right
        anchors.left: parent.left
        model: tables
        delegate: Component{
            Button {
                text:name
                onClicked: {
                   var editor = addTableViewComponent.createObject(stack,{tableName:name,rootWindow:rootWindow})
                   stack.push(editor)
                }

            }
        }
    }


    Button {
        anchors.horizontalCenter: parent.horizontalCenter
        id: button
        background: Rectangle{
            color: "#6adaf3"
        }
        text: qsTr("Add new table")
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 7
        onClicked: {
            //            stack.push(addTableViewComponent.createObject(stack,{}))
            var dialog = createTableDialogComponent.createObject(null,{})
            dialog.onTableNameSelect.connect(createTable)
            dialog.open()
        }
    }

    function createTable(name){
        welcomeInfo.add_item(name)
    }

}

