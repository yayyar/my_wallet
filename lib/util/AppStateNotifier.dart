import 'package:flutter/material.dart';
import 'package:my_wallet/ui/ChartPages/ExpenseSeries.dart';
import 'package:my_wallet/util/DateTools.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'ActiveBudgetService.dart';
import 'Database/DatabaseHelper.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class AppStateNotifier extends ChangeNotifier {
  final SharedPreferences _prefs;
  bool _isDarkMode;

  var _db = new DatabaseHelper();
  List categoryCountList = [];
  var countMap = {};

  double estimateCost = 0.0, actualCost = 0.0;
  List expenseItemList = [];
  var activeBudgetService = new ActiveBudgetService();
  List<ExpenseSeries> barDataList = [];

  AppStateNotifier(this._prefs) {
    _isDarkMode = _prefs.getBool('themeMode') ?? false;
  }

  bool get isDarkMode => _isDarkMode;

  void updateTheme(bool value) {
    _isDarkMode = value;
    notifyListeners();

    _prefs.setBool('themeMode', value);
  }

  getBudgetCategoryCount() async {
    categoryCountList = [];
    List _items = await _db.getBudgetCategoryCount();
    _items.forEach((element) {
      categoryCountList.add(element);
    });
    //print('category count list => $categoryCountList ');
    generateCountMap();
  }

  generateCountMap() {
    countMap = {};
    for (int i = 0; i < categoryCountList.length; i++) {
      countMap[categoryCountList[i]['budgetId']] =
          categoryCountList[i]['count'];
    }
    //print('count map => $countMap');
    notifyListeners();
  }

  getEstimateCost() async {
    estimateCost = 0;
    List estimateItems = await _db.getEstimateCost();
    estimateItems.forEach((element) {
        estimateCost = element['estimateCost'] != null ? element['estimateCost'] : 0.0;
    });
    //debugPrint('App Estimate => $estimateCost');
    notifyListeners();
  }

  getActualCost({int startDate, int endDate}) async {
    actualCost = 0;
    await activeBudgetService.getCurrentBudgetDate();
    DateTime curBudgetDate = DateTime.parse(activeBudgetService.curDateStr);
    DateTime lastUpdatedDate = DateTime.parse(activeBudgetService.lastUpdatedDateStr);
    int itemDate = curBudgetDate.millisecondsSinceEpoch;
    int itemUpdatedDate = lastUpdatedDate.millisecondsSinceEpoch;
    List actualItems = [];
    if(startDate == null || endDate == null){
      actualItems = await _db.getActualCost(startDate: itemDate,endDate: itemUpdatedDate);
    }else {
      actualItems = await _db.getActualCost(startDate: startDate,endDate: endDate);
    }
    actualItems.forEach((element) {
      actualCost = element['actualCost'] != null ? element['actualCost'] : 0.0;
    });
    //debugPrint('App Actual => $actualCost');
    notifyListeners();
  }

  getAllExpenseItems({int startDate, int endDate}) async {
    barDataList = [];
    await activeBudgetService.getCurrentBudgetDate();
    DateTime curBudgetDate = DateTime.parse(activeBudgetService.curDateStr);
    DateTime lastUpdatedDate = DateTime.parse(activeBudgetService.lastUpdatedDateStr);
    int itemDate = curBudgetDate.millisecondsSinceEpoch;
    int itemUpdatedDate = lastUpdatedDate.millisecondsSinceEpoch;
    //debugPrint('App All date => $startDate, $endDate');
    //debugPrint('App All full date => ${fullDateFormatted(date: DateTime.fromMillisecondsSinceEpoch(startDate))}, ${fullDateFormatted(date: DateTime.fromMillisecondsSinceEpoch(endDate))}');
    expenseItemList = [];
    if(startDate == null || endDate == null){
      expenseItemList = await _db.getAllExpenseItems(startDate: itemDate,endDate: itemUpdatedDate);
    }else{
      expenseItemList = await _db.getAllExpenseItems(startDate: startDate,endDate: endDate);
    }
    expenseItemList.forEach((value) {
      barDataList.add(
          ExpenseSeries(
            category: value['categoryName'],
            actualCost: value['actualCost'],
            barColor: charts.ColorUtil.fromDartColor(Colors.blue),
          )
      );
    });
    //print('App barDataList => ${barDataList[0].toString()}');
    //await _db.getAllExpense();
    notifyListeners();
  }
}
