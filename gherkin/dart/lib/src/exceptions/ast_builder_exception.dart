import 'package:gherkin/language.dart';

import 'parser_exception.dart';

class AstBuilderException extends ParserException
{
  AstBuilderException(String message, Location location)
      : super(message, location);
}
