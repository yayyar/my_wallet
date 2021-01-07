import 'Database/DatabaseHelper.dart';

class ActiveBudgetService{
  String curDateStr;
  String lastUpdatedDateStr;
  ActiveBudgetService.internal();
  static final ActiveBudgetService _instance = new ActiveBudgetService.internal();
  factory ActiveBudgetService() => _instance;

  getCurrentBudgetDate() async {
    var _db = new DatabaseHelper();
    List curDate = await _db.currentBudgetDate();
    DateTime dateTime = new DateTime.now();
    curDateStr = curDate.length != 0 ? curDate[0]['budgetDate'].toString() : dateTime.toString();
    lastUpdatedDateStr = curDate.length != 0 ? curDate[0]['lastUpdatedDate'].toString() : dateTime.toString();
    //print('curDateStrOne => $curDate');
  }
}