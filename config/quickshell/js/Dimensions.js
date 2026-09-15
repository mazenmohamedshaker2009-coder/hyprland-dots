function getDimentions ($page) {
  switch ($page) {
  
      case "homeClock": return [{ width: 100, height: 38},];
      break;

      case "homeWork": return [{ width: 300, height: 38},];
      break;
  
      case "homeStatus": return [{ width: 350, height: 38},];
      break;

      case "notify": return [{ width: 350, height: 50},];
      break;

      case "osdAduio": return [{ width: 340, height: 48},];
      break;
      
      case "osdBrightness": return [{ width: 340, height: 48},];
      break;
      
      case "osdAudioMute": return [{ width: 70, height: 38},];
      break;   

      case "osdAudioUnmute": return [{ width: 70, height: 38},];
      break; 

      case "osdMicMute": return [{ width: 70, height: 38},];
      break;

      case "osdMicUnmute": return [{ width: 70, height: 38},];
      break; 

      case "windowPreview": return [{ width: 1300, height: 550},];
      break;

      case "wallPicker": return [{ width: 1000, height: 340},];
      break;

      case "power": return [{ width: 400, height: 140},];
      break;

      case "control": return [{ width: 400, height: 340},];
      break;

      default: return [];
      break;
  }
}
