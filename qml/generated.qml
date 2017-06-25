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
    width: 476
    height: 177

   
      property var views:/**views**/ /***/ 

     FormBackend{
        id:backend
        requests:[{name:"r1",body:"./r1.sql"}] 
        elements:[{name: "name1",eID: "0",program: "Init:
  value=r1",ui: element0}] 
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
        x:33.6171875
        y:52.58984375
        width:418.0078125
        height:100
        objectName:"name1"

        Component
        {
            id: tableComponent
             ListModel{ }
        }
        model:tableComponent.createObject(element0,{})

        TableViewColumn {
role: '0'
title: 'name'
width: 100
}

TableViewColumn {
role: '1'
title: 'sgjg'
width: 200
}

TableViewColumn {
role: '2'
title: 'fgfhgf'
width: 100
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

