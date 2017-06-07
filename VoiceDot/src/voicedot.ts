import { DomListener } from "./utils/dommanager";

class VoiceDot {

  private domListener: DomListener = new DomListener();

  start() {
    this.domListener.registerVoiceDotListener();
  }
}

export default VoiceDot;
