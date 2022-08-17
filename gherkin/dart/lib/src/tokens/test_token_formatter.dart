import 'package:gherkin/extensions.dart';
import 'package:gherkin/language.dart';

class TestTokenFormatter
{
  String formatToken(Token token)
  {
    if (token.isEof) {
      return 'EOF';
    }

    String stepTypeText;

    switch (token.matchedType)
    {
      case TokenType.FeatureLine:
      case TokenType.ScenarioLine:
      case TokenType.ExamplesLine:
      case TokenType.DocStringSeparator:
      case TokenType.BackgroundLine:
      case TokenType.RuleLine:
        stepTypeText = '()';
        break;
      case TokenType.StepLine:
        var tokenType = token.matchedGherkinDialect.stepKeywordType(token.matchedKeyword);
        stepTypeText = '(${tokenType.name.capitalize})';
        break;
      default:
        stepTypeText = '';
        break;
    }

    var items = token.matchedItems.map((element) => '${element.column}:${element.text}');
    var matchedItems = items.isEmpty ? '' : items.join(',');
    var matchedType = token.matchedType.toString().split('.').last;
    var matchedKeyword = token.matchedKeyword.isEmpty ? '' : token.matchedKeyword;
    var matchedText = token.matchedText.isEmpty ? '' : token.matchedText;

    return '(${token.location.line}:${token.location.column})'
        '$matchedType:$stepTypeText$matchedKeyword/$matchedText/$matchedItems';
  }
}