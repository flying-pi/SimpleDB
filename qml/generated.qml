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
    width: 499
    height: 300

   
      property var views:/**views**/ /***/ 

     FormBackend{
        id:backend
        requests:[{name:"select carname, speed,color from car",body:"./select carname, speed,color from car.sql"},
{name:"carss",body:"./carss.sql"}] 
        elements:[{name: "carTable",eID: "0",program: "Init:
  value=carss",ui: element0}] 
     }

    function getData(eID)
    {
       return backend.updateData(eID);
    }

   Component.onCompleted: {
       for(var i =0;i<views.length;i++)
           views[i].update()
   }

      
      

    

//todo change to binding
    TableView{
        id:element0
        x:11.56640625
        y:6.44140625
        width:463.4140625
        height:269.28515625
        objectName:"carTable"

        Component
        {
            id: tableComponent
             ListModel{ }
        }
        model:tableComponent.createObject(element0,{})

        TableViewColumn {
role: '0'
title: 'Name'
width: 150
}

TableViewColumn {
role: '1'
title: 'Speed'
width: 150
}

TableViewColumn {
role: '2'
title: 'Color'
width: 159
}

        function update()
        {
            model.clear()
            var newData = getData(0)
            for(var i=0;i<newData.length;i++)
                model.append(newData[i])
        }
    }

    

}

