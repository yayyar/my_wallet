import 'package:fl_responsive_ui/fl_responsive_ui.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';

class CircularProgressPage extends StatefulWidget {
  final double expectCost, actualCost;
  CircularProgressPage({this.expectCost,this.actualCost});
  @override
  _CircularProgressPageState createState() => _CircularProgressPageState();
}

class _CircularProgressPageState extends State<CircularProgressPage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: FlResponsiveUI().getProportionalHeight(height: 180.0),
      child: Card(
        margin: EdgeInsets.only(left: 9.0, right: 9.0),
        //color: const Color(0xff2c4260),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              CircularPercentIndicator(
                animation: true,
                radius: FlResponsiveUI().getProportionalHeight(height: 110.0),
                lineWidth: 10.0,
                percent: ((widget.expectCost - widget.actualCost) / widget.expectCost),
                circularStrokeCap: CircularStrokeCap.round,
                center: new Text("${(((widget.expectCost - widget.actualCost) / widget.expectCost) * 100).toStringAsFixed(2)}%"),
                progressColor: Colors.orange,
              ),
              CircularPercentIndicator(
                animation: true,
                radius: FlResponsiveUI().getProportionalHeight(height: 110.0),
                lineWidth: 10.0,
                percent: (widget.actualCost / widget.expectCost),
                circularStrokeCap: CircularStrokeCap.round,
                center: new Text("${((widget.actualCost / widget.expectCost) * 100).toStringAsFixed(2)}%"),
                progressColor: const Color(0xff2491ea),
              )
            ],
          ),
        ),
      ),
    );
  }
}
