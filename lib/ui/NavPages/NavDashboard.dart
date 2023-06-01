import 'package:fl_responsive_ui/fl_responsive_ui.dart';
import 'package:flutter/material.dart';
import 'package:my_wallet/ui/ChartPages/CircularProgressPage.dart';
import 'package:my_wallet/util/AppStateNotifier.dart';
import 'package:my_wallet/util/DateTools.dart';
import 'package:my_wallet/widget/date_range_picker.dart';
import 'package:provider/provider.dart';

import '../ChartPages/BarChartPage.dart';

class NavDashboard extends StatefulWidget {
  @override
  _NavDashboardState createState() => _NavDashboardState();
}

class _NavDashboardState extends State<NavDashboard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<AppStateNotifier>(builder: (context, appState, child) {
        return Column(
          children: [
            Container(
              height: FlResponsiveUI().getProportionalHeight(height: 190.0),
              width: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(
                    child: Stack(
                      children: [
                        Container(
                          alignment: Alignment.topCenter,
                          width: double.infinity,
                          height: FlResponsiveUI()
                              .getProportionalHeight(height: 150.0),
                          decoration: BoxDecoration(
                            color: Colors.blueGrey,
                            borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(10.0),
                                bottomRight: Radius.circular(10.0)),
                          ),
                        ),
                        Container(
                          margin:
                              EdgeInsets.only(top: 50, left: 10.0, right: 10.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Dashboard',
                                style: FlResponsiveUI().getTextStyleRegular(
                                    fontSize: 20, color: Colors.white70),
                              ),
                              DateRangePickerWidget(),
                            ],
                          ),
                        ),
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: Container(
                            width: double.infinity,
                            child: FittedBox(
                              fit: BoxFit.fitWidth,
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    left: 10.0, right: 10.0),
                                child: Row(
                                  children: [
                                    reportCard(
                                        title: "Estimate",
                                        cost: appState.estimateCost,
                                        currencySymbol:
                                            appState.currencySymbol),
                                    reportCard(
                                        title: "Actual",
                                        cost: appState.actualCost,
                                        currencySymbol:
                                            appState.currencySymbol),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: appState.expenseItemList.length > 0
                  ? ListView(
                      children: [
                        BarChartPage(appState.barDataList),
                        Container(
                          margin: EdgeInsets.only(top: 10.0, bottom: 10.0),
                          child: appState.actualCost > appState.estimateCost
                              ? Center(
                                  child: Container(
                                    child: Text(
                                      'Overload cost ${appState.currencySymbol} ${currencyFormat(data: (appState.actualCost - appState.estimateCost))}',
                                      style: FlResponsiveUI()
                                          .getTextStyleRegular(
                                              color: Colors.red, fontSize: 18),
                                    ),
                                  ),
                                )
                              : CircularProgressPage(
                                  expectCost: appState.estimateCost,
                                  actualCost: appState.actualCost,
                                ),
                        ),
                      ],
                    )
                  : Container(),
            )
          ],
        );
      }),
    );
  }

  Widget reportCard(
      {required String title,
      required double cost,
      required String currencySymbol}) {
    return Container(
      width: FlResponsiveUI().getProportionalWidth(width: 230.0),
      height: FlResponsiveUI().getProportionalHeight(height: 105.0),
      child: Card(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 10.0,
                  height: 10.0,
                  decoration: BoxDecoration(
                    color: title == 'Estimate'
                        ? Colors.orange
                        : const Color(0xff2491ea),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                SizedBox(
                  width: 10.0,
                ),
                Text(
                  title,
                  style: FlResponsiveUI().getTextStyleRegular(
                    fontSize: 18,
                  ),
                ),
              ],
            ),
            Text(
              '$currencySymbol ${currencyFormat(data: cost)}',
              style: FlResponsiveUI().getTextStyleRegular(
                fontSize: 20,
              ),
            )
          ],
        ),
      ),
    );
  }
}
