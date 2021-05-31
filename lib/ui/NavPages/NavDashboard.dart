import 'package:fl_responsive_ui/fl_responsive_ui.dart';
import 'package:flutter/material.dart';
import 'package:date_range_picker/date_range_picker.dart' as DateRangePicker;
import 'package:my_wallet/ui/ChartPages/CircularProgressPage.dart';
import 'package:my_wallet/ui/ChartPages/BarChartPage.dart';
import 'package:my_wallet/util/ActiveBudgetService.dart';
import 'package:my_wallet/util/AppStateNotifier.dart';
import 'package:my_wallet/util/DateTools.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NavDashboard extends StatefulWidget {
  @override
  _NavDashboardState createState() => _NavDashboardState();
}

class _NavDashboardState extends State<NavDashboard> {
  List<dynamic> _dateRangeList;
  String _startDateStr, _endDateStr;
  int startPickedDate, endPickedDate;
  var activeBudgetService = new ActiveBudgetService();
  String currencySymbol = '';

  _loadCurrency() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      currencySymbol = (prefs.getString('symbol') ?? 'K');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<AppStateNotifier>(builder: (context, appState, child) {
        return Column(
          children: [
            Container(
              // top layer
              //color: Colors.black45,
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
                          margin: EdgeInsets.only(
                              top: FlResponsiveUI()
                                  .getProportionalHeight(height: 50.0),
                              left: 10.0,
                              right: 10.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Dashboard',
                                style: FlResponsiveUI().getTextStyleRegular(
                                    fontSize: 20, color: Colors.white70),
                              ),
                              Container(
                                padding: const EdgeInsets.all(6.0),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.cyan),
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                child: InkWell(
                                  onTap: () async {
                                    final List<DateTime> picked =
                                        await DateRangePicker.showDatePicker(
                                            context: context,
                                            initialFirstDate:
                                                _dateRangeList != null
                                                    ? _dateRangeList[0]
                                                    : new DateTime.now(),
                                            initialLastDate:
                                                _dateRangeList != null
                                                    ? _dateRangeList[1]
                                                    : new DateTime.now(),
                                            firstDate: new DateTime(
                                                DateTime.now().year - 2),
                                            lastDate: new DateTime(
                                                DateTime.now().year + 2),
                                            selectableDayPredicate:
                                                allowCurrentMonthDay);
                                    if (picked != null && picked.length == 2) {
                                      _dateFormatted(dateTime: picked);
                                      final _appStateNotifier =
                                          Provider.of<AppStateNotifier>(context,
                                              listen: false);
                                      _appStateNotifier.getActualCost(
                                          startDate: startPickedDate,
                                          endDate: endPickedDate);
                                      _appStateNotifier.getAllExpenseItems(
                                          startDate: startPickedDate,
                                          endDate: endPickedDate);
                                    }
                                  },
                                  child: Row(
                                    children: [
                                      Text(
                                        '${_startDateStr != null ? _startDateStr : 'MM'}',
                                        style: FlResponsiveUI()
                                            .getTextStyleRegular(
                                                fontSize: 14,
                                                color: Colors.white),
                                      ),
                                      Icon(
                                        Icons.arrow_forward,
                                        color: Colors.yellow[600],
                                        size: FlResponsiveUI()
                                            .getProportionalWidth(width: 15),
                                      ),
                                      Text(
                                        '${_endDateStr != null ? _endDateStr : 'DD'}',
                                        style: FlResponsiveUI()
                                            .getTextStyleRegular(
                                                fontSize: 14,
                                                color: Colors.white),
                                      ),
                                    ],
                                  ),
                                ),
                              )
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
                                        cost: appState.estimateCost),
                                    reportCard(
                                        title: "Actual",
                                        cost: appState.actualCost),
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
                                        'Overload cost $currencySymbol ${currencyFormat(data: (appState.actualCost - appState.estimateCost))}',
                                    style: FlResponsiveUI().getTextStyleRegular(
                                      color: Colors.red,
                                      fontSize: 18
                                    ),),
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

  Widget reportCard({String title, double cost}) {
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

  void _dateFormatted({List dateTime}) {
    setState(() {
      _dateRangeList = dateTime;
      startPickedDate =
          DateTime.parse(fullDateFormatted(date: _dateRangeList[0]))
              .millisecondsSinceEpoch;
      endPickedDate = DateTime.parse(fullDateFormatted(date: _dateRangeList[1]))
          .millisecondsSinceEpoch;
      _startDateStr = dayMonthFormatted(date: _dateRangeList[0]);
      _endDateStr = dayMonthFormatted(date: _dateRangeList[1]);
    });
  }

  @override
  void initState() {
    super.initState();
    _initDate();
    _loadCurrency();
  }

  _initDate() async {
    var now = DateTime.now();
    setState(() {
      _startDateStr = dayMonthFormatted(date: now);
      _endDateStr = dayMonthFormatted(date: now);
    });

    await activeBudgetService.getCurrentBudgetDate();
    DateTime curBudgetDate = DateTime.parse(activeBudgetService.curDateStr);
    DateTime lastUpdateDate =
        DateTime.parse(activeBudgetService.lastUpdatedDateStr);
    _dateFormatted(dateTime: [curBudgetDate, lastUpdateDate]);
  }
}
