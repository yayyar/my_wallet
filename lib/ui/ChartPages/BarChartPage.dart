import 'package:charts_flutter_new/flutter.dart' as charts;
import 'package:fl_responsive_ui/fl_responsive_ui.dart';
import 'package:flutter/material.dart';
import 'package:my_wallet/ui/ChartPages/ExpenseSeries.dart';

class BarChartPage extends StatelessWidget {
  late List<ExpenseSeries> seriesList;
  bool? animate;

  BarChartPage(this.seriesList, {this.animate});

  @override
  Widget build(BuildContext context) {
    List<charts.Series<ExpenseSeries, String>> series = [
      charts.Series(
          id: "ExpenseItems",
          data: seriesList,
          domainFn: (ExpenseSeries series, _) => series.category,
          measureFn: (ExpenseSeries series, _) => series.actualCost,
          colorFn: (ExpenseSeries series, _) => series.barColor)
    ];
    return Container(
      height: FlResponsiveUI().getProportionalHeight(height: 300),
      padding: EdgeInsets.only(left: 6.0, right: 6.0),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: <Widget>[
              Text(
                "Actual cost by category",
              ),
              Expanded(
                child: charts.BarChart(
                  series,
                  animate: true,
                  domainAxis: new charts.OrdinalAxisSpec(
                    renderSpec: charts.SmallTickRendererSpec(
                      labelRotation: 45,
                      labelStyle: charts.TextStyleSpec(
                        color: charts.MaterialPalette.gray.shadeDefault,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  primaryMeasureAxis: new charts.NumericAxisSpec(
                      renderSpec: new charts.GridlineRendererSpec(

                          // Tick and Label styling here.
                          labelStyle: new charts.TextStyleSpec(
                            // size in Pts.
                            color: charts.MaterialPalette.gray.shadeDefault,
                            fontSize: 14,
                          ),

                          // Change the line colors to match text color.
                          lineStyle: new charts.LineStyleSpec(
                              color:
                                  charts.MaterialPalette.gray.shadeDefault))),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
