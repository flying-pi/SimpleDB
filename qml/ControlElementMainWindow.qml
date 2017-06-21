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

/*--
import SimpleDB 1.0
 --*/

Window {
    id:mainWindow
    visible: true
    width: /**W**/900/***/
    height: /**H**/200/***/



   /*--
      property var views:/**views**/ /***/ /*--

     FormBackend{
        id:backend
        requests:/**requests**/ /***/ /*--
        elements:/**elements**/ /***/ /*--
     }

    function getData(eID)
    {
       return backend.updateData(eID);
    }


   Component.onCompleted: {
       for(var i =0;i<views.length;i++)
           views[i].update()
   }

      --*/
      


    /**insert**/
    function getData(eID)
    {
        var result = []
        for(var i=0;i<100;i++){
            var test = {}
            for(var j=0;j<100;j++){
                test[j.toString()] = "mock"+i.toString()+";"+j.toString()
            }
            result.push(test)
        }
        return result;

    }
    /***/
}

