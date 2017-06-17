import QtQuick 2.7
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.0

import SimpleDB 1.0

Item {
    id: db_editer

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

    TableEditModel
    {
        id:tableData
    }

    ListModel{
        id:tableModel
    }

    Component
    {
        id: createTableColumnDialog
        CreateTableColumnDialog{
            editInfo:tableData
        }
    }

    Component {
        id: editableDelegate
        Item {

            Text {
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
                    //TODO
                    }
                }
                sourceComponent: styleData.selected ? editor : null
                Component {
                    id: editor
                    TextInput {
                        id: textinput
                        color: styleData.textColor
                        text: styleData.value
                        MouseArea {
                            id: mouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: textinput.forceActiveFocus()
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

    }


    Button {
        id: addCollumn
        text:"Add new collumn"
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        onClicked: {
            tableData.add_column()
            view.addColumn(columnComponent.createObject(view, {"role":""+view.columnCount, "title": "title"+view.columnCount}))

            var dialog = createTableColumnDialog.createObject(db_editer)
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

