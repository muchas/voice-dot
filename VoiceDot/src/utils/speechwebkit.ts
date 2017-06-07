import * as $ from "jquery";
import { Parser} from "./haskellparser";

declare let webkitSpeechRecognition: any;

export class SpeechWebkit {
  private static element = null;
  private running: boolean = false;
  private static recognizer ;
  private static parser = new Parser();
  private transcript: String;

  constructor() {
    SpeechWebkit.recognizer = new webkitSpeechRecognition();
    SpeechWebkit.recognizer.lang = 'pl-PL';
    SpeechWebkit.recognizer.continuous = true;
    SpeechWebkit.recognizer.interimResults = true;
    SpeechWebkit.recognizer.onresult = this.appendResult.bind(this);

    this.transcript = '';
  }


  private appendResult(event: any) {
    var finalTranscript = '';
    var interimTranscript = '';

    console.log(event.results);
    for (var i = event.resultIndex; i < event.results.length; ++i) {
      if (event.results[i].isFinal) {
        finalTranscript += event.results[i][0].transcript;
        this.transcript += finalTranscript;

        $(SpeechWebkit.element).val(SpeechWebkit.parser.parse(SpeechWebkit.element.value, this.transcript));
        console.log('final');
      } else {
        interimTranscript += event.results[i][0].transcript;

        $(SpeechWebkit.element).val(SpeechWebkit.parser.parse(SpeechWebkit.element.value, this.transcript + interimTranscript));
        console.log('temporary');
      }
    }
  }

  runFor(element: HTMLElement) {
    SpeechWebkit.element = element;
    this.transcript = $(element).val() || this.transcript;
    SpeechWebkit.recognizer.start();
  }

  restart(element: HTMLElement) {
    SpeechWebkit.recognizer.abort();
    this.runFor(element);
  }
}
