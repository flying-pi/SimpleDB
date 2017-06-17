import QtQuick 2.7
import QtQuick.Layouts 1.0
import QtQuick.Controls 2.1
import QtQuick.Window 2.0
import QtQuick.Controls.Styles 1.4

import SimpleDB 1.0


Window {

    property TableEditModel editInfo

    ColumnInfo{
        id:columnInfo
    }

    property variant comboboxTypes: [  ]

    Component.onCompleted: {
        var loadedData = columnInfo.column_types
       comboboxTypes =loadedData
    }

    id: mypopDialog
    title: "Adding new column"
    maximumWidth: 450
    maximumHeight: 175
    minimumWidth: maximumWidth
    minimumHeight: maximumHeight
    flags: Qt.Dialog
    modality: Qt.ApplicationModal
    property int popupType: 1

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
        anchors.topMargin: 20
        anchors.top: text1.bottom
        font.pixelSize: 16
        anchors.leftMargin: 27
        anchors.left: parent.left
    }

    TextInput {
        id: textInput
        y: 104
        height: 20
        text: qsTr("")
        anchors.right: columnType.right
        anchors.rightMargin: 0
        selectionColor: "#000000"
        echoMode: TextInput.Normal
        anchors.left: columnType.left
        anchors.leftMargin: 0
        anchors.verticalCenter: text2.verticalCenter
        font.pixelSize: 12
    }

    Button {
        id: button
        x: 320
        y: 129
        text: qsTr("Create")
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 31
        anchors.right: parent.right
        anchors.rightMargin: 30
    }

    Button {
        id: button1
        x: 313
        y: 137
        text: qsTr("Create")
        anchors.right: button.left
        anchors.rightMargin: 20
        anchors.bottomMargin: 31
        anchors.bottom: parent.bottom
    }
}

