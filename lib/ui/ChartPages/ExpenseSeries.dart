import 'package:charts_flutter_new/flutter.dart' as charts;

class ExpenseSeries {
  final String category;
  final double actualCost;
  final charts.Color barColor;

  ExpenseSeries(
      {required this.category,
      required this.actualCost,
      required this.barColor});
}
