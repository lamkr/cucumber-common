enum MediaType
{
  textXCucumberGherkinPlain,
  textXCucumberGherkinMarkdown
}

extension MediaTypeExtension on MediaType
{
  String get name {
    switch(this) {
      case MediaType.textXCucumberGherkinPlain:
        return 'text/x.cucumber.gherkin+plain';
      case MediaType.textXCucumberGherkinMarkdown:
        return 'text/x.cucumber.gherkin+markdown';
      default:
        throw ArgumentError('Invalid MediaType');
    }
  }
}