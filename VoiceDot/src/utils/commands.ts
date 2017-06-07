
class BaseCommand {

  startIndex: any;
  endIndex: any;
  transcript: String;

  constructor(startIndex: any, endIndex: any) {
    this.startIndex = startIndex;
    this.endIndex = endIndex;
  }

  processTranscript(transcript, context) {
    return transcript;
  }

  execute(transcript, context) {
      if(context['ignore']) {
        context['ignore'] = false;
        return transcript;
      }
      return this.processTranscript(transcript, context);
  }
};


class ReplaceCommand extends BaseCommand {

  REPLACE_WORD = 'REPLACE_WORD';

  processTranscript(transcript, context) {
    const startString = transcript.substring(0, this.startIndex + context['shift']);
    const endString = transcript.substring(this.endIndex + context['shift'], transcript.length);
    context['shift'] += this.REPLACE_WORD.length - (this.endIndex - this.startIndex);
    return startString + this.REPLACE_WORD + endString;
  }
};


class IgnoreCommand extends ReplaceCommand {

  REPLACE_WORD = '';

  processTranscript(transcript, context) {
    context['ignore'] = !context['ignore'];
    return super.processTranscript(transcript, context);
  }
};



class OpenParenthesisCommand extends ReplaceCommand {
    REPLACE_WORD = '(';

    processTranscript(transcript, context) {
      context['bracketsStack'].push(this.REPLACE_WORD);
      return super.processTranscript(transcript, context);
    }
};


class CloseParenthesisCommand extends ReplaceCommand {

    processTranscript(transcript, context) {
      const lastBracket = context['bracketsStack'].pop();
      switch(lastBracket) {
        case '(':
          this.REPLACE_WORD = ')';
          break;
        case '[':
          this.REPLACE_WORD = ']';
         break;
        case '{':
          this.REPLACE_WORD = '}';
        break;
      }
      return super.processTranscript(transcript, context);
    }
};

class OpenQuotationMarkCommand extends ReplaceCommand { REPLACE_WORD = '„'; };
class CloseQuotationMarkCommand extends ReplaceCommand { REPLACE_WORD = '”'; };
class DotCommand extends ReplaceCommand { REPLACE_WORD = '.'; };
class AmpersandCommand extends ReplaceCommand { REPLACE_WORD = '&'; };
class ColonCommand extends ReplaceCommand { REPLACE_WORD = ':'; };
class QuestionMarkCommand extends ReplaceCommand { REPLACE_WORD = '?'; };
class ExclamationMarkCommand extends ReplaceCommand { REPLACE_WORD = '!'; };
class CommaCommand extends ReplaceCommand { REPLACE_WORD = ','; };
class AtCommand extends ReplaceCommand { REPLACE_WORD = '@'; };
class HyphenCommand extends ReplaceCommand { REPLACE_WORD = '?'; };
class QuoteCommand extends ReplaceCommand { REPLACE_WORD = '"'; };
class SingleQuoteCommand extends ReplaceCommand { REPLACE_WORD = '\''; };
class LeftParenthesisCommand extends ReplaceCommand { REPLACE_WORD = '('; }
class RightParenthesisCommand extends ReplaceCommand { REPLACE_WORD = ')'; }
class ForwardSlashCommand extends ReplaceCommand { REPLACE_WORD = '/'; };


export {
  OpenQuotationMarkCommand,
  CloseQuotationMarkCommand,
  DotCommand,
  AmpersandCommand,
  ColonCommand,
  QuestionMarkCommand,
  ExclamationMarkCommand,
  CommaCommand,
  AtCommand,
  HyphenCommand,
  QuoteCommand,
  SingleQuoteCommand,
  LeftParenthesisCommand,
  RightParenthesisCommand,
  ForwardSlashCommand,
  IgnoreCommand,
  OpenParenthesisCommand,
  CloseParenthesisCommand,
  ReplaceCommand
};
