import QtQuick 2.7
import QtQuick.Layouts 1.0
import QtQuick.Controls 2.1
import QtQuick.Window 2.0
import QtQuick.Controls.Styles 1.4

import SimpleDB 1.0


Window {
    id: createTableColumnDialog
    title: "Adding new column"
    maximumWidth: 450
    maximumHeight: 175
    minimumWidth: maximumWidth
    minimumHeight: maximumHeight
    flags: Qt.Dialog
    modality: Qt.ApplicationModal

    signal onCancel()
    signal onSuccess(int columnType,string columnName)

    property TableEditModel editInfo

    ColumnInfo{
        id:columnInfo
    }

    property variant comboboxTypes: [  ]
    width: 550
    height: 250

    Component.onCompleted: {
        var loadedData = columnInfo.column_types
        comboboxTypes =loadedData
        createTableColumnDialog.closing.connect(onWindowClissing)
    }

    function onWindowClissing(info){
        createTableColumnDialog.onCancel()
    }

    ComboBox {
        id: columnType
        y: 58
        height: 26
        anchors.right: parent.right
        anchors.rightMargin: 30
        anchors.left: text1.right
        anchors.leftMargin: 20
        anchors.verticalCenter: text1.verticalCenter
        model: comboboxTypes
        currentIndex: 0
        onCurrentIndexChanged:{
            console.log(currentIndex)
        }

    }

    Text {
        id: text1
        text: qsTr("Select Column type:")
        anchors.left: parent.left
        anchors.leftMargin: 27
        anchors.top: parent.top
        anchors.topMargin: 30
        font.pixelSize: 16
    }

    Text {
        id: text2
        x: 2
        y: 2
        text: qsTr("Column name:")
        anchors.topMargin: 40
        anchors.top: text1.bottom
        font.pixelSize: 16
        anchors.leftMargin: 0
        anchors.left: text1.left
    }

    TextField {
        id: collumnName
        y: 104
        height: 40
        text: qsTr("")
        anchors.right: columnType.right
        anchors.rightMargin: 0
        selectionColor: "#000000"
        echoMode: TextInput.Normal
        anchors.left: columnType.left
        anchors.leftMargin: 0
        anchors.verticalCenter: text2.verticalCenter
        font.pixelSize: 12
        placeholderText: "Column name"
    }

    Button {
        id: createBtn
        x: 320
        y: 129
        text: qsTr("Create")
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 31
        anchors.right: parent.right
        anchors.rightMargin: 30
        onClicked: {
            createTableColumnDialog.onSuccess(columnType.currentIndex,collumnName.text)
            close()
        }
    }

    Button {
        id: cancelBtn
        x: 313
        y: 137
        text: qsTr("Cancel")
        anchors.right: createBtn.left
        anchors.rightMargin: 20
        anchors.bottomMargin: 31
        anchors.bottom: parent.bottom
        onClicked: {
            createTableColumnDialog.onCancel()
            close()
        }
    }
}

