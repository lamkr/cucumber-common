import 'table_row.dart';

abstract class IHasRows
{
  Iterable<TableRow> get rows;
}
