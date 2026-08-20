pragma Singleton

import QtQuick
import "./js/Dimensions.js" as Dimensions
import "." 1.0

QtObject {

 readonly property color background: "black"
 readonly property color text: "white"

 readonly property int fontSize: 22
 readonly property int fontSizeM: 18
 readonly property int fontSizeS: 14 
 readonly property int fontSizeXS: 11 
 
 readonly property string fontFamily: "Victor Mono"

 readonly property int radius: 20
 readonly property int radiusTop: 20
 readonly property int spacing: 12


  readonly property color panelBackground: Qt.rgba(0, 0, 0, 0.9)
 readonly property int panelWidth:{ return Dimensions.getDimentions(Main.currentPage)[0].width} 
 readonly property int panelHeight:{ return Dimensions.getDimentions(Main.currentPage)[0].height}
 readonly property int panelTop: 8 
 readonly property int panelBottom: 0 

}

