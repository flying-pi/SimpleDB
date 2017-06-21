/**BEGIN_UTIL**/
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
    /**END_UTIL**/

//todo change to binding
    TableView{
        id:element/**elementID**/ /***/
        x:/**X**/10/***/
        y:/**Y**/10/***/
        width:/**W**/100/***/
        height:/**H**/200/***/
        objectName:"/**name**/ /***/"

        Component
        {
            id: tableComponent
             ListModel{ }
        }
        model:tableComponent.createObject(element/**elementID**/ /***/,{})


        /**Collumns**/
        TableViewColumn {
            role: "0"
            title: "Title"
            width: 100
        }
        TableViewColumn {
            role: "1"
            title: "Author"
            width: 200
        }

        /***/

        function update()
        {
            model.clear()
            var newData = getData(/**elementID**/0/***/)
            for(var i=0;i<newData.length;i++)
                model.append(newData[i])
        }
    }

    /**BEGIN_UTIL**/
}
/**END_UTIL**/
