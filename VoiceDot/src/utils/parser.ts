import * as commands from "./commands";

declare var chrome: any;

export class Parser {

  dict_pl = {};
  custom_replaces = {};

  constructor() {
    this.dict_pl['kropka'] = commands.DotCommand;
    this.dict_pl['ampersand'] = commands.AmpersandCommand;
    this.dict_pl['dwukropek'] = commands.ColonCommand;
    this.dict_pl['znak zapytania'] = commands.QuestionMarkCommand;
    this.dict_pl['wykrzyknik'] = commands.ExclamationMarkCommand;
    this.dict_pl['przecinek'] = commands.CommaCommand;
    this.dict_pl['małpa'] = commands.AtCommand;
    this.dict_pl['myślnik'] = commands.HyphenCommand;
    // this.dict_pl['cudzysłów'] = commands.QuoteCommand;
    this.dict_pl['apostrof'] = commands.SingleQuoteCommand;
    this.dict_pl['lewy nawias'] = commands.LeftParenthesisCommand;
    this.dict_pl['prawy nawias'] = commands.RightParenthesisCommand;
    this.dict_pl['łamane'] = commands.ForwardSlashCommand;
    this.dict_pl['ignoruj'] = commands.IgnoreCommand;
    this.dict_pl['otwórz nawias'] = commands.OpenParenthesisCommand;
    this.dict_pl['zamknij nawias'] = commands.CloseParenthesisCommand;
    this.dict_pl['otwórz cudzysłów'] = commands.OpenQuotationMarkCommand;
    this.dict_pl['zamknij cudzysłów'] = commands.CloseQuotationMarkCommand;
    this.listenForCustomReplaces();
  }

  listenForCustomReplaces() {

    chrome.storage.local.get('custom_replaces', items => {
      this.custom_replaces = items['custom_replaces'] || {};
    });

    chrome.storage.onChanged.addListener((changes, areaName) => {
      if (areaName === 'local') {
        this.custom_replaces = changes['custom_replaces']['newValue'] || {};
      }
    });
  }

  parse(value, transcript) {
    var commandsArray = new Array();
    var context = {
      'ignore': false,
      'shift': 0,
      'bracketsStack': [],
    };

    for (var key in (<any>Object).assign({}, this.custom_replaces, this.dict_pl)){
      if (transcript.includes(key)) {
        var regExp = new RegExp(key, 'g');
        var res, cmd;

        while((res=regExp.exec(transcript)) !== null){

          if (key in this.custom_replaces) {
            cmd = new commands.ReplaceCommand(res.index, regExp.lastIndex);
            cmd.REPLACE_WORD = this.custom_replaces[key];
          } else {
            cmd = new this.dict_pl[key](res.index, regExp.lastIndex);
          }

          commandsArray.push(cmd);
        }
      }
    }

    commandsArray.sort(function(a: any, b:any){
      return a.startIndex - b.startIndex;
    });

    console.log(transcript);
    for(var command in commandsArray) {
      transcript = commandsArray[command].execute(transcript, context);
    }
    console.log(commandsArray);
    console.log(transcript);
    console.log(context);
    return transcript;
  }
}
