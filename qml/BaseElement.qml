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


QtObject {
    id:baseElement
    property string name:""
    property var eID: -1
    property double x:0
    property double y:0
    property double width:100
    property double height:100
    property string elementType:'baseElement'
    property string program: 'Init:\n  value=mock'
    property Item uiContainer: null
    property Item uiComponent: null

    function getUiComponent(){
        if(uiComponent == null )
            uiContainer = inserdetTable.createObject(uiContainer,{})
        return uiContainer
    }

    function bindToContainer(container){
        uiContainer = container
        uiComponent = inserdetTable.createObject(uiContainer,{})
    }

    function move(newX,newY){
        x = newX
        y = newY
    }

    function resize(w,h){
        width = w
        height = h
    }

    function regist(){
        stateInfo.push(this)
        eID = stateInfo.length-1;
    }

    function insertInSourceInfo(){
        return ""
    }

    function insertInSourceBaseInfo(source){
        const Xregex = /\/\*\*X\*\*\/[\s\S]*?\/\*\*\*\//g;
        const Yregex = /\/\*\*Y\*\*\/[\s\S]*?\/\*\*\*\//g;
        const Wregex = /\/\*\*W\*\*\/[\s\S]*?\/\*\*\*\//g;
        const Hregex = /\/\*\*H\*\*\/[\s\S]*?\/\*\*\*\//g;
        const IDregex = /\/\*\*elementID\*\*\/[\s\S]*?\/\*\*\*\//g;
        const regexUtil = /\/\*\*BEGIN_UTIL\*\*\/[\s\S]*?\/\*\*END_UTIL\*\*\//g;
        return source
        .replace(Xregex,''+x)
        .replace(Yregex,''+y)
        .replace(Wregex,''+width)
        .replace(Hregex,''+height)
        .replace(IDregex,''+eID)
        .replace(regexUtil,'');
    }
}
