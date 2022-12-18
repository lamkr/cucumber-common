

import 'gherkin_language_keywords.dart';
import 'igherkin_dialect.dart';
import 'step_keyword_type.dart';

class GherkinDialect implements IGherkinDialect
{
  static const asteriskKeyword = '* ';

  final String _language;
  final GherkinLanguageKeywords _keywords;
  late final Map<String, StepKeywordType> _stepKeywordTypes;

  GherkinDialect(this._language, this._keywords) {
    _stepKeywordTypes = <String, StepKeywordType>
      {}
      ..addEntries( _keywords.given.map((e) => MapEntry(e, StepKeywordType.context)) )
      ..addEntries( _keywords.when.map((e) => MapEntry(e, StepKeywordType.action)) )
      ..addEntries( _keywords.then.map((e) => MapEntry(e, StepKeywordType.outcome)) )
      ..addEntries( _keywords.and.map((e) => MapEntry(e, StepKeywordType.conjunction)) )
      ..addEntries( _keywords.but.map((e) => MapEntry(e, StepKeywordType.conjunction)) )
      ..[asteriskKeyword] = StepKeywordType.unknown;
  }

  @override
  GherkinLanguageKeywords get keywords => _keywords;

  @override
  String get language => _language;

  @override
  List<String> get featureKeywords => keywords.feature;

  @override
  String get name => keywords.name;

  @override
  String get nativeName => keywords.native;

  @override
  List<String> get ruleKeywords => keywords.rule;

  @override
  List<String> get scenarioKeywords => keywords.scenario;

  @override
  List<String> get scenarioOutlineKeywords => keywords.scenarioOutline;

  @override
  List<String> get stepKeywords => <String>{
    ...givenStepKeywords,
    ...whenStepKeywords,
    ...thenStepKeywords,
    ...andStepKeywords,
    ...butStepKeywords
  }.toList();

  @override
  List<String> get backgroundKeywords => keywords.background;

  @override
  List<String> get examplesKeywords => keywords.examples;

  @override
  List<String> get givenStepKeywords => keywords.given;

  @override
  List<String> get whenStepKeywords => keywords.when;

  @override
  List<String> get thenStepKeywords => keywords.then;

  @override
  List<String> get andStepKeywords => keywords.and;

  @override
  List<String> get butStepKeywords => keywords.but;

  @override
  Map<String, StepKeywordType> get stepKeywordTypes => _stepKeywordTypes;

  @override
  StepKeywordType stepKeywordType(String keyword) =>
    stepKeywordTypes[keyword] ?? StepKeywordType.unspecified;

  @override
  bool get isEmpty => false;

  @override
  bool get isNotEmpty => !isEmpty;
}

