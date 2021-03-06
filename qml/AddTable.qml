import QtQuick 2.7
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.0
import QtQuick.Controls.Styles 1.4
import QtQuick.Window 2.2

import SimpleDB 1.0

Item {
    id: db_editer
    property string tableName: ""
    property Window rootWindow: null
    property TableEditModel tableData: null

    Component
    {
        id: columnComponent
        TableViewColumn{width: 100 }
    }

    Component
    {
        id: elementComponent
        ListElement{}
    }

    ListModel{
        id:tableModel
    }

    Component{
        id:tableDataCreator
        TableEditModel{}
    }

    Component.onCompleted: {
        var collumnsCount = tableData.get_column_count()
        console.log(collumnsCount)
        for (var i = 0; i < collumnsCount; i++)
        {
            console.log(i)
            view.addColumn(columnComponent.createObject(view, {"role":view.columnCount, "title": tableData.get_column_name(i)}))
        }
        view.getColumn(0).width = 30

        var rowsCount  = tableData.get_row_count()
        for (var i = 0; i < rowsCount; i++)
        {
            tableModel.append({})
        }

        rootWindow.title = "Editing table `"+tableName+"`";
    }

    Component {
        id: editableDelegate
        Item {

            Text {
                id:simpleText
                width: parent.width
                anchors.margins: 4
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                elide: styleData.elideMode
                text: tableData.item_data(styleData.row, styleData.role)
                color: styleData.textColor
                visible: !styleData.selected
            }
            Loader {
                id: loaderEditor
                anchors.fill: parent
                anchors.margins: 4
                Connections {
                    target: loaderEditor.item
                    onEditingFinished: {
                        tableData.set_data(styleData.row, styleData.role,loaderEditor.item.text)
                        simpleText.text = loaderEditor.item.text
                    }
                }
                sourceComponent: styleData.selected ? editor : null
                Component {
                    id: editor
                    TextInput {
                        id: textinput
                        color: styleData.textColor
                        text: simpleText.text
                        readOnly: tableData.is_readonly(styleData.role)
                        MouseArea {
                            id: mouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked:{
                                textinput.forceActiveFocus()
                            }
                        }
                    }
                }
            }
        }
    }

    TableView {
        id: view
        model: tableModel
        anchors.bottom: addCollumn.top
        anchors.right: parent.right
        anchors.left: parent.left
        anchors.top: parent.top
        itemDelegate: {
            return editableDelegate;
        }

        style: TableViewStyle{
            highlightedTextColor: "#000"
            textColor: "#111"
        }

    }

    Component
    {
        id: createTableColumnDialog

        CreateTableColumnDialog{}
    }

    function addNewColumn( columnType, columnName){
        console.log("on success call "+columnType+" name "+columnName)

        tableData.add_column(columnType,columnName)
        view.addColumn(columnComponent.createObject(view, {"role":view.columnCount, "title": columnName}))
    }

    Button {
        id: addCollumn
        text:"Add new collumn"
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        onClicked: {
            var dialog = createTableColumnDialog.createObject(db_editer)
            dialog.onSuccess.connect(addNewColumn)
            dialog.show()
        }
    }

    Button {
        id: addRow
        text:"Add new row"
        anchors.rightMargin: 12
        anchors.right: addCollumn.left
        anchors.bottom: parent.bottom
        onClicked: {
            tableData.add_row()
            tableModel.append({})
        }
    }

}

