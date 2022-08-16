import 'package:gherkin/parser.dart';

import 'gherkin_language_constants.dart';
import 'gherkin_line_span.dart';
import 'igherkin_dialect.dart';
import 'igherkin_dialect_provider.dart';
import 'igherkin_line.dart';
import 'location.dart';
import 'token.dart';
import 'token_type.dart';
import 'package:gherkin/extensions.dart';

class TokenMatcher implements ITokenMatcher
{
  static final RegExp _languagePattern = RegExp(r'^\s*#\s*language\s*:\s*([a-zA-Z\-_]+)\s*$');

  final IGherkinDialectProvider _dialectProvider;

  IGherkinDialect _currentDialect;
  String _activeDocStringSeparator = Strings.empty;
  int _indentToRemove = 0;

  TokenMatcher(this._dialectProvider)
      : _currentDialect = _dialectProvider.defaultDialect;

  IGherkinDialect get currentDialect {
    if( _currentDialect.isEmpty ) {
      return _dialectProvider.defaultDialect;
    }
    return _currentDialect;
  }

  @override
  void reset() {
    _activeDocStringSeparator = Strings.empty;
    _indentToRemove = 0;
    _currentDialect = _dialectProvider.defaultDialect;
  }

  @override
  bool matchEof(Token token) {
    if (token.isEof) {
      setTokenMatched(token, TokenType.EOF);
      return true;
    }
    return false;
  }

  @override
  bool matchOther(Token token) {
    /// take the entire line, except removing DocString indents
    var text = token.line.getLineText(_indentToRemove);
    setTokenMatched(token, TokenType.Other, text: _unescapeDocString(text), indent: 0);
    return true;
  }

  @override
  bool matchEmpty(Token token) {
    if (token.line.isEmptyLine) {
      setTokenMatched(token, TokenType.Empty);
      return true;
    }
    return false;
  }

  @override
  bool matchComment(Token token) {
    if (token.line.startsWith(GherkinLanguageConstants.commentPrefix)) {
      var text = token.line.getLineText(IGherkinLine.entireLine);
      setTokenMatched(token, TokenType.Comment, text: text, indent: 0);
      return true;
    }
    return false;
  }

  @override
  bool matchLanguage(Token token) {
    var match = _languagePattern.firstMatch(token.line.getLineText(IGherkinLine.entireLine));
    if (match != null) {
      var language = match.group(1) ?? Strings.empty;
      setTokenMatched(token, TokenType.Language, text:language);
      _currentDialect = _dialectProvider.getDialect(language, token.location);
      return true;
    }
    return false;
  }

  @override
  bool matchTagLine(Token token) {
    if (token.line.startsWith(GherkinLanguageConstants.tagPrefix)) {
      setTokenMatched(token, TokenType.TagLine, items:token.line.tags);
      return true;
    }
    return false;
  }

  @override
  bool matchFeatureLine(Token token) =>
      _matchTitleLine(token, TokenType.FeatureLine, currentDialect.featureKeywords);

  @override
  bool matchRuleLine(Token token) =>
      _matchTitleLine(token, TokenType.RuleLine, currentDialect.ruleKeywords);

  @override
  bool matchBackgroundLine(Token token) =>
      _matchTitleLine(token, TokenType.BackgroundLine, currentDialect.backgroundKeywords);

  @override
  bool matchScenarioLine(Token token) =>
      _matchTitleLine(token, TokenType.ScenarioLine, currentDialect.scenarioKeywords)
          || _matchTitleLine(token, TokenType.ScenarioLine, currentDialect.scenarioOutlineKeywords);

  @override
  bool matchExamplesLine(Token token) =>
      _matchTitleLine(token, TokenType.ExamplesLine, currentDialect.examplesKeywords);

  bool _matchTitleLine(Token token, TokenType tokenType, List<String> keywords) {
    for (var keyword in keywords) {
      if (token.line.startsWithTitleKeyword(keyword)) {
        var title = token.line.getRestTrimmed(keyword.length + GherkinLanguageConstants.titleKeywordSeparator.length);
        setTokenMatched(token, tokenType, keyword: keyword, text: title);
        return true;
      }
    }
    return false;
  }

  @override
  bool matchDocStringSeparator(Token token) =>
      _activeDocStringSeparator.isEmpty
      // open
          ? _matchDocStringSeparator(token, GherkinLanguageConstants.docStringSeparator, true)
          || _matchDocStringSeparator(token, GherkinLanguageConstants.docStringAlternativeSeparator, true)
      // close
          : _matchDocStringSeparator(token, _activeDocStringSeparator, false);

  bool _matchDocStringSeparator(Token token, String separator, bool isOpen) {
    if (token.line.startsWith(separator)) {
      var mediaType = Strings.empty;
      if (isOpen) {
        mediaType = token.line.getRestTrimmed(separator.length);
        _activeDocStringSeparator = separator;
        _indentToRemove = token.line.indent;
      }
      else {
        _activeDocStringSeparator = Strings.empty;
        _indentToRemove = 0;
      }
      setTokenMatched(token, TokenType.DocStringSeparator, text:mediaType, keyword:separator);
      return true;
    }
    return false;
  }

  @override
  bool matchStepLine(token) {
    var keywords = currentDialect.stepKeywords;
    for (var keyword in keywords) {
      if (token.line.startsWith(keyword)) {
        var stepText = token.line.getRestTrimmed(keyword.length);
        setTokenMatched(token, TokenType.StepLine, keyword:keyword, text:stepText);
        return true;
      }
    }
    return false;
  }

  @override
  bool matchTableRow(token) {
    if (token.line.startsWith(GherkinLanguageConstants.tableCellSeparator)) {
      setTokenMatched(token, TokenType.TableRow, items:token.line.tableCells);
      return true;
    }
    return false;
  }

  void setTokenMatched(Token token, TokenType matchedType,
      {String text=Strings.empty, String keyword=Strings.empty, int indent=Int.min, Iterable<GherkinLineSpan> items=const <GherkinLineSpan>[]})
  {
    token.matchedType = matchedType;
    token.matchedKeyword = keyword;
    token.matchedText = text;
    token.matchedItems = items;
    token.matchedGherkinDialect = currentDialect;
    token.matchedIndent = indent.isNotMin ? indent : (token.line.isEmpty ? 0 : token.line.indent);
    token.location = Location(token.location.line, token.matchedIndent + 1);
  }

  String _unescapeDocString(String text) {
    if (GherkinLanguageConstants.docStringSeparator == _activeDocStringSeparator) {
      return text.replaceFirst('\\"\\"\\"', GherkinLanguageConstants.docStringSeparator);
    }
    if (GherkinLanguageConstants.docStringAlternativeSeparator == _activeDocStringSeparator) {
      return text.replaceFirst('\\`\\`\\`', GherkinLanguageConstants.docStringAlternativeSeparator);
    }
    return text;
  }
}

