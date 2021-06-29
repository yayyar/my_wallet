import 'package:fl_responsive_ui/fl_responsive_ui.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:my_wallet/util/AppStateNotifier.dart';
import 'package:my_wallet/util/DateTools.dart';
import 'package:provider/provider.dart';

import 'NavPages/NavDashboard.dart';
import 'NavPages/NavHome.dart';
import 'NavPages/NavMore.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;
  bool _doNavHome = true, _isNavHome = true, _isNavDashboard = true;

  List<Widget> _widgetNavPages = <Widget>[NavHome(), NavDashboard(), NavMore()];
  int itemDate = DateTime.parse(fullDateFormatted(date: DateTime.now()))
      .millisecondsSinceEpoch;

  @override
  Widget build(BuildContext context) {
    final _appStateNotifier =
        Provider.of<AppStateNotifier>(context, listen: false);
    if (_doNavHome) {
      _appStateNotifier.loadCurrency();
      _appStateNotifier.getAllExpenseItems();
      _appStateNotifier.getEstimateCost();
      _appStateNotifier.getActualCost();
      _doNavHome = false;
    }
    final screeSize = MediaQuery.of(context).size;
    FlResponsiveUI().updateScreenDimension(
        width: screeSize.width, height: screeSize.height);
    return Scaffold(
        body: _widgetNavPages.elementAt(_selectedIndex),
        bottomNavigationBar:
            Consumer<AppStateNotifier>(builder: (context, appState, child) {
          return BottomNavigationBar(
            showSelectedLabels: true,
            showUnselectedLabels: false,
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.chart_pie),
                label: 'Dashboard',
              ),
              BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.ellipsis),
                label: 'More',
              ),
            ],
            currentIndex: _selectedIndex,
            onTap: (index) {
              if (_isNavHome && index == 0) {
                appState.getActualCost(
                    startDate: strDateToMilliseconds(appState.activeStartDate),
                    endDate: strDateToMilliseconds(appState.activeEndDate));
                appState.getEstimateCost();
                appState.getAllExpenseItems(
                    startDate: strDateToMilliseconds(appState.activeStartDate),
                    endDate: strDateToMilliseconds(appState.activeEndDate));
                _isNavHome = false;
              }
              if (index != 0) {
                _isNavHome = true;
              }
              if (_isNavDashboard && index == 1) {
                appState.getActualCost(
                    startDate: strDateToMilliseconds(appState.activeStartDate),
                    endDate: strDateToMilliseconds(appState.activeEndDate));
                appState.getEstimateCost();
                appState.getAllExpenseItems(
                    startDate: strDateToMilliseconds(appState.activeStartDate),
                    endDate: strDateToMilliseconds(appState.activeEndDate));
                _isNavDashboard = false;
              }
              if (index != 1) {
                _isNavDashboard = true;
              }
              setState(() {
                _selectedIndex = index;
              });
            },
          );
        }));
  }
}
