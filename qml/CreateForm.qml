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


import SimpleDB 1.0

Item {
    id: db_editer
    anchors.fill: parent
    height: 600

    FormCreationHelper{
        id:helper
    }

    property var stateInfo: []

    function getSourceForComponent(componentType){
        return helper.get_source_for_component(componentType)
    }

    function getRegExpForParametr(param){
        return "\\\/\\/\\*\\*"+param+"\\*\\*\\/[\\s\\S]*?\\/\\*\\*\\*\\/\\\/g"
    }

    function fromEID(eID){
        return stateInfo[(eID)]
    }

    Component
    {
        id: columnComponent
        TableViewColumn{ }
    }

    ListModel{
        id:requestListModel
    }

    ListModel{
        id:elementListModel
    }

    Component{
        id:listModelComponent
        ListModel{

        }
    }

    function generateSourceCode(){
        const regex = /\/\*\*insert\*\*\/[\s\S]*?\/\*\*\*\//g;
        var source = getSourceForComponent("mainWindow")
        var components = "";
        var w =0
        var h = 0;
        for(var i =0;i<stateInfo.length;i++)
        {
            var element = stateInfo[i]
            if((element.width+element.x)>w)
                w = element.width+element.x
            if((element.height+element.y)>h)
                h = element.height+element.y
            components+=element.insertInSourceInfo();
            components+="\n\n";
        }
        w+=25
        h+=25

        source = source.replace(regex,components)

        const Wregex = /\/\*\*W\*\*\/[\s\S]*?\/\*\*\*\//g;
        const Hregex = /\/\*\*H\*\*\/[\s\S]*?\/\*\*\*\//g;

        source = source.replace(Wregex,''+w|0)
        source = source.replace(Hregex,''+h|0)

        var requestStr = getAllRequestAsString();
        console.log(requestStr)

        var items = allElementsApiAsString();
        console.log(items)

        const requestRegex = /\/\*\*requests\*\*\/[\s\S]*?\/\*\*\*\//g;
        const elementsRegex = /\/\*\*elements\*\*\/[\s\S]*?\/\*\*\*\//g;

        source = source.replace(requestRegex,requestStr)
        source = source.replace(elementsRegex,items)

        while(source.includes('/*--'))
            source = source.replace('/*--','')

        while(source.includes('--*/'))
            source = source.replace('--*/','')

        while(source.includes('\n\n\n'))
            source = source.replace('\n\n\n','\n\n')
        return source;
    }


    Component{
        id:createFileDialogComponent

        FileDialog {
            id: fileDialog
            title: "Please choose a file"
            signal onSuccess(var filePath)
            selectFolder: true
            onAccepted: {
                onSuccess(fileDialog.folder)
            }
            onRejected: {
                console.log("Canceled")
            }
            Component.onCompleted: visible = true
        }
    }

    Component{
        id:inserdetTable
        TableView{
            TableViewColumn {
                role: "title"
                title: "Title"
                width: 100
            }
            TableViewColumn {
                role: "author"
                title: "Author"
                width: 200
            }
            anchors.fill: parent

        }
    }

    Component{
        id:addColumnDialog
        Dialog{
            id:addColumn
            contentItem.implicitHeight: 500
            contentItem.implicitWidth: 600
            title: "Add column"
            standardButtons: StandardButton.Ok | StandardButton.Cancel
            signal onSuccess(var result)
            property var source:[]

            onButtonClicked: {
                if (clickedButton === StandardButton.Ok)
                    onSuccess(source)
            }

            Button{
                id:addBtn
                anchors.bottom: parent.bottom
                text: "add new column"
                onClicked: {
                    columnList.model.append({name:'',collumnWidth:''})
                    addColumn.source.push({name:'',collumnWidth:''})
                }
            }


            ScrollView{
                anchors.top: parent.top
                anchors.bottom:addBtn.top
                anchors.right: parent.right
                anchors.left: parent.left
                id:columnListScroll

                ListView{
                    id:columnList
                    anchors.fill: parent
                    model: listModelComponent.createObject(columnList,{})

                    Component.onCompleted: {
                        model.append({name:'Name',collumnWidth:'Width'})
                        for(var i=0;i<addColumn.source.length;i+=1)
                            model.append(addColumn.source[i])
                    }


                    delegate: Rectangle{
                        width: parent.width
                        height: 45

                        RowLayout{
                            anchors.fill: parent
                            spacing: 6
                            anchors.topMargin: 3
                            anchors.bottomMargin: 3

                            TextField{
                                Layout.fillWidth: true
                                Layout.leftMargin: 7
                                text: name
                                onTextChanged:  {
                                    if(index>0)
                                        addColumn.source[index-1].name = text
                                }
                                readOnly: index == 0
                            }

                            TextField{
                                Layout.fillWidth: true
                                text: collumnWidth
                                onTextChanged:  {
                                    if(index>0)
                                        addColumn.source[index-1].collumnWidth = text
                                }
                                readOnly: index== 0
                            }

                            Button{
                                Layout.minimumWidth:50
                                Layout.fillWidth: true
                                Layout.rightMargin: 7
                                text: "delete row"
                                onClicked: {
                                    columnList.model.remove(index,1)
                                    addColumn.source = []
                                    for(var i=1;i<columnList.model.count;i++){
                                        if(i!==index)
                                            addColumn.source.push({name: columnList.model.get(i).name
                                                                      ,collumnWidth: columnList.model.get(i).collumnWidth})
                                    }

                                }
                            }
                        }
                    }

                }
            }

        }
    }

    Component{
        id:baseElementComponent
        BaseElement {
            id: baseElement
        }
    }

    Component{
        id:tableComponent
        BaseElement{
            elementType: "table"
            property var columns: []


            function showAdditionalEdotor(){
                var columns = []
                for(var i=0; i<uiComponent.columnCount ;i++){
                    columns.push({
                                     name:uiComponent.getColumn(i).title
                                     ,collumnWidth:''+uiComponent.getColumn(i).width})

                }
                var dialog = addColumnDialog.createObject(null,{source:columns})

                dialog.onSuccess.connect(function(result){
                    var table = uiComponent
                    for(var i=table.columnCount; i>0 ;i--){
                        table.removeColumn(0)
                    }
                    var lasttAddedPos = 0;
                    for(var i=0;i<result.length;i++){
                        var newColl = result[i]
                        if(newColl.name.length>0 && newColl.collumnWidth.length>0)
                        {
                            var columnInfo = {'role':''+(lasttAddedPos++),
                                'title':newColl.name,
                                'width': parseInt(newColl.collumnWidth)}
                            var column = columnComponent.createObject(table,columnInfo);
                            table.addColumn(column);
                        };
                    }

                });
                dialog.open()
            }

            function insertInSourceInfo(){
                var source = getSourceForComponent("table");
                source = insertInSourceBaseInfo(source)
                source = insertInSourceTableInfo(source)
                return source;
            }

            function insertInSourceTableInfo(source){
                var table = uiComponent
                var columns = '';
                for(var i=0;i<table.columnCount;i+=1)
                {
                    var column = 'TableViewColumn {'
                    column+=('\nrole: \'' + i+'\'')
                    column+=('\ntitle: \'' + table.getColumn(i).title+'\'')
                    column+=('\nwidth: ' + table.getColumn(i).width)
                    column+='\n}'
                    columns+=column
                    columns+='\n\n'
                }
                const regex = /\/\*\*Collumns\*\*\/[\s\S]*?\/\*\*\*\//g;
                source = source.replace(regex,columns);
                return source;
            }
        }
    }

    function newElement(component){
        var futureName = 'name'
        var nameIndex = 1
        for(var i =0;i< stateInfo.length;i++){
            if ((futureName+nameIndex) == stateInfo[i].name){
                i=-1;
                nameIndex++;
            }
        }
        var result = component.createObject(
                    db_editer,
                    {name:(futureName+nameIndex)})
        return result;
    }

    Component{
        id:messaheDialogComponent
        MessageDialog {
        }
    }

    Component{
        id:movebleElement
        Rectangle {
            property var element
            property var inserComponent: undefined
            property var insertedComponentArg: undefined
            property int diametr: 12
            property var resizerColor: "#336ba3ff"
            property var resizerBorderColor: "#0d2651"
            property var resizerBorderWidth: 1
            x:element.x
            y:element.y
            width:element.width
            height:element.height

            color: "#ffffff"
            Rectangle{
                anchors.fill: parent
                id:content
            }

            onXChanged: {
                element.x = x
            }
            onYChanged: {
                element.y = y
            }
            onWidthChanged: {
                element.width = width
            }
            onHeightChanged: {
                element.height = height
            }

            Rectangle{
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
                width: diametr
                height: diametr
                color: resizerColor
                border.color: resizerBorderColor
                border.width: resizerBorderWidth
                radius: diametr/2
                MouseArea {
                    anchors.fill: parent
                    drag{
                        axis: Drag.XAxis | Drag.YAxis
                        target: parent.parent
                        minimumX: 0
                        minimumY: 0
                        maximumX: parent.parent.parent.width -  parent.parent.width
                        maximumY: parent.parent.parent.height -  parent.parent.height
                        smoothed: true
                    }
                }
            }

            Rectangle{

                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.bottom
                width: diametr
                height: diametr
                color: resizerColor
                border.color: resizerBorderColor
                border.width: resizerBorderWidth
                radius: diametr
                MouseArea {
                    anchors.fill:parent
                    drag{ target: parent; axis: Drag.YAxis }
                    onMouseYChanged: {
                        if(drag.active)
                            parent.parent.height =  parent.parent.height + mouseY
                        if(parent.parent.height<10)
                            parent.parent.height = 10
                    }
                }
            }

            Rectangle{
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.top
                width: diametr
                height: diametr
                color: resizerColor
                border.color: resizerBorderColor
                border.width: resizerBorderWidth
                radius: diametr
                MouseArea {
                    anchors.fill:parent
                    drag{ target: parent; axis: Drag.YAxis }
                    onMouseYChanged: {
                        if(drag.active){
                            parent.parent.y = parent.parent.y + mouseY
                            parent.parent.height =  (parent.parent.height - mouseY)
                            if(parent.parent.height<10)
                                parent.parent.height = 10
                        }
                    }
                }
            }

            Rectangle{

                anchors.horizontalCenter: parent.right
                anchors.verticalCenter: parent.verticalCenter
                width: diametr
                height: diametr
                color: resizerColor
                border.color: resizerBorderColor
                border.width: resizerBorderWidth
                radius: diametr
                MouseArea {
                    anchors.fill:parent
                    drag{ target: parent; axis: Drag.XAxis }
                    onMouseXChanged: {
                        if(drag.active)
                            parent.parent.width =  parent.parent.width + mouseX
                        if(parent.parent.width<10)
                            parent.parent.width = 10
                    }
                }
            }

            Rectangle{
                anchors.horizontalCenter: parent.left
                anchors.verticalCenter: parent.verticalCenter
                width: diametr
                height: diametr
                color: resizerColor
                border.color: resizerBorderColor
                border.width: resizerBorderWidth
                radius: diametr
                MouseArea {
                    anchors.fill:parent
                    drag{ target: parent; axis: Drag.XAxis }
                    onMouseXChanged: {
                        if(drag.active){
                            parent.parent.x = parent.parent.x + mouseX
                            parent.parent.width =  (parent.parent.width - mouseX)
                            if(parent.parent.width<10)
                                parent.parent.width = 10
                        }
                    }
                }
            }

            Component.onCompleted: {
                element.bindToContainer(content)
            }


        }
    }


    function showMessahe(title,message){
        var dialog = messaheDialogComponent.createObject(null,{title:title,text: message})
        dialog.open();
    }


    property Dialog createRequestDialog: null

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
        requestListModel.append({requestAlias:reqAlias,requestBody:reqBody,itemPosition:requestListModel.count})
        requestListView.update()
    }

    function getAllRequestAsString(){
        var result = '['
        for(var i =0;i<requestListModel.count;i++){
            if(i>0)
                result+=',\n'
            var sqlFilePath = helper.save_sql_to_file(
                        requestListModel.get(i).requestAlias,
                        requestListModel.get(i).requestBody)
            result+='{name:"'+requestListModel.get(i).requestAlias+'",'
            result+='body:"' + sqlFilePath +'"'
            result+='}'
        }
        result+=']'
        return result;
    }

    function allElementsApiAsString(){
        var result = '['
        for(var i =0;i<stateInfo.length;i++){
            if(i>0)
                result+=',\n'


            result+='{name: "' + stateInfo[i].name + '",'
            result+='eID: "' + stateInfo[i].eID +'",'
            result+='program: "' + stateInfo[i].program +'",'
            result+='ui: element' + stateInfo[i].eID +''
            result+='}'
        }
        result+=']'
        return result;
    }



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
                    anchors.right: parent.right
                    anchors.left: parent.left
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
                    placeholderText: "Enter name for request"
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

    Rectangle {
        id: componentBox
        x: 0
        width: 200
        color: "#ecfffe"
        border.color: "#243331"
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 0
        anchors.top: parent.top
        anchors.topMargin: 0

        Text {
            id: toolBox
            color: "#000000"
            text: "ToolBox ::"
            anchors.right: parent.right
            anchors.rightMargin: 7
            anchors.left: parent.left
            anchors.leftMargin: 7
            anchors.top: parent.top
            anchors.topMargin: 7
            fontSizeMode: Text.VerticalFit
            renderType: Text.NativeRendering
            font.weight: Font.Normal
            font.capitalization: Font.MixedCase
            font.family: "Tahoma"
            font.bold: true
            font.pointSize: 12
            horizontalAlignment: Text.AlignLeft
        }

        Button {
            id: insertTableBtn
            width: 50
            height: 15
            text: qsTr("Table")
            anchors.top: toolBox.bottom
            anchors.topMargin: 12
            anchors.left: parent.left
            anchors.leftMargin: 7
            onClicked:{

                var element = newElement(tableComponent)
                element.regist()
                elementListModel.append(element)
                var container = movebleElement.createObject(workField,{element:element})
                element.uiContainer = container
            }
        }

        Rectangle {
            id: upToolDevider
            height: 1
            color: "#000000"
            anchors.top: insertTableBtn.bottom
            anchors.topMargin: 6
            anchors.right: parent.right
            anchors.rightMargin: 0
            anchors.left: parent.left
            anchors.leftMargin: 0
        }

        ScrollView{
            id:itemsListScroll
            anchors.right: parent.right
            anchors.rightMargin: 6
            anchors.left: parent.left
            anchors.leftMargin: 6
            anchors.bottom: dowToolDevider.top
            anchors.bottomMargin: 6
            anchors.top: upToolDevider.bottom
            anchors.topMargin: 6
            ListView{
                id:itemsList
                model: elementListModel
                delegate: Rectangle{
                    height: 30
                    width: itemsListScroll.width
                    RowLayout{
                        Text {
                            text: fromEID(eID).name
                        }
                        Text {
                            text: ' :: '
                        }
                        Text {
                            text: fromEID(eID).elementType
                        }
                    }
                    MouseArea{
                        anchors.fill: parent
                        onClicked: {
                            var el = fromEID(eID)
                            gridLayout.element = el
                            codeEditor.element = el
                        }
                    }
                }
            }
        }

        Rectangle {
            id: dowToolDevider
            height: 1
            color: "#000000"
            anchors.bottom: gridLayout.top
            anchors.bottomMargin: 6
            anchors.right: parent.right
            anchors.rightMargin: 0
            anchors.left: parent.left
            anchors.leftMargin: 0
        }

        GridLayout {
            id: gridLayout
            y: 600
            height: 175
            opacity: 1
            rows: 4
            columns: 2
            anchors.right: parent.right
            anchors.rightMargin: 7
            anchors.left: parent.left
            anchors.leftMargin: 7
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 12

            property var element:0

            Component.onCompleted: {
            }

            TextField {
                id: textInput
                placeholderText: "Item name"
                Layout.fillWidth: true
                font.pixelSize: 16
                Layout.columnSpan: 2
                text: parent.element.name
                onTextChanged: {
                    if(text !== parent.element.name)
                        parent.element.name =  text
                }

            }

            TextField {
                id: elementPositionX
                hoverEnabled: true
                text: parent.element.x
                placeholderText: "X"
                ToolTip.text: qsTr("X coordinate of element position")
                ToolTip.delay: 500
                ToolTip.timeout: 5000
                ToolTip.visible: hovered
                Layout.fillWidth: true
                Layout.columnSpan: 1
                onTextChanged: parent.element.x =  text
            }

            TextField {
                id: elementPositionY
                hoverEnabled: true
                text: parent.element.y
                placeholderText: "Y"
                ToolTip.text: qsTr("Y coordinate of element position")
                ToolTip.delay: 500
                ToolTip.timeout: 5000
                ToolTip.visible: hovered
                Layout.fillWidth: true
                Layout.columnSpan: 1
                onTextChanged: parent.element.y =  text
            }

            TextField {
                id: elementWidth
                hoverEnabled: true
                text: parent.element.width
                placeholderText: "Width"
                ToolTip.text: qsTr("Element width")
                ToolTip.delay: 500
                ToolTip.timeout: 5000
                ToolTip.visible: hovered
                Layout.fillWidth: true
                Layout.columnSpan: 1
                onTextChanged: parent.element.width =  text
            }

            TextField {
                id: elementHeight
                hoverEnabled: true
                text: parent.element.height
                placeholderText: "Height"
                ToolTip.text: qsTr("Element height")
                ToolTip.delay: 500
                ToolTip.timeout: 5000
                ToolTip.visible: hovered
                Layout.fillWidth: true
                Layout.columnSpan: 1
                onTextChanged:parent.element.height =  text
            }
            Button {
                id: optionBtn
                text: qsTr("Item options")
                Layout.columnSpan: 2
                Layout.rowSpan: 1
                Layout.fillWidth: true
                Layout.minimumWidth: 40
                Layout.alignment: Qt.AlignHCenter | Qt.AlignBottom
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom
                onClicked: {
                    parent.element.showAdditionalEdotor()
                }
            }

        }

    }

    Rectangle{
        id:wokBack
        color: "#dff2f5"
        anchors.bottom: toolBack.top
        anchors.bottomMargin: 0
        anchors.right: codeEditor.left
        anchors.rightMargin: 0
        anchors.left: componentBox.right
        anchors.leftMargin: 0
        anchors.top: parent.top
        anchors.topMargin: 0

        ScrollView{
            anchors.fill: parent
            Rectangle{
                id:workField
                width: 10000
                height:  10000
            }
        }

    }


    Rectangle{
        id:codeEditor
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.bottom: toolBack.top
        anchors.bottomMargin: -1
        width: 100
        color: "#86ffc7"
        border.color: "#000000"
        border.width: 1

        property var element:0

        TextEdit{
            anchors.fill: parent
            anchors.margins: 7
            text: parent.element.program
            onTextChanged: {
                if(text!==parent.element.program)
                    parent.element.program = text
            }
        }

    }


    Rectangle{
        id:toolBack
        height: 200
        color: "#f9f6f6"
        border.color: "#000000"
        anchors.right: parent.right
        anchors.rightMargin: 0
        anchors.left: componentBox.right
        anchors.leftMargin: -1
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
            }
        }

        Button {
            id:previewResult
            anchors.left: addRequestButton.right
            anchors.top: addRequestButton.top
            anchors.bottom: addRequestButton.bottom
            anchors.leftMargin: 10
            text: "Preview"
            onClicked: {
                var source = generateSourceCode();


                console.log(source)
                helper.seave_generated_source(source)
                var component =  Qt.createQmlObject(source,mainWindow,"/Users/yurabraiko/dev/python/SimpleDB/qml/dsdsd.gml");
                component.show()
            }
        }

        Button {
            id: save_project
            anchors.left: previewResult.right
            anchors.top: previewResult.top
            anchors.bottom: previewResult.bottom
            anchors.leftMargin: 10
            text: save
            onClicked: {
                var dialog = createFileDialogComponent.createObject(db_editer,{})
                dialog.onSuccess.connect(function(filePath){
                    var source = generateSourceCode();
                    helper.save_as_project(filePath,source);
                })
                dialog.open()
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
                    color: "#f7f7ff"
                    border.color: "#6200ff"
                    border.width: 1
                    height: 55
                    width: requestListScroll.width

                    RowLayout {
                        anchors.margins: 7
                        anchors.verticalCenter: requestListItem.verticalCenter
                        id: rowLayout
                        width: requestListScroll.width
                        Text {
                            Layout.leftMargin: 16
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
                            Layout.rightMargin: 16
                            anchors.verticalCenter: requestListItem.verticalCenter
                            id: deleteBtn
                            text: qsTr("Remove")
                            onClicked: requestListModel.remove(itemPosition)
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
        color: "#00000000"

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

                    if(componentBox.width<150)
                        componentBox.width = 150
                }

            }
        }
    }

    Rectangle{
        id:horizontalSplit2
        width: 20
        color: "#00000000"
        anchors.bottom: toolBack.top
        anchors.top: parent.top
        anchors.left: codeEditor.left
        anchors.rightMargin:-10

        MouseArea {
            anchors.rightMargin: 0
            cursorShape: Qt.Horizontal
            anchors.fill: parent
            drag{ target: parent; axis: Drag.XAxis }
            drag.smoothed: true
            onMouseXChanged: {
                if(drag.active){
                    codeEditor.width -= mouseX
                    codeEditor.x+=mouseX

                    if(codeEditor.width<30)
                        codeEditor.width = 30
                }

            }
        }
    }

    Component.onCompleted: {
    }

}
