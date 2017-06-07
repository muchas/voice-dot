import * as $ from "jquery";
import "./style.css";
import { SpeechWebkit } from "./speechwebkit";

export class DomListener {

  speechWebkit: SpeechWebkit;

  constructor() {
    this.speechWebkit = new SpeechWebkit();
  }

  registerVoiceDotListener() {
    document.addEventListener('focusin', onFocusIn);
    let that = this;

    function onFocusIn(event) {
      let el: HTMLElement = event.target;

      if (el.matches('textarea, input')) {
          el.addEventListener('focusout', () => el.removeEventListener('keydown', voiceDotRun));
          el.addEventListener('keydown', voiceDotRun);
      }
    }

    function voiceDotRun(event) {
      if (event.ctrlKey && event.key === ';') {
        that.speechWebkit.runFor(event.target);
      } else {
        that.speechWebkit.restart(event.target);
      }
    }
  }
}
