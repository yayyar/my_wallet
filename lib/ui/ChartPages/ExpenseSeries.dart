import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/foundation.dart';

class ExpenseSeries {
  final String category;
  final double actualCost;
  final charts.Color barColor;

  ExpenseSeries(
      {@required this.category,
      @required this.actualCost,
      @required this.barColor});
}
