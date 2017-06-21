import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.0
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import QtQuick.Window 2.2
import QtQuick.Controls 2.1
import QtQuick.Dialogs 1.2
import QtQuick 2.2
import QtQuick.Window 2.2
import QtGraphicalEffects 1.0

import SimpleDB 1.0


Window {
    id:mainWindow
    visible: true
    width: 418
    height: 250


    property var views:[element0]

    FormBackend{
        id:backend
        requests:[{name:"cars",body:"./cars.sql"}]
        elements:[{name: "carsTable",eID: "0",program: "Init:
  value=cars",ui: element0}]
     }

    function getData(eID)
    {
        return backend.updateData(eID);
    }

    Component.onCompleted: {
        for(var i =0;i<views.length;i++)
            views[i].update()
    }




    

    TableView{
        id:element0
        x:16.17578125
        y:20.96484375
        width:402.796875
        height:229.6953125
        objectName:'carsTable'

        Component
        {
            id: tableComponent
            ListModel{ }
        }
        model:tableComponent.createObject(element0,{})

        TableViewColumn {
            role: '0'
            title: 'Name'
            width: 200
        }

        TableViewColumn {
            role: '1'
            title: 'Speed'
            width: 75
        }

        TableViewColumn {
            role: '2'
            title: 'Color'
            width: 125
        }

        function update()
        {
            console.log("ping from qt")
            model.clear()
            var newData = getData(0)
            console.log(newData)
            for(var i=0;i<newData.length;i++)
                model.append(newData[i])
        }
    }

    

}

