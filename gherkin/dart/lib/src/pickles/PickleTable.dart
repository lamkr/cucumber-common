import 'package:gherkin/core.dart';
import 'package:gherkin/src/pickles/PickleTableRow.dart';

class PickleTable
  implements INullSafetyObject
{
  static const PickleTable empty = _InvalidPickleTable();

  final Iterable<PickleTableRow> rows;

  const PickleTable(this.rows);

  @override
  bool get isEmpty => false;

  @override
  bool get isNotEmpty => !isEmpty;
}

class _InvalidPickleTable extends PickleTable {
  const _InvalidPickleTable()
    : super(const <PickleTableRow>[]);

  @override
  bool get isEmpty => true;
}