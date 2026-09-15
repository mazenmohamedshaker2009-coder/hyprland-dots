pragma Singleton
import QtQuick


QtObject {

  property string currentPage: " " 
  property string lastPage: "homeClock" 
  property string battary: " " 
  property string brightness: " " 
  property string aduio: " " 
  property int osdAduio: 1 
  property int osdBrightness: 1 
  property bool workSpacePrevActive: false 
  property bool audioInternalRequest: false
  property bool brightnessInternalRequest: false 
  property string currentWifiName: ""
  property bool isWifiConnected: false
  property bool isWifiActive:true 
  property bool wifiMenuShown: false
  property bool isBluetoothConnected: false
  property bool isBluetoothActive:true 
  property bool bluetoothMenuShown: false
}

