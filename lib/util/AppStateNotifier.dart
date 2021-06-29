import 'package:flutter/material.dart';
import 'package:my_wallet/ui/ChartPages/ExpenseSeries.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Database/DatabaseHelper.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class AppStateNotifier extends ChangeNotifier {
  final SharedPreferences _prefs;
  bool _isDarkMode;

  var _db = new DatabaseHelper();
  List categoryCountList = [];
  var countMap = {};

  double _estimateCost = 0.0, _actualCost = 0.0;
  double get estimateCost => _estimateCost;
  double get actualCost => _actualCost;

  List expenseItemList = [];
  List<ExpenseSeries> barDataList = [];

  String _currencySymbol = 'K';
  String get currencySymbol => _currencySymbol;

  String _currencyCode = 'MMK';
  String get currencyCode => _currencyCode;

  List<dynamic> _dateRangeList = [];
  List<dynamic> get dateRangeList => _dateRangeList;

  String _activeStartDate = new DateTime.now().toString();
  String _activeEndDate = new DateTime.now().toString();
  String get activeStartDate => _activeStartDate;
  String get activeEndDate => _activeEndDate;


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

  void getEstimateCost() async {
    List estimateItems = await _db.getEstimateCost();
    estimateItems.forEach((element) {
      _estimateCost =
          element['estimateCost'] != null ? element['estimateCost'] : 0.0;
    });
    //debugPrint('App Estimate => $estimateCost');
    notifyListeners();
  }

  void getActualCost({int startDate, int endDate}) async {
    List actualItems = [];
    if (startDate == null || endDate == null) {
      await getCurrentActiveBudgetDate();
      int itemDate = DateTime.parse(activeStartDate).millisecondsSinceEpoch;
      int itemUpdatedDate = DateTime.parse(activeEndDate).millisecondsSinceEpoch;
      actualItems = await _db.getActualCost(
          startDate: itemDate, endDate: itemUpdatedDate);
    } else {
      actualItems =
          await _db.getActualCost(startDate: startDate, endDate: endDate);
    }
    actualItems.forEach((element) {
      _actualCost = element['actualCost'] != null ? element['actualCost'] : 0.0;
    });
    debugPrint('App Actual => $actualCost');
    notifyListeners();
  }

  void getAllExpenseItems({int startDate, int endDate}) async {
    barDataList = [];
    expenseItemList = [];
    if (startDate == null || endDate == null) {
      await getCurrentActiveBudgetDate();
      int itemDate = DateTime.parse(activeStartDate).millisecondsSinceEpoch;
      int itemUpdatedDate = DateTime.parse(activeEndDate).millisecondsSinceEpoch;
      expenseItemList = await _db.getAllExpenseItems(
          startDate: itemDate, endDate: itemUpdatedDate);
    } else {
      expenseItemList =
          await _db.getAllExpenseItems(startDate: startDate, endDate: endDate);
    }
    expenseItemList.forEach((value) {
      barDataList.add(ExpenseSeries(
        category: value['categoryName'],
        actualCost: value['actualCost'],
        barColor: charts.ColorUtil.fromDartColor(Colors.blue),
      ));
    });
    //print('App barDataList => ${barDataList[0].toString()}');
    //await _db.getAllExpense();
    notifyListeners();
  }

  void setCurrency(String code, String symbol, BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('code', code);
    prefs.setString('symbol', symbol);
    Navigator.pop(context);
    loadCurrency();
  }

  void loadCurrency() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _currencySymbol = (prefs.getString('symbol') ?? 'K');
    _currencyCode = (prefs.getString('code') ?? 'MMK');
    notifyListeners();
  }

  getCurrentActiveBudgetDate() async {
    var _db = new DatabaseHelper();
    List curDate = await _db.currentBudgetDate();
    DateTime dateTime = new DateTime.now();
    _activeStartDate = curDate.length != 0 ? curDate[0]['budgetDate'].toString() : dateTime.toString();
    _activeEndDate = curDate.length != 0 ? curDate[0]['lastUpdatedDate'].toString() : dateTime.toString();
    // debugPrint('active date=> $activeStartDate , $activeEndDate');
    notifyListeners();
  }

  updateDateRange({List dateTime}) {
    _activeStartDate = dateTime[0].toString();
    _activeEndDate = dateTime[1].toString();
    notifyListeners();
  }
}
